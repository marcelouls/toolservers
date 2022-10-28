#!/usr/bin/env bash

# servidores.sh (Shell Script )

# Objetivo : simplificar requerimentos de informação e conexão com servidores dos clientes

# versão 1.0

# Progamador : Marcelo Palacios /07/2022.

# email : marcelo.palacios@mv.com.br
#-----------------------------------------------------------------------------------------
##======== sources ==============##
source conf-toolserver/menu.conf 
source conf-toolserver/menu-tomcat.txt
BANCO="conf-toolserver/db-clientes.txt"
LISTCL="conf-toolserver/clientes.txt"
SEMTOMCAT="\e[1;35m Esse servidor não contem Tomcats \e[0m"
NOLINUX="\e[1;35m Esse servidor e Windows! \e[0m"
OPTION=0
USUARIO=`whoami`
c="c"
while [ $OPTION -ne 9 ]; do
	unset AMBIENTES	
	unset CLIENTE
	unset NOMECLIENTE
	unset AMBIENTES
	clear
	# echo  "$MENU"
	menu
	#echo -e "                    \e[1;32m $SUBTITTLE \e[0m";
	echo "Bem-vindo : " $USUARIO;
	read -p $'\033[32;1mCód. do cliente: \033[m' CLIENTE
	##================== escolhe meneu ambientes =================##
	NOMECLIENTE=$(grep $CLIENTE $LISTCL | cut -d ":" -f2 )
	AMBIENTES=$(grep $CLIENTE $LISTCL | cut -d ":" -f3 )
	OPTION=$(grep $CLIENTE $LISTCL | cut -d ":" -f4 )
	##============== fim escolhe menu ambiente ====================##
	if [ -z $OPTION ]
	then
		echo -e "\033[35;1mCliente $CLIENTE não existe! \033[m"
		OPTION=0
		sleep 1s
	elif [ $OPTION == "0" ]
	then
		clear
		$AMBIENTES
		CDCLIENTE=$CLIENTE
		#echo -e "                    \e[1;32m $SUBTITTLE \e[0m";
		echo "$NOMECLIENTE"
		read -p $'\033[32;1mInforme o Ambiente: \033[m' AMBIENTE
		CDAMBIENTE=$CDCLIENTE${AMBIENTE^^}
		CONECTANDO=$(echo "Conectando a : ${AMBIENTE^^} - $NOMECLIENTE")
		##========================= interação com banco de dados =========================##
		CHECK=$(grep $CDAMBIENTE $BANCO | cut -d ":" -f1 )
		SENHA=$(grep $CDAMBIENTE $BANCO | cut -d ":" -f2 )
		USER=$(grep $CDAMBIENTE $BANCO | cut -d ":" -f3 )
		SERVER=$(grep $CDAMBIENTE $BANCO | cut -d ":" -f4 )
		AMB=$(grep $CDAMBIENTE $BANCO | cut -d ":" -f5 )
		##========================== fim interação de banco de dcados ==========================""
		##chech check
		if [ ! -z $CHECK ]
		then
			#limpa keyHost CCOU=================#
			if [ "$CLIENTE" == "1927" ]
			then
				echo > '/home/'$USUARIO'/.ssh/known_hosts';
			fi
			#fim limpa keyHost CCOU=================#
			##========== VERIFICA CONEXAO ============##
			if [[ ! -z $SERVER ]]; then
				echo "Verificando Conexão com o servidor...... "
				sleep 2s
				while  ! ping -c1 $SERVER &>/dev/null 
				do
					echo -e "\e[31;5m Sem Conexão \n confira estar conectado na VPN do cliente! \e[0m";
					echo "pressione uma tecla para continuar ou digite "exit" para sair";
					read  c;
					if [ $c == "exit" ]
					then 
						exit
					fi	
				done
				echo ".....Servidor disponivel!"
				##========== fim VERIFICA CONEXAO ============##
				PRINTPASS="echo Senha :  $SENHA"
				CONECTA="ssh $USER@$SERVER"
				sleep 2s
				clear 
				echo "                        MENU"
				echo "     ------------------------------------------"
				echo "     [ 1 ]  Conectar ao Servidor do Cliente";
				echo "     [ 2 ]  Download das pastas logs e mv-logs";
				echo "     [ 3 ]  Check status servidor e tomcats";
				echo "     [ 4 ]  Reiniciar Tomcat";
				echo "     [ 5 ]  Versões Soul-Pep-License no servidor";
				echo "     [ 6 ]  Pacotes";
				echo "     ------------------------------------------"
				#teste
				read -p $'\033[32;1mDigite a opção desejada : \033[m' OPCAO
				#fim menu
				if [ $OPCAO == "1" ]
				then
					echo -e "      \e[1;32m Conexão ao Servidor \e[0m";        
					$PRINTPASS
					$CONECTA
				elif [ $OPCAO == "2" ]
				then
					############### ADD  LOGS INDIVIDUAL ###############
					clear
					echo "                        MENU"
					echo "     ------------------------------------------"
					echo "     [ 1 ]  logs data atual";
					echo "     [ 2 ]  mv-logs data atual"
					echo "     [ 3 ]  Download das pastas logs e mv-logs";
					echo "     ------------------------------------------"

					read -p $'\033[32;1mDigite a opção desejada : \033[m' LOG_OPCAO;

					if [ $LOG_OPCAO == "1" ]
					then
						echo -e "      \e[1;32m Download Logs e mv-logs \e[0m";
						$PRINTPASS
						$CONECTA 'export AMBIENTE='$AMB '; tomcatctl contexto';
						echo -e "\n";
						read -p $'\033[32;1mInforme numero de tomcat : \033[m' TOMCAT
						for i in `ssh $USER@$SERVER find "/MV/servers/soulmv_$AMB/tomcat$TOMCAT/logs" -type f -mtime 0`
							#echo "arquivos do for : $i"
						do

							echo  $i | cut -d '/' -f7;  
							read -p $'\033[32;1mDownload ? (y/n) : \033[m' download
							if [[ "$download" = "y" ]]
							then
								scp $USER@$SERVER:/$i /home/$USUARIO/logs/$CLIENTE/
							fi
						done






					elif [ $LOG_OPCAO == "2" ]
					then
						echo -e "      \e[1;32m Download Logs e mv-logs \e[0m";
						$PRINTPASS
						$CONECTA 'export AMBIENTE='$AMB '; tomcatctl contexto';
						echo -e "\n";
						read -p $'\033[32;1mInforme numero de tomcat : \033[m' TOMCAT
						for i in `ssh $USER@$SERVER find "/MV/servers/soulmv_$AMB/tomcat$TOMCAT/mv-logs" -type f -mtime 0`
							#echo "arquivos do for : $i"
						do

							echo  $i | cut -d '/' -f7;
							read -p $'\033[32;1mDownload ? (y/n) : \033[m' download
							if [[ "$download" = "y" ]]
							then
								scp $USER@$SERVER:/$i /home/$USUARIO/logs/$CLIENTE/
							fi
						done

					elif [ $LOG_OPCAO == "3" ]
					then
						echo -e "      \e[1;32m Download Logs e mv-logs \e[0m";
						$PRINTPASS
						$CONECTA 'export AMBIENTE='$AMB '; tomcatctl contexto';
						echo -e "\n";
						read -p "informe numero de tomcat :" TOMCAT
						#download de log  e mv-logs
						scp -r -C $USER@$SERVER:/MV/servers/soulmv_$AMB/tomcat$TOMCAT/logs/ /home/$USUARIO/logs/$CLIENTE-$AMB-Tomcat$TOMCAT-logs-$(date +"%Y_%m_%d")/;scp -r -C $USER@$SERVER:/MV/servers/soulmv_$AMB/tomcat$TOMCAT/mv-logs/ /home/$USUARIO/logs/$CLIENTE-$AMB-Tomcat$TOMCAT-mvlogs-$(date +"%Y_%m_%d")/
					fi


				

				################ FIM LOG INDIVIDUAL ################ 

			elif [ $OPCAO == "3" ]
			then
				echo -e "      \e[1;32m Status Servidor e Tomcat \e[0m";
				$PRINTPASS
				$CONECTA  'echo -e "\n"; free -h ;echo -e "\n"; df -h' ';echo -e "\n"; export AMBIENTE='$AMB '; tomcatctl contexto; ' ;
				##============ MENU REINCIO TOMCAT ===============================##
			elif [ $OPCAO == "4" ]
			then
				clear
				menu-tomcat
				read -p "Digite a opção desejada : " REINICIA ;
				if [ $REINICIA == "1" ]
				then 
					$PRINTPASS
					$CONECTA 'tomcatctl restart all' ;
				elif [ $REINICIA == "2" ]
				then
					$PRINTPASS
					$CONECTA 'export AMBIENTE='$AMB '; tomcatctl contexto';
					read -p "Informe o Tomcat para reinicio :" NUMTOM 
					$CONECTA 'tomcatctl restart' $NUMTOM ;
				elif [ $REINICIA == "3" ]
				then
					$PRINTPASS
					$CONECTA 'tomcatctl stop all; tomcatctl cleanup all; tomcatctl start all'
				elif [ $REINICIA == "4" ]
				then
					$PRINTPASS
					$CONECTA 'export AMBIENTE='$AMB '; tomcatctl contexto';
					read -p "Informe o Tomcat para reinicio :" NUMTOM
					$CONECTA 'tomcatctl stop '$NUMTOM';tomcatctl cleanup '$NUMTOM';tomcatctl start '$NUMTOM;	
				elif [ $REINICIA == "5" ]
				then
					$PRINTPASS
					$CONECTA 'tomcatctl stop all'
				elif [ $REINICIA == "6" ]
				then
					$PRINTPASS
					$CONECTA 'export AMBIENTE='$AMB' ; tomcatctl contexto';
					read -p "Informe o Tomcat para PARAR : " NUMTOM
					$CONECTA 'tomcatctl stop '$NUMTOM;
				elif [ $REINICIA == "7" ]
				then
					$PRINTPASS
					$CONECTA 'echo 3 > /proc/sys/vm/drop_caches ; sysctl -w vm.drop_caches=3';
				else
					echo "Esolha opção de 1 a 7"; 
				fi
				##============ FIM MENU REINICIO TOMCAT =========================##
			elif [ $OPCAO == "5" ]
			then
				$PRINTPASS
				$CONECTA 'echo -e "\nSOUL : " ;
				ls -t  /MV/apps/soulmv_'$AMB'/products/mv/ | tail -n  +1 | head -1  ;
				echo "PEP : " ;
				ls -t /MV/apps/soulmv_'$AMB'/products/mvpep/ | tail -n +1 | head -1 ;
				echo "LICENSE : " ;
				ls -t /MV/apps/soulmv_'$AMB'/products/license-service/ | tail -n +1 | head -1 ;'
				if [ $OPCAO == "6" ]
				then
					clear
					echo "                        MENU"
					echo "     ------------------------------------------"
					echo "     [ 1 ]  Download arquivo cliente - HTML";
					echo "     [ 2 ]  Download arquivo cliente - FLEX";
					echo "     [ 3 ]  Subir aquivo modificado - HTML";
					echo "     [ 4 ]  Subir arquivo modificado - FLEX";
					echo "     ------------------------------------------";
					read -p "Digite a opção desejada : " PACOTE ;
					if [ $PACOTE == "1" ]
					then
						$PRINTPASS
						$CONECTA "ls -t /MV/apps/soulmv_'$AMB'/products/soul-product-forms/" ;
						read -p "Escolha a  versão : "  VERSAO;
						read -p "Escreva o produto ex: ffcv : " PRDT;
						scp -r $USER@$SERVER:/MV/apps/soulmv_$AMB/products/soul-product-forms/$VERSAO/forms/WEB-INF/lib/soul-${PRDT,,}-forms-$VERSAO.jar /home/marcelopalacios/
					elif [ $PACOTE == "2" ]
					then
						$PRINTPASS
						$CONECTA "ls -t /MV/apps/soulmv_'$AMB'/products/mv/" ;
						read -p "Escolha a  versão : "  VERSAO;
						read -p "Escreva o produto ex: ffcv : " PRDT;
						read -p "Escreva o nome da tela (Camel Case) : " TELA
						scp -r $USER@$SERVER:/MV/apps/soulmv_$AMB/products/'mv'/$VERSAO/forms/WEB-INF/lib/com.mvsistemas.mv2000.${PRDT,,}.forms.$TELA.jar /home/marcelopalacios/
					elif [ $PACOTE == "3" ]
					then
						ls -l soul-*;
						read -p "Copie e cole o nome do arquivo : " ARQUIVO
						$PRINTPASS
						$CONECTA "ls -t /MV/apps/soulmv_'$AMB'/products/soul-product-forms/" ;
						read -p "Escolha a  versão : "  VERSAO;
						scp -r /home/marcelopalacios/$ARQUIVO $USER@$SERVER:/MV/apps/soulmv_$AMB/products/soul-product-forms/$VERSAO/forms/WEB-INF/lib/
					elif [ $PACOTE == "4" ]
					then
						ls -l com.mvsistemas.mv2000.*;
						read -p "Copie e cole o nome do arquivo : " ARQUIVO
						$PRINTPASS
						$CONECTA "ls -t /MV/apps/soulmv_'$AMB'/products/mv/" ;
						read -p "Escolha a  versão : "  VERSAO;
						scp -r /home/marcelopalacios/$ARQUIVO $USER@$SERVER:/MV/apps/soulmv_$AMB/products/'mv'/$VERSAO/forms/WEB-INF/lib/
					else
						echo "Opção não existe"
					fi

				fi
			fi
		fi
	fi
	fi
	echo "pulse uma tecla para continuar......"
	read p
done
