@isTest
private class PaymentSuccessControllerTests {
	
	static PaymentSuccessController psc;
	static Account acc;
	static PageReference page;
	static Lead lead;
	static Club_Opportunity_Product__c cop;
	static constants sc;
	static Contact cAssocMember;
	static Opportunity o;
	
	static void init(){
	    
        TestDataFactory.testDataforPaymentMethod();
		sc = new constants();
    	acc = [Select Id, Membership_Status__c, date_joined__c FROM Account];  
    	lead = [Select Id, LastName,Email,sections__c FROM Lead];
    	cop = [Select Id, recordtypeId, price__c, Status__c from Club_Opportunity_Product__c limit 1];
		cAssocMember = [select title,firstname,lastname,birthdate from Contact where date_ended__c = null and accountid=:acc.id and recordtypeid=:sc.associateContactRecordTypeId limit 1];
		o = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
		 
	}

    static testMethod void PaymentSuccessControllerTestWithCancelledResult() {
    	init();
		psc = new PaymentSuccessController();  
		psc.ref = lead.Id;
		psc.lea = lead; 
		psc.result = 'CANCELLED';
		psc.ConvertLead();
    }

    static testMethod void PaymentSuccessControllerTestWithNoResultAndNoAccount() {
    	init();
		psc = new PaymentSuccessController();   
		psc.result = 'CANCELLED';
		lead.Company = 'hello';
		update lead;
        acc.Membership_Status__c = 'Ex-Member';
        update acc;
		psc.ref = lead.Id;
		psc.lea = lead;
		psc.ConvertLead();
    }

	static testMethod void PaymentSuccessControllerTestWithNoResultAndNoAccount2() {
		init();
		psc = new PaymentSuccessController();
		psc.result = 'FAILED';
		lead.Company = '1hello';
		update lead;
		acc.Membership_Status__c = 'Cancelled';
		update acc;
		psc.ref = lead.Id;
		psc.lea = lead;
		psc.ConvertLead();
	}

    static testMethod void PaymentSuccessControllerTestWithFailedResult() {
    	init();
		psc = new PaymentSuccessController();   
		psc.ref = lead.Id;
		psc.lea = lead;
		psc.result = 'FAILED';
		psc.ConvertLead();

    }

    static testMethod void PaymentSuccessControllerTestWithNoResult() {
    	init();
		cop.Price__c= 10;
		cop.Status__c = 'Active';
		psc = new PaymentSuccessController();   
		psc.ref = lead.Id;
		psc.lea = lead;   	
		psc.result = '';
        Test.startTest();
		psc.ConvertLead();
        test.stopTest();
		update cop;

    }

    static testMethod void PaymentSuccessControllerTestWithNoMembershipStatus() {
    	init(); 
		psc = new PaymentSuccessController();  
		psc.ref = lead.Id;
		psc.lea = lead;     	  	
    	acc.Membership_Status__c='Paid';
    	acc.Payment_Method2__c = 'Direct Debit';
    	update acc;
		//psc.result = '';
        test.startTest();
		psc.ConvertLead();
        test.stopTest();

    }

    static testMethod void PaymentSuccessControllerTestWithNoLeadPartner() {
    	init();  
		psc = new PaymentSuccessController();   	  	
    	acc.Membership_Status__c='Paid';
    	update acc;  	  	
    	lead.hasPartner__c=false;
    	lead.hasAssociate__c = true;
        Lead.Secondary_Member_First_Name__c = null;
        Lead.Secondary_Member_Surname__c = null;
        Lead.Secondary_Member_Title__c = null;
        update lead;
    	cop.RecordTypeId = sc.amRecordTypeId;
    	update cop;
		psc.ref = lead.Id;
		psc.lea = lead; 
		psc.result = '';
        test.startTest();
		psc.ConvertLead();
        test.stopTest();

    }

    static testMethod void PaymentSuccessControllerTestWithDCCPaymentMethodOnLead() {
    	init();
		cop.Price__c= 10;
		cop.Status__c = 'Active';
		psc = new PaymentSuccessController();      	  	
    	lead.Payment_Method__c='Debit/Credit Card';
    	update lead;
		psc.ref = lead.Id;
		psc.lea = lead; 
		psc.result = '';
        Test.startTest();
		psc.ConvertLead();
        Test.stopTest();
		//update cop;

    }

