#/usr/bin/env bash

set -e

volumes_from=
volume_dir=
backup_file_prefix=

showHelp() {
  echo 'Usage: backup-docker-volume.sh [options]'
  echo 'Script to backup docker volume'
  echo ''
  echo 'Params:'
  echo '  -f, --volumes-from <value>        container id/name to backup volumes from'
  echo '  -d, --volume-dir <value>          path within the container to backup'
  echo '  -p, --backup-file-prefix <value>  prefix of the output backup file'
  echo '  -o, --backups-dir <value>         output directory to save backup to. Default: $(pwd)/backup'
  echo ''
  echo 'Example:'
  echo '  Backup volues from "pg-stage" container:'
  echo '  - backup directory: /var/lib/postgresql/data'
  echo '  - backup file prefix: pg-stage'
  echo '  - file to be saved to default dir: ${pwd}/backup'
  echo '  Command:'
  echo '  $ backup-docker-volume.sh -f pg-stage -d /var/lib/postgresql/data -p pg-stage'
}

while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -f|--volumes-from)
      volumes_from="$2"
      shift # past argument
      ;;
      -d|--volume-dir)
      volume_dir="$2"
      shift # past argument
      ;;
      -p|--backup-file-prefix)
      backup_file_prefix="$2"
      shift # past argument
      ;;
      -o|--backups-dir)
      backups_dir="$2"
      shift # past argument
      ;;
      -h|--help)
      showHelp
      exit 0
      ;;
      *)
      echo "ERROR: Unknown option $key"
      echo ''
      showHelp
      exit 1
      ;;
  esac
  shift # past argument or value
done

: ${volumes_from:?"Please provide -f|--volumes-from. See --help for more details"}
: ${volume_dir:?"Please provide -d|--volumes-dir. See --help for more details"}
: ${backup_file_prefix:?"Please provide -p|--backup-file-prefix. See --help for more details"}

backups_dir=${backups_dir:-$(pwd)/backup}
backup_file_name="${backup_file_prefix}-`date +%Y-%m-%dT%H-%M-%SZ --utc`.tar.gz"

BACKUP_CMD="tar --totals -z -C ${volume_dir} -cf /backup/${backup_file_name} ."

echo Starting backup of "${volumes_from}" volume
echo - volume dir "${volume_dir}"
echo - backup will be written to: "${backups_dir}/${backup_file_name}"
docker run -it --rm --volumes-from ${volumes_from} -v ${backups_dir}:/backup ubuntu ${BACKUP_CMD}
