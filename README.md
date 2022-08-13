# Redirected Folder Health

> _"You should PowerShell a way to find broken folder redirections..."_

![Redirection.Check.png](https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/Redirection.Check.png)

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> About
> _**NOTE: This function has a previous edition located at
[Redirected.Folder.Health](https://github.com/OpsChasingDev/Redirected.Folder.Health)**_

We all love the functionality and idea behind folder redirections on Windows platforms.  The idea of user data on servers is an attractive one, providing both security and backup protection.  At the same time, folder redirection works behind the scenes, allowing users to work on and save data in places they are already familiar with using.

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> The Problem
As good as folder redirections are, this Group Policy based solution comes with absolutely no system of alerting when things go wrong, leaving admins blind to issues where user data is no longer being redirected.  The issue can be a time bomb, silently waiting until the day comes where the user's device fails, a file gets corrupted, or some other type of data integrity event occurs.  As a result, data loss events occur out of left field and can be catastrophic in certain situations.

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> A Solution
![PowerShell Icon](https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/PowerShell_Core_6.0_icon.png)
The initial design of the solution was specific to our work case at the time, but I have since published this code base as a means of controlling a far more re-useable version.  The Get-RFH.ps1 script can be used in a standalone method for quick, one-off checks for individual or bulk machines, or it can be called on in constructors for more versatility such as automating a regular event where Get-RedirectedFolderGPO updates which libraries are configured to be redirected and passes that information to the Get-RFH script where the results are emailed to a ticketing solution for an engineer to investigate further.

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> Known Issues and Limitations
- Target machines are checked in serial
- System initiating the operation must have the ActiveDirectory PS module
- Remote PS connections must be allowed on client endpoints
- Only logged in user sessions will be detected (users who are logged in but have their screen locked, are idle, are inactive, or are disconneted (in the case of a connection to a remote desktop) **_will_** be detected)

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> Future Goals
As a means of self-criticism, the biggest thing that bothers me about the way my tool works is that it operates in serial.  If you need to check a few hundred machines, you're going to be waiting for each of them to be checked one at a time.  While this methodology may save on bandwidth and not matter for use in an automated check, the solution currently fails to utilize one of the best aspects about PowerShell and therefore creates limitations when scaling.  Leveraging more resouces on the client end and getting the script to work in parallel is ultimately what needs to be done next.

> **Other future goals for the project included below:**
- Add a progress bar (though moot if the operation can run in parallel)
- New function for estimating the total size redirections will consume on a server once implemented
- New function for actively changing broken redirections when found