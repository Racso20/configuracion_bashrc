function exposePort(){

	local OPTIND
	local OPTARG
	local option
	local servicio
	local windows_port
	local linux_port
	local salir

	
	salir=0
	servicio="get"
	usage="$((basename "$0")) [-h -w -l] [-s] -- Programa para exponer puertos de Linux en Windows
	donde:
	-h   Muestra el menu de ayuda
	-w   Puerto en Windows
	-l   Puerto en Linux
	-s   {GET;START;STOP}"
	while getopts 'w:l:h:s:' option; do
		case "$option" in
			h) echo "$usage"
			;;
			w) windows_port=$OPTARG
			;;
			l) linux_port=$OPTARG
			;;
			s) servicio=$OPTARG
			;;
			:) printf "missing argument for -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			;;
			\?) printf "illegal option: -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			;;
			*) printf "missing argument for -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			;;
		esac
	done

	ip=$(ip -a addr show eth0 | grep "scope global" | grep -Po '(?<=inet )[\d.]+')
	if [ ${servicio^^} == "START" ]; then
		if ! [[ "$windows_port" =~ ^[0-9]+$ ]]; then
			echo "El puerto ingresado para Windows $windows_port no es numerico"
		elif ! [[ "$linux_port" =~ ^[0-9]+$ ]]; then
			echo "El puerto ingresado para Linux $linux_port no es numerico"
		else
			powershell /C "netsh interface portproxy add v4tov4 listenport=$windows_port listenaddress=0.0.0.0 connectport=$linux_port connectaddress=$ip" &>/dev/null
			powershell /C "New-NetFirewallRule -DisplayName 'Redirect $windows_port to Kali' -Profile 'Private,Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $windows_port" &>/dev/null
			echo "El puerto $windows_port esta apuntando a $linux_port en WSL"
		fi

	elif [ ${servicio^^} == "STOP" ]; then
		if ! [[ "$windows_port" =~ ^[0-9]+$ ]]; then
			echo "El puerto ingresado para Windows $windows_port no es numerico"
		else
			powershell /c "Remove-NetFirewallRule -DisplayName 'Redirect $windows_port to Kali'" &>/dev/null
			powershell /c "netsh interface portproxy del v4tov4 listenport=$windows_port listenaddress=0.0.0.0" &>/dev/null
			echo "Se cerró el puerto $windows_port"
        	fi
	else
		powershell /c "netsh interface portproxy show v4tov4" 2>/dev/null
	fi
}
