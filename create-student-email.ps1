#Config
$c = $configuration | ConvertFrom-Json
$user = $c.user;
$magisterBaseUri = "";
$pass = $c.pass;
$tenant = $c.tenant
#$magisterFunction = "UpdateLeerEMail";
$magisterFunction=$c.function;
#$magisterLibrary = "ADFuncties";
$magisterLibrary = $c.library;
$magisterUsername = $c.user;
$magisterPassword = $pass;


#Enable TLS 1.2
if ([Net.ServicePointManager]::SecurityProtocol -notmatch "Tls12") {
    [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
}

#Initialize default properties
$p = $person | ConvertFrom-Json;
$stamNr = $p.ExternalId;
$aRef = $p.ExternalId;
$success = $False;
$auditMessage = "";

#Read UPN from AD, change to the correct source
$userPrincipalName = $p.Accounts.MicrosoftActiveDirectoryLeerlingen.userPrincipalName;

#Change Magister Base URI based on location code
$locationCode = $p.PrimaryContract.Location.Code;
$magisterBaseUri = "https://$tenant.swp.nl:8800";

if ($magisterBaseUri -eq "nvt"  ) {
    $auditMessage = "User is not in Magister, skipping update..."
    $success = $False;

    #build up result
    $result = [PSCustomObject]@{
        Success          = $success;
        AccountReference = $aRef;
        AuditDetails     = $auditMessage;
        Account          = $account;
    };

    Write-Output $result | ConvertTo-Json -Depth 10;
    exit
}

#Create account object
$account = [PSCustomObject]@{
    'ref'   = $p.ExternalId
    'email' = $userPrincipalName
    'locationCode' = $locationCode
}

if ([String]::IsNullOrEmpty($userPrincipalName)  ) {
    $auditMessage = "AD UPN empty, skipping update..."
    $success = $False;

    #build up result
    $result = [PSCustomObject]@{
        Success          = $success;
        AccountReference = $aRef;
        AuditDetails     = $auditMessage;
        Account          = $account;
    };

    Write-Output $result | ConvertTo-Json -Depth 10;
    exit
}

# Compose update uri
$uri = "$magisterBaseUri/doc?Function=$magisterFunction&Library=$magisterLibrary&SessionToken=$magisterUsername%3B$magisterPassword&StamNr=$stamNr&EMail=$userPrincipalName";

Write-Verbose $uri -Verbose

try {
    if (-Not($dryRun -eq $True)) {
        $response = Invoke-WebRequest -Method POST -Uri $uri -UseBasicParsing
        if ($response.statuscode -eq "200") {
            $success = $True;
            $auditMessage = "Email address updated";
        } else {
            $success = $False;
            $auditMessage = "Update failed: $reponse";
        }
    }
}
catch {
    $errResponse = $_;
    $auditMessage = "Update failed: ${errResponse}";
}
#build up result
$result = [PSCustomObject]@{
    Success          = $success;
    AccountReference = $aRef;
    AuditDetails     = $auditMessage;
    Account          = $account;
};

Write-Output $result | ConvertTo-Json -Depth 10;