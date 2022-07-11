# returns list of folders corresponding to SIDs on a machine
# Get-ChildItem 'REGISTRY::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' | Select Name

# returns the username (SamAccountName) and corresponding SID for each user profile on the computer
$ComputerName = 'sl-computer-001','sl-computer-002','sl-db-01','notonline'
$TotalCount = $ComputerName.Count
Write-Output $TotalCount

Invoke-Command $ComputerName -ErrorAction SilentlyContinue -AsJob {
    Start-Sleep -Seconds 3
    Write-Output "Done on $env:ComputerName"
}

do {
    # act on each job where the state is Completed and HasMoreData is false (newly completed jobs)
    # receive the job and update the counter
    foreach ($j in (Get-Job -IncludeChildJob | Where-Object { $_.State -eq "Completed" -or $_.State -eq "Failed" -and $_.HasMoreData -eq $true })) {
        Receive-Job -Job $j
        $TotalCount -= 1
        Write-Output $TotalCount
        Write-Verbose "Done checking $($j.Location)"
    }
} while (
    # while a running job exists
    $(Get-Job -IncludeChildJob | Where-Object { $_.State -eq "Running" })
)

# clean up parent job
Get-Job | Where-Object { $_.State -eq "Completed" -or $_.State -eq "Failed" } | Remove-Job