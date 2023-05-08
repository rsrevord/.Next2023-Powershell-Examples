<#
 # Purpose:  Get online offline status
 # Created by: Kyle Kuhnhenn
 # Contributors/Acknowledgements: Jamison Harwood, Ryan Revord
 # Modules Required:  
 # Notes:  
 # Modifications: 
 #>

 #### declare variables

$allClusters = @("10.10.5.30")
# Get cluster user
$creds = Get-Credential -Message "Provide the user to gather node info"

# Self-Signed Certs
try
    {
        Write-Host "Adding TrustAllCertsPolicy type." -ForegroundColor White
        Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy
        {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem)
             {
                 return true;
            }
        }
"@
        Write-Host "TrustAllCertsPolicy type added." -ForegroundColor White
      }
    catch
    {
       # Write-Host $_ -ForegroundColor "Yellow"
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# End Self-Signed Certs

# setup header
$Header = @{Authorization = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($creds.UserName + ":" + $creds.GetNetworkCredential().Password ))}
$Type = "application/json"
$runDate = Get-Date
$allHostDetails = @()
$hostDetails = $null
write-host $cluster

ForEach($cluster in $allClusters){
    # Get Hosts
    # using V1 API for this example since i can't find its equiv in V2...
    $uri = "https://"+ $ntnxcluster +":9440/PrismGateway/services/rest/v1/disks/"
    $NTNXDisks = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Header -ContentType $Type -TimeoutSec 30

} # end cluster loop
    # $NTNXDisks.entities by itself returns the entire output similar to RestAPI Exploerer.
    # from there we can eumberate it in various output filters to see data. 
    #$NTNXDisks.entities | Select NodeName, Online
