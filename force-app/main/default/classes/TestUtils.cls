/**
 * @name TestUtils
 * @description this tests Utils class to cover Exception paths
 */
@isTest(SeeAllData = true)
public class TestUtils {

    @IsTest
    static void testUtils(){
    
        Integer numberOfEmailsSent = 0;
        
        Test.startTest();

            Utils.getOrgWideEmailAddress('');
            Utils.getTemplate('');

            numberOfEmailsSent = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals( 2, numberOfEmailsSent );
    }
}
