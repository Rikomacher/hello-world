#!/bin/bash
#Ce sript affiche le stop des services pour un ou plusieurs composants CIAO.
#Il est spécifique à l'application CIAO qui fonctionne sur deux OS différent.
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="pvadmin"


usage ()
{
    echo
    echo "Ce sript affiche le stop des services pour un ou plusieurs composants CIAO"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e t4 -c all"
    echo "    -e | --env      Nom de l'environnement"
    echo "    -c | --ALL     Composant à arreter (All)"
    echo "    -h | --help     Affichage de l'aide"
    echo
    exit 1
}

# test des options
while [ "$1" != "" ]; do
    case $1 in
        -e | --env ) shift
                          env=$1;;
        -c | --comp ) shift
                          comp=$1;;
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

if [ -z "$comp" ]
then
    usage
fi


# on recupere le fichier de conf utilise par pvcpdeploy
if [ ! -d $HOME/exploitation/conf/$env ]
then
    mkdir -p $HOME/exploitation/conf/$env
fi
cp -p  $HOME/pvcpdeploy/conf/$env/ciao2.conf $HOME/exploitation/conf/$env/ciao2.conf
confFile=$HOME/exploitation/conf/$env/ciao2.conf


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

if [ $comp == ALL ]
then

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

        exit 0
fi

