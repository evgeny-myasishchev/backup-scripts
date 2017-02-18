#/usr/bin/env bash

set -e

volumes_from=
volume_dir=
backup_file_prefix=

showHelp() {
  echo 'Usage: restore-docker-volume.sh [options]'
  echo 'Script to restore docker volume.'
  echo 'Note: Current data will be moved to a temporary location and then removed'
  echo ''
  echo 'Params:'
  echo '  -f, --volumes-from <value>        container id/name to restore volume'
  echo '  -d, --volume-dir <value>          path within the container to restore'
  echo '  -b, --backup-file-path <value>    path to backup file to restore'
  echo ''
  echo 'Example:'
  echo '  Restore volues of "pg-stage" container:'
  echo '  Command:'
  echo '  $ restore-docker-volume.sh -f pg-stage -d /var/lib/postgresql/data -b ./backup/pg-stage-2017-02-18T07-56-10Z.tar.gz'
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
      -b|--backup-file-path)
      backup_file_path="$2"
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
: ${backup_file_path:?"Please provide -b|--backup-file-path. See --help for more details"}

function abs_path() {
  cd $(dirname $1)
  echo $PWD/$(basename $1)
}

backup_file_dir=`dirname ${backup_file_path}`
backup_file_dir=`abs_path ${backup_file_dir}`
backup_file_name=`basename ${backup_file_path}`
tmp_moved_stuff_dir="${volume_dir}/tmp-moved-stuff"

DOCKER_RUN="docker run -it --rm --volumes-from ${volumes_from} -v ${backup_file_dir}:/backup ubuntu"

echo Moving current data to tmp location: ${tmp_moved_stuff_dir}
${DOCKER_RUN} bash -O extglob -c "mkdir -p ${tmp_moved_stuff_dir} && mv ${volume_dir}/!(tmp-moved-stuff) ${tmp_moved_stuff_dir}"

echo Restoring backup file ${backup_file_path}
${DOCKER_RUN} tar -xvf /backup/${backup_file_name} -C ${volume_dir}
echo Backup restored successfully!

echo Removing temporary moved old data
${DOCKER_RUN} rm -r -f ${tmp_moved_stuff_dir}
