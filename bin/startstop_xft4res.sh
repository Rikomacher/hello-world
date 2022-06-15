#!/bin/bash
##################################################################################
#Ce sript permet d'arrêter et de relancer les applications l'application xft4res.#
##################################################################################

PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="local-restart"
proj="xft4res"

####################
#variable ansible  #
####################

export ANSIBLE_HOME="/opt/pvcp/ansible"


usage ()
{
    echo
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e env -a act"
    echo "    -e | --env: acc ou prod    Nom de l'environnement"
    echo "    -a | --Action: start ou stop    Action à réaliser"
    echo "    -h | --help     Affichage de l'aide"
    echo
    exit 1
}


# test des options
while [ "$1" != "" ]; do
    case $1 in
        -e | --env )  shift
                        env=$1;;
        -a | --action )  shift
                        act=$1;;
        -h | --help )     usage
                          exit;;
        * )               usage
                          exit 1
    esac
    shift
done

if [ -z "$env" ]
then
    usage
fi

if [ -z "$act" ]
then
    usage
fi


# on recupere le fichier de conf utilise par pvcp_deploy
if [ ! -d $HOME/exploitation/ansible_inventories/$proj/$env ]
then
    mkdir -p $HOME/exploitation/ansible_inventories/$proj/$env
fi
cp -p $ANSIBLE_HOME/dynamic_inventories/$proj/$env/$proj_* $HOME/exploitation/ansible_inventories/$proj/$env/
ansibleFile=$HOME/exploitation/ansible_inventories/$proj/$env/$proj"_"$env"_lb"


startComponent ()
{
   if [ -z "$2" ]
   then
      echo "Il manque un parametre pour la fonction 'startComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       START de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost sudo /etc/init.d/jboss-$proj $act
}

stopComponent ()
{
   if [ -z "$2" ]
   then
      echo "Il manque un parametre pour la fonction 'startComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       ARRET de $jbInst sur $appHost "
     echo "#######################################################"
     ssh -tT $ADMIN_USER@$appHost sudo /etc/init.d/jboss-$proj $act
}


	start () {
	

	hostDone=""

        # Stop XFT4RES
        jbInst=`echo "jboss-"$proj`
        #echo $jbInst
        echo ""
        appHostList=`cat $ansibleFile | awk '{print $1}' | tr " " "\n"`
	echo $appHostList
        
	for appHost in $appHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst $act
                 $HOME/exploitation/centreon/downtime_auto.sh $appHost DEL
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        echo "=====================Relance d'apache========================="

        hostDone=""

        appHostList=`cat $ansibleFile | awk '{print $1}' | tr " " "\n"`
        echo $appHostList

        for appHost in $appHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
        ssh -tT $ADMIN_USER@$appHost sudo /etc/init.d/httpd $act
           fi
        done
        hostDone=""

        echo "=========================================================================================="
	}

	stop () {

	echo "============Arrêt du jboss xft4res============"

        hostDone=""

         #Stop XFT4RES
        jbInst=`echo "jboss-"$proj`
        #echo $jbInst
        echo ""
        appHostList=`cat $ansibleFile | awk '{print $1}' | tr " " "\n"`
        echo $appHostList
        
	for appHost in $appHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 $HOME/exploitation/bin/downtime_auto.sh $appHost ADD
                 stopComponent $jbInst $act
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        echo "=====================Arrêt d'apache========================="
        echo ""
        
	hostDone=""

	appHostList=`cat $ansibleFile | awk '{print $1}' | tr " " "\n"`
        echo $appHostList

        for appHost in $appHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
	ssh -tT $ADMIN_USER@$appHost sudo /etc/init.d/httpd $act
           fi
        done
        hostDone=""

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
