#!/bin/bash

# verify that the required Cloud Foundry variables are set
invocation_error=0
# - BXIAM: IBM Cloud API key
if [ -z ${BXIAM+x} ]; then echo 'Error: Environment variable BXIAM is undefined.'; invocation_error=1; fi
# - CF_ORGANIZATION: IBM Cloud/Cloud Foundry organization name
if [ -z ${CF_ORGANIZATION+x} ]; then echo 'Error: Environment variable CF_ORGANIZATION is undefined.'; invocation_error=1; fi
# - CF_SPACE: IBM Cloud/Cluod Foundry space name
if [ -z ${CF_SPACE+x} ]; then echo 'Error: Environment variable CF_SPACE is undefined.'; invocation_error=1; fi
# - APP_NAME: IBM Cloud/Cluod Foundry application name
if [ -z ${APP_NAME+x} ]; then echo 'Error: Environment variable APP_NAME is undefined.'; invocation_error=1; fi

# set optional Cloud Foundry variables if they are not set
# - CF_API: IBM Cloud API endpoint (default to US-South region)
if [ -z ${CF_API+x} ]; then export CF_API='https://api.ng.bluemix.net'; fi

# verify that the required application specific variables are set
# - refer to documentation
if [ -z ${SLACK_BOT_TOKEN+x} ]; then echo 'Error: Environment variable SLACK_BOT_TOKEN is undefined.'; invocation_error=1; fi
if [ -z ${SLACK_CHANNEL_ID+x} ]; then echo 'Error: Environment variable SLACK_CHANNEL_ID is undefined.'; invocation_error=1; fi

if [ ${invocation_error} -eq 1 ]; then echo 'Aborting deployment.'; exit 1; fi

# login and set target
./Bluemix_CLI/bin/bluemix config --check-version false
./Bluemix_CLI/bin/bluemix api $CF_API
./Bluemix_CLI/bin/bluemix login --apikey $BXIAM
./Bluemix_CLI/bin/bluemix target -o $CF_ORGANIZATION -s $CF_SPACE
# push app but don't start it (app start will fail unless the following environment
# variables are defined: CLOUDANT_URL, CLOUDANT_DB and SLACK_TOKEN
./Bluemix_CLI/bin/bluemix cf push $APP_NAME --no-start
# set required environment variables
./Bluemix_CLI/bin/bluemix cf set-env $APP_NAME SLACK_BOT_TOKEN $SLACK_BOT_TOKEN
./Bluemix_CLI/bin/bluemix cf set-env $APP_NAME SLACK_CHANNEL_ID $SLACK_CHANNEL_ID
# start the app
./Bluemix_CLI/bin/bluemix cf start $APP_NAME
