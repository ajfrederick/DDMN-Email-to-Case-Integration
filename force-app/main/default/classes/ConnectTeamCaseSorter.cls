/**
 * @name ConnectTeamCaseSorter
 * @description Sorts Cases for Connect Team into appropriate categories depending on criteria
**/
public class ConnectTeamCaseSorter {

/**
 * FIELDS
**/

    private Map<Id, Case> connectTeamCases {
        get {
            if( connectTeamCases == null ) connectTeamCases = new Map<Id, Case>();
            return connectTeamCases;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    public ConnectTeamCaseSorter( Map<Id, Case> newMap ) {
        
        for( Case obj : newMap.values() ){
            if( isConnectTeam(obj) ){
                connectTeamCases.put( obj.Id, obj );
            }
        }
    }

/**
 * ACTION METHODS
**/

    /**
     * @name getAllCases
     * @description returns a list of all connect team cases
     * @return Case[]
    **/
    public Case[] getAllCases(){  
        return connectTeamCases.values();
    }

    /**
     * @name getEmailChangedCases
     * @description returns a list of connect team cases that had a CHANGE in email address upon update
     * @param Map<Id, Case> oldMap
     * @return Case[]
    **/
    public Case[] getEmailChangedCases( Map<Id, Case> oldMap ){
        Case[] cases = new Case[]{};

        for( Id caseId : connectTeamCases.keyset() ){
            if( !oldMap.containsKey( caseId ) ) continue;

            Case oldCase = oldMap.get(caseId);
            Case newCase = connectTeamCases.get(caseId);

            // if case is updated and the email has changed and it's not closed
            if( emailChanged( oldCase, newCase ) && (!isClosed( oldCase, newCase )) ){
                cases.add( newCase );
            }
        }

        return cases;
    }

    /**
     * @name getConnectTeamClosedCases
     * @description returns a list of connect team cases that are closed upon update
     * @param Map<Id, Case> oldMap
     * @return Case[]
    **/
    public Case[] getClosedCases( Map<Id, Case> oldMap ){
        Case[] cases = new Case[]{};

        for( Id caseId : connectTeamCases.keyset() ){
            if( !oldMap.containsKey( caseId ) ) continue;

            Case oldCase = oldMap.get(caseId);
            Case newCase = connectTeamCases.get(caseId);

            // if case is updated to closed 
            if( changedToClosed( oldCase, newCase ) ){
                cases.add( newCase );
            }
        }

        return cases;
    }

/**
 * UTILITY METHODS
**/

    /**
     * @name isConnectTeam
     * @description returns a true if cases is of the connect team's record type and is open
     * @param Case case
     * @return Boolean
    **/
    private Boolean isConnectTeam( Case obj ){
        return obj.RecordTypeId == Constants.CONNECT_TEAM_RECORD_TYPE_ID;
    }

    /**
     * @name isClosed
     * @description returns a true if cases was and still is closed
     * @param Case oldCase
     * @param Case newCase
     * @return Boolean
    **/
    private Boolean isClosed( Case oldCase, Case newCase ){
        return oldCase.IsClosed && newCase.IsClosed;
    }

    /**
     * @name changedToClosed
     * @description returns a true if cases status was changed to closed
     * @param Case oldCase
     * @param Case newCase
     * @return Boolean
    **/
    private Boolean changedToClosed( Case oldCase, Case newCase ){
        return (!oldCase.IsClosed) && newCase.IsClosed;
    }

    /**
     * @name emailChanged
     *  
     * @description checks whether either contact has changed or supplied email has changed
     * if the contact has changed then check if the contact email has changed. If there is not contact
     * but check if supplied email has changed.
     * 
     * @param Case oldCase
     * @param Case newCase
     * @return Boolean
    **/
    private Boolean emailChanged( Case oldCase, Case newCase ){
        Boolean ret = false;

        // if the new version of case has a contact email and email has changed
        if( newCase.ContactEmail != null && oldCase.ContactEmail != newCase.ContactEmail ){
            ret = true;
        // if it does not has a contact then check if there is a supplied email and it has changed
        } else
        if( newCase.SuppliedEmail != null && oldCase.SuppliedEmail != newCase.SuppliedEmail ){
            ret = true;
        }

        return ret;
    }
}
