# Set of backup scripts

Set of scripts to manage backups

## Backup docker volume

```backup-docker-volume.sh -f pg-stage -d /var/lib/postgresql/data -p pg-stage'```

See ```backup-docker-volume.sh -h``` for more details

## Restore docker volume

```./restore-docker-volume.sh -f pg-stage -d /var/lib/postgresql/data -b ./backup/pg-stage-2017-02-18T15-08-19Z.tar.gz```

See ```restore-docker-volume.sh -h``` for more details
