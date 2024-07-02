/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ChangeDetailsControllerTest {

    private static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        constants c = new constants();
        test.startTest();
        PageReference pageRef = page.ChangeDetails;
        Club_Product__c cp = new Club_Product__c();
        cp.RecordTypeId = c.clubProdMembershipCodeRecordTypeId;
        cp.Name = 'Digital';
        cp.Product_Detail__c = 'Digital Membership';
        cp.Active__c = true;
        cp.Show_in_New_Membership_Picklist__c = true;
        cp.Sections_Allowed__c = true;
        cp.Associate_Allowed__c = true;
        cp.PartnerAllowed__c = true;
        cp.DD_Payment_Allowed__c = true;
        insert cp;
        
         Account acc = new Account();
         acc.Name = 'Test Membership';
         acc.Membership_Code__c = cp.Id;
        insert acc;
        Opportunity opp = new Opportunity ();
        opp.name = 'testOppty';
        opp.AccountId=acc.id;
        Opp.StageName='Open';
  		opp.CloseDate=System.today();        
        insert opp;
                
        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',acc.id);
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        ChangeDetailsController cont = new ChangeDetailsController(sc);
        
        ChangeDetailsController cont2 = new ChangeDetailsController(sc);
        PageReference pageref2 = cont2.ChangePaymentDetails();
        
        ChangeDetailsController cont3 = new ChangeDetailsController(sc);
        PageReference pageref3 = cont3.ChangeMembership();
        
        ChangeDetailsController cont4 = new ChangeDetailsController(sc);
        PageReference pageref4 = cont4.ChangeAtRenewal();
        
        ChangeDetailsController cont5 = new ChangeDetailsController(sc);
        PageReference pageref5 = cont5.ChangeAddress();
        
        ChangeDetailsController cont6 = new ChangeDetailsController(sc);
        PageReference pageref6 = cont6.NewChildMember();
        
        ChangeDetailsController cont7 = new ChangeDetailsController(sc);
        PageReference pageref7 = cont7.NewSecondarymember();
        
        club_product__c cp2 = cont7.cp;
        PageReference NewAccessMember = cont7.NewAccessMember();
        
        
        
        
        
        test.stopTest();
        
        
        

        
        
        
        
        
        
        
        
        
    }
}