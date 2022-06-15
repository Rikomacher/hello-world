#/bin/bash

usage ()
{
    echo "Script gerant le downtime centreon automatiquement avec le nom du host"
    echo
    echo "usage: `basename $0` PARAM1 PARAM2"
    echo "Exemple : `basename $0` frcceopjba01 ADD"
    echo "    PARAM 1 : nom du host cible"
    echo "    PARAM 2 : ADD ajout ou DEL retrait du downtime"
    echo "Ajout d'un downtime de 24 heure"
    echo
    exit 1
}


appHost=$1
action=$2

if [ -z "$appHost" ] || [ -z "$action" ]
then
    usage
fi

shortAppHost=`echo "$appHost" | cut -d"." -f1 | tr '[:lower:]' '[:upper:]'`

if [ "$action" = "ADD" ]
then
  dt_delay_hours=24
  dt_end=`date -d "today + $dt_delay_hours hour" +"%m/%d/%Y %H:%M:%S"`
  echo "Downtime de $dt_delay_hours heure(s) sur $shortAppHost [$dt_end]"
# TODO centreon_prd.pvcp.intra
  sshpass -p kCLuvn6K ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 svc-downtime@centreon_prd '/exploit/script/downtime.sh ADD svc-downtime kCLuvn6K '${shortAppHost}' '${dt_end}''
  exitCode=$?

  # verification du downtime
  if [ $exitCode != 0 ]
  then
    echo ""
    echo -e ${orange}"--- ATTENTION --------"
    echo -e "Un probleme est apparu en positionnant le downtime sur ${shortAppHost}"
    echo -e "Il n y a donc pas de downtime sur ce serveur.${black}"
  fi
elif [ "$action" = "DEL" ]
then
  echo "Retrait du downtime sur $shortAppHost"
# TODO centreon_prd.pvcp.intra
  sshpass -p kCLuvn6K ssh -o StrictHostKeyChecking=no svc-downtime@centreon_prd '/exploit/script/downtime.sh DEL svc-downtime kCLuvn6K '${shortAppHost}''
  echo ""
fi

