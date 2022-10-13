############################################################################################
#Script is getting TFS Service Endpoints of required Team Project and write it to JSON file#
############################################################################################
Param
(
    [Parameter(HelpMessage="Azure DevOps - API Root.")]
    [ValidateNotNullOrEmpty()]
    [string]$API_Root="",  # Azure DevOps collection URL

    [Parameter(HelpMessage="Azure DevOps - Team Project.")]
    [ValidateNotNullOrEmpty()]
    [string]$Team_Project="" # Project name under collection
)

$Date = Get-Date -UFormat "%Y-%m-%d@%H-%M-%S"
$OutputJsonFile="$(pwd)\ServiceEndpoints_$Team_Project_$Date.json"

# Definitions - List
# GET https://dev.azure.com/{organization}/{project}/_apis/build/definitions?name={name}&repositoryId={repositoryId}&repositoryType={repositoryType}&queryOrder={queryOrder}&$top={$top}&continuationToken={continuationToken}&minMetricsTime={minMetricsTime}&definitionIds={definitionIds}&path={path}&builtAfter={builtAfter}&notBuiltAfter={notBuiltAfter}&includeAllProperties={includeAllProperties}&includeLatestBuilds={includeLatestBuilds}&taskIdFilter={taskIdFilter}&processType={processType}&yamlFilename={yamlFilename}&api-version=5.1
$RestAPI = "$API_Root/$Team_Project/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2"

$ServiceEndpoints = Invoke-RestMethod -Uri $RestAPI -Method Get -UseDefaultCredentials -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$ServiceEndpointsContent = $ServiceEndpoints.value | ConvertTo-Json

Write-Host $ServiceEndpointsContent
$ServiceEndpointsContent | Out-File -FilePath $OutputJsonFile -Append
