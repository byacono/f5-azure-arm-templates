#!/bin/bash

## Bash Script to deploy an F5 ARM template into Azure, using azure cli 1.0 ##
## Example Command: ./deploy_via_bash.sh --vmScaleSetMinCount 2 --vmScaleSetMaxCount 4 --autoScaleMetric F5_TMM_Traffic --appInsights CREATE_NEW --calculatedBandwidth 200m --scaleOutThreshold 90 --scaleInThreshold 10 --scaleTimeWindow 10 --adminUsername azureuser --authenticationType password --adminPasswordOrKey <value> --dnsLabel <value> --instanceType Standard_DS2_v2 --imageName Best --bigIpVersion 13.1.100000 --licensedBandwidth 200m --vnetAddressPrefix 10.0 --dnsMemberIpType private --dnsMemberPort 80 --dnsProviderHost <value> --dnsProviderPort 443 --dnsProviderUser <value> --dnsProviderPassword <value> --dnsProviderPool autoscale_pool --dnsProviderDataCenter azure_datacenter --tenantId <value> --clientId <value> --servicePrincipalSecret <value> --notificationEmail OPTIONAL --ntpServer 0.pool.ntp.org --timeZone UTC --customImage OPTIONAL --allowUsageAnalytics Yes --resourceGroupName <value> --azureLoginUser <value> --azureLoginPassword <value>

# Assign Script Parameters and Define Variables
# Specify static items below, change these as needed or make them parameters
region="westus"
restrictedSrcAddress="*"
tagValues='{"application":"APP","environment":"ENV","group":"GROUP","owner":"OWNER","cost":"COST"}'

# Parse the command line arguments, primarily checking full params as short params are just placeholders
while [[ $# -gt 1 ]]; do
    case "$1" in
        --vmScaleSetMinCount)
            vmScaleSetMinCount=$2
            shift 2;;
        --vmScaleSetMaxCount)
            vmScaleSetMaxCount=$2
            shift 2;;
        --autoScaleMetric)
            autoScaleMetric=$2
            shift 2;;
        --appInsights)
            appInsights=$2
            shift 2;;
        --calculatedBandwidth)
            calculatedBandwidth=$2
            shift 2;;
        --scaleOutThreshold)
            scaleOutThreshold=$2
            shift 2;;
        --scaleInThreshold)
            scaleInThreshold=$2
            shift 2;;
        --scaleTimeWindow)
            scaleTimeWindow=$2
            shift 2;;
        --adminUsername)
            adminUsername=$2
            shift 2;;
        --authenticationType)
            authenticationType=$2
            shift 2;;
        --adminPasswordOrKey)
            adminPasswordOrKey=$2
            shift 2;;
        --dnsLabel)
            dnsLabel=$2
            shift 2;;
        --instanceType)
            instanceType=$2
            shift 2;;
        --imageName)
            imageName=$2
            shift 2;;
        --bigIpVersion)
            bigIpVersion=$2
            shift 2;;
        --licensedBandwidth)
            licensedBandwidth=$2
            shift 2;;
        --vnetAddressPrefix)
            vnetAddressPrefix=$2
            shift 2;;
        --dnsMemberIpType)
            dnsMemberIpType=$2
            shift 2;;
        --dnsMemberPort)
            dnsMemberPort=$2
            shift 2;;
        --dnsProviderHost)
            dnsProviderHost=$2
            shift 2;;
        --dnsProviderPort)
            dnsProviderPort=$2
            shift 2;;
        --dnsProviderUser)
            dnsProviderUser=$2
            shift 2;;
        --dnsProviderPassword)
            dnsProviderPassword=$2
            shift 2;;
        --dnsProviderPool)
            dnsProviderPool=$2
            shift 2;;
        --dnsProviderDataCenter)
            dnsProviderDataCenter=$2
            shift 2;;
        --tenantId)
            tenantId=$2
            shift 2;;
        --clientId)
            clientId=$2
            shift 2;;
        --servicePrincipalSecret)
            servicePrincipalSecret=$2
            shift 2;;
        --notificationEmail)
            notificationEmail=$2
            shift 2;;
        --ntpServer)
            ntpServer=$2
            shift 2;;
        --timeZone)
            timeZone=$2
            shift 2;;
        --customImage)
            customImage=$2
            shift 2;;
        --restrictedSrcAddress)
            restrictedSrcAddress=$2
            shift 2;;
        --tagValues)
            tagValues=$2
            shift 2;;
        --allowUsageAnalytics)
            allowUsageAnalytics=$2
            shift 2;;
        --resourceGroupName)
            resourceGroupName=$2
            shift 2;;
        --region)
            region=$2
            shift 2;;
        --azureLoginUser)
            azureLoginUser=$2
            shift 2;;
        --azureLoginPassword)
            azureLoginPassword=$2
            shift 2;;
        --)
            shift
            break;;
    esac
