#!/bin/bash
# Ce sript startpe le service JBoss pour l'ensemble d'un environnement
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="pvadmin"
#ADMIN_USER="root"

usage ()
{
    echo
    echo "Ce script permet d'arreter l'ensemble des composants d'un environnement"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e t4"
    echo "    -e | --env      Nom de l'environnement"
    echo "    -h | --help     Affichage de l'aide"
    echo
    exit 1
}

# test des options
while [ "$1" != "" ]; do
    case $1 in
        -e | --env ) shift
                          env=$1;;
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

confFile=$CURRENT_DIR/../conf/$env/polo_sysctl.conf


getHostName ()
{
    if [ -z "$1" ]
    then
        echo "Il manque un parametre pour la fonction 'getHostName'."
        exit 1
    fi
    appHost=`grep "^$1" $confFile | awk -F '=' '{ print $2 }'`
}

startComponent ()
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

     ssh $ADMIN_USER@$appHost sudo /usr/bin/systemctl start $2 &
     sleep 10
#     ssh $ADMIN_USER@$appHost  /etc/init.d/$2 start
} 


hostDone=""

# Arret Paiement Gateway
jbInst=`echo $env"pgw"`
#echo $jbInst 
echo ""
getHostName "poloPgwHost"
poloPgwHostsList=`echo $appHost | tr "," "\n"`
#echo "Pgw srv = " $poloPgwHostsList
for appHost in $poloPgwHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
#     startComponent $appHost jboss-"$env"pgw
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done

hostDone=""

# Arret WS
jbInst=`echo $env"ws"`
#echo $jbInst
echo ""
getHostName "poloWsHost"
poloWsHostsList=`echo $appHost | tr "," "\n"`
#echo "Ws srv = " $poloWsHostsList
for appHost in $poloWsHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done

hostDone=""

# Arret BackOffice
jbInst=`echo $env"backoffice"`
#echo $jbInst
echo ""
getHostName "poloBackofficeHost"
poloBackHostList=`echo $appHost | tr "," "\n"`
#echo "Back srv = " $poloBackHostList
for appHost in $poloBackHostList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done

hostDone=""

# Arret Booking
jbInst=`echo $env"booking"`
#echo $jbInst
echo ""
getHostName "poloBookingHost"
poloBookingHostsList=`echo $appHost | tr "," "\n"`
#echo "Book srv = " $poloBookingHostsList
for appHost in $poloBookingHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done

hostDone=""

# Arret Async
jbInst=`echo $env"async"`
#echo $jbInst
echo ""
getHostName "poloAsyncHost"
poloAsyncHostsList=`echo $appHost | tr "," "\n"`
#echo "Async srv = " $poloAsyncHostsList^
for appHost in $poloAsyncHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done

hostDone=""

# Arret Rules
jbInst=`echo $env"rules"`
#echo $jbInst
echo ""
getHostName "poloRulesHost"
poloRulesHostsList=`echo $appHost | tr "," "\n"`
#echo "Rules srv = " $poloRulesHostsList
for appHost in $poloRulesHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done


hostDone=""

# Arret Rules-Deploy
jbInst=`echo $env"rules-deploy"`
#echo $jbInst
echo ""
getHostName "poloRules-deployHost"
poloRulesDeployHostsList=`echo $appHost | tr "," "\n"`
#echo "Rules srv = " $poloRulesHostsList
for appHost in $poloRulesDeployHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
     startComponent $appHost jboss-$jbInst
     hostDone=$hostDone,$appHost
   fi
done

hostDone=""

