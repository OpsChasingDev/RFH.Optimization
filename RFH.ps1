<#

#>

# stores a list of SIDs belonging to only the users logged in (includes domain admin)
$User_LoggedIn = (Get-ChildItem "REGISTRY::HKU\" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name.Length -gt 25 -and $_.Name -notlike '*_Classes' }).Name
$User_LoggedIn = $User_LoggedIn | ForEach-Object { $_.Split('\')[1] }

# store usernames for each SID found on the computer in a custom object collection for comparison later
$SID = Get-ChildItem 'REGISTRY::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' | Select-Object -ExpandProperty Name
$Col_SID = @()
foreach ($s in $SID) {
    $Prof = Get-ItemProperty -Path "REGISTRY::$s" -Name "ProfileImagePath"
    $User = ($Prof.ProfileImagePath.ToString()).Split('\')[-1]
    $obj = [PSCustomObject]@{
        UserSID  = $Prof.PSChildName
        UserName = $User
    }
    if ($obj.UserSID.Length -gt 25 -and $User_LoggedIn -contains $obj.UserSID) {
        $Col_SID += $obj
    }
}

# foreach logged in user, return value of the Desktop path
foreach ($s in $Col_SID) {
    $DesktopPathSplat = @{
        Path = "REGISTRY::HKU\$($s.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
        Name = "Desktop"
        ErrorAction = "SilentlyContinue"
    }
    $DesktopPath = (Get-ItemProperty @DesktopPathSplat).Desktop
    $DesktopMemberSplat = @{
        MemberType = "NoteProperty"
        Name = "Desktop"
        Value = $DesktopPath
    }
    $s | Add-Member @DesktopMemberSplat
    Write-Output $s
}