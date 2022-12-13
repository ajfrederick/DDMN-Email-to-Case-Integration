/**
 * @name TestEmailAppUtil
 * @description this tests EmailAppUtil class to cover Exception paths
 */
@isTest(SeeAllData = true)
public class TestEmailAppUtil {

    @IsTest
    static void test(){
    
        Integer numberOfEmailsSent = 0;
        
        Test.startTest();

            EmailAppUtil.getOrgWideEmailAddress('');
            EmailAppUtil.getTemplate('');

            numberOfEmailsSent = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals( 2, numberOfEmailsSent );
    }
}