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

function Uninstall() {
    if(Test-Path "$TargetToolsetPath") {
        Remove-Item "$TargetToolsetPath" -Recurse
        "Toolset integration uninstalled."
    } else {
        "$($ToolsetName) not installed."
    }
}

""
"=== Configuration ==="
"* Target Platform: Android ARM64"
"* Clang 8.0 toolset: $ToolsetName"
"* At $TargetToolsetPath"
""

Uninstall
