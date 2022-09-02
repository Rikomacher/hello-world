#!/bin/bash
#Ce sript affiche le stop des services pour un ou plusieurs composants CIAO.
#Il est spécifique à l'application CIAO qui fonctionne sur deux OS différent.
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="local-restart"
proj="ciao2"


usage ()
{
    echo
    echo "Usage: $0 -e {acc|prod} -a {start|stop|status|restart}"
    echo "Exemple : `basename $0` -e env -a act"
    echo "    -e | --env: ACC ou PROD    Nom de l'environnement"
    echo "    -a | --Action: start ou status ou stop Action à réaliser"
    echo "    -h | --help     Affichage de l'aide"
    echo
    exit 1
}

# test des options
while [ "$1" != "" ]; do
    case $1 in
        -e | --env ) shift
                          env=$1;;
        -a | --action ) shift
                          act=$1;;
        -h | --help )     usage
                          exit;;
        * )               usage
                          exit 1
    esac
    shift
done

#echo env: $env
#echo comp: $comp

if [ -z "$env" ]
then
    usage
fi

if [ -z "$act" ]
then
    usage
fi


# on recupere le fichier de conf utilise par pvcp_deploy
if [ ! -d $HOME/exploitation/conf/$env ]
then
    mkdir -p $HOME/exploitation/conf/$env
fi
cp -p  $HOME/pvcp_deploy/conf/$env/$proj".conf" $HOME/exploitation/conf/$env/$proj".conf"
confFile=$HOME/exploitation/conf/$env/$proj".conf"


getHostName ()
{
    if [ -z "$1" ]
    then
        echo "Il manque un parametre pour la fonction 'getHostName'."
        exit 1
    fi
    appHost=`grep "^$1" $confFile | awk -F '=' '{ print $2 }'`
}

stopComponent6 ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'stopComponent'."
      exit 1
   fi
   if [ -z "$2" ]
   then
      echo "Il manque un second parametre pour la fonction 'stopComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       STOP de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost sudo /etc/init.d/jboss-$jbInstt stop
}

stopComponent7 ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'stopComponent'."
      exit 1
   fi
   if [ -z "$2" ]
   then
      echo "Il manque un second parametre pour la fonction 'stopComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       STOP de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost sudo systemctl stop jboss-$jbInst
}

startComponent6 ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'startComponent'."
      exit 1
   fi
   if [ -z "$2" ]
   then
      echo "Il manque un second parametre pour la fonction 'startComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       START de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost sudo /etc/init.d/jboss-$jbInstt start
}

startComponent7 ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'startComponent'."
      exit 1
   fi
   if [ -z "$2" ]
   then
      echo "Il manque un second parametre pour la fonction 'startComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       START de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost sudo systemctl start jboss-$jbInst
}

statusComponent6 ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'statusComponent'."
      exit 1
   fi
   if [ -z "$2" ]
   then
      echo "Il manque un second parametre pour la fonction 'statusComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       STATUS de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost /etc/init.d/jboss-$jbInstt status
}

statusComponent7 ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'statusComponent'."
      exit 1
   fi
   if [ -z "$2" ]
   then
      echo "Il manque un second parametre pour la fonction 'statusComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       STATUS de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost systemctl status jboss-$jbInst
}

	stop () {

        #echo "on arrete TOUT"
        hostDone=""

        # Arret Paiement Gateway
        jbInst=`echo $env"ciao2web.service"`
	jbInstt=`echo $env"ciao2web"`
        #echo $jbInst
        echo ""
        getHostName "ciao2WebHost"
        ciao2WebHostsList=`echo $appHost | tr "," "\n"`
        for appHost in $ciao2WebHostsList
        do
		echo "$appHost : "
	oslevel=$(ssh $ADMIN_USER@$appHost cat "/etc/centos-release" |awk '{print $4}' |cut -d "." -f1) 
	  echo $oslevel
		if [ "$oslevel" == "7" ]
		then
	 	echo "OS 7"
               	stopComponent7 $appHost jboss-$jbInst
               	hostDone=$hostDone,$appHost
                else [ "$oslevel" != "7" ]
                 echo "OS 6"
                 stopComponent6 $appHost jboss-$jbInstt
                 hostDone=$hostDone,$appHost

		fi
        done

        hostDone=""
	        echo "=========================================================================================="
        }

	start () {

        #echo "on arrete TOUT"
        hostDone=""

        # Arret Paiement Gateway
        jbInst=`echo $env"ciao2web.service"`
        jbInstt=`echo $env"ciao2web"`
        #echo $jbInst
        echo ""
        getHostName "ciao2WebHost"
        ciao2WebHostsList=`echo $appHost | tr "," "\n"`
        for appHost in $ciao2WebHostsList
        do
                echo "$appHost : "
        oslevel=$(ssh $ADMIN_USER@$appHost cat "/etc/centos-release" |awk '{print $4}' |cut -d "." -f1)
          echo $oslevel

                if [ "$oslevel" == "7" ]
                then
                echo "OS 7"
                startComponent7 $appHost jboss-$jbInst
                hostDone=$hostDone,$appHost
                else [ "$oslevel" != "7" ]
                 echo "OS 6"
                 startComponent6 $appHost jboss-$jbInstt
                 hostDone=$hostDone,$appHost
                fi
        done

        hostDone=""
                echo "=========================================================================================="
	}

	status () {
        #echo "on arrete TOUT"
        hostDone=""

        # Arret Paiement Gateway
        jbInst=`echo $env"ciao2web.service"`
        jbInstt=`echo $env"ciao2web"`
        #echo $jbInst
        echo ""
        getHostName "ciao2WebHost"
        ciao2WebHostsList=`echo $appHost | tr "," "\n"`
        for appHost in $ciao2WebHostsList
        do
                echo "$appHost : "

        oslevel=$(ssh $ADMIN_USER@$appHost cat "/etc/centos-release" |awk '{print $4}' |cut -d "." -f1)
          echo $oslevel

                if [ "$oslevel" == "7" ]
                then
                echo "OS 7"
                statusComponent7 $appHost jboss-$jbInst
                hostDone=$hostDone,$appHost
                else [ "$oslevel" != "7" ]
                 echo "OS 6"
                 statusComponent6 $appHost jboss-$jbInstt
                 hostDone=$hostDone,$appHost
                fi
        done

        hostDone=""
                echo "=========================================================================================="
        
	}

        case $act in
          start)
              start
              ;;
          stop)
              stop
              ;;
          status)
              status
              ;;
        esac
