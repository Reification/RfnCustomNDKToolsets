$id=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal=new-object System.Security.Principal.WindowsPrincipal($id)
$role=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if (!$principal.IsInRole($role)) {
   $pinfo = New-Object System.Diagnostics.ProcessStartInfo "powershell"
   [string[]]$arguments = @("-ExecutionPolicy","Bypass",$myInvocation.MyCommand.Definition)

   foreach ($key in $myInvocation.BoundParameters.Keys) {
       $arguments += ,@("-$key")
       $arguments += ,@($myInvocation.BoundParameters[$key])
    }

   $pinfo.Arguments = $arguments
   $pinfo.Verb = "runas"
   $null = [System.Diagnostics.Process]::Start($pinfo)

   exit
}

function Pause() {
    Write-Host -NoNewLine "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    ""
}

$Host.UI.RawUI.WindowTitle = "Reification Android NDK r16b Clang 5 MSVS Toolset Installer"

function Install-Failed($message) {
    Write-Error $message
    Pause
    exit
}

function Get-Registry($key, $valuekey = "") {
    $reg = Get-Item -Path $key -ErrorAction SilentlyContinue
    if ($reg) {
        return $reg.GetValue($valuekey)
    }
    return $null
}

$VSInstallDir = Get-Registry Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\SxS\VS7 "15.0"
if (!$VSInstallDir) {
    $VSInstallDir = Get-Registry Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7 "15.0"
}

$VSArm64ToolsetsDir = "${VSInstallDir}Common7\IDE\VC\VCTargets\Application Type\Android\3.0\Platforms\ARM64\PlatformToolsets"
$ClangToolsetName = "Clang_5_ndk-r16b"
$TargetToolsetPath = "$VSArm64ToolsetsDir\$ClangToolsetName"

if (!$VSInstallDir) {
    Install-Failed "Visual Studio 2017 not installed."
}

if(!(Test-Path $VSArm64ToolsetsDir)) {
    Install-Failed( "Visual Studio C++ Mobile Workflow for Android not installed." )
}

$rootDir = Split-Path -Parent $myInvocation.MyCommand.Definition | Split-Path -Parent
$SourceToolsetPath = "$rootDir\assets\Clang_5"

function Install () {
    if(Test-Path "$TargetToolsetPath") {
        Remove-Item "$TargetToolsetPath" -Recurse
    }
    Copy-Item -Path "$SourceToolsetPath" -Destination "$TargetToolsetPath" -Recurse -Force

    "Toolset integration installed."
}

function Uninstall() {
    if(Test-Path "$TargetToolsetPath") {
        Remove-Item "$TargetToolsetPath" -Recurse
    }

    "Toolset integration uninstalled."
}

""
"=== Install configuration ==="
"* Target Platform: Android ARM64"
"* Clang 5.0 toolset: $ClangToolsetName"
"* At $TargetToolsetPath"
""

$Operation = "Install"

if(Test-Path $TargetToolsetPath) {
    if ((Read-Host "Uninstall? (N/y)") -match "y|yes") {
        $Operation = "Uninstall"
    } else {
        $Operation = "Re-Install"
    }
}

if( $Operation -ne "Uninstall" ) {
    if ((Read-Host "${Operation}? (Y/n)") -match "n|no") {
        "operation canceled by user."
        Pause
        exit
    }
}

if ($Operation -eq "Uninstall") {
    Uninstall
} else {
    Install
}

Pause