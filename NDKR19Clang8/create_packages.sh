#!/bin/bash
projDir=$(dirname "${0}")
cd "$projDir"
projDir=$(pwd)

pkgName=$(echo *.nuspec)
pkgName=${pkgName/.nuspec/}
pkgVersion=$(sed 's:[<>]: :g' *.nuspec | gawk '/ version / { print $2; exit(0); }')

if (which cmake 2>&1) > /dev/null; then
  echo > /dev/null
else
  echo "cmake not installed or not in PATH" 1>&2
  exit 1
fi

(rm -rf ${pkgName}.${pkgVersion}/ ${pkgName}.${pkgVersion}.zip ${pkgName}.${pkgVersion}.nupkg 2>&1) > /dev/null

if (which nuget 2>&1) > /dev/null; then
  projDirW=$(cygpath -w "$projDir")
  nuget config -Set repositoryPath="$projDirW"
  #filter out the warnings about ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 - they are actually incorrect
  (nuget pack -IncludeReferencedProjects -properties Configuration=Release 2>&1) | grep -v 'nstall\.ps1'
else
  echo "nuget not installed. skipping creation of ${pkgName}.${pkgVersion}.nupkg."
fi

mkdir ${pkgName}.${pkgVersion}
cp -r ../LICENSE *.bat *.txt assets scripts ${pkgName}.${pkgVersion}/

cmake -E tar "cf" ${pkgName}.${pkgVersion}.zip --format=zip ${pkgName}.${pkgVersion}

echo "Manual installation archive packaged as ${pkgName}.${pkgVersion}.zip"

(rm -rf ${pkgName}.${pkgVersion}/ 2>&1) > /dev/null
