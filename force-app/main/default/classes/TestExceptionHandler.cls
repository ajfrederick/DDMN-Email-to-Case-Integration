/**
 * @name TestExceptionHandler
 * @description this us a unit test of the exception handler class
 */
@isTest(SeeAllData=true)
public class TestExceptionHandler {
    
    @IsTest
    static void testHandler(){
        Contact contact = new Contact();

        Integer numberOfEmailsSent = 0;

        Test.startTest();

            try {
                insert contact;
            } catch( Exception e ){
                ExceptionHandler handler = new ExceptionHandler(e);
                handler.handle();
            }

            numberOfEmailsSent = Limits.getEmailInvocations();
            
        Test.stopTest();


        System.assertEquals( null, contact.Id );
        System.assertEquals( 1, numberOfEmailsSent );
        
    }
}
