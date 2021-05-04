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
            ExceptionHandler handler = new ExceptionHandler( e );
            handler.addMessage( getOrgWideAddressQueryError( addressName ) );
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
            handler.addMessage( getTemplateQueryError( name ) );
            handler.handle();
        }

        return template;
    }

    private static String getTemplateQueryError( String name ){
        String ret = '';
        
        ret += 'Failed attempt to query Template with name of ' + name + '. '; 
        ret +=  'One of the Connect Team\'s email template unique names has been ill advisedly changed. ';
        ret +=  'Please change them back to ' + Constants.NEW_EMAIL_TEMPLATE_NAME + ' and ' + Constants.CLOSED_EMAIL_TEMPLATE_NAME;
        
        return ret;
    }

    private static String getOrgWideAddressQueryError( String address ){
        String ret = '';

        ret += 'Failed attempt to query Org Wide Address with address of ' + address + '. ';
        ret += 'This address is found in Custom Label \'Connect Team From Email Address\'. ';
        ret += 'Change this label to match appropriate Org Wide Email Address. This is for email auto reply From line.';

        return ret;
    }
}
