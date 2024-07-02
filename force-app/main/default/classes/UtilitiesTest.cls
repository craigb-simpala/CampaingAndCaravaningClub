/**
 * @description       : Generic utilities that can be used across the org.
 * @author            : Kev Cadger (kevin.cadger@wipro.com)
 * @group             : Generic
 * @last modified on  : 03-03-2022
 * @last modified by  : Kev Cadger (kevin.cadger@wipro.com)
 * Modifications Log
 * Ver   Date         Author                        Request                         Modification
 * 1.0   01-03-2022   Kev Cadger                    REQ-000109128                   Initial Version
**/

/**
 * Method naming:
 * - test denotes a test method.
 * - _{Method} denotes the method being tested.
 * - _F for failure expected.
 * - _S for success expected.
 * - _{Criteria} shows what is being tested.
 */

@IsTest
public class UtilitiesTest {

    /**
    * @description Tests the validateDirectDebitInfo with blank values. 
    * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022 
    * @result Failure expected due to the blank direct debit info.
    **/
    @IsTest
    static void test_ValidateDirectDebitInfo_F_BlankValues() {
        Lead lead = getNewLead();

        Test.startTest();
        Boolean isValid = Utilities.validateDirectDebitInfo(lead);
        Test.stopTest();
        
        System.assertEquals(false, isValid, 'Failure expected due to the blank direct debit info.');
    }

    /**
    * @description Tests the validateDirectDebitInfo with invalid account number.
    * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022 
    * @result Failure expected due to the invalid account number.
    **/
    @IsTest
    static void test_ValidateDirectDebitInfo_F_InvalidAccountNumber() {
        Lead lead = getNewLead();
        lead.Bank_Account_Name__c = 'Testy McTesterton';
        lead.Bank_Account_Number__c = '00000000';
        lead.Bank_Name__c = 'Test Bank';
        lead.Sort_Code__c = '123456';

        Test.startTest();
        Boolean isValid = Utilities.validateDirectDebitInfo(lead);
        Test.stopTest();
        
        System.assertEquals(false, isValid, 'Failure expected due to the invalid account number.');
    }

    /**
    * @description Tests the validateDirectDebitInfo with invalid sort code. 
    * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022 
    * @result Failure expected due to the invlaid sort code.
    **/
    @IsTest
    static void test_ValidateDirectDebitInfo_F_InvalidSortCode() {
        Lead lead = getNewLead();
        lead.Bank_Account_Name__c = 'Testy McTesterton';
        lead.Bank_Account_Number__c = '00000001';
        lead.Bank_Name__c = 'Test Bank';
        lead.Sort_Code__c = '000000';

        Test.startTest();
        Boolean isValid = Utilities.validateDirectDebitInfo(lead);
        Test.stopTest();
        
        System.assertEquals(false, isValid, 'Failure expected due to the invlaid sort code.');
    }

    /**
    * @description Tests the validateDirectDebitInfo with correct direct debit details. 
    * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022 
    * @result Success expected due to the correct direct debit details.
    **/
    @IsTest
    static void test_ValidateDirectDebitInfo_S() {
        Lead lead = getNewLead();
        lead.Bank_Account_Name__c = 'Testy McTesterton';
        lead.Bank_Account_Number__c = '00000001';
        lead.Bank_Name__c = 'Test Bank';
        lead.Sort_Code__c = '123456';

        Test.startTest();
        Boolean isValid = Utilities.validateDirectDebitInfo(lead);
        Test.stopTest();
        
        System.assertEquals(true, isValid, 'Success expected due to the correct direct debit details.');
    }

    /**
    * @description Generates a blank lead with minimal data for testing.
    * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022 
    * @return Lead 
    **/
    private static Lead getNewLead() {
        Lead lead = new Lead(
            Bank_Account_Name__c = '',
            Bank_Account_Number__c= '',
            Bank_Name__c = '',
            Company = 'McTesterton',
            FirstName = 'Testy',    
            LastName = 'McTesterton',
            Sort_Code__c = ''
        );

        insert lead;

        return lead;
    }
}