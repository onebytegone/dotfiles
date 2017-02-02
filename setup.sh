#!/bin/bash

HOME_DIR=$(echo ~)
MYCLI_DIR=$(cd `dirname $0` && pwd)

echo "STARTUP: Setting up config in: ${HOME_DIR}"
echo "STARTUP: Will link to: ${MYCLI_DIR}"

#################################################
# Create symlinks for config
#################################################

function create_config_link {
   CONFIG_FILE=$1
   CONFIG_SOURCE=$2
   echo "INFO: Linking: ${CONFIG_FILE}"
   if [ -h $CONFIG_FILE ]; then
      echo "WARNING: '${CONFIG_FILE}' already seems to be symlinked, taking no action."
   elif [ -f $CONFIG_FILE ]; then
      echo "ERROR: A config file already exists at '${CONFIG_FILE}', taking no action."
   else
      echo "INFO: Creating symlink to: ${CONFIG_SOURCE}"
      ln -s "${CONFIG_SOURCE}" "${CONFIG_FILE}"
   fi
}

create_config_link "${HOME_DIR}/.vimrc" "${MYCLI_DIR}/config/vimrc"


#################################################
# Create import for gitconfig
#################################################

if [[ $(git config --global include.path) ]]; then
   echo "WARNING: It appears that the git config already has a include, taking no action"
else
   echo "INFO: Adding include to global git config"
   git config --global include.path "${MYCLI_DIR}/config/gitconfig"
fi
