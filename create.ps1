#################################################
# HelloID-Conn-Prov-Target-Magister-Student-UpdateEmail-Create
# PowerShell V2
#################################################

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region functions
function Resolve-MagisterError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            ScriptLineNumber = $ErrorObject.InvocationInfo.ScriptLineNumber
            Line             = $ErrorObject.InvocationInfo.Line
            ErrorDetails     = $ErrorObject.Exception.Message
            FriendlyMessage  = $ErrorObject.Exception.Message
        }
        if (-not [string]::IsNullOrEmpty($ErrorObject.ErrorDetails.Message)) {
            $httpErrorObj.ErrorDetails = $ErrorObject.ErrorDetails.Message
        }
        elseif ($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException') {
            if ($null -ne $ErrorObject.Exception.Response) {
                $streamReaderResponse = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream()).ReadToEnd()
                if (-not [string]::IsNullOrEmpty($streamReaderResponse)) {
                    $httpErrorObj.ErrorDetails = $streamReaderResponse
                }
            }
        }
        try {
            $errorDetailsObject = ($httpErrorObj.ErrorDetails | ConvertFrom-Json)
            # Make sure to inspect the error result object and add only the error message as a FriendlyMessage.
            # $httpErrorObj.FriendlyMessage = $errorDetailsObject.message
            $httpErrorObj.FriendlyMessage = $httpErrorObj.ErrorDetails # Temporarily assignment
        }
        catch {
            $httpErrorObj.FriendlyMessage = $httpErrorObj.ErrorDetails
        }
        Write-Output $httpErrorObj
    }
}
#endregion

try {

    $outputContext.AccountReference = $actionContext.Data.StamNr

    # process

    if ($null -ne $actionContext.Data.StudentEmailAddress) {
        $uri = "$magisterBaseUri/doc?Function=UpdateLeerEMail&Library=ADFuncties&SessionToken=$($actionContext.Configuration.UserName)%3B$($actionContext.Configuration.Password)&StamNr=$($actionContext.Data.StamNr)&EMail=$($ActionContext.Data.StudentEmailAddress)"
        $splatCreateParams = @{
            Uri             = $uri
            Method          = 'POST'
            UseBasicParsing = $true
        }

        if (-not($actionContext.DryRun -eq $true)) {
            Write-Information 'Creating Student Email address'
            $response = Invoke-RestMethod @splatCreateParams
            if ($response.statuscode -ne "200") {
                throw "Error $($response.statuscode) when creating student email address $($ActionContext.Data.StudentEmailAddress)"
            }
        }
        else {
            Write-Information '[DryRun] setting Student Email address to $($ActionContext.Data.StudentEmailAddress), will be executed during enforcement'
        }
    }

    $auditLogMessage = "Create student email address for account was successful. AccountReference is: [$($outputContext.AccountReference)]"
    $outputContext.success = $true
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = $action
            Message = $auditLogMessage
            IsError = $false
        })
    break
}

catch {
    $outputContext.success = $false
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-MagisterError -ErrorObject $ex
        $auditMessage = "Could not create email address for Magister student account. Error: $($errorObj.FriendlyMessage)"
        Write-Warning "Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
    }
    else {
        $auditMessage = "Could not create email addres for Magister student account. Error: $($ex.Exception.Message)"
        Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    }
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
}