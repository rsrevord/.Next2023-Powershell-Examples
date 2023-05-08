<#
 # Purpose:  Get Nutanix Node Details
 # Created by: Kyle Kuhnhenn
 # Contributors/Acknowledgements: Jamison Harwood
 # Modules Required:  
 # Notes:  
 # Modifications: 
 #>




#### declare variables

$allClusters = @("10.10.5.30")
$ntnxcluster = "10.10.5.30"


# Get cluster user
$creds = Get-Credential -Message "Provide the user to gather node info"

<# option for using file with password... for automated tasks...
# NOTE you need to change the $header line...
# create and save credential to file....
# don't use something so obvious if you can avoid it..
$securePasswordFile = "C:\temp\password.txt"
# use to build the password file.
#Read-Host "Enter Password" -AsSecureString |  ConvertFrom-SecureString | Out-File $securePasswordFile
$securePassword = Get-Content $securePasswordFile | ConvertTo-SecureString
$username = "Admin"
#>

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
# use this line if using the password file...
#$Header = @{Authorization = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username + ":" + $securePassword ))}
$Type = "application/json"
$runDate = Get-Date
$allHostDetails = @()
$hostDetails = $null
write-host $cluster
ForEach($cluster in $allClusters){

   # Get Disks
    $uri = "https://"+ $ntnxcluster +":9440/api/nutanix/v2.0/disks/"
    $NTNXDisks = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Header -ContentType $Type -TimeoutSec 30

} # end cluster loop
# output alerts
$NTNXDisks.entities | FT
# each has multiple entries below
foreach ($disk in $NTNXDisks.entities) {
    $disk | select id, storage_tier_name, host_name, disk_status  | FT
}

foreach ($disk in $NTNXDisks.entities) {
    $disk.disk_hardware_config | FT
}