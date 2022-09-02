#!/bin/bash
# Ce sript affiche le status de service dynaTraceCollector
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
#ADMIN_USER="adm-skanzari"



usage ()
{
    echo
    echo "Ce sript affiche le status du service DYNATRACE"
    echo "usage: `basename $0` -OPTIONS"
    echo "Exemple : `basename $0` -e t4 "
    echo "    -e | --env      Nom de l'environnement ACC ou PROD"
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

Host1='frccedyapp01'
Host2='euccedyapp02'
Host3='frccedyapa01'



case $env in
        PROD )

            ssh -t $Host1 "sudo echo  '***************STATUT DYNATRACE Collector sur FRCCEDYAPP01***************' &&  systemctl status dynaTraceCollector.service && echo  '***************STATUT DYNATRACE SERVER sur FRCCEDYAPP01***************' &&  systemctl status dynaTraceServer.service";

            ssh -t $Host2 "sudo echo  '***************STATUT DYNATRACE Collector sur EUCCEDYAPP02***************' &&  systemctl status dynaTraceCollector.service " ;;
        ACC )

           ssh -t $Host3 "sudo  echo  '***************STATUT DYNATRACE sur FRCCEDYAPA01***************' && sudo systemctl status dynaTraceCollector.service " ;;

        *)
            echo "Le nom de l'environnement est incorrect"; usage
           exit 1
    esac


exit 0



exit 0

