<#
- conditionalize the operation of finding the desktop value
- the above item will be used respectively for each library checked based on user input
#>
function Get-RFH {
    [CmdletBinding()]
    [Alias('Get-RedirectedFolderHealth')]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$ComputerName,
        
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateSet("D", "O", "W", "M", "P", "V", "F", "A", "S", "C", "L", "H", "G")]
        [string[]]$Library,

        [switch]$ShowError
    )
    Invoke-Command -ComputerName $ComputerName -ErrorAction SilentlyContinue -ErrorVariable InvokeError {
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
            if ($($using:Library) -eq "D") {
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
            }
            if ($($using:Library) -eq "O") {
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
            }
            if ($($using:Library) -eq "W") {
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
            }
            if ($($using:Library) -eq "M") {
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
            }
            if ($($using:Library) -eq "P") {
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
            }
            if ($($using:Library) -eq "V") {
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
            }
            if ($($using:Library) -eq "F") {
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
            }
            if ($($using:Library) -eq "A") {
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
            }
            if ($($using:Library) -eq "S") {
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
            }
            if ($($using:Library) -eq "C") {
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
            }
            if ($($using:Library) -eq "L") {
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
            }
            if ($($using:Library) -eq "H") {
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
            }
            if ($($using:Library) -eq "G") {
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
            }
            Write-Output $obj
        }
    }
    
    if ($ShowError) { Write-Output $InvokeError }
}