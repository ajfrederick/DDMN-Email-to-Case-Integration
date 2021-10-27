/**
 * @name OutboundEmailResults
 * @description Contains Email Sent email results for further activites (ie creating feed Items or error handling) 
 * after sending an email
**/
public class OutboundEmailResults {

/**
 * FIELDS
**/

    public Map<String, Messaging.SingleEmailMessage[]> sentEmailsByObjId {
        get {
            if( sentEmailsByObjId == null ) sentEmailsByObjId = new Map<String, Messaging.SingleEmailMessage[]>();
            return sentEmailsByObjId;
        }
        set;
    }

    public Messaging.SendEmailResult[] failedResults {
        get {
            if( failedResults == null ) failedResults = new Messaging.SendEmailResult[]{};
            return failedResults;
        }
        set;
    }
    
/**
 * CONSTRUCTOR
**/
    
    public OutboundEmailResults( Messaging.SendEmailResult[] results ){
        setFailures(results);
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
    public void setSuccesses( Messaging.SingleEmailMessage[] messages ){
        String failedIds = '';

        for( Messaging.SendEmailResult result : failedResults ){
            Messaging.SendEmailError[] errors = result.getErrors();

            for( Integer i = 0; i < errors.size(); i++ ){
                Messaging.SendEmailError error = errors[i];

                failedIds += error.getTargetObjectId();
            }

            System.debug(failedIds);
        }

        for( Messaging.SingleEmailMessage message : messages ){
            String objId = message.getWhatId() != null ? message.getWhatId() : message.getTargetObjectId() != null ? message.getTargetObjectId() : null;

            if( objId == null ) continue;

            if( failedIds.indexOf( objId ) < 0 ){

                if( sentEmailsByObjId.containsKey( objId ) ){
                    sentEmailsByObjId.get( objId ).add( message );
                } else {
                    sentEmailsByObjId.put( objId, new Messaging.SingleEmailMessage[]{ message } );
                }   
            }
        }
    }

    /**
     * @name getSuccesses
     * @description returns all successfully sent messages
     * @return void
    **/
    public Messaging.SingleEmailMessage[] getSuccesses(){
        Messaging.SingleEmailMessage[] successes = new Messaging.SingleEmailMessage[]{};

        for( String objId : sentEmailsByObjId.keyset() ){
            for( Messaging.SingleEmailMessage message : sentEmailsByObjId.get(objId) ){
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
    public Map<String, Messaging.SingleEmailMessage[]> getSuccessesByObjId(){
        return sentEmailsByObjId;
    }

    /**
     * @name setFailures
     * @description checks the results for failed emails
     * @return void
    **/
    private void setFailures( Messaging.SendEmailResult[] results ){
        if( results == null ) return;

        for( Messaging.SendEmailResult result : results ){
            if( !result.isSuccess() ){
                failedResults.add(result);
            }
        }
    }

    /**
     * @name getFailures
     * @description returns failures
     * @return void
    **/
    public Messaging.SendEmailResult[] getFailures(){
        return failedResults;
    }

    /**
     * @name getErrorMessages
     * @description returns a list of all the error messages for failed emails
     * @return String[]
    **/
    public String[] getErrorMessages(){
        String[] messages = new String[]{};

        for( Messaging.SendEmailResult result : failedResults ){
            Messaging.SendEmailError[] errors = result.getErrors();

            String message = 'Email Errors: \n \n';

            for( Integer i = 0; i < errors.size(); i++ ){
                Messaging.SendEmailError error = errors[i];

                message += 'Error #' + i+1 + ': ' + error.getMessage() + '\n \n';
            }

            messages.add( message );
        }

        return messages;
    }

/**
 * UTILITY METHODS
**/
    
    /**
     * @name hasSuccesses
     * @description checks if email was sent successfully or not
     * @return Boolean
    **/
    public Boolean hasSuccesses(){
        return !sentEmailsByObjId.isEmpty();
    }
    
    /**
     * @name hasFailures
     * @description checks if email has any failures
     * @return Boolean
    **/
    public Boolean hasFailures(){
        return !failedResults.isEmpty();
    }
}
