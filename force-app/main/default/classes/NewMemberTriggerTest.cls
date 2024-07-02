@istest(seealldata=true)
public class NewMemberTriggerTest {
    
		static testMethod void myUnitTest() {
        
       
       system.debug('inside the myUnitTest');
       
        Account acc = new Account();
        Contact con = new Contact();
        contact con2 = new Contact();
        Contact con3 = new Contact();
        Constants c = new constants();
        Lead lea = new Lead();
        Correspondence__c corr = new Correspondence__c();
            
       lea.FirstName = 'Test First';
	   lea.LastName = 'Test Last';
       lea.Company = 'Test Co';
       system.debug('inserting lead');
       insert lea;  
       system.debug('inserted lead ' + lea.Id);  
            
        acc.Name = 'Paul';
        acc.Renewal_Date__c = date.parse('19/01/2017');
        acc.District_Association__c =  'a0026000004RfSq';
        system.debug('inserting Account');
        /*insert acc;
        system.debug('inserted Account ' + acc.Id);
            
            
        con.AccountId = acc.Id;   
        con.RecordTypeId = c.associateContactRecordTypeId;
        con.Salutation = 'Mr';
        con.FirstName = 'Test';
        con.LastName = 'Testing';
        system.debug('inserting Contact');
        insert con;
        system.debug('inserted Contact ' + con.Id);

        con2.AccountId = acc.Id;
        con2.RecordTypeId = c.leadContactRecordTypeId;
        con2.Salutation = 'Mr';
        con2.FirstName = 'Test';
        con2.LastName = 'Testing';
        insert con2;
        
        con3.AccountId = acc.Id;
        con3.RecordTypeId = c.secondaryContactRecordTypeId;
        con3.Salutation = 'Mr';
        con3.FirstName = 'Test';
        con3.LastName = 'Testing';
        con3.Date_Ended__c = date.parse('18/01/2017');    
        insert con3;*/


        
            
        
        
        
            
        
        
    }
    

}