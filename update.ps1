#################################################
# HelloID-Conn-Prov-Target-Magister-Student-UpdateEmail-Update
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
    # Verify if [aRef] has a value
    if ([string]::IsNullOrEmpty($($actionContext.References.Account))) {
        throw 'The account reference could not be found'
    }

    if ($null -ne $actionContext.Data.StudentEmailAddress) {
        $action = 'UpdateAccount'
    }
    else {
        $action = 'NoChanges'
    }

    # Process
    switch ($action) {
        'UpdateAccount' {
            if ($null -ne $actionContext.Data.StudentEmailAddress) {
                $uri = "$($actionContext.Configuration.BaseUrl)/doc?Function=UpdateLeerEMail&Library=ADFuncties&SessionToken=$($actionContext.Configuration.UserName)%3B$($actionContext.Configuration.Password)&StamNr=$($actionContext.Data.StamNr)&EMail=$($ActionContext.Data.StudentEmailAddress)"
                $splatCreateParams = @{
                    Uri             = $uri
                    Method          = 'POST'
                    UseBasicParsing = $true
                }

                if (-not($actionContext.DryRun -eq $true)) {
                    Write-Information 'Update Student Email address'
                    $response = Invoke-WebRequest @splatCreateParams
                    if ($response.statuscode -ne "200") {
                        throw "Error $($response.statuscode) when updating Student email address to $($ActionContext.Data.StudentEmailAddress)"
                    }
                }
                else {
                    Write-Information "[DryRun] updating Student email address to $($ActionContext.Data.StudentEmailAddress), will be executed during enforcement"
                }
            }

            $auditLogMessage = "Update account was successful. AccountReference is: [$($outputContext.AccountReference)]"
            $outputContext.success = $true
            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "UpdateAccount"
                    Message = $auditLogMessage
                    IsError = $false
                })
            break
        }

        'NoChanges' {

            Write-Information "No changes to Magister account with accountReference: [$($actionContext.References.Account)]"
            $outputContext.data = $actionContext.Data
            $outputContext.Success = $true
            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Message = 'No changes will be made to the account during enforcement'
                    IsError = $false
                })
            break
        }
    }
}
catch {
    $outputContext.Success = $false
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-MagisterError -ErrorObject $ex
        $auditMessage = "Could not update Magister student account. Error: $($errorObj.FriendlyMessage)"
        Write-Warning "Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
    }
    else {
        $auditMessage = "Could not update Magister student account. Error: $($ex.Exception.Message)"
        Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    }
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
}