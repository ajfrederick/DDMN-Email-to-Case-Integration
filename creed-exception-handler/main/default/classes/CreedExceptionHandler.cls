/**
 * @name CreedExceptionHandler
 * @description custom exception handler for robust debugging and sends an email notification
 * 
 * @author Andrew Frederick (Creed Interactive) 11/23/2021
**/
global class CreedExceptionHandler {

/**
 * CONSTRUCTOR
**/

    // System exception
    private Exception ex {get;set;}

    // email address to send error details to
    private static final String creedAddress = 'salesforceteam@creedinteractive.com';

    // org name for email subject and body
    private static String orgName = '';

    static {
        try {
            orgName = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
        } catch( Exception e ){

        }
    }

    // optional append a message
    private String appendedMessage {get;set;}

    private String[] recipientAddresses {
        get {
            if( recipientAddresses == null ) recipientAddresses = new String[]{};
            return recipientAddresses;
        }
        set;
    }

    // a list of sobjects to derive error info for email
    private SObject[] errorRecords {
        get {
            if( errorRecords == null ) errorRecords = new SObject[]{};
            return errorRecords;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    global CreedExceptionHandler( Exception e ) {
        ex = e;
    }

    // Overloaded Constuctor
    global CreedExceptionHandler( Exception e, SObject[] errorRecs ) {
        ex = e;
        errorRecords = errorRecs;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name handle
     * @description handles with an email and debud
     * @return void
    **/
    global void handle(){
        debug();
        email();
    }

    /**
     * @name debug
     * @description logs a full debug of exception
     * @return void
    **/
    global void debug(){
        System.debug('Exception type caught: ' + ex.getTypeName());    
        System.debug('Exception Message: ' + ex.getMessage());

        if( appendedMessage != null ){
            System.debug('Custom Message: ' + appendedMessage);   
        }

        if( ex.getCause() != null ){
            System.debug('Cause: ' + ex.getCause());
        }

        System.debug('Line number: ' + ex.getLineNumber());    
        System.debug('Stack trace: ' + ex.getStackTraceString()); 
    }

    /**
     * @name email
     * @description sends an email to package creater that a caught exception has ocurred
     * 
     * TO DO set up the ability to register email in an external source and callout to api (Google Drive?)
     * this is so that you can change the address and every package that uses this class will reflect the change
     *
     * @return void
    **/
    global void email(){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        recipientAddresses.add(creedAddress);

        String body = getMessageBody( ex );

        message.setHtmlBody( body );
        message.setSubject( 'Caught Apex Exception in org: ' + orgName );
        message.setToAddresses( recipientAddresses );

        message.setSaveAsActivity( false );
        message.setUseSignature( false );

        Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ message } );
    }

    /**
     * @name addMessage
     * @description appends a custom message exception message
     * @param String message
     * @return void
    **/
    global void addMessage( String message ){
        appendedMessage = message;
    }

    /**
     * @name addAddress
     * @description appends additional recipient email addresses
     * @param String address
     * @return void
    **/
    global void addAddress( String address ){
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(address);

        if( !myMatcher.matches() ){
            System.debug('Error while attempting to add a recipient address in CreedExceptionHandler. ' + address + ' is an invalid email address.');
            return;
        }

        recipientAddresses.add( address );
    }

/**
 * UTILITY METHODS
**/

    /**
     * @name getMessageBody
     * @description assembles message body
     * @param Exception e
     * @return String
    **/
    private String getMessageBody( Exception e ){
        String message = 'Hello! Unfortunately a caught exception has ocurred in ' + orgName + '\'s org. See details below.<br/><br/>';

        message += getUserDetails() + '<br/><br/>';
        message += getExceptionDetails( e );

        if( errorRecords.size() > 0 ){
            message += '<br/><br/>' + getRecordDetails();
        }
        
        return message;
    }

    /**
     * @name getUserDetails
     * @description assembles the details of the user when the exception occured
     * @return String
    **/
    private String getUserDetails(){
        String message = '<h3><b> User details: </b></h3>';

        message += 'User Name: ' + UserInfo.getName() + '<br/>';
        message += 'User Email: ' + UserInfo.getUserEmail(); 

        return message;
    }

    /**
     * @name getExceptionDetails
     * @description assembles the details of the Exception Object
     * @param Exception e
     * @return String
    **/
    private String getExceptionDetails( Exception e ){
        String message = '<h3><b> Exception details: </b></h3>';
        
        message += '<b>Exception type caught:</b> ' + e.getTypeName() + '<br/>'; 
        message += '<b>Exception Message:</b> ' + e.getMessage() + '<br/>';

        if( appendedMessage != null ){
            message += '<b>Custom Message:</b> ' + appendedMessage + '<br/>';
        }

        if( e.getCause() != null ){
            message += '<b>Cause:</b> ' + e.getCause() + '<br/>';
        }

        message += '<b>Line number:</b> ' + e.getLineNumber() + '<br/>';    
        message += '<b>Stack trace:</b> ' + e.getStackTraceString();

        return message;
    }

    /**
     * @name getRecordDetails
     * @description assembles record details if there are an records that accompany the excpetion
     * @param Exception e
     * @return String
    **/
    private String getRecordDetails(){
        DescribeSObjectResult describe = errorRecords[0].Id.getSObjectType().getDescribe();

        String message = '<h3><b> Record details (Errors ocurred with these ' + describe.getName() + '\'s): </b></h3>';

        for( SObject record : errorRecords ){
            message += '<b>Id:</b> ' + record.Id + '<br/><br/>';
        }

        return message;
    }
}