/**
 * @name CreedExceptionHandlerTest
 * @description this is a unit test of the exception handler class
 */
@isTest(SeeAllData=true)
public class CreedExceptionHandlerTest {
    
    @IsTest
    static void testHandler(){
        Contact contact = new Contact();

        Integer numberOfEmailsSent = 0;

        Test.startTest();

            try {
                insert contact;
            } catch( Exception e ){
                CreedExceptionHandler handler = new CreedExceptionHandler(e);
                handler.addAddress('test@me.com');
                handler.handle();
            }

            numberOfEmailsSent = Limits.getEmailInvocations();
            
        Test.stopTest();


        System.assertEquals( null, contact.Id );
        System.assertEquals( 1, numberOfEmailsSent );
        
    }
}