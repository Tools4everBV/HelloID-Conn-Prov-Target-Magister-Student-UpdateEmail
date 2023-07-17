#####################################################
# HelloID-Conn-Prov-Target-Magister-Create-Student-Email
#
# Version: 2.0.0
#####################################################

# Initialize default values
$c = $configuration | ConvertFrom-Json
$p = $person | ConvertFrom-Json
$success = $false
$auditLogs = [System.Collections.Generic.List[PSCustomObject]]::new()

# Set TLS to accept TLS, TLS 1.1 and TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

# Set debug logging
switch ($($c.isDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}
$InformationPreference = "Continue"
$WarningPreference = "Continue"

$magisterFunction = $c.Function;
$magisterLibrary = $c.Library;
$magisterUsername = $c.Username;
$magisterPassword = $c.Password;
$magisterBaseUri = $c.BaseUrl;

#Change mapping here
$account = [PSCustomObject]@{
    StamNr       = $p.ExternalId;
    emailAddress = $p.Accounts.MicrosoftActiveDirectory.userPrincipalName;
}

#region functions
function Resolve-HTTPError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline
        )]
        [object]$ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            FullyQualifiedErrorId = $ErrorObject.FullyQualifiedErrorId
            MyCommand             = $ErrorObject.InvocationInfo.MyCommand
            RequestUri            = $ErrorObject.TargetObject.RequestUri
            ScriptStackTrace      = $ErrorObject.ScriptStackTrace
            ErrorMessage          = ''
        }

        if ($ErrorObject.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') {
            # $httpErrorObj.ErrorMessage = $ErrorObject.ErrorDetails.Message # Does not show the correct error message for the Raet IAM API calls
            $httpErrorObj.ErrorMessage = $ErrorObject.Exception.Message

        }
        elseif ($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException') {
            $httpErrorObj.ErrorMessage = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream()).ReadToEnd()
        }

        Write-Output $httpErrorObj
    }
}

function Get-ErrorMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline
        )]
        [object]$ErrorObject
    )
    process {
        $errorMessage = [PSCustomObject]@{
            VerboseErrorMessage = $null
            AuditErrorMessage   = $null
        }

        if ( $($ErrorObject.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or $($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException')) {
            $httpErrorObject = Resolve-HTTPError -Error $ErrorObject

            $errorMessage.VerboseErrorMessage = $httpErrorObject.ErrorMessage

            $errorMessage.AuditErrorMessage = $httpErrorObject.ErrorMessage
        }

        # If error message empty, fall back on $ex.Exception.Message
        if ([String]::IsNullOrEmpty($errorMessage.VerboseErrorMessage)) {
            $errorMessage.VerboseErrorMessage = $ErrorObject.Exception.Message
        }
        if ([String]::IsNullOrEmpty($errorMessage.AuditErrorMessage)) {
            $errorMessage.AuditErrorMessage = $ErrorObject.Exception.Message
        }

        Write-Output $errorMessage
    }
}
#endregion functions

try {

    # Check if required fields are available for correlation
    $incompleteCorrelationValues = $false
    if ([String]::IsNullOrEmpty($($account.emailAddress))) {
        $incompleteCorrelationValues = $true
        Write-Warning "UPN cannot be empty"
    }
         
    if ($incompleteCorrelationValues -eq $true) {
        throw "UPN cannot be empty"
    }
   
    $uri = "$magisterBaseUri/doc?Function=$magisterFunction&Library=$magisterLibrary&SessionToken=$magisterUsername%3B$magisterPassword&StamNr=$($account.StamNr)&EMail=$($account.emailAddress)";
    Write-Verbose $uri

    if (-Not($dryRun -eq $True)) {
        $response = Invoke-WebRequest -Method POST -Uri $uri -UseBasicParsing
        if ($response.statuscode -eq "200") {
            $success = $True;
            $auditLogs.Add([PSCustomObject]@{
                    Message = "Successfully updated magister student stamNr: [$($account.StamNr)] UPN: [$($account.emailAddress)]"
                    IsError = $false
                })
        }
        else {
            $success = $False;
            $auditLogs.Add([PSCustomObject]@{
                    Message = "Error updating magister student stamNr: [$($account.StamNr)] UPN: [$($account.emailAddress)]"
                    IsError = $true
                })
        }
    }
    else {
        Write-Warning "Dryrun should update stamNr: [$($account.StamNr)] with UPN: [$($account.emailAddress)]"
    }    
}
Catch {
    $ex = $PSItem
    $errorMessage = Get-ErrorMessage -ErrorObject $ex

    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($($errorMessage.VerboseErrorMessage))"

    $auditLogs.Add([PSCustomObject]@{
            Message = "Error updating emailadress. Error Message: $($errorMessage.AuditErrorMessage)"
            IsError = $true
        })     
}

finally {
    # Check if auditLogs contains errors, if no errors are found, set success to true
    if (-NOT($auditLogs.IsError -contains $true)) {
        $success = $true
    }

    # Send results
    $result = [PSCustomObject]@{
        Success          = $success
        AccountReference = $aRef
        AuditLogs        = $auditLogs
        PreviousAccount  = $previousAccount
        Account          = $account

        # Optionally return data for use in other systems
        ExportData       = [PSCustomObject]@{
            StamNr       = $account.StamNr;
            emailAddress = $account.emailAddress;
        }
    }

    Write-Output ($result | ConvertTo-Json -Depth 10)  
}