########################################################################################################
#Script is creating SSH Service Endpoint to remote server on TFS and granting pipeline permission to it#
########################################################################################################
$UnixAccountName = $args[0]
$HostIP = $args[1]
########################################################################################################
[string]$API_Root="" # Azure DevOps collection URL
[string]$Team_Project="" # Project name under collection
[string]$sshServiceEndpointName="$UnixAccountName.$HostIP"
########################################################################################################

#Validate if arguments entered is not null
if (!$UnixAccountName -Or !$HostIP) {
  $scriptName = $MyInvocation.MyCommand.Name
  Write-Host "Usage:"
  Write-Host "pwsh $scriptName <Unix Account Name> <Host IP Address>"
  Write-Host "e.g."
  Write-Host "pwsh $scriptName pmc 1**.**.***.**5"
  exit 1
}

# Set rest API for service endpoint creation
$RestAPI = "$API_Root/$Team_Project/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2"

# Create JSON Body for the SSH Service Definition
function CreateJsonBody
{
    $value = @"
    {
        "administratorsGroup": null,
        "authorization": {
            "scheme": "UsernamePassword",
            "parameters": {
                "username": "$UnixAccountName",
                "password": "$UnixAccountName"
            }
        },
        "createdBy": null,
        "data": {
            "Host": "$HostIP",
            "Port": "22"
        },
        "description": "",
        "groupScopeId": null,
        "name": "$sshServiceEndpointName",
        "operationStatus": null,
        "readersGroup": null,
        "serviceEndpointProjectReferences": [
            {
                "description": "SSH Test",
                "name": "SSH Test",
                "projectReference": {
                    "id": "901f7f54-f0b1-40cb-8b6c-f82d590b0838",
                    "name": "Test0924"
                }
            }
        ],
        "type": "ssh",
        "url": "",
        "isShared": false,
        "owner": "library"
    }
"@

 return $value
}
$json = CreateJsonBody

# Create SSH Service Endpoint on TFS
$result = Invoke-RestMethod -Uri $RestAPI -Method POST -UseDefaultCredentials -Body $json -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

#Grant pipeline permissions
$endpointid = $result.id
function CreateJsonBody
{

    $value = @"
    {
        "resource": {
            "id": "$endpointid",
            "type": "endpoint",
            "name": ""
        },
        "pipelines": [],
        "allPipelines": {
            "authorized": true,
            "authorizedBy": null,
            "authorizedOn": null
        }
    }
"@

 return $value
}
$json = CreateJsonBody

$permissionurl = "$API_Root/$Team_Project/_apis/pipelines/pipelinePermissions/endpoint/$($endpointid)?api-version=5.1-preview.1"
Write-Host "permissionurl:"$permission
Invoke-RestMethod -Uri $permissionurl -Method PATCH -UseDefaultCredentials -Body $json -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
