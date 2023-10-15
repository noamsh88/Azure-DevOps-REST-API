# Script get build name and return its latest build artifacts (directory path or URL) using Azure DevOps REST APIs
$buildName = $args[0]

# Script Configurations
[string]$API_Root = "" # Azure DevOps collection URI
[string]$Team_Project = "" # Collection name


# Validate buildName variable value not null
if (!$buildName) {
  $scriptName = $MyInvocation.MyCommand.Name
  Write-Host "Usage:"
  Write-Host "$scriptName <Build Name> "
  Write-Host "e.g."
  Write-Host ".\$scriptName pipeline_name"
  exit 1
}

# Get latest build ID by build name 
#$latestBuildInfo = Execute-RestMethod -Rest_Api "$API_Root/$Team_Project/_apis/build/latest/"$buildName"?api-version=5.1-preview.1" #-UseDefaultCredentials
$Rest_Api = "$API_Root/$Team_Project/_apis/build/latest/$($buildName)?api-version=5.1-preview.1"
$latestBuildInfo = Invoke-RestMethod -Uri $Rest_Api -Method GET -UseDefaultCredentials -ContentType "application/json"
Write-Host "Latest Build Info: `n $latestBuildInfo `n "

$latestBuildID = $latestBuildInfo.id
Write-Host "Build ID: $latestBuildID"

# Get latest build Artifacts info
# GET https://dev.azure.com/{organization}/{project}/_apis/build/builds/{buildId}/artifacts?api-version=5.1
$Rest_Api = "$API_Root/$Team_Project/_apis/build/builds/$($latestBuildID)/artifacts?api-version=5.1"
#Write-Host "`n collect info from: $Rest_Api"
$buildArtifactsInfo = Invoke-RestMethod -Uri $Rest_Api -Method GET -UseDefaultCredentials -ContentType "application/json"
Write-Host "`n Latest $buildName Build Artifacts info: `n  $($buildArtifactsInfo.value.resource) `n"

$buildArtifactsPath = $buildArtifactsInfo.value.resource.downloadUrl

# Check build artifact storage type on Azure DevOps (file or URL)
if ($buildArtifactsPath -like "*file*" ){
   # cut "file:" string to remain with clean artifacts path
  [String]$buildArtifactsPath = $buildArtifactsPath.substring(5)
  }
elseif ($buildArtifactsPath -like "*http*" ){
  $artifactStorageType = "URL"
}


# Print Build URL
Write-Host "Artifacts Storage Type: $artifactStorageType"  # (file or URL)
Write-Host "Build Artifacts Path: $buildArtifactsPath"

# Output variable to Azure DevOps pipeline
Write-Host "##vso[task.setvariable variable=BUILD_ARTIFACTS_PATH;]$buildArtifactsPath"
