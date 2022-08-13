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

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> Improvements from the Previous Edition
- Target machines are now checked in parallel with concurrency control
- No more dependencies on the ActiveDirectory module
- Removed params, parameter sets, and other "features" that ultimately were more restrictive on how to use the tool
- Added cleaner verbose messaging
- Added progress bar
- Specific output type [RFH.RFH] for better tool making
- Puts the computational power to the target machines

## <img src="https://raw.githubusercontent.com/drummermanrob20/Misc/main/resources/shell.prompt.icon2.png" width="25"/> Future Goals
- New function for estimating the total size redirections will consume on a server once implemented
- New function for actively changing broken redirections when found