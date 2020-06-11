#!/usr/bin/env bash

# deploy.sh, describe the network_config.yml
#
# 1. Parameters should be introduced and validate
# 2. Then, it is checked if the stack exists to update or create the stack.

# 1
stack_name=$1
template=$2
parameters=$3
capabilities=CAPABILITY_NAMED_IAM
region=us-west-2


##### validate the parameters
if [ -z $stack_name ] || [ -z $template ] || [ -z $parameters ]
then
    echo
    echo 'Error:  Invalid parameters'
    echo 'Usage:  deploy <stack-name> <template file> <param file>'
    echo
    exit 1
fi

aws cloudformation validate-template --template-body file://$template > /dev/null 2>&1

if [ $? -gt 0 ]
then
    # show the error
    aws cloudformation validate-template --template-body file://$template
    exit 1
else
    echo
    echo "Template $template is valid"
fi


##### check if stack exist
aws cloudformation describe-stacks --stack-name $stack_name > /dev/null 2>&1
response=$?
if [ $response -eq 255 ]
then
    echo
    echo 'Creating stack...'
    cfn_cmd='create-stack'
elif [ $response -eq 0 ]
then
    echo
    echo 'Updating stack...'
    cfn_cmd='update-stack'
else
    echo 'Unknown exception ...exiting!'
    exit 1
fi


##### execute aws command
aws cloudformation $cfn_cmd \
--stack-name $stack_name \
--template-body file://$template \
--parameters file://$parameters \
--region=$region \
--capabilities=$capabilities

if [ $? -eq 0 ]
then
    echo 'Command executed successfully... check AWS console for status.'
fi
echo
echo 'Done.'
echo