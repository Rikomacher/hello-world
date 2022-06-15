e sript affiche le status des services pour un ou plusieurs composants PARISOPEN
PRG=`dirname $0`
CURRENT_DIR=`cd "$PRG" && pwd`
ADMIN_USER="root"



usage ()
{
    echo
    echo "Ce sript affiche le status du service NEOLANE"
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

Host1="EUCCENEAPP02"
Host2="EUCCENEAPA01"


case $env in
        PROD )

            ssh -t $Host1 "sudo  echo -e '***************STARTING NEOLANE***************' && sudo /etc/init.d/nlserver6 start && sudo echo '***************STARTING  APACHE***************' &&  sudo /etc/init.d/httpd start" ;;

        ACC )

            ssh -t $Host2 "sudo  echo -e '***************STARTING APACHE***************' && sudo /etc/init.d/httpd start && sudo echo '***************STARTING NEOLANE***************' &&  sudo /etc/init.d/nlserver6 start" ;;
        * )
            echo "Le nom de l'environnement est incorrect"; usage
            exit 1
    esac


exit 0


   fi
done

hostDone=""

exit 0

