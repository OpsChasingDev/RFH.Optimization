<#
- each machine has the following logic invoked:
    - checks the registry to collect all currently logged in users
    - checks each logged in user's libraries
    - returns a psobject containing members to describe:
        - ComputerName
        - User
        - library path value
#>

Get-ChildItem "REGISTRY::HKU\" -ErrorAction SilentlyContinue