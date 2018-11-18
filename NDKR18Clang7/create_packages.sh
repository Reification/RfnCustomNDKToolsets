#!/bin/bash
projDir=$(dirname "${0}")
cd "$projDir"
projDir=$(pwd)

pkgName=$(echo *.nuspec)
pkgName=${pkgName/.nuspec/}

if (which cmake 2>&1) > /dev/null; then
  echo > /dev/null
else
  echo "cmake not installed or not in PATH" 1>&2
  exit 1
fi

(rm -rf $pkgName/ $pkgName.zip $pkgName.nupkg 2>&1) > /dev/null

if (which nuget 2>&1) > /dev/null; then
  projDirW=$(cygpath -w "$projDir")
  nuget config -Set repositoryPath="$projDirW"
  #filter out the warnings about ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 - they are actually incorrect
  (nuget pack -IncludeReferencedProjects -properties Configuration=Release 2>&1) | grep -v 'nstall\.ps1'
else
  echo "nuget not installed. skipping creation of $pkgName.nupkg."
fi

mkdir $pkgName
cp -r ../LICENSE *.bat *.txt assets scripts $pkgName/

cmake -E tar "cf" $pkgName.zip --format=zip $pkgName

echo "Manual installation archive packaged as $pkgName.zip"

(rm -rf $pkgName/ 2>&1) > /dev/null
