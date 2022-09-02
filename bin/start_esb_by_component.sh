#!/bin/bash
#set -x

# Ce sript affiche le start des services pour un ou plusieurs composants ESB
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="pvadmin"


usage ()
{
    echo
    echo "Ce sript affiche le start des services pour un ou plusieurs composants ESB"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e ACC -c all"
    echo "    -e | --env      Nom de l'environnement"
    echo "    -c | --comp     Composant à démarrer (ALL ou crm ou front ou mycp ou sap ou ap ou pms-prestige ou pms-misterbooking ou pms-dedge ou ramses ou tars ou editique ou starlight )"
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
cp -p  $HOME/pvcpdeploy/conf/$env/esb.conf $HOME/exploitation/conf/$env/esb.conf
confFile=$HOME/exploitation/conf/$env/esb.conf

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

# fonction recuperation des noms de serveurs pour les connector
getHostNameconnector ()
{
    if [ -z "$1" ]
    then
        echo "Il manque un parametre pour la fonction 'getHostName'."
        exit 1
    fi
    appHost=`grep "$1" $confFile | awk -F '=' '{ print $2 }'`
}

# fonction redemarrage d'une instance
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
     echo "#######################################################"
     echo "       DEMARRAGE de $jbInst sur $appHost "
     echo "#######################################################"

     ssh -tT $ADMIN_USER@$appHost sudo systemctl start mule-$jbInst

}


if [ $comp == ALL ]
then
        #echo "on affiche le statut TOUT"
        hostDone=""

        # Start CRM
        jbInst=`echo $env"crm"`
        #echo $jbInst
        echo ""
        getHostName "esbCrmHost"
        esbCrmHostList=`echo $appHost | tr "," "\n"`
        #echo "CRM srv = " $esbCrmHostList
        for appHost in $esbCrmHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Start Front
        jbInst=`echo $env"front"`
        #echo $jbInst
        echo ""
        getHostName "esbFrontHost"
        esbFrontHostList=`echo $appHost | tr "," "\n"`
        #echo "FRONT srv = " $esbFrontHostList
        for appHost in $esbFrontHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent  $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

       # Start Sap
        jbInst=`echo $env"sap"`
        #echo $jbInst
        echo ""
        getHostName "esbSapHost"
        esbSapHostList=`echo $appHost | tr "," "\n"`
        #echo "SAP srv = " $esbSapHostList
        for appHost in $esbSapHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""
        
         # Start Starlight
        jbInst=`echo $env"starlight"`
        #echo $jbInst
        echo ""
        getHostName "esbStarlightHost"
        esbStarlightHostList=`echo $appHost | tr "," "\n"`
        #echo "Starlight srv = " $esbStarlightHostList
        for appHost in $esbStarlightHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then

                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

       # Start Editique
        jbInst=`echo $env"editique"`
        #echo $jbInst
        echo ""
        getHostName "esbEditiqueHost"
        esbEditiqueHostList=`echo $appHost | tr "," "\n"`
        #echo "Editique srv = " $esbEditiqueHostList
        for appHost in $esbEditiqueHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

       # Start Tars
        jbInst=`echo $env"tars"`
        #echo $jbInst
        echo ""
        getHostName "esbTarsHost"
        esbTarsHostList=`echo $appHost | tr "," "\n"`
        #echo "TARS srv = " $esbTarsHostList
        for appHost in $esbTarsHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Start ramses
        jbInst=`echo $env"ramses"`
        #echo $jbInst
        echo ""
        getHostName "esbRamsesHost"
        esbRamsesHostList=`echo $appHost | tr "," "\n"`
        #echo "Ramses srv = " $esbRamsesHostList
        for appHost in $esbRamsesHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Start ap
        jbInst=`echo $env"ap"`
        #echo $jbInst
        echo ""
        getHostName "esbApHost"
        esbApHostList=`echo $appHost | tr "," "\n"`
        #echo "Ap srv = " $esbApHostList
        for appHost in $esbApHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Start customer
        jbInst=`echo $env"customer"`
        #echo $jbInst
        echo ""
        getHostName "esbCustomerHost"
        esbCustomerHostList=`echo $appHost | tr "," "\n"`
        #echo "Customer srv = " $esbCustomerHostList
        for appHost in $esbCustomerHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
                 startComponent $jbInst
                 hostDone=$hostDone,$appHost
           fi
        done

	hostDone=""

        #Start Mycp
	jbInstt1=`echo "mule-"$env"front"`

        getHostName "esbMycpHost"
        esbMycpHostList=`echo $appHost | tr "," "\n"`
        for appHost in $esbMycpHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
          echo "#######################################################"
          echo "       START de $jbInstt1 sur $appHost "
          echo "#######################################################"
                ssh $ADMIN_USER@$appHost systemctl start $jbInstt1
                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""
                                                          
        # Start pms-prestige
        jbInstt=`echo "mule-"$env"pms-prestige"`
        echo $jbInstt
        echo ""
        getHostName "esbPms-prestigeHost"
        esbPmsHostList=`echo $appHost | tr "," "\n"`
        #echo "Pms srv = " $esbPmsHostList
        for appHost in $esbPmsHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then

           echo "#######################################################"
           echo "       START de pms-prestige  sur $appHost "
           echo "#######################################################"

           ssh $ADMIN_USER@$appHost systemctl start $jbInstt

                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Start pms-misterbooking
        jbInstt=`echo "mule-"$env"pms-misterbooking"`
        echo $jbInstt
        echo ""
        getHostName "esbPms-misterbookingHost"
        esbPmsHostList=`echo $appHost | tr "," "\n"`
        #echo "Pms srv = " $esbPmsHostList
        for appHost in $esbPmsHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then

           echo "#######################################################"
           echo "       START de pms-misterbooking  sur $appHost "
           echo "#######################################################"

           ssh $ADMIN_USER@$appHost systemctl start $jbInstt

                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        # Start pms-dedge
        jbInstt=`echo "mule-"$env"pms-dedge"`
        echo $jbInstt
        echo ""
        getHostName "esbPms-dedgeHost"
        esbPmsHostList=`echo $appHost | tr "," "\n"`
        #echo "Pms srv = " $esbPmsHostList
        for appHost in $esbPmsHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then

           echo "#######################################################"
           echo "       START de pms-dedge  sur $appHost "
           echo "#######################################################"

           ssh $ADMIN_USER@$appHost systemctl start $jbInstt

                 hostDone=$hostDone,$appHost
           fi
        done

        hostDone=""

        exit 0
