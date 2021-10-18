function mkt(){

	local OPTIND
	local OPTARG
	local option
	usage="$(basename "$0") [-h -m -i] -- Programa para realizar HTB ordenado
donde:
    -h   Muestra el menu de ayuda
    -m   Nombre de la maquina a realizar
    -i   IP de la maquina a realizar"
    	local usuario=$(whoami)

	while getopts 'm:i:h:' option; do
		case "$option" in
			h) echo "$usage"
			exit
			;;
			m) maquina=$OPTARG
			;;
			i) ip=$OPTARG
			;;
			:) printf "missing argument for -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			exit 1
			;;
			\?) printf "illegal option: -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			exit 1
			;;
			*)printf "missing argument for -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			exit 1
			;;
		esac
	done

	seguir=1
	if [ -z "$maquina" ]; then
		echo "la maquina no puede ser nula"
		seguir=0
	fi

	if [ -z "$ip" ]; then
		echo "la IP no puede ser nula"
		seguir=0
	fi

	if [ $seguir == 1 ]; then
		ruta="/home/$usuario/Documentos/HTB/"$maquina
		mkdir -p $ruta/{nmap,contenido,exploits,scripts}
		file='/etc/hosts'
		cargar=1
		while IFS= read -r line
		do
			if [[ "$line" == *"$ip"* ]]; then
				cargar=0
			fi
		done < "$file"

		if [ $cargar == 1 ]; then
			echo "cargando ip en /etc/hosts"
			comando="echo $ip	$maquina.htb"
			$comando | tr '[:upper:]' '[:lower:]' | sudo tee -a /etc/hosts
		fi
		cd $ruta
	else
		echo "$usage" >&2
	fi
}