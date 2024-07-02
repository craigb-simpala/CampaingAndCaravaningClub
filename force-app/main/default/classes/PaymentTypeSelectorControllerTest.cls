@isTest
public class PaymentTypeSelectorControllerTest {
    
    @testSetup
    static void testSetup(){
        Club_Product__c clubProduct = new Club_Product__c(Allowed_Payment_Types__c='Direct Debit;Debit/Credit Card');
        insert clubProduct;
        Lead l = new Lead(Email='email@test.com',FirstName='Test',LastName='Lead',Company='Test',Membership_Type__c=clubProduct.Id);
        insert l;
	}
    
    @isTest
    static void test_getAllowedPaymentTypes(){
        Lead l = [SELECT Id, Email FROM Lead LIMIT 1];
        Test.startTest();
        	List<String> paymentTypes = PaymentTypeSelectorController.getAllowedPaymentTypes(l.Id);
        Test.stopTest();
        
        System.assert(paymentTypes.contains('Direct Debit'));     
	}
        
    @isTest
    static void test_saveNewMembershipBillingDetails(){
        Lead l = [SELECT Id, Bank_Account_Name__c, Bank_Account_Number__c, Sort_Code__c FROM Lead LIMIT 1];
        Test.startTest();
        PaymentTypeSelectorController.saveNewMembershipBillingDetails(l.Id, 'Direct Debit', new List<String>{'Acc name','12345678','123456'});
        Test.stopTest();
        Lead le = [SELECT Id, Bank_Account_Name__c, Bank_Account_Number__c, Sort_Code__c FROM Lead LIMIT 1];
        System.assertEquals('Acc name',le.Bank_Account_Name__c);     
        System.assertEquals('12345678',le.Bank_Account_Number__c);     
        System.assertEquals('123456',le.Sort_Code__c);     

	}

}