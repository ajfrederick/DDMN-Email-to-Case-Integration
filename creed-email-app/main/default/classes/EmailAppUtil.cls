/**
 * @name EmailAppUtil
 * @description general utility class
**/
global class EmailAppUtil {

    global static Map<String, String> contentTypes = new Map<String, String>();

    static {
        contentTypes.put('css', 'text/css');
        contentTypes.put('csv', 'text/csv');
        contentTypes.put('doc', 'application/msword');
        contentTypes.put('docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        contentTypes.put('gif', 'image/gif');
        contentTypes.put('htm', 'text/html');
        contentTypes.put('html', 'text/html');
        contentTypes.put('jpeg', 'image/jpeg');
        contentTypes.put('jpg', 'image/jpeg');
        contentTypes.put('mp3', 'audio/mpeg');
        contentTypes.put('png', 'image/png');
        contentTypes.put('pdf', 'application/pdf');
        contentTypes.put('ppt', 'application/vnd.ms-powerpoint');
        contentTypes.put('rtf', 'application/rtf');
        contentTypes.put('tif', 'image/tiff');
        contentTypes.put('tiff', 'image/tiff');
        contentTypes.put('txt', 'text/plain');
        contentTypes.put('wav', 'audio/wav');
        contentTypes.put('xls', 'application/vnd.ms-excel');
        contentTypes.put('xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        contentTypes.put('xml', 'application/xml');
        contentTypes.put('zip', 'application/zip');
        contentTypes.put('7z', 'application/x-7z-compressed');
    }

    /**
     * @name getOrgWideEmailAddress
     * @description returns Org Wide Email Address
     * @param String addressName
     * @return OrgWideEmailAddress
    **/
    global static OrgWideEmailAddress getOrgWideEmailAddress( String addressName ){
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
    global static EmailTemplate getTemplate( String name ){
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