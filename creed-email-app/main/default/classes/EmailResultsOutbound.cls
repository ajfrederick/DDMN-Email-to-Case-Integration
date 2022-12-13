/**
 * @name EmailResultsOutbound
 * @description Contains Email Sent email results for further activites (ie creating feed Items or error handling) 
 * after sending an email
**/
global class EmailResultsOutbound {

/**
 * FIELDS
**/

    global Messaging.SendEmailResult[] results {
        get {
            if( results == null ) results = new Messaging.SendEmailResult[]{};
            return results;
        }
        set;
    }

    global Map<String, Messaging.SingleEmailMessage[]> successesByObjId {
        get {
            if( successesByObjId == null ) successesByObjId = new Map<String, Messaging.SingleEmailMessage[]>();
            return successesByObjId;
        }
        set;
    }

    global Messaging.SendEmailResult[] failures {
        get {
            if( failures == null ) failures = new Messaging.SendEmailResult[]{};
            return failures;
        }
        set;
    }
    
    global String failedIds {
        get {
            if( failedIds == null ) failedIds = '';
            return failedIds;
        }
        set;
    }
    
/**
 * CONSTRUCTOR
**/

    global EmailResultsOutbound( Messaging.SendEmailResult[] res ){
        results = res;

        setFailures();
    }
    
/**
 * ACTION METHODS
**/ 
    
    /**
     * @name setSuccesses
     * @description recieves a list of emails and compares them to the list of failed emails
     * if the messages are NOT in the failed list then they were sent successfully
     * @return void
    **/
    global void setSuccesses( Messaging.SingleEmailMessage[] messages ){

        for( Messaging.SendEmailResult result : failures ){
            Messaging.SendEmailError[] errors = result.getErrors();

            for( Integer i = 0; i < errors.size(); i++ ){
                Messaging.SendEmailError error = errors[i];

                failedIds += error.getTargetObjectId();

                System.debug('Failed Email Target Object Id >>>' + error.getTargetObjectId());
            }
        }

        for( Messaging.SingleEmailMessage message : messages ){
            String objId = message.getWhatId() != null ? message.getWhatId() : message.getTargetObjectId() != null ? message.getTargetObjectId() : null;

            if( objId == null ) continue;

            if( failedIds.indexOf( objId ) < 0 ){

                if( successesByObjId.containsKey( objId ) ){
                    successesByObjId.get( objId ).add( message );
                } else {
                    successesByObjId.put( objId, new Messaging.SingleEmailMessage[]{ message } );
                }   
            }
        }
    }

    /**
     * @name getSuccesses
     * @description returns all successfully sent messages
     * @return void
    **/
    global Messaging.SingleEmailMessage[] getSuccesses(){
        Messaging.SingleEmailMessage[] successes = new Messaging.SingleEmailMessage[]{};

        for( String objId : successesByObjId.keyset() ){
            for( Messaging.SingleEmailMessage message : successesByObjId.get(objId) ){
                successes.add(message);
            }
        }
        
        return successes;
    }

    /**
     * @name getSuccesses
     * @description returns all successfully sent messages but record Id
     * @return void
    **/
    global Map<String, Messaging.SingleEmailMessage[]> getSuccessesByObjId(){
        return successesByObjId;
    }

    /**
     * @name setFailures
     * @description checks the results for failed emails
     * @return void
    **/
    private void setFailures(){
        if( results == null ) return;

        for( Messaging.SendEmailResult result : results ){
            if( !result.isSuccess() ){
                failures.add(result);
            }
        }
    }

    /**
     * @name getFailures
     * @description returns failures
     * @return void
    **/
    global Messaging.SendEmailResult[] getFailures(){
        return failures;
    }

/**
 * UTILITY METHODS
**/

    /**
     * @name getErrorMessages
     * @description returns a list of all the error messages for failed emails
     * @return String[]
    **/
    global String[] getErrorMessages(){
        String[] messages = new String[]{};

        for( Messaging.SendEmailResult result : failures ){
            Messaging.SendEmailError[] errors = result.getErrors();

            String message = 'Email Errors: \n \n';

            for( Integer i = 0; i < errors.size(); i++ ){
                Messaging.SendEmailError error = errors[i];

                message += 'Object Id: ' + error.getTargetObjectId() + '\n \n';
                message += 'Error #' + i+1 + ': ' + error.getMessage() + '\n \n';
            }

            messages.add( message );
        }

        return messages;
    }
    
    /**
     * @name hasSuccesses
     * @description checks if email was sent successfully or not
     * @return Boolean
    **/
    global Boolean hasSuccesses(){
        return !successesByObjId.isEmpty();
    }
    
    /**
     * @name hasFailures
     * @description checks if email has any failures
     * @return Boolean
    **/
    global Boolean hasFailures(){
        return !failures.isEmpty();
    }
}