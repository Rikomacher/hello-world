#!/bin/bash
#set -x

# Ce sript affiche le start des services pour un ou plusieurs composants WS
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="pvadmin"


usage ()
{
    echo
    echo "Ce sript affiche le start des services pour un ou plusieurs composants WS"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e ACC -c all"
    echo "    -e | --env      Nom de l'environnement"
    echo "    -c | --comp     Composant à vérifier (ALL ou ramses ou ap ou wsrc ou edt ou jrl ou edw ou rpi"
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

# on recupere le fichier de conf utilise par pvcp_eploy
if [ ! -d $HOME/exploitation/conf/$env ]
then
    mkdir -p $HOME/exploitation/conf/$env
fi
cp -p  $HOME/pvcpdeploy/conf/$env/crs.conf $HOME/exploitation/conf/$env/crs.conf
confFile=$HOME/exploitation/conf/$env/crs.conf

# fonction recuperation des noms de serveurs
getHostName ()
{
    if [ -z "$1" ]
    then
        echo "Il manque un parametre pour la fonction 'getHostName'."
        exit 1
    fi
    appHost=`grep "^$1" $confFile | awk -F '=' '{ print $2 }'`
}


# fonction start d'une instance
startComponent ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'startComponent'."
      exit 1
   fi
   if [ -z "$1" ]
   then
      echo "Il manque un second parametre pour la fonction 'startComponent'."
      exit 1
   fi
     echo "############################################################"
     echo "        START de $jbInst sur $appHost "
     echo "############################################################"

     ssh -tT $ADMIN_USER@$appHost sudo systemctl start jboss-$jbInst
     echo ""
}


if [ $comp == ALL ]
then
        #echo "start TOUT"
        hostDone=""

        # Ramses
        jbInst=`echo $env"ramses"`
        echo ""
        getHostName "crsRamsesHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        # AP
        jbInst=`echo $env"ap"`
        echo ""
        getHostName "crsApHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        # WSRC
        jbInst=`echo $env"wsrc"`
        echo ""
        getHostName "crsWsrcHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        # EDT
        jbInst=`echo $env"edt"`
        echo ""
        getHostName "crsEdtHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        # JRL
        jbInst=`echo $env"jrl"`
        echo ""
        getHostName "crsJrlHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        # EDW
        jbInst=`echo $env"edw"`
        echo ""
        getHostName "crsEdwHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""

        # RPI
        jbInst=`echo $env"rpi"`
        echo ""
        getHostName "crsRpiHost"
        WSHostList=`echo $appHost | tr "," "\n"`
        for appHost in $WSHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done
        hostDone=""
        
	echo ""
        exit 0
fi


#echo "Un seul composant"
hostDone=""

jbInst=`echo $env$comp`
#echo $jbInst
echo ""

case $comp in
        ramses )
	       getHostName "crsRamsesHost";;
        ap )
	       getHostName "crsApHost";;
        wsrc )
	       getHostName "crsWsrcHost";;
        edt )
	       getHostName "crsEdtHost";;
        jrl )
	       getHostName "crsJrlHost";;
        edw )
	       getHostName "crsEdwHost";;
        rpi )
	       getHostName "crsRpiHost";;
        * )               echo "Le nom du composant est incorrect"; usage
                          exit 1
esac

#echo $appHost

WSHostsList=`echo $appHost | tr "," "\n"`
for appHost in $WSHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
         startComponent $appHost jboss-$jbInst
         hostDone=$hostDone,$appHost
   fi
done

hostDone=""

exit 0

