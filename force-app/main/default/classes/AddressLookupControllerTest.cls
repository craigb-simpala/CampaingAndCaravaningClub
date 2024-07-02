/*
* @who   Patrick Duncan <patrick.duncan@weare4c.com>
* @what  Test class for AddressLookupController
* @when  22/7/2019
*/
@isTest
private class AddressLookupControllerTest {

	/*
	* @method AddressLookupController.lookupAddress
   	* @case when making a callout with a set of parameters
   	* @result expect 3 seperate addresses to be mocked
   	*/
    static testMethod void getAddresses() {
        Test.setMock(WebServiceMock.class, new HopewiserMockResponse());
        List<String> params = new List<String>{'TEST-----XX'};
        List<List<String>> result = AddressLookupController.lookupAddress(params);
        System.assertEquals(3, result.get(0).size());

    }

    /*
	* @method AddressLookupController.setAddress
   	* @case when saving a lead with a new address
   	* @result expect the lead to contain the updated fields 
   	*/
    static testMethod void setAddress() {
       	Lead l = new Lead(LastName='Test',Company='Testy');
       	insert l;
       	String address = '1/1 11 Test street, Teston, TEST 1'; 
        AddressLookupController.setAddress(l.Id, address);

        List<Lead> updatedLead = [SELECT Id, Street, PostalCode, City FROM Lead WHERE Id = :l.Id];
        System.assertEquals('1/1 11 Test street', updatedLead.get(0).Street);
        System.assertEquals('Teston', updatedLead.get(0).City);
        System.assertEquals('TEST 1', updatedLead.get(0).PostalCode);

    }
}