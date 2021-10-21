/**
 * @name Utils
 * @description general utility class
**/
public class Utils {

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
            CreedExceptionHandler handler = new CreedExceptionHandler( e );
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
            CreedExceptionHandler handler = new CreedExceptionHandler( e );
            handler.addMessage( 'Failed attempt to query Template with name of ' + name + '. ');
            handler.handle();
        }

        return template;
    }
}