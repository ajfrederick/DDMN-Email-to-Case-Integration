/**
 * @name Constants
 * @description constants for application scope
**/
public class Constants {
   
    public static final String FROM_ADDRESS = System.Label.Connect_Team_From_Email_Address;

    public static final String NEW_EMAIL_TEMPLATE_NAME = 'Connect_Team_Notification_of_New_Case';
    public static final String CLOSED_EMAIL_TEMPLATE_NAME = 'Connect_Team_Notification_of_Closed_Case';

    public static Id CONNECT_TEAM_RECORD_TYPE_ID;
    public static Id CONNECT_TEAM_QUEUE_ID;

    static {
        DescribeSObjectResult describe = Case.SObjectType.getDescribe();

        try {

            CONNECT_TEAM_RECORD_TYPE_ID = describe.getRecordTypeInfosByDeveloperName().get('Connect_Team').getRecordTypeId();
            
        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.addMessage('Someone probably renamed or deleted the case record type that belongs to the Connect Team');
            handler.handle();
        }

        try {

            Group g = [SELECT 
                        Id 
                            FROM Group 
                            WHERE DeveloperName = 'Connect_Team' 
                            AND Type = 'Queue'];
            
            if( g != null ){
                CONNECT_TEAM_QUEUE_ID = g.Id;
            }

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.addMessage('Someone probably renamed or deleted the queue that belongs to the Connect Team');
            handler.handle();
        }
    }
}