done

#If a required parameter is not passed, the script will prompt for it below
required_variables="vmScaleSetMinCount vmScaleSetMaxCount autoScaleMetric appInsights calculatedBandwidth scaleOutThreshold scaleInThreshold scaleTimeWindow adminUsername authenticationType adminPasswordOrKey dnsLabel instanceType imageName bigIpVersion licensedBandwidth vnetAddressPrefix dnsMemberIpType dnsMemberPort dnsProviderHost dnsProviderPort dnsProviderUser dnsProviderPassword dnsProviderPool dnsProviderDataCenter tenantId clientId servicePrincipalSecret notificationEmail ntpServer timeZone customImage allowUsageAnalytics resourceGroupName "
for variable in $required_variables
        do
        if [ -z ${!variable} ] ; then
                read -p "Please enter value for $variable:" $variable
        fi
done

echo "Disclaimer: Scripting to Deploy F5 Solution templates into Cloud Environments are provided as examples. They will be treated as best effort for issues that occur, feedback is encouraged."
sleep 3

# Login to Azure, for simplicity in this example using username and password supplied as script arguments --azureLoginUser and --azureLoginPassword
# Perform Check to see if already logged in
azure account show > /dev/null 2>&1
if [[ $? != 0 ]] ; then
        azure login -u $azureLoginUser -p $azureLoginPassword
fi

# Switch to ARM mode
azure config mode arm

# Create ARM Group
azure group create -n $resourceGroupName -l $region

# Deploy ARM Template, right now cannot specify parameter file and parameters inline via Azure CLI
template_file="./azuredeploy.json"
parameter_file="./azuredeploy.parameters.json"
azure group deployment create -f $template_file -g $resourceGroupName -n $resourceGroupName -p "{\"vmScaleSetMinCount\":{\"value\":$vmScaleSetMinCount},\"vmScaleSetMaxCount\":{\"value\":$vmScaleSetMaxCount},\"autoScaleMetric\":{\"value\":\"$autoScaleMetric\"},\"appInsights\":{\"value\":\"$appInsights\"},\"calculatedBandwidth\":{\"value\":\"$calculatedBandwidth\"},\"scaleOutThreshold\":{\"value\":$scaleOutThreshold},\"scaleInThreshold\":{\"value\":$scaleInThreshold},\"scaleTimeWindow\":{\"value\":$scaleTimeWindow},\"adminUsername\":{\"value\":\"$adminUsername\"},\"authenticationType\":{\"value\":\"$authenticationType\"},\"adminPasswordOrKey\":{\"value\":\"$adminPasswordOrKey\"},\"dnsLabel\":{\"value\":\"$dnsLabel\"},\"instanceType\":{\"value\":\"$instanceType\"},\"imageName\":{\"value\":\"$imageName\"},\"bigIpVersion\":{\"value\":\"$bigIpVersion\"},\"licensedBandwidth\":{\"value\":\"$licensedBandwidth\"},\"vnetAddressPrefix\":{\"value\":\"$vnetAddressPrefix\"},\"dnsMemberIpType\":{\"value\":\"$dnsMemberIpType\"},\"dnsMemberPort\":{\"value\":\"$dnsMemberPort\"},\"dnsProviderHost\":{\"value\":\"$dnsProviderHost\"},\"dnsProviderPort\":{\"value\":\"$dnsProviderPort\"},\"dnsProviderUser\":{\"value\":\"$dnsProviderUser\"},\"dnsProviderPassword\":{\"value\":\"$dnsProviderPassword\"},\"dnsProviderPool\":{\"value\":\"$dnsProviderPool\"},\"dnsProviderDataCenter\":{\"value\":\"$dnsProviderDataCenter\"},\"tenantId\":{\"value\":\"$tenantId\"},\"clientId\":{\"value\":\"$clientId\"},\"servicePrincipalSecret\":{\"value\":\"$servicePrincipalSecret\"},\"notificationEmail\":{\"value\":\"$notificationEmail\"},\"ntpServer\":{\"value\":\"$ntpServer\"},\"timeZone\":{\"value\":\"$timeZone\"},\"customImage\":{\"value\":\"$customImage\"},\"restrictedSrcAddress\":{\"value\":\"$restrictedSrcAddress\"},\"tagValues\":{\"value\":$tagValues},\"allowUsageAnalytics\":{\"value\":\"$allowUsageAnalytics\"}}"