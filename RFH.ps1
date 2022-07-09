<#
- set the object output type of RFH to validate input to the below new function
- create a new function to take Get-RFH's output and generate reports based on user's wishes; only accept custom output type from RFh
- add in progress bar
- add in CBH

#>
function Get-RFH {
    [CmdletBinding()]
    [Alias('Get-RedirectedFolderHealth')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("D", "O", "W", "M", "P", "V", "F", "A", "S", "C", "L", "H", "G")]
        [string[]]$Library,

        [int]$ThrottleLimit = 32,

        [switch]$ShowError
    )
    $StartTime = Get-Date
    Write-Verbose "Starting redirection check for: $ComputerName"
    Invoke-Command -ComputerName $ComputerName -ErrorAction SilentlyContinue -ErrorVariable InvokeError -ThrottleLimit $ThrottleLimit {
        # stores a list of SIDs belonging to only the users logged in (includes domain admin)
        eventcreate /ID 13 /L APPLICATION /T INFORMATION /SO RedirectedFolderHealth /D "A RedirectedFolderHealth check has started a query on this machine..." > $null
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
                PSTypeName = "RFH"
                UserSID  = $Prof.PSChildName
                UserName = $User
            }
            if ($objUser.UserSID.Length -gt 25 -and $User_LoggedIn -contains $objUser.UserSID) {
                $colUser += $objUser
            }
        }
        
        # foreach logged in user, check the libraries specified
        foreach ($obj in $colUser) {
            # Desktop
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
            # Documents
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
            # Downloads
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
            # Music
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
            # Pictures
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
            # Video
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
            # Favorites
            if ($($using:Library) -eq "F") {
                $FavoritesPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "Favorites"
                    ErrorAction = "SilentlyContinue"
                }
                $FavoritesPath = (Get-ItemProperty @FavoritesPathSplat).Favorites
                $FavoritesMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Favorites"
                    Value      = $FavoritesPath
                }
                $obj | Add-Member @FavoritesMemberSplat
            }
            # AppData (roaming)
            if ($($using:Library) -eq "A") {
                $AppDataPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "AppData"
                    ErrorAction = "SilentlyContinue"
                }
                $AppDataPath = (Get-ItemProperty @AppDataPathSplat).AppData
                $AppDataMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "AppData"
                    Value      = $AppDataPath
                }
                $obj | Add-Member @AppDataMemberSplat
            }
            # Start Menu
            if ($($using:Library) -eq "S") {
                $StartMenuPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "Start Menu"
                    ErrorAction = "SilentlyContinue"
                }
                $StartMenuPath = (Get-ItemProperty @StartMenuPathSplat)."Start Menu"
                $StartMenuMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "StartMenu"
                    Value      = $StartMenuPath
                }
                $obj | Add-Member @StartMenuMemberSplat
            }
            # Contacts
            if ($($using:Library) -eq "C") {
                $ContactsPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "{56784854-C6CB-462B-8169-88E350ACB882}"
                    ErrorAction = "SilentlyContinue"
                }
                $ContactsPath = (Get-ItemProperty @ContactsPathSplat)."{56784854-C6CB-462B-8169-88E350ACB882}"
                $ContactsMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Contacts"
                    Value      = $ContactsPath
                }
                $obj | Add-Member @ContactsMemberSplat
            }
            # Links
            if ($($using:Library) -eq "L") {
                $LinksPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}"
                    ErrorAction = "SilentlyContinue"
                }
                $LinksPath = (Get-ItemProperty @LinksPathSplat)."{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}"
                $LinksMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Links"
                    Value      = $LinksPath
                }
                $obj | Add-Member @LinksMemberSplat
            }
            # Searches
            if ($($using:Library) -eq "H") {
                $SearchesPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}"
                    ErrorAction = "SilentlyContinue"
                }
                $SearchesPath = (Get-ItemProperty @SearchesPathSplat)."{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}"
                $SearchesMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "Searches"
                    Value      = $SearchesPath
                }
                $obj | Add-Member @SearchesMemberSplat
            }
            # Saved Games
            if ($($using:Library) -eq "G") {
                $SavedGamesPathSplat = @{
                    Path        = "REGISTRY::HKU\$($obj.UserSID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\"
                    Name        = "{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}"
                    ErrorAction = "SilentlyContinue"
                }
                $SavedGamesPath = (Get-ItemProperty @SavedGamesPathSplat)."{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}"
                $SavedGamesMemberSplat = @{
                    MemberType = "NoteProperty"
                    Name       = "SavedGames"
                    Value      = $SavedGamesPath
                }
                $obj | Add-Member @SavedGamesMemberSplat
            }
            Write-Output $obj
            eventcreate /ID 13 /L APPLICATION /T INFORMATION /SO RedirectedFolderHealth /D "A RedirectedFolderHealth check has completed on this machine." > $null
        }
    }
    
    if ($ShowError) { Write-Output $InvokeError }
    $EndTime = Get-Date
    $ElapsedTime = $EndTime - $StartTime
    Write-Verbose "Elapsed time (HH:MM:SS): $ElapsedTime"
}