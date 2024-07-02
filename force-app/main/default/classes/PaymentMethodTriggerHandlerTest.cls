@isTest
private class PaymentMethodTriggerHandlerTest {
    
    @testSetup
    static void setup() {

    	// test memberships
    	List<Account> memberships = new List<Account>();

    	// test membership with dummy email address
    	Account membershipDummyEmail = new Account(
    		Name = 'testMembershipDummyEmail',
    		Email__c = 'example@example.com'
    	);
    	memberships.add(membershipDummyEmail);

    	Account membershipRealEmail = new Account(
    		Name = 'testMembershipRealEmail',
    		Email__c = 'test@email.com'
    	);
    	memberships.add(membershipRealEmail);
    	insert memberships;


    	// test members
    	List<Contact> members = new List<Contact>();
    	Id contactLeadRecordType = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Lead').RecordTypeId;

    	// test member associated to membership with dummy email
    	Contact memberDummyEmail = new Contact(
    		RecordTypeId = contactLeadRecordType,
    		Salutation = 'Mr',
    		FirstName = 'firstName',
    		LastName = 'testMemberDummyEmail',
    		AccountId = membershipDummyEmail.Id
    	);
    	members.add(memberDummyEmail);

    	// test member associated to membership with real email
    	Contact memberRealEmail = new Contact(
    		RecordTypeId = contactLeadRecordType,
    		Salutation = 'Dr',
    		FirstName = 'firstName',
    		LastName = 'testMemberRealEmail',
    		AccountId = membershipRealEmail.Id
    	);
    	members.add(memberRealEmail);

    	insert members;

    	// test payment methods
    	List<Payment_Method__c> paymentMethods = new List<Payment_Method__c>();
    	Id paymentMethodDirectDebitRecordTypeId = Schema.SObjectType.Payment_Method__c.RecordTypeInfosByName.get('Direct Debit').RecordTypeId;

    	// test payment method associated to membership with dummy email
		Payment_Method__c paymentMethodDummyEmail = new Payment_Method__c(
			RecordTypeId = paymentMethodDirectDebitRecordTypeId,
			Status__c = 'Active',
			Membership__c = membershipDummyEmail.Id,
			Bank_Account_Name__c = 'testBankAccount'
		);
		paymentMethods.add(paymentMethodDummyEmail);

		// test payment method associated to membership with dummy email
		Payment_Method__c paymentMethodRealEmail = new Payment_Method__c(
			RecordTypeId = paymentMethodDirectDebitRecordTypeId,
			Membership__c = membershipRealEmail.Id,
			Status__c = 'Active',
			Mandate_Amount__c = 1.0,
			Bank_Account_Name__c = 'testBankAccount'
		);
		paymentMethods.add(paymentMethodRealEmail);

		insert paymentMethods;
        
    }

    @isTest
    static void testCorrespondenceCreatedForDummyEmail(){
    	List<Correspondence__c> correspondences = [SELECT Id FROM Correspondence__c];
    	System.assertEquals(1, correspondences.size());
    }

    @isTest
    static void testNewPendingTransactionCreated(){
    	List<Transaction__c> transactions = [SELECT Id FROM Transaction__c];

    	// since we are testing various scenarios, we insert various payment methods
    	// need to assert correct number of transactions created
    	System.assertEquals(2, transactions.size());
    }

    @isTest
    static void testPaymentMethodStatusCancelTransactionRejected(){
    	// update payment method
    	Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Status__c = 'Active' LIMIT 1].get(0);
    	paymentMethod.Status__c = 'Cancelled';
    	update paymentMethod;

    	// assert that a new transaction record has been created
    	List<Transaction__c> transactions = [SELECT Id FROM Transaction__c WHERE Status__c = 'Cancelled'];
    	System.assertEquals(1, transactions.size());

    }

    @isTest
    static void testPaymentMethodStatusRejectTransactionRejected(){
    	// update payment method
    	Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Status__c = 'Active' LIMIT 1].get(0);
    	paymentMethod.Status__c = 'Rejected';
    	update paymentMethod;

    	// assert that a new transaction record has been created
    	List<Transaction__c> transactions = [SELECT Id FROM Transaction__c WHERE Status__c = 'Rejected'];
    	System.assertEquals(1, transactions.size());

    }

    @isTest
    static void testPaymentMethodMandateAmountChangeCorrespondenceCreated(){
    	// assert 1 correspondence record in db from dummy email membership
    	List<Correspondence__c> correspondences = [SELECT Id FROM Correspondence__c];
    	System.assertEquals(1, correspondences.size());


    	Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Status__c = 'Active' LIMIT 1].get(0);
    	paymentMethod.Mandate_Amount__c = 2.0;
    	update paymentMethod;

    	// assert new correspondence record created from payment method update
    	correspondences = [SELECT Id FROM Correspondence__c];
    	System.assertEquals(2, correspondences.size());
    }

    @isTest 
    static void testNewPaymentMethodCorrespondenceCreated(){
    	TriggerRecursionCheck.preventCorrespondenceCreation = false;

    	// assert 1 correspondence record in db from dummy email membership
    	List<Correspondence__c> correspondences = [SELECT Id FROM Correspondence__c];
    	System.assertEquals(1, correspondences.size());

    	// get existing membership from db
    	Account membership = [SELECT Id FROM Account WHERE Name = 'testMembershipDummyEmail'];

    	// create new payment method and associate to existing account
    	Id paymentMethodDirectDebitRecordTypeId = Schema.SObjectType.Payment_Method__c.RecordTypeInfosByName.get('Direct Debit').RecordTypeId;
    	Payment_Method__c newPaymentMethod = new Payment_Method__c(
    		RecordTypeId = paymentMethodDirectDebitRecordTypeId,
			Membership__c = membership.Id,
			Status__c = 'Active',
			Mandate_Amount__c = 11.0,
			Bank_Account_Name__c = 'testBankAccountNew'
    	);
    	insert newPaymentMethod;

    	// assert number of correspondences in db from new payment method creation
    	correspondences = [SELECT Id FROM Correspondence__c];
    	System.assertEquals(2, correspondences.size());
    }





















}