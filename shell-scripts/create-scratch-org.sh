#! /bin/bash

# if there is an arg then use that as an alias

# -d sets to 30 duration days
# -f is def file
# -a is alias name
# -s sets as default scratch

if [ -z $1 ]
then
  sfdx force:org:create  -d 30 -f ./config/project-scratch-def.json -a Scratchy -s
else
  sfdx force:org:create  -d 30 -f ./config/project-scratch-def.json -a $1 -s
fi