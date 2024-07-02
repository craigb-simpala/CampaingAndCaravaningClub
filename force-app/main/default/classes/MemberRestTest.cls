@isTest (SeeAllData=true)
public with sharing class MemberRestTest {
	
      	
      	static testMethod void testGetMemberDetails() {



	//Test.setMock(MemberRest.class, new MemberRest());

	MemberRest mem = new MemberRest();
	MemberRestPass mempass = new MemberRestPass();
	Products prods = new Products();

	TestDataFactory.createTestRecords();

      	
    RestRequest req = new RestRequest();
    RestRequest req2 = new RestRequest();
    RestRequest req3 = new RestRequest();
	RestResponse res = new RestResponse();

    // pass the req and resp objects to the method
	req.requestURI ='/services/apexrest/Membership';
	req2.requestURI ='/services/apexrest/MembershipWithPassword';
	req3.requestURI ='/services/apexrest/Products';
	req.params.put('MembershipNumber', '111');
	req2.params.put('MembershipNumber', '111');
	req2.params.put('MembershipNumber', '111');
	req.httpMethod = 'GET';
	req2.httpMethod = 'GET';
	req3.httpMethod = 'GET';
	RestContext.request = req;
   	RestContext.response = res;
	MemberRest.Result results = MemberRest.getMemberDetails();
	MemberRestPass.Result results2 = MemberRestPass.getMemberDetails();
	Products.Result results3 = Products.getProductPriceDetails();

	req.params.put('MembershipNumber', '');
	req2.params.put('MembershipNumber', '');
	results = MemberRest.getMemberDetails();
	results2 = MemberRestPass.getMemberDetails();
	Account a = [select id,Hybrid_Membership_Number__c from account limit 1];

	req.params.put('MembershipNumber', a.Hybrid_Membership_Number__c);
	req2.params.put('MembershipNumber', a.Hybrid_Membership_Number__c);
	results = MemberRest.getMemberDetails();
	results2 = MemberRestPass.getMemberDetails();
    /*
    Account a2 = [select id,Hybrid_Membership_Number__c from account where Hybrid_Membership_Number__c = '170574' ];
   	req2.params.put('MembershipNumber', a2.Hybrid_Membership_Number__c);
	results2 = MemberRestPass.getMemberDetails();
	*/
            /*
    Account a4 = [select id,Hybrid_Membership_Number__c from account where Hybrid_Membership_Number__c = '23487' ];
   	req4.params.put('MembershipNumber', a4.Hybrid_Membership_Number__c);
	results4 = MemberRestPass.getMemberDetails();
    */
            
    //getMemberDetails.MemberId results = getMemberDetails.doGet(req,res);

   // System.assertEquals('true', results.Errors);
    //System.assertEquals(10, results.records.size());
    //System.assertEquals('Query executed successfully.', results.message);

  }
        
    
}