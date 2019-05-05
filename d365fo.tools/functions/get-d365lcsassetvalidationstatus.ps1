﻿
<#
    .SYNOPSIS
        Get the validation status from LCS
        
    .DESCRIPTION
        Get the validation status for a given file in the Asset Library in LCS
        
    .PARAMETER ProjectId
        The project id for the Dynamics 365 for Finance & Operations project inside LCS
        
        Default value can be configured using Set-D365LcsApiConfig
        
    .PARAMETER BearerToken
        The token you want to use when working against the LCS api
        
        Default value can be configured using Set-D365LcsApiConfig
        
    .PARAMETER AssetId
        The unique id of the asset / file that you are trying to deploy from LCS
        
    .PARAMETER LcsApiUri
        URI / URL to the LCS API you want to use
        
        Default value can be configured using Set-D365LcsApiConfig
        
    .PARAMETER WaitForValidation
        Instruct the cmdlet to wait for the validation process to complete
        
        The cmdlet will sleep for 60 seconds, before requesting the status of the validation process from LCS
        
    .EXAMPLE
        PS C:\> Get-D365LcsAssetValidationStatus -ProjectId 123456789 -BearerToken "sdaflkja21jlkfjfdsa" -AssetId "958ae597-f089-4811-abbd-c1190917eaae" -LcsApiUri "https://lcsapi.lcs.dynamics.com"
        
        This will check the validation status for the file in the Asset Library.
        The LCS project is identified by the ProjectId 123456789, which can be obtained in the LCS portal.
        The file is identified by the AssetId "958ae597-f089-4811-abbd-c1190917eaae", which is obtained either by earlier upload or simply looking in the LCS portal.
        The request will authenticate with the BearerToken "Bearer JldjfafLJdfjlfsalfd...".
        The http request will be going to the LcsApiUri "https://lcsapi.lcs.dynamics.com" (NON-EUROPE).
        
    .EXAMPLE
        PS C:\> Get-D365LcsAssetValidationStatus -AssetId "958ae597-f089-4811-abbd-c1190917eaae"
        
        This will start the deployment of the file located in the Asset Library.
        The file is identified by the AssetId "958ae597-f089-4811-abbd-c1190917eaae", which is obtained either by earlier upload or simply looking in the LCS portal.
        
        All default values will come from the configuration available from Get-D365LcsApiConfig.
        
    .LINK
        Get-D365LcsApiConfig
        
    .LINK
        Get-D365LcsApiToken
        
    .LINK
        Get-D365LcsDeploymentStatus
        
    .LINK
        Invoke-D365LcsApiRefreshToken
        
    .LINK
        Invoke-D365LcsDeployment
        
    .LINK
        Invoke-D365LcsUpload
        
    .LINK
        Set-D365LcsApiConfig
        
    .NOTES
        Author: Mötz Jensen (@Splaxi)
        
#>

function Get-D365LcsAssetValidationStatus {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $false)]
        [int] $ProjectId = $Script:LcsApiProjectId,
        
        [Parameter(Mandatory = $false)]
        [Alias('Token')]
        [string] $BearerToken = $Script:LcsApiBearerToken,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 3)]
        [string] $AssetId,

        [Parameter(Mandatory = $false)]
        [string] $LcsApiUri = $Script:LcsApiLcsApiUri,

        [switch] $WaitForValidation
    )

    if (-not ($BearerToken.StartsWith("Bearer "))) {
        $BearerToken = "Bearer $BearerToken"
    }

    do {
        Write-PSFMessage -Level Verbose -Message "Sleeping before hitting the LCS API for Asset Validation Status"
        Start-Sleep -Seconds 60
        $status = Get-LcsAssetValidationStatus -BearerToken $BearerToken -ProjectId $ProjectId -AssetId $AssetId -LcsApiUri $LcsApiUri
    }
    while (($status.DisplayStatus -eq "Process") -and $WaitForValidation)

    $status | Select-PSFObject "ID as AssetId", "DisplayStatus as Status"
}