    static testMethod void PaymentSuccessControllerTestWithCashPaymentMethodOnLeadANDWithoutcAssocMember() {
    	init();
		cop.Price__c=10;
		cop.Status__c = 'Active';
		psc = new PaymentSuccessController();
    	lead.Payment_Method__c='Cash/Cheque';
    	update lead;
    	cAssocMember.date_ended__c = system.today();
    	update cAssocMember;
		psc.ref = lead.Id;
		psc.lea = lead; 
		psc.result = '';
		system.debug('running in error now ');
		Test.startTest();
		psc.ConvertLead();
		Test.stopTest();
		//update cop;

    }

    static testMethod void PaymentSuccessControllerTestWithRenewalOppData() {
    	init();
		cop.Price__c=10;
		cop.Status__c = 'Active';
		psc = new PaymentSuccessController();     
    	TestDataFactory.createRenewalTestRecords(); 
		psc.ref = lead.Id;
		psc.lea = lead;
        Test.startTest();
    	psc.ConvertLead();
        Test.stopTest();
		update cop;

    }

    static testMethod void PaymentSuccessControllerTestWithNoResultAndNoAccWithOpp() {
    	//init();    
    	TestDataFactory.testDataforPaymentMethod();
		sc = new constants();
    	lead = [Select Id, LastName,Email,sections__c FROM Lead];
    	cop = [Select Id, recordtypeId from Club_Opportunity_Product__c limit 1];   
		o = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
		lead.Company = o.Id;
		update lead;
		psc = new PaymentSuccessController();
		psc.ref = lead.Id;
		psc.lea = lead;
		system.debug('PaymentSuccessControllerTestWithNoResultAndNoAccWithOpp '+acc);
		//psc.ConvertLead();
    }

    static testMethod void PaymentSuccessControllerTestWithNoResultAndNoAccWithOppAndAssoc() {
    	//init();    
    	TestDataFactory.testDataforPaymentMethod();
		sc = new constants();
    	lead = [Select Id, LastName,Email,sections__c,hasPartner__c,hasAssociate__c, Payment_Method__c FROM Lead];
    	cop = [Select Id, recordtypeId from Club_Opportunity_Product__c limit 1];   
		o = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
		lead.Company = o.Id;
		lead.hasPartner__c = false;
		lead.hasAssociate__c = true;
		lead.Payment_Method__c='Debit/Credit Card';
        Lead.Secondary_Member_First_Name__c = null;
        Lead.Secondary_Member_Surname__c = null;
        Lead.Secondary_Member_Title__c = null;
		update lead;
		psc = new PaymentSuccessController();
		psc.ref = lead.Id;
		psc.lea = lead;
		system.debug('PaymentSuccessControllerTestWithNoResultAndNoAccWithOppAndAssoc '+acc);
        test.startTest();
		psc.ConvertLead();
        test.stopTest();
    }

    static testMethod void PaymentSuccessControllerTestWithNoResultAndNoAccWithOppAndNoAssoc() {
    	//init();    
    	TestDataFactory.testDataforPaymentMethod();
		sc = new constants();
    	lead = [Select Id, LastName,Email,sections__c,hasPartner__c,hasAssociate__c, Payment_Method__c FROM Lead];
    	cop = [Select Id, recordtypeId, Product__c, Price__c, Status__c from Club_Opportunity_Product__c limit 1];
		o = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
		Club_Product__c cp = [Select id,SectionsAreFree__c, Product_Detail__c, name, (SELECT Id, Price__c, Start_Date__c, End_Date__c FROM Prices__r) from Club_Product__c where Product_Detail__c = 'Association of Lightweight Camper'];
		cAssocMember = [select title,firstname,lastname,birthdate from Contact where date_ended__c = null and recordtypeid=:sc.associateContactRecordTypeId limit 1];
		cAssocMember.Date_Ended__c = system.today();
		update cAssocMember;
		lead.Company = o.Id;
		lead.hasPartner__c = false;
		lead.hasAssociate__c = true;
		lead.Payment_Method__c='Cash/Cheque';
        Lead.Secondary_Member_First_Name__c = null;
        Lead.Secondary_Member_Surname__c = null;
        Lead.Secondary_Member_Title__c = null;
		update lead;
		cop.Price__c = 10;
		cop.Status__c = 'Active';
		update cop;
		psc = new PaymentSuccessController();
		psc.ref = lead.Id;
		psc.lea = lead;
		List<sectionSelectWrapper> sections = new List<sectionSelectWrapper>();
		sectionSelectWrapper s = new sectionSelectWrapper(cp, cp.Prices__r, true);
		sections.add(s);
		psc.sections = sections;
		system.debug('PaymentSuccessControllerTestWithNoResultAndNoAccWithOppAndNoAssoc '+acc);
        Test.startTest();
		psc.ConvertLead();
        Test.stopTest();
    }
}