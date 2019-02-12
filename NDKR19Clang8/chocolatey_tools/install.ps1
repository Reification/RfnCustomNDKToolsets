function Install-Failed($message) {
    Write-Error $message
    exit 1
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
$ToolsetName = "Clang_8_ndk-r19"
$TargetToolsetPath = "$VSArm64ToolsetsDir\$ToolsetName"

if (!$VSInstallDir) {
    Install-Failed "Visual Studio 2017 not installed."
}

if(!(Test-Path $VSArm64ToolsetsDir)) {
    Install-Failed( "Visual Studio C++ Mobile Workflow for Android not installed." )
}

$rootDir = Split-Path -Parent $myInvocation.MyCommand.Definition | Split-Path -Parent
$SourceToolsetPath = "$rootDir\assets"

function Install () {
    if(Test-Path "$TargetToolsetPath") {
        "$($ToolsetName) being removed and re-installed."
        Remove-Item "$TargetToolsetPath" -Recurse
    }
    Copy-Item -Path "$SourceToolsetPath" -Destination "$TargetToolsetPath" -Recurse -Force

    "Toolset integration installed."
}

""
"=== Configuration ==="
"* Target Platform: Android ARM64"
"* Clang 8.0 toolset: $ToolsetName"
"* At $TargetToolsetPath"
""

Install
