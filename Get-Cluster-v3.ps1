<#
 # Purpose:  Get Nutanix Node Details
 # Created by: Kyle Kuhnhenn
 # Contributors/Acknowledgements: Jamison Harwood, Ryan Revord
 # Modules Required:  None at this time.
 # Notes:  
 # Modifications: 
 # Change log:
 # 
 #>


###################################
# Variables: 
###################################
# array of clusters, exampel @("10.10.10.1","10.10.10.2","10.10.10.3"), or as shown can use just with a single.
$allClusters = @("10.10.5.30")


<# 
# Get cluster user, because hard coding credz in SCRIPTS ARE BAD!!!!
# create and save credential to file....
# don't use something so obvious if you can avoid it..
$securePasswordFile = "C:\temp\password.txt"

# use to build the password file.
#Read-Host "Enter Password" -AsSecureString |  ConvertFrom-SecureString | Out-File $securePasswordFile

$securePassword = Get-Content $securePasswordFile | ConvertTo-SecureString
$userName = "Admin"

$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $securePassword
#>

# Get cluster user, because hard coding credz in SCRIPTS ARE BAD!!!!
$creds = Get-Credential -Message "Provide the user to gather node info"


###################################
#Forces powershell/.net to TLS 1.2
###################################
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

###################################
# Self-Signed Certs, REPLACE your DEFAULT CERT!!!!
###################################
try {
        Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem) {
                 return true;
            }
        }
"@
} catch {
        #Write-Host $_ -ForegroundColor "Yellow"
}
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
###################################
# End Self-Signed Certs
###################################

###################################
# setup header
###################################
$Header = @{Authorization = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($creds.UserName + ":" + $creds.GetNetworkCredential().Password ))}
$Type = "application/json"
###################################
# end header config
###################################

#Cluster Loop, we don't have to loop just makes it more useful to have this setup.
ForEach($cluster in $allClusters){

    # this is where we put the API call we figured out we want from the API Explorer...
    #$apiURI = "/api/nutanix/v2.0/alerts/"
    #$apiURI = "/PrismGateway/services/rest/v2.0/alerts/"
    #$apiURI = "/PrismGateway/services/rest/v2.0/disks/"
    $apiURI = "/PrismGateway/services/rest/v2.0/cluster/"

    $uri = "https://"+ $cluster +":9440" + $apiURI
    
    $NTNX=Invoke-RestMethod -Method Get -Uri $Uri -Headers $Header -ContentType $Type -TimeoutSec 30
} # end cluster loop

#output our hard work
#$NTNX
