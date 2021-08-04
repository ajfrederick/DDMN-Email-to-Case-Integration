/**
 * @name Utils
 * @description general utility class
**/
public class Utils {

    public static final String FROM_ADDRESS = System.Label.Creed_Email_Messaging_Sender_Address;

    /**
     * @name getOrgWideEmailAddress
     * @description returns Org Wide Email Address
     * @param String addressName
     * @return OrgWideEmailAddress
    **/
    public static OrgWideEmailAddress getOrgWideEmailAddress( String addressName ){
        OrgWideEmailAddress address;

        try {

            address = [SELECT 
                Id,
                Address,
                DisplayName
                    FROM OrgWideEmailAddress
                    WHERE Address = :addressName];

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler( e );
            handler.addMessage( 'Failed attempt to query Org Wide Address with address of ' + addressName + '. ' );
            handler.handle();
        }

        return address;
    }

    /**
     * @name getTemplate
     * @description returns Email Template filtered by developerName
     * @param String name
     * @return EmailTemplate
    **/
    public static EmailTemplate getTemplate( String name ){
        EmailTemplate template;

        try {
            
            template = [SELECT 
                Id,
                Subject,
                Body,
                HtmlValue
                    FROM EmailTemplate
                    WHERE DeveloperName = :name];

        } catch( QueryException e ){
            ExceptionHandler handler = new ExceptionHandler( e );
            handler.addMessage( 'Failed attempt to query Template with name of ' + name + '. ');
            handler.handle();
        }

        return template;
    }
}