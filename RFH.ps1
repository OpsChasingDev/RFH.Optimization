<#
- each machine has the following logic invoked:
    - checks the registry to collect all currently logged in users
    - checks each logged in user's libraries
    - returns a psobject containing members to describe:
        - ComputerName
        - User
        - library path value
#>

# returns a list of SIDs belonging to only the users logged in (includes domain admin)
$User_LoggedIn = (Get-ChildItem "REGISTRY::HKU\" -ErrorAction SilentlyContinue |
    Where-Object {$_.Name.Length -gt 25 -and $_.Name -notlike '*_Classes'}).Name
$User_LoggedIn = $User_LoggedIn | ForEach-Object {$_.Split('\')[1]}

# get usernames for each SID found on the computer for comparison later
$SID = Get-ChildItem 'REGISTRY::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' | Select-Object -ExpandProperty Name
$Col_SID = @()
foreach ($s in $SID) {
    $Prof = Get-ItemProperty -Path "REGISTRY::$s" -Name "ProfileImagePath"
    $User = ($Prof.ProfileImagePath.ToString()).Split('\')[-1]
    $obj = [PSCustomObject]@{
        UserSID = $Prof.PSChildName
        UserName = $User
    }
    $Col_SID += $obj
}
Write-Output $Col_SID

# match each returned SID with its corresponding username