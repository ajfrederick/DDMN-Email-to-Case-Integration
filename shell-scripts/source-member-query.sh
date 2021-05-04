#! /bin/bash
sfdx force:data:soql:query -q 'SELECT Id, MemberName, MemberType, RevisionCounter, IsNameObsolete FROM SourceMember' -t