#!/bin/bash
#ce sript affiche stoppe les services pour un ou plusieurs composants PARISOPEN
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="pvadmin"


usage ()
{
    echo
    echo "Ce sript stoppe les services pour un ou plusieurs composants PARISOPEN"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e t4 -c all"
    echo "    -e | --env      Nom de l'environnement"
    echo "    -c | --comp     Composant à arreter (All ou web ou ws ou cache ou bo ou Async )"
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
cp -p  $HOME/pvcpdeploy/conf/$env/parisopen.conf $HOME/exploitation/conf/$env/parisopen.conf
confFile=$HOME/exploitation/conf/$env/parisopen.conf


getHostName ()
{
    if [ -z "$1" ]
    then
        echo "Il manque un parametre pour la fonction 'getHostName'."
        exit 1
    fi
    appHost=`grep "^$1" $confFile | awk -F '=' '{ print $2 }'`
}

stopComponent ()
{
   if [ -z "$1" ]
   then
      echo "Il manque un parametre pour la fonction 'stopComponent'."
      exit 1
   fi
   if [ -z "$1" ]
   then
      echo "Il manque un second parametre pour la fonction 'stopComponent'."
      exit 1
   fi
     echo "#######################################################"
     echo "       ARRET de $jbInst sur $appHost "
     echo "#######################################################"

     ssh $ADMIN_USER@$appHost sudo systemctl stop jboss-$jbInst
}





if [ $comp == ALL ]
then
        #echo "on arrete TOUT"
        hostDone=""

        # Arret WEB
        jbInst=`echo $env"parisopenweb.service"`
        #echo $jbInst
        echo ""
        getHostName "parisopenWebHost"
        parisopenWebHostList=`echo $appHost | tr "," "\n"`
        #echo "WEB srv = " $parisopenWebHostList
        for appHost in $parisopenWebHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 stopComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Arret WS
        jbInst=`echo $env"parisopenws.service"`
        #echo $jbInst
        echo ""
        getHostName "parisopenWsHost"
        parisopenWsHostList=`echo $appHost | tr "," "\n"`
        #echo "WEB srv = " $parisopenWsHostList
        for appHost in $parisopenWsHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 stopComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

         # Arret CACHE
        jbInst=`echo $env"parisopencache.service"`
        #echo $jbInst
        echo ""
        getHostName "parisopenCacheHost"
        parisopenCacheHostList=`echo $appHost | tr "," "\n"`
        #echo "WEB srv = " $parisopenCacheHostList
        for appHost in $parisopenCacheHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then

                 stopComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

       # Stop Back Office
        jbInst=`echo $env"parisopenbo.service"`
        #echo $jbInst
        echo ""
        getHostName "parisopenBoHost"
        parisopenBoHostList=`echo $appHost | tr "," "\n"`
        #echo "WEB srv = " $parisopenBoHostList
        for appHost in $parisopenBoHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 stopComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Stop RES ASYNC
        jbInstt=`echo $env"-resAsync.service"`
        echo $jbInstt
        echo ""
        getHostName "parisopenResasyncHost"
        parisopenResasyncHostList=`echo $appHost | tr "," "\n"`
        #echo "WEB srv = " $parisopenResasyncHostList
        for appHost in $parisopenResasyncHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then

           echo "#######################################################"
           echo "       Arret de Async  sur $appHost "
           echo "#######################################################"

           ssh $ADMIN_USER@$appHost  systemctl stop $jbInstt

                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""


        exit 0
fi


#echo "On arrete un seul composant"
hostDone=""

# Arret $env"parisopen"$comp
jbInst=`echo $env"parisopen"$comp`
jbInstt=`echo $env"-res"$comp`
echo $jbInst
echo ""

case $comp in
        web )
            getHostName "parisopenWebHost";;
        ws )
            getHostName "parisopenWsHost";;
        cache )
            getHostName "parisopenCacheHost";;
        bo )
            getHostName "parisopenBoHost";;

        Async )
            getHostName "parisopenResasyncHost";;

        * )
            echo "Le nom du composant est incorrect"; usage
            exit 1
    esac

if [ $comp != Async ]
then

parisopenHostsList=`echo $appHost | tr "," "\n"`
#echo "srv = " $parisopenHostsList
for appHost in $parisopenHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
         stopComponent $appHost $jbInst
         hostDone=$hostDone,$appHost
   fi
done

fi
hostDone=""


# Boucle specifique pour parisopen Async
if [ $comp == Async ]
then
        getHostName "parisopenResasyncHost"
        parisopenResasyncHostList=`echo $appHost | tr "," "\n"`
       # echo "srv parisopenResasync= " $parisopenResasyncHostList
        for appHost in $parisopenResasyncHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
          echo "#######################################################"
          echo "       Arret de $jbInstt sur $appHost "
          echo "#######################################################"

       ssh $ADMIN_USER@$appHost systemctl stop $jbInstt
                #hostDone=$hostDone,$appHost
           fi
        done
fi

hostDone=""


exit 0