fi


#echo "On démarre un seul composant"
hostDone=""

# Start $env"parisopen"$comp
jbInst=`echo $env$comp`
jbInstt=`echo $env"to-connector-"$comp`
echo $jbInst
echo ""

case $comp in
        crm )
	    getHostName "esbCrmHost";;
        front )
	      getHostName "esbFrontHost";;
        mycp ) 
	     getHostName "esbMycpHost";;
        sap )
	    getHostName "esbSapHost";;
        starlight ) 
                  getHostName "esbStarlightHost";;
        editique )
	         getHostName "esbEditiqueHost";;
        tars )
	     getHostName "esbTarsHost";;
        ramses )
	       getHostName "esbRamsesHost";;
        ap )
	   getHostName "esbApHost";;
        customer )
		 getHostName "esbCustomerHost";;
        pms-prestige )
	    getHostName "esbPms-prestigeHost";;
        pms-dedge )
            getHostName "esbPms-dedgeHost";;
        pms-misterbooking)
            getHostName "esbPms-misterbookingHost";;
* )               echo "Le nom du composant est incorrect"; usage
                          exit 1
esac

if [ "$comp" != "mycp" ]
then

esbHostsList=`echo $appHost | tr "," "\n"`
#echo "srv = " $poloHostsList
for appHost in $esbHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
         startComponent $appHost mule-$jbInst
         hostDone=$hostDone,$appHost
   fi
done
fi

hostDone=""

esbconnectorHostList=`echo $appHost | tr "," "\n"`
#echo "srv = " $poloHostsList
for appHost in $esbconnectorHostsList
do
   isDone=`echo $hostDone | grep $appHost`
   if [ "$isDone" = "" ]
   then
         startComponent $appHost mule-$jbInstt
         hostDone=$hostDone,$appHost
   fi
done

hostDone=""

jbInstt1=`echo "mule-"$env"front"`
    if [ "$comp" == "mycp" ];
    then
        #Start Mycp
        getHostName "esbMycpHost"
        esbMycpHostList=`echo $appHost | tr "," "\n"`
        for appHost in $esbMycpHostList
        do
           isDone=`echo $hostDone | grep $appHost`
           if [ "$isDone" = "" ]
           then
          echo "#######################################################"
          echo "       START de $jbInsttl sur $appHost "
          echo "#######################################################"
#                 startComponent $jbInstt1
		ssh $ADMIN_USER@$appHost systemctl start $jbInstt1
                 hostDone=$hostDone,$appHost
           fi
        done
     fi
hostDone=""
exit 0

