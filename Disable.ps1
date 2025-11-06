

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

function Remove-WinlogonProperty {
    param (
        [String] $Name
    )

   $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

   Remove-ItemProperty `
        -Path $Path `
        -Name $Name `
        -Force `
        -ErrorAction SilentlyContinue

}

$host.UI.RawUI.WindowTitle = "Windows Automatic Logon [Disable]"

Write-Output "Windows Automatic Logon"
Write-Output "Method: Disable"
Write-Output "Windows will use the default account selection screen on boot"
Write-Output ''

$confirmation = Read-Host -Prompt "Are you sure you want to proceed? (Y/N)"

if ($confirmation.ToLower() -eq 'y') {

    # Set the 'DefaultUserName' Registry Item
    Remove-WinlogonProperty `
        -Name "DefaultUserName"

    # Set the 'DefaultPassword' Registry Item
    Remove-WinlogonProperty `
        -Name "DefaultPassword"

    Write-Output ''
    Write-Output 'Account Information has been cleared from Registry'
    Write-Output ''

} else {

    Write-Output ''
    Write-Output 'Nothing has been changed'
    Write-Output ''

}

Pause