#! /bin/bash

# if there is an arg then use that as perm set name

if [ -z $1 ]
then
  sfdx force:user:permset:assign --permsetname Connect_Team_Case_Management
else
  sfdx force:user:permset:assign --permsetname $1
fi