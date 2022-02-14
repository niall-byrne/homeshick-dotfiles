#!/bin/bash

# Protection Against Data Loss

LOCAL_BASE_PATH="/Volumes/RAID A/RAID/Encrypted"
S3_BASE_PATH="s3://backup.niallbyrne.ca"

do_backup() {

  # $1 Directory

  echo "Source: ${LOCAL_BASE_PATH}/${1}"
  echo "Destination: ${S3_BASE_PATH}/${1}"

  aws --profile root s3 cp "${LOCAL_BASE_PATH}/${1}"/* "${S3_BASE_PATH}"/"${1}"/
}

do_help() {
  echo "USAGE: raid_backup.sh [target]"
  echo ""
  echo "Valid Targets:"
  echo "- business"
  echo "- library"
  echo "- personal"
  echo "- photos"
  echo "- videos"
  echo ""

}

main() {

  echo "Backup RAID Disk to S3"

  case $1 in
    business)
      do_backup "Business_Backups"
      ;;
    library)
      do_backup "Library_Backups"
      ;;
    personal)
      do_backup "Personal_Backups"
      ;;
    photos)
      do_backup "Photos_Backups"
      ;;
    videos)
      do_backup "Videos_Backups"
      ;;
    *)
      do_help
      ;;
  esac

}

main "$@"
