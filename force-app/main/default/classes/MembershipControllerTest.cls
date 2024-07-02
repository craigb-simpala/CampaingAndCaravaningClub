@isTest
public with sharing class MembershipControllerTest {

	@testSetup
	static void testSetup(){
        // record types
		Id mtRecordTypeId = Schema.SObjectType.Club_Product__c.getRecordTypeInfosByName().get('Membership Code').getRecordTypeId();
		Id sectionRecordTypeId = Schema.SObjectType.Club_Product__c.getRecordTypeInfosByName().get('Section').getRecordTypeId();


        // test membership types
		List<Club_Product__c> membershipTypes = new List<Club_Product__c>();
		for(Integer i=0;i<5;i++){
            // test club membership club product
			Club_Product__c membershipProduct  = new Club_Product__c(
                Name = 'Test'+i,
                RecordTypeId = mtRecordTypeId,
                Sections_Allowed__c = true,
                Visible_to_Admin_Users_Only__c = false,
                Show_in_New_Membership_Picklist__c = true
            );
            
            // test club section club product
			Club_Product__c sectionProduct  = new Club_Product__c(
                Name = 'TS'+i,
                Product_Detail__c = 'Test'+i+5,
                RecordTypeId = sectionRecordTypeId
            );
            
			membershipTypes.add(membershipProduct);
			membershipTypes.add(sectionProduct);
		}
		insert membershipTypes;

        // test new membership
		Lead newMembership = new Lead(
            LastName = 'Test',
            Company = 'Testy',
            Membership_Type__c = membershipTypes.get(0).Id,
            sections__c = 'TS0:TS1'
        );
		insert newMembership;
	}
	/*
	* @method getMembershipTypes
	* @case when retrieving all the Club_Product__c's of type Membership Code
	* @result expect there to be 5 records
    */
    @isTest
	static void testMembershipTypeProducts(){
		List<Club_Product__c> membershipTypes = MembershipController.getMembershipTypes();
		System.assertEquals(5, membershipTypes.size());
	}

	/*
	* @method getSelectedMembershipType
	* @case querying for the membership type lookup of a lead record
	* @result expect to retrieve the Membership type with name Test0
    */
    @isTest
	static void testGetNewMembershipMembershipType(){
		Lead l = [SELECT Id, Membership_Type__c FROM Lead LIMIT 1];
		Club_Product__c expectedMT = [SELECT Id, Name FROM Club_Product__c WHERE Name = 'Test0'];
		Club_Product__c resultMT = MembershipController.getSelectedMembershipType(l.Id);
		System.assertEquals(expectedMT.Id, resultMT.Id);
	}

	/*
	* @method getSelectedMembershipType
	* @case querying for all the Club_Product__c's of type Section
	* @result expect to retrieve 5 records
    */
    @isTest
	static void testGetSections(){
		Lead l = [SELECT Id, Membership_Type__c FROM Lead LIMIT 1];
		Club_Product__c expectedMT = [SELECT Id, Name FROM Club_Product__c WHERE Name = 'Test0'];
		List<MembershipController.Section> sections = MembershipController.getSections(l.Id);
		System.assertEquals(5, sections.size());
	}

	/*
	* @method saveChanges
	* @case saving the New Membership with 2 sections selected and Test1 Membership type selected
	* @result expect to retrieve one record with updated fields
    */
    @isTest
	static void testSaveChanges(){
		Lead l = [SELECT Id, Membership_Type__c FROM Lead LIMIT 1];
        
		Club_Product__c expectedMT = [SELECT Id, Name FROM Club_Product__c WHERE Name = 'Test1'];
        
		Map<Object,Object> m1 = new Map<Object,Object>();
		m1.put('selected', true);
		m1.put('abbreviation', 'T0');
        
		Map<Object,Object> m2 = new Map<Object,Object>();
		m2.put('selected', true);
		m2.put('abbreviation', 'T2');
        
		Object o1 = (Object) m1;
		Object o2 = (Object) m2;
		MembershipController.Section section = new MembershipController.Section('Test7', 'message', '123','T2');
		MembershipController.saveChanges(l.Id,new List<Object>{o1,o2},'Test1');
		List<Lead> results = [SELECT Id, sections__c, Membership_Type__c FROM Lead WHERE sections__c = 'T0:T2' AND Membership_Type__r.Id = :expectedMT.Id];
		System.assertEquals(1, results.size());
	}
    
}