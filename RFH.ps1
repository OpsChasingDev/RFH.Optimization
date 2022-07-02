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
                $DocumentsPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "Personal"
                    ErrorAction = "SilentlyContinue"
                }
                $DocumentsPath = (Get-ItemProperty @DocumentsPathSplat).Personal
                $DocumentsMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Documents"
                    Value      = $DocumentsPath
                }
                $obj | Add-Member @DocumentsMemberSplat
            }
            if ($($using:Library) -eq "W") {
                $DownloadsPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "{374DE290-123F-4565-9164-39C4925E467B}"
                    ErrorAction = "SilentlyContinue"
                }
                $DownloadsPath = (Get-ItemProperty @DownloadsPathSplat)."{374DE290-123F-4565-9164-39C4925E467B}"
                $DownloadsMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Downloads"
                    Value      = $DownloadsPath
                }
                $obj | Add-Member @DownloadsMemberSplat
            }
            if ($($using:Library) -eq "M") {
                $MusicPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "My Music"
                    ErrorAction = "SilentlyContinue"
                }
                $MusicPath = (Get-ItemProperty @MusicPathSplat)."My Music"
                $MusicMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Music"
                    Value      = $MusicPath
                }
                $obj | Add-Member @MusicMemberSplat
            }
            if ($($using:Library) -eq "P") {
                $PicturesPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "My Pictures"
                    ErrorAction = "SilentlyContinue"
                }
                $PicturesPath = (Get-ItemProperty @PicturesPathSplat)."My Pictures"
                $PicturesMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Pictures"
                    Value      = $PicturesPath
                }
                $obj | Add-Member @PicturesMemberSplat
            }
            if ($($using:Library) -eq "V") {
                $VideoPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "My Video"
                    ErrorAction = "SilentlyContinue"
                }
                $VideoPath = (Get-ItemProperty @VideoPathSplat)."My Video"
                $VideoMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Video"
                    Value      = $VideoPath
                }
                $obj | Add-Member @VideoMemberSplat
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