#!/usr/bin/env bash

set -e

function show_help {
   cat << EOF >&2
Usage: $(basename ${0}) [-h] [-d seconds] [profile]
    -h, --help
        Display this help and exit
    -d seconds, --duration seconds
        Sets how long the temporary credentials are valid for. The default is
        3600 seconds (1 hour).
EOF
   exit 1
}

DURATION=3600
ARGV=''

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -d|--duration)
      DURATION=$2
      shift 2
      ;;
    -*|--*=)
      echo "Error: unknown flag $1" >&2
      exit 1
      ;;
    *)
      ARGV="$ARGV $1"
      shift
      ;;
  esac
done

eval set -- "$ARGV"

REQUESTED_PROFILE="${1}"

if [ -z "${REQUESTED_PROFILE}" ]; then
   show_help
fi

ROLE_ARN=$(aws configure get --profile "${REQUESTED_PROFILE}" role_arn)
SESSION_NAME="$(hostname)-$(id -un)"
SOURCE_PROFILE=$(aws configure get --profile "${REQUESTED_PROFILE}" source_profile)
MFA_SERIAL=$(aws configure get --profile "${REQUESTED_PROFILE}" mfa_serial)

echo "Requested Profile: ${REQUESTED_PROFILE}" >&2
echo "Session Name: ${SESSION_NAME}" >&2
echo "Role ARN: ${ROLE_ARN}" >&2
echo "Source Profile: ${SOURCE_PROFILE}" >&2
echo "MFA: ${MFA_SERIAL}" >&2
echo "Duration: ${DURATION} seconds" >&2
echo "---" >&2

while true; do
   read -p "MFA token: " TOKEN
   case $TOKEN in
      [0-9][0-9][0-9][0-9][0-9][0-9])
         ASSUME_ROLE_RESPONSE=$(
            aws sts assume-role \
               --role-arn "${ROLE_ARN}" \
               --role-session-name "${SESSION_NAME}" \
               --serial-number "${MFA_SERIAL}" \
               --profile "${SOURCE_PROFILE}" \
               --duration "${DURATION}" \
               --token-code "${TOKEN}"
         )
         echo 'export AWS_SECRET_ACCESS_KEY="'$(echo "${ASSUME_ROLE_RESPONSE}" | jq -r '.Credentials.SecretAccessKey')'"'
         echo 'export AWS_ACCESS_KEY_ID="'$(echo "${ASSUME_ROLE_RESPONSE}" | jq -r '.Credentials.AccessKeyId')'"'
         echo 'export AWS_SESSION_TOKEN="'$(echo "${ASSUME_ROLE_RESPONSE}" | jq -r '.Credentials.SessionToken')'"'
         break
         ;;
      *)
         echo 'Please enter a 6 digit MFA token' >&2
         ;;
   esac
done
