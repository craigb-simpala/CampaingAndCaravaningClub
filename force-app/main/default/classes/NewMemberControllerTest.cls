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
private class NewMemberControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
     Constants sc = new Constants();
        
        test.startTest();
        
        PageReference pageRef = page.NewAccessMember;
        Date LMDob = Date.newInstance(1972, 01, 01);

        
        Account acc = new Account();
        acc.Name = 'Test Membership';
        insert acc;
        
        Opportunity opp = new opportunity();
        opp.name = 'Test Opp';
        opp.AccountId = acc.id;
        opp.StageName='Open';
        opp.CloseDate=System.today();
        insert opp;
        
               
        
        Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =sc.leadContactRecordTypeId, AccountId=acc.id, mobilephone='07985468888', email='tony@tony.com');
        insert con; 
        
        Contact con2 = new Contact(FirstName = 'Tony', LastName = 'Jr.', Phone = '01232324', RecordTypeId =sc.secondaryContactRecordTypeId, AccountId=acc.id, mobilephone='07985468888', email='tony@tony.com');
        //insert con2;
        
    
        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accid',acc.id);
        pageref.getParameters().put('returl','TX');
        pageref.getParameters().put('rtid',sc.secondaryContactRecordTypeId);
        
        Apexpages.StandardController c = new ApexPages.standardController(con2);
        NewMemberController nwc = new NewMemberController(c);
        
        
        Test.setCurrentPage(pageRef);
        
        nwc.Bday= LMDob.format();
        
        //nwc.returl = 'return url';
        pagereference cancl = nwc.cancl();
        string getVFPageName = nwc.getVFPageName();
        pagereference saverec = nwc.saverec();
        pagereference newRec = nwc.newRec();
        
        
    }
}