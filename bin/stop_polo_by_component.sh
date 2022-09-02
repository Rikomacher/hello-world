#!/bin/bash
# Creation 07/08/2019 par F. Pimentel
# Ce sript stoppe le service JBoss pour un ou plusieurs composants POLO
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="pvadmin"


usage ()
{
    echo
    echo "Ce sript stoppe le service JBoss pour un ou plusieurs composants POLO"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e t4 -c all"
    echo "    -e | --env      Nom de l'environnement"
    echo "    -c | --comp     Composant à arreter (pgw ou ws ou backoffice ou booking ou async ou rules ou rules-deploy ou polo-batch ou polo-batchCatalog ou ALL)"
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
cp -p  $HOME/pvcpdeploy/conf/$env/polo.conf $HOME/exploitation/conf/$env/polo.conf
confFile=$HOME/exploitation/conf/$env/polo.conf


getHostName ()
{
    if [ -z "$1" ]
    then
        echo "Il manque un parametre pour la fonction 'getHostName'."
        exit 1
    fi
    appHost=`grep "^$1" $confFile | awk -F '=' '{ print $2 }'`
}

statusComponent ()
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
     echo "       ARRET de $jbInst sur $appHost "
     echo "#######################################################"

     ssh -t $ADMIN_USER@$appHost sudo systemctl status jboss-$jbInst
} 


if [ $comp == ALL ]
then
	#echo "on arrete TOUT"
	hostDone=""

	# Arret Paiement Gateway
	jbInst=`echo $env"pgw.service"`
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
	#     statusComponent $appHost jboss-"$env"pgw
		 statusComponent $appHost $jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done

	hostDone=""

	# Arret WS
	jbInst=`echo $env"ws.service"`
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
		 statusComponent $appHost jboss-$jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done

	hostDone=""

	# Arret BackOffice
	jbInst=`echo $env"backoffice.service"`
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
		 statusComponent $appHost jboss-$jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done

	hostDone=""

	# Arret Booking
	jbInst=`echo $env"booking.service"`
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
		 statusComponent $appHost jboss-$jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done

	hostDone=""

	# Arret Async
	jbInst=`echo $env"async.service"`
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
		 statusComponent $appHost jboss-$jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done

	hostDone=""

	# Arret Rules
	jbInst=`echo $env"rules.service"`
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
		 statusComponent $appHost jboss-$jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done


	hostDone=""

	# Arret Rules-Deploy
	jbInst=`echo $env"rules-deploy.service"`
	#echo $jbInst
	echo ""
	getHostName "poloRules-deployHost"
	poloRulesDeployHostsList=`echo $appHost | tr "," "\n"`
	#echo "Rules-Deploy srv = " $poloRulesDeployHostsList
	for appHost in $poloRulesDeployHostsList
	do
	   isDone=`echo $hostDone | grep $appHost`
	   if [ "$isDone" = "" ]
	   then
		 statusComponent $appHost jboss-$jbInst
		 hostDone=$hostDone,$appHost
	   fi
	done

	hostDone=""

        # Arret polobatch
        jbInstt=`echo $env"polo-batch.service"`
        echo $jbInstt
        getHostName "poloBatchHost"
        poloHostsList=`echo $appHost | tr "," "\n"`
        for appHost in $poloHostsList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
           echo "#######################################################"
           echo "       ARRET de $jbInstt sur $appHost "
           echo "#######################################################"
                ssh -t $ADMIN_USER@$appHost systemctl status $jbInstt
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Arret polobatch-catalog
        jbInstt=`echo $env"polo-batch.service"`
        getHostName "poloBatch-catalogHost"
        poloBatchHostsList=`echo $appHost | tr "," "\n"`
        for appHost in $poloBatchHostsList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
           echo "#######################################################"
           echo "       ARRET de $jbInstt sur $appHost "
           echo "#######################################################"
                ssh -t $ADMIN_USER@$appHost systemctl status $jbInstt
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

	exit 0
fi


#echo "On arrete un seul composant"
hostDone=""

# Arret $env$comp
jbInst=`echo $env$comp`
echo $jbInst 
echo ""

case $comp in
        pgw )
            getHostName "poloPgwHost";;
        ws )
            getHostName "poloWsHost";;
	backoffice )
            getHostName "poloBackofficeHost";;
	booking )
            getHostName "poloBookingHost";;
	async )
            getHostName "poloAsyncHost";;
	rules )
            getHostName "poloRulesHost";;
	rules-deploy )
	    getHostName "poloRules-deployHost";;
	polo-batchCatalog )
            getHostName "poloBatch-catalogHost";;
	polo-batch )
            getHostName "poloBatchHost";;
        * )               echo "Le nom du composant est incorrect"; usage
                          exit 1
    esac

hostDone=""


# Boucle specifique pour polobatch
if [ $comp == polo-batch ]
then
        jbInstt=`echo $env"polo-batch.service"`
	echo $jbInstt
	getHostName "poloBatchHost"
	poloHostsList=`echo $appHost | tr "," "\n"`
	for appHost in $poloHostsList
	do
	   isDone=`echo $hostDone | grep $appHost`
	   if [ "$isDone" = "" ]
	   then
	   echo "#######################################################"
           echo "       ARRET de $jbInstt sur $appHost "
           echo "#######################################################"
                ssh -t $ADMIN_USER@$appHost systemctl status $jbInstt
                 hostDone=$hostDone,$appHost
	   fi
	done
exit 0
fi


# Boucle specifique pour polobatch-catalog
if [ $comp == polo-batchCatalog ]
then
        jbInstt=`echo $env"polo-batch.service"`
        getHostName "poloBatch-catalogHost"
        poloBatchHostsList=`echo $appHost | tr "," "\n"`
        for appHost in $poloBatchHostsList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
           echo "#######################################################"
           echo "       ARRET de $jbInstt sur $appHost "
           echo "#######################################################"
                ssh -t $ADMIN_USER@$appHost systemctl status $jbInstt
                 hostDone=$hostDone,$appHost
           fi
        done
exit 0
fi


poloHostsList=`echo $appHost | tr "," "\n"`
#echo "srv = " $poloHostsList
for appHost in $poloHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
         statusComponent $appHost jboss-$jbInst
         hostDone=$hostDone,$appHost
   fi
done

hostDone=""

exit 0
