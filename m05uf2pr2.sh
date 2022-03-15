#!/bin/bash
case "$1" in
	'install_docker')
		if (( EUID != 0 ))
		then
			echo "Aquesta opció s'ha d'executar amb privilegis de l'usuari root"
			exit 1
		else
			docker_installed=$(systemctl status docker 2> /dev/null)
			if [[ ! $docker_installed ]]
			then
				echo "Instal·lació de Dockers per la pràctica  m05uf2pr2"
				apt-get update
				apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
				curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
				add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian   $(lsb_release -cs) stable"
				apt-get update
				apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
				if [[ $? == 0 ]]
				then
					clear
					echo "DOCKER INSTAL·LAT AMB ÈXIT"
					gpasswd -a $SUDO_USER docker > /dev/null
					echo " "
					echo "RECORDA QUE ABANS DE POODER UTILITZAR DOCKERS HAS DE FER UN LOGOUT I UN LOGIN DE L'USUARI $SUDO_USER"
					read
				fi
			else
				echo "Docker instal·lat"
			fi
		fi
		;;
   	'up')
		if (( EUID == 0 ))
		then
			echo "Aquest opció no s'ha d'executar amb prilegis de l'usuari root"
			exit 2
		else
			echo "Instal·lació dels Dockers de MySQL-PHPMyAdmin-WordPress-Joomla per la pràctica  m05uf2pr2"
			docker pull mysql:latest
			docker run --name m05uf2pr2_mysql -e MYSQL_ROOT_PASSWORD=FjeClot22@ -d -v voldb:$PWD/voldb -p 3306:3306 -p 33060:33060 mysql:latest
			docker pull phpmyadmin:latest
			docker run --name m05uf2pr2_phpmyadmin -d --link m05uf2pr2_mysql:db -p 8081:80 phpmyadmin
			docker pull wordpress:latest
			docker run --name m05uf2pr2_wordpress -p 8080:80 -d wordpress
			docker network create --attachable xarxa_m05uf2pr2
			docker network connect xarxa_m05uf2pr2 m05uf2pr2_mysql
			docker network connect xarxa_m05uf2pr2 m05uf2pr2_wordpress
			docker pull joomla:latest
			docker run --name m05uf2pr2_joomla -d --link m05uf2pr2_mysql:mysql -p 8088:80 joomla:latest
			docker network connect xarxa_m05uf2pr2 m05uf2pr2_joomla
		fi
		;;
   	'down')
		if (( EUID == 0 ))
		then
			echo "Aquest opció no s'ha d'executar amb prilegis de l'usuari root"
			exit 3
		else
			echo "Desinstal·lació dels Dockers de MySQL-PHPMyAdmin-WordPress-Joomla per la pràctica  m05uf2pr2"
			docker stop m05uf2pr2_joomla > /dev/null
			docker stop m05uf2pr2_wordpress > /dev/null
			docker stop m05uf2pr2_phpmyadmin > /dev/null
			docker stop m05uf2pr2_mysql > /dev/null
			docker network rm xarxa_m05uf2pr2 > /dev/null
			docker rm m05uf2pr2_joomla > /dev/null
			docker rm m05uf2pr2_wordpress > /dev/null
			docker rm m05uf2pr2_phpmyadmin > /dev/null
			docker rm m05uf2pr2_mysql > /dev/null
			docker rmi mysql:latest wordpress:latest phpmyadmin:latest joomla:latest > /dev/null
		fi
		;;
	'start')
		if (( EUID == 0 ))
		then
			echo "Aquest opció no s'ha d'executar amb prilegis de l'usuari root"
			exit 4
		else
			echo "Iniciant Dockers de MySQL-PHPMyAdmin-WordPress-Joomla per la pràctica  m05uf2pr2"
			docker start m05uf2pr2_mysql
			docker start m05uf2pr2_phpmyadmin
			docker start m05uf2pr2_wordpress
			docker start m05uf2pr2_joomla			
		fi
		;;
	'stop')
		if (( EUID == 0 ))
		then
			echo "Aquest opció no s'ha d'executar amb prilegis de l'usuari root"
			exit 5
		else
			echo "Aturant Dockers de MySQL-PHPMyAdmin-WordPress-Joomla per la pràctica  m05uf2pr2"
			docker stop m05uf2pr2_mysql
			docker stop m05uf2pr2_phpmyadmin
			docker stop m05uf2pr2_wordpress
			docker stop m05uf2pr2_joomla			
		fi
		;;		
	*)
		clear
		echo "COM UTILITZAR AQUEST SCRIPT:"
		echo " "
		echo "Instal·lació de docker: sudo ./m05uf2pr2.sh install_docker"
		echo " "
		echo "Descarregant imatges i creant docker de mysql-phpmyadmin-wordpress-joomla: ./m05uf2pr2.sh up"
		echo " "
		echo "Aturant i esborrant dockers i imatges de mysql-phpmyadmin-wordpress-joomla: ./m05uf2pr2.sh destroy"
		echo " "
		echo "Iniciant dockers de mysql-phpmyadmin-wordpress-joomla: ./m05uf2pr2.sh start"
		echo " "
		echo "Aturant dockers de mysql-phpmyadmin-wordpress-joomla: ./m05uf2pr2.sh stop"
		echo " "
		;;
esac
exit 0
