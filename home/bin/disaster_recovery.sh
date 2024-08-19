#!/bin/bash

# Protection Against Data Loss

LOCAL_BACKUPS_BASE_PATH="/Volumes/SSH/backups"
RAID_BASE_PATH="/Volumes/RAID A/RAID"
S3_BACKUP_BUCKET="s3://backup.niallbyrne.ca"
S3_MEDIA_BUCKET="s3://media.niallbyrne.ca"

RAID_ENCRYPTED_BASE_PATH="${RAID_BASE_PATH}/EncryptedBackups"

do_backup() {
  # $1 File System Path
  # $2 Bucket Path
  # $3 Optionally delete remote files that do not exist locally.

  echo -e "Source:\t\t${1}"
  echo -e "Destination:\t${2}"

  local ARGS
  if [[ -z "${3}" ]]; then
    ARGS=("${1}" "${2}")
    echo -e "Delete:\t\tDISABLED"
  else
    ARGS=("--delete" "${1}" "${2}")
    echo -e "Delete:\t\tENABLED"
  fi

  do_prune_file_system "${1}"
  aws --profile backup s3 sync "${ARGS[@]}"
}

do_help() {
  echo "USAGE: s3_data_backup.sh [target]"
  echo ""
  echo "Valid Targets:"
  echo "- all"
  echo "- business"
  echo "- library"
  echo "- obsidian"
  echo "- personal"
  echo "- photos"
  echo "- music"
  echo "- videos"
  echo ""
}

do_macro_all() {
  main "anki"
  main "business"
  main "library"
  main "music"
  main "obsidian"
  main "personal"
  main "photos"
  main "videos"
}

do_prune_file_system() {
  # $1 File System Path

  find "${1}" -name ".DS_Store" -delete
}

main() {
  case $1 in
    all)
      do_macro_all
      ;;
  	anki)
      do_backup "${LOCAL_BACKUPS_BASE_PATH}/anki" "${S3_BACKUP_BUCKET}/Anki_Backups" "--delete"
      ;;
    business)
      do_backup "${RAID_ENCRYPTED_BASE_PATH}/Business_Backups" "${S3_BACKUP_BUCKET}/Business_Backups/"
      ;;
    library)
      do_backup "${RAID_ENCRYPTED_BASE_PATH}/Library_Backups" "${S3_BACKUP_BUCKET}/Library_Backups"
      ;;
	  music)
	    do_backup "${RAID_BASE_PATH}/Music" "${S3_MEDIA_BUCKET}/Music"
	    ;;
  	obsidian)
      do_backup "${LOCAL_BACKUPS_BASE_PATH}/obsidian" "${S3_BACKUP_BUCKET}/Obsidian_Backups" "--delete"
      ;;
    personal)
      do_backup "${RAID_ENCRYPTED_BASE_PATH}/Personal_Backups" "${S3_BACKUP_BUCKET}/Personal_Backups"
      ;;
    photos)
      do_backup "${RAID_ENCRYPTED_BASE_PATH}/Photos_Backups" "${S3_BACKUP_BUCKET}/Photos_Backups"
      ;;
    videos)
      do_backup "${RAID_ENCRYPTED_BASE_PATH}/Videos_Backups" "${S3_BACKUP_BUCKET}/Videos_Backups"
      ;;
    *)
      do_help
      ;;
  esac
}

echo "Backup Data to S3"
main "$@"
