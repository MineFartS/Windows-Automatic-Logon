

# Check and run the script as admin if required
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (!$myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Output "Restarting as admin in a new window, you can close this one."
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

function Set-WinlogonProperty {
    param (
        [String] $Name,
        [String] $Value
    )

   $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

   $property = Get-ItemProperty `
        -Path $Path `
        -Name $Name `
        -ErrorAction SilentlyContinue

    if ($property -eq $null) {

        # Create a new registry item with the given value
        New-ItemProperty `
            -Path $Path `
            -Name $Name `
            -Value $Value `
            -Type "String" `
            | Out-Null

    } else {

        # Change the value of the existing registry item
        Set-ItemProperty `
            -Path $Path `
            -Name $Name `
            -Value $Value `
            | Out-Null

    }
    
}

$host.UI.RawUI.WindowTitle = "Windows Automatic Logon [Enable]"

Write-Output "Windows Automatic Logon"
Write-Output "Method: Enable"
Write-Output "Windows will automatically sign in to the given account on boot"
Write-Output ''

# Ask for username
$Username = Read-Host "Username"

# Ask for password
$Password = Read-Host "Password" -AsSecureString
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

# Set the 'DefaultUserName' Registry Item
Set-WinlogonProperty `
    -Name "DefaultUserName" `
    -Value $Username

# Set the 'DefaultPassword' Registry Item
Set-WinlogonProperty `
    -Name "DefaultPassword" `
    -Value $Password


Write-Output ''
Write-Output 'Account Information has been saved to Registry'
Write-Output ''

Pause