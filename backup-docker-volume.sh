#/usr/bin/env bash

set -e

volumes_from=pg-stage
volume_dir=/var/lib/postgresql/data
backups_dir=$(pwd)/backup
backup_file_prefix=pg-staging

backup_file_name="${backup_file_prefix}-`date +%Y-%m-%dT%H-%M-%SZ --utc`"

BACKUP_CMD="tar --totals -z -C ${volume_dir} -cf /backup/${backup_file_name}.tar.gz ."

echo Starting backup of "${volumes_from}" volumes
echo - volume dir "${volume_dir}"
echo - backup will be written to: "${backups_dir}/${backup_file_name}"
docker run -it --rm --volumes-from ${volumes_from} -v ${backups_dir}:/backup ubuntu ${BACKUP_CMD}
