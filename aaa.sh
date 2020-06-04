#!/bin/bash



git checkout develop

version_line=`cat package.json | grep '"version":'`
version=`echo $version_line | grep -P -o '\d+\.\d+\.\d+'`
rc_version="$version-RC"
echo "release_branch_name=release/1" > release.properties

echo "upgrading develop and rc_branch to -RC version to avoid merge conflicts when merging RC into develop in future"
echo "adding '-RC' in version number"
rc_version_line="\"version\": \"$rc_version\""
sed -r -i "s/\"version\":\ \".+\"/$rc_version_line/" package.json
git commit -a -m "New release candidate version: $rc_version"
git push origin develop

echo "making RC branch"
git checkout -b "release/1"
git push origin release/1


echo "incresing develop version"
git checkout develop
if [[ "$version" =~ ([0-9]+).([0-9]+).([0-9]+) ]]; then
  new_develop_version="${BASH_REMATCH[1]}.$((${BASH_REMATCH[2]} + 1)).0-SNAPSHOT"
else
    echo "no match"
fi
echo "setting version on develop branch to $new_develop_version"
new_develop_version_line="\"version\": \"$new_develop_version\""
sed -r -i "s/\"version\":\ \".+\"/$new_develop_version_line/" package.json
git commit -a -m "develop version automaically increased by bamboo: $new_develop_version"
git push origin develop
