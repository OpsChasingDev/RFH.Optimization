# returns list of folders corresponding to SIDs on a machine
# Get-ChildItem 'REGISTRY::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' | Select Name

# returns the username (SamAccountName) and corresponding SID for each user profile on the computer
$VerbosePreference = 'Continue'
$ComputerName = @(
    'sl-computer-001'
    'sl-computer-002'
    'sl-db-01'
    'notonline'
)
$TotalCount = $ComputerName.Count
$RemainingCount = $TotalCount
Write-Output "$TotalCount computers remaining"
Write-Progress -Activity "Checking user library paths..." -Status "Running..." -PercentComplete ((0 / $TotalCount) * 100)

Invoke-Command $ComputerName -ErrorAction SilentlyContinue -AsJob {
    Start-Sleep -Seconds 3
    Write-Output "Done on $env:ComputerName"
} | Out-Null

do {
    # act on each job where the state is Completed and HasMoreData is false (newly completed jobs)
    # receive the job and update the counter
    foreach ($j in (Get-Job -IncludeChildJob | Where-Object { $_.State -eq "Completed" -or $_.State -eq "Failed" -and $_.HasMoreData -eq $true })) {
        Receive-Job -Job $j
        $RemainingCount -= 1
        Write-Output "$RemainingCount computers remaining"
        Write-Progress -Activity "Checking user library paths..." -Status "Running..." -PercentComplete (($RemainingCount / $TotalCount) * 100)
        Write-Verbose "Done checking $($j.Location)"
    }
} while (
    # while a running job exists
    $(Get-Job -IncludeChildJob | Where-Object { $_.State -eq "Running" })
)

# clean up parent job
Get-Job | Where-Object { $_.State -eq "Completed" -or $_.State -eq "Failed" } | Remove-Job