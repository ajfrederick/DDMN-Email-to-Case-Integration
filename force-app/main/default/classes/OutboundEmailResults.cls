/**
 * @name OutboundEmailResults
 * @description Contains Email Sent email results for further activites (ie creating feed Items or error handling) 
 * after sending an email
**/
public class OutboundEmailResults {

/**
 * FIELDS
**/

    public Map<Id, Messaging.SingleEmailMessage[]> sentEmailsByObjId {
        get {
            if( sentEmailsByObjId == null ) sentEmailsByObjId = new Map<Id, Messaging.SingleEmailMessage[]>();
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
        }

        for( Messaging.SingleEmailMessage message : messages ){
            Id objId = message.whatId != null ? message.whatId : '';

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
    
    public Boolean hasSuccesses(){
        return !sentEmailsByObjId.isEmpty();
    }
    
    public Boolean hasFailures(){
        return !failedResults.isEmpty();
    }
}
