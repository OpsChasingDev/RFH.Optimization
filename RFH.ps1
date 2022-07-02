<#
- conditionalize the operation of finding the desktop value
- the above item will be used respectively for each library checked based on user input
- formulate advanced function features to start invoking properly on machines with parameters
#>

param (
    [Parameter(Mandatory)]
    [string[]]$ComputerName
)
Invoke-Command -ComputerName $ComputerName {
    # stores a list of SIDs belonging to only the users logged in (includes domain admin)
    $User_LoggedIn = (Get-ChildItem "REGISTRY::HKU\" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name.Length -gt 25 -and $_.Name -notlike '*_Classes' }).Name
    $User_LoggedIn = $User_LoggedIn | ForEach-Object { $_.Split('\')[1] }
    
    # store usernames for each SID found on the computer in a custom object collection for comparison later
    $SID = Get-ChildItem 'REGISTRY::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' | Select-Object -ExpandProperty Name
    $colUser = @()
    foreach ($s in $SID) {
        $Prof = Get-ItemProperty -Path "REGISTRY::$s" -Name "ProfileImagePath"
        $User = ($Prof.ProfileImagePath.ToString()).Split('\')[-1]
        $objUser = [PSCustomObject]@{
            UserSID  = $Prof.PSChildName
            UserName = $User
        }
        if ($objUser.UserSID.Length -gt 25 -and $User_LoggedIn -contains $objUser.UserSID) {
            $colUser += $objUser
        }
    }
    
    # foreach logged in user, return value of the Desktop path
    foreach ($obj in $colUser) {
        $DesktopPathSplat = @{
            Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
            Name        = "Desktop"
            ErrorAction = "SilentlyContinue"
        }
        $DesktopPath = (Get-ItemProperty @DesktopPathSplat).Desktop
        $DesktopMemberSplat = @{
            MemberType = "NoteProperty"
            Name       = "Desktop"
            Value      = $DesktopPath
        }
        $obj | Add-Member @DesktopMemberSplat
        Write-Output $obj
    }
}