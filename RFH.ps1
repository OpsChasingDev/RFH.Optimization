<#
- add in CBH
- modify readme.md

#>
function Get-RFH {
    <#
    .SYNOPSIS
        Runs against a computer to check the path of specified user libraries for any user logged into that machine.
    .DESCRIPTION
        Runs against a computer to check the path of specified user libraries for any user logged into that machine.
        This function is a refactored version of its previous state and includes the below changes:
            - Checks now run in parallel with control for a throttle limit
            - No dependencies on ActiveDirectory
            - No dependencies on logged in users
            - Removed params and output types that restricted use cases
            - Removed the need for multiple parameter sets
            - Removed options for Write-Host
            - Added better verbose messaging
            - Added progress bar
            - Declared specific output type of [RFH.RFH] for more specific pipe-sending use cases in constructor scripts
            - Still supports excluding user accounts from the checks
            - Most computational requirements are executed at each target computer
            - Executes using PowerShell jobs
    .NOTES
        Written to support backwards compatibility up to Windows PowerShell version 3.0
        Operates against target machines in parallel with a default concurrency of 32.
    .LINK
        https://github.com/OpsChasingDev/RFH.Optimization
    .EXAMPLE
PS C:\> Get-RFH -ComputerName 'SL-COMPUTER-001' -Library D,O

    UserSID        : S-1-5-21-1728172293-1059764289-3432225222-500
    UserName       : Administrator
    Desktop        : C:\Users\Administrator\Desktop
    Documents      : C:\Users\Administrator\Documents
    PSComputerName : SL-COMPUTER-001
    RunspaceId     : c4c1cf68-1710-49ec-80d1-d41c7e236f0b

This example checks the computer named SL-COMPUTER-001 to retrieve the user's Desktop and Documents path.
    .EXAMPLE
PS C:\> $comp = @('SL-COMPUTER-001','SL-COMPUTER-002')
PS C:\> Get-RFH -ComputerName $comp -Library D

    UserSID        : S-1-5-21-1728172293-1059764289-3432225222-500
    UserName       : Administrator
    Desktop        : C:\Users\Administrator\Desktop
    PSComputerName : SL-COMPUTER-001
    RunspaceId     : c078795c-b2d5-44df-bd60-daf51e238bcb

    UserSID        : S-1-5-21-1728172293-1059764289-3432225222-500
    UserName       : Administrator
    Desktop        : C:\Users\Administrator\Desktop
    PSComputerName : SL-COMPUTER-002
    RunspaceId     : 5d6f6735-dc61-42fb-9b1b-7137b614bb68

This example first declares a collection of computers to check.  The variable storing the collection is then used in the -ComputerName parameter to check the Desktop path of all logged in users for both computers.
    .EXAMPLE
PS C:\> Get-RFH -ComputerName $comp -Library D,O,M,P,V -ExcludeAccount Administrator

    UserSID        : S-1-5-21-1728172293-1059764289-3432225222-1104
    UserName       : user1
    Desktop        : \\SL-DC-01\RedirectedFolders\user1\Desktop
    Documents      : \\SL-DC-01\RedirectedFolders\user1\Documents
    Music          : \\SL-DC-01\RedirectedFolders\user1\Music
    Pictures       : \\SL-DC-01\RedirectedFolders\user1\Pictures
    Video          : \\SL-DC-01\RedirectedFolders\user1\Videos
    PSComputerName : SL-COMPUTER-001
    RunspaceId     : 1b8bbcc5-80e8-4f5b-b77d-903cb0e74d5a

    UserSID        : S-1-5-21-1728172293-1059764289-3432225222-1112
    UserName       : user-002
    Desktop        : C:\Users\user-002\Desktop
    Documents      : C:\Users\user-002\Documents
    Music          : C:\Users\user-002\Music
    Pictures       : C:\Users\user-002\Pictures
    Video          : C:\Users\user-002\Videos
    PSComputerName : SL-COMPUTER-002
    RunspaceId     : 3641923c-9241-4dae-8821-6815a1029dbd

Checks multiple computers for multiple library paths of logged in users.  The -ExcludeAccount param has been used to prevent the Administrator account from being returned.
    .EXAMPLE
PS C:\> Get-RFH -ComputerName $comp -Library O -ExcludeAccount Administrator | Select-Object UserName,PSComputerName,Documents

    UserName PSComputerName  Documents
    -------- --------------  ---------
    user1    SL-COMPUTER-001 \\SL-DC-01\RedirectedFolders\user1\Documents
    user-002 SL-COMPUTER-002 C:\Users\user-002\Documents
    User-003 SL-COMPUTER-002 C:\Users\User-003\Documents

Retrieves the Documents path for all users except the Administrator for the specified computers.  Output has been sent down the pipeline to only return desired properties.
    .EXAMPLE
Get-RFH -ComputerName "SL-RDS-01" -Library D | Where-Object {$_.Desktop -notlike "\\*"}

Returns any desktop path for all users logged into SL-RDS-01 that are not redirected to a shared location.
    .EXAMPLE
Get-RFH -ComputerName $List -Library D,O,M,P,V,F -ThrottleLimit 100

Checks multiple libraries on a list of computers.  The -ThrottleLimit param has been used to increase the concurrency of the operation from the default 32.
    #>
    [CmdletBinding()]
    [Alias('Get-RedirectedFolderHealth')]
    [OutputType('RFH.RFH')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("D", "O", "W", "M", "P", "V", "F", "A", "S", "C", "L", "H", "G")]
        [string[]]$Library,

        [string[]]$ExcludeAccount,

        [int]$ThrottleLimit = 32
    )
    # immediate break if existing jobs are found
    if ($null -ne (Get-Job)) {
        Write-Warning "Nothing was run. Finish and remove all existing jobs in the scope before running this function."
        break
    }

    $StartTime = Get-Date
    $TotalCount = $ComputerName.Count

    Write-Verbose "Starting redirection check for: $($ComputerName | Sort-Object | ForEach-Object {Write-Output "`n$_"})"
    $InitComplete = (0 / $TotalCount) * 100
    Write-Progress -Activity "Checking user library paths..." -Status "$($InitComplete)%" -PercentComplete $InitComplete

    $InvokeSplat = @{
        ComputerName  = $ComputerName
        ErrorAction   = 'SilentlyContinue'
        ThrottleLimit = $ThrottleLimit
        AsJob         = $true
    }
    Invoke-Command @InvokeSplat {
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
            # check to make sure the $User value doesn't exist in the -Exclude param
            if ($($using:ExcludeAccount) -notcontains $User) {
                $objUser = [PSCustomObject]@{
                    PSTypeName = "RFH.RFH"
                    UserSID    = $Prof.PSChildName
                    UserName   = $User
                }
                if ($objUser.UserSID.Length -gt 25 -and $User_LoggedIn -contains $objUser.UserSID) {
                    $colUser += $objUser
                }
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
    } | Out-Null

    while ($(Get-Job -IncludeChildJob | Where-Object { $_.HasMoreData -eq $true })) {
        Get-Job -IncludeChildJob | Where-Object { $_.HasMoreData -eq $true } | Receive-Job -ErrorAction 'SilentlyContinue'
        $CompleteJob = Get-Job -IncludeChildJob | Where-Object { $_.HasMoreData -eq $false }
        # only do the below write progress if there exist a non-zero number of jobs where HasMoreData is $false
        if ($CompleteJob.Count -gt 0) {
            $PercentComplete = (($CompleteJob.Count - 1) / $TotalCount) * 100
            Write-Progress -Activity "Checking user library paths..." -Status "$([math]::Round($PercentComplete,0))%" -PercentComplete $PercentComplete
        }
    }

    # clean up jobs
    Write-Verbose "Removing $((Get-Job -IncludeChildJob).Count) jobs."
    Get-Job | Remove-Job -Force

    $EndTime = Get-Date
    $ElapsedTime = $EndTime - $StartTime
    Write-Verbose "Elapsed time (HH:MM:SS): $ElapsedTime"
}