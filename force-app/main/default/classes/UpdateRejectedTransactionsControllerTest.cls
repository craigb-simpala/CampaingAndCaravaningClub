/*
* @who   Patrick Duncan <patrick.duncan@weare4c.com>
* @what  Test class for UpdateRejectedTransactionsController
* @when  6/11/2019
*/
@isTest
public class UpdateRejectedTransactionsControllerTest {

	@testSetup
	static void setup(){
		// test account
		Account acc1 = new Account(
			Name = 'TestAcc1',
            Membership_Status__c = 'Active'
		);

		Account acc2 = new Account(
			Name = 'TestAcc2',
            Membership_Status__c = 'Active'
		);


		insert new List<Account>{acc1,acc2};


		// test payment method
		Payment_Method__c paymentMethod1 = new Payment_Method__c(
			RecordTypeId = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId(),
			Membership__c = acc1.Id,
            Status__c = 'Active'
		);
		

		Payment_Method__c paymentMethod2 = new Payment_Method__c(
			RecordTypeId = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId(),
			Membership__c = acc2.Id,
            Status__c = 'Active'
		);
		insert new List<Payment_Method__c>{paymentMethod1,paymentMethod2};

	}

	/*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an ARUDD xml which references one of the existing memberships
  	* @result expect the referenced membeship's status to be set to 'DD Rejected', its payment method's statuses to have been set to 'Rejected' and its payment method's transactions statuses
  	*/
    @isTest
    static void testARUDDTransactionUpdate(){
    	Id reportId = UpdateRejectedTransactionsController.createBACSReport('ARUDD');
    	String membershipNumber = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'].Membership_Number__c;

		// create attachment
		String xmlBody = '<ReturnedDebitItem ref="' + membershipNumber +'DIRECT DBT" transCode="17" returnCode="0161" returnDescription="REFER TO PAYER" originalProcessingDate="2019-06-14" valueOf="40.00" currency="GBP"></ReturnedDebitItem>';
		generateXmlDocAttachment(reportId, xmlBody);
        
		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'ARUDD');        
        
		// check update success
		Account membership = [SELECT Id, Membership_Status__c FROM Account].get(0);
		Payment_Method__c paymentMethod = [SELECT Id, Status__c FROM Payment_Method__c].get(0);
		Transaction__c trans0N = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0N'].get(0);

		System.assertEquals('DD Rejected', membership.Membership_Status__c);
		System.assertEquals('Rejected', paymentMethod.Status__c);
		System.assertEquals('Rejected', trans0N.Status__c);

    }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an ADDACS xml which references one of the existing memberships with code '1'
  	* @result expect the referenced membeship's payment method's status to have been set to 'Cancelled' and its transaction to have been set to 'Complete'
  	*/
    @isTest
    static void testADDACSTransactionUpdateReasonCode1(){
     	Id reportId = UpdateRejectedTransactionsController.createBACSReport('ADDACS');
     	Account membership = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];
     	Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Membership__c = :membership.Id];
     	List<Transaction__c> transactions = [SELECT Id, Status__c, Transaction_Type__c FROM Transaction__c WHERE Payment_Method__c = :paymentMethod.Id AND Status__c = 'Pending' AND Transaction_Type__c = '0N'];
     	transactions.get(0).Status__c = 'Complete';
     	update transactions;

     	String testAccountNumber = '12345678';
    	String testSortCode = '123456';
     	// create attachment

		String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership.Membership_Number__c;
			  xmlBody += 'DIRECT DBT" payer-name="MR B JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="1" aosn="00547721"  ';
		      xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"></MessagingAdvice></MessagingAdvices>\n';

		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'ADDACS');

		// check update success
		paymentMethod = [SELECT Id, Status__c FROM Payment_Method__c WHERE Membership__c = :membership.Id];
		Transaction__c trans0C = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0C' AND Payment_Method__c = :paymentMethod.Id];

		System.assertEquals('Cancelled', paymentMethod.Status__c);
		System.assertEquals('Complete', trans0C.Status__c);
    }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an ADDACS xml which references one of the existing memberships with code '3' with a new account name, number + sort code + st
  	* @result expect the referenced membeship's old payment method's status to have been set to 'Cancelled' and it to have 2 transactions, one of both 0N & 0C with the 0C set to cancelled, 
  					also a new payment method should have been created with the new account name, number + sort code and start date of today
  	*/
    @isTest
    static void testADDACSTransactionUpdateReasonCode3(){
     	Id reportId = UpdateRejectedTransactionsController.createBACSReport('ADDACS');
     	Account membership = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];
     	Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Membership__c = :membership.Id];
     	List<Transaction__c> transactions = [SELECT Id, Status__c, Transaction_Type__c FROM Transaction__c WHERE Payment_Method__c = :paymentMethod.Id AND Status__c = 'Pending' AND Transaction_Type__c = '0N'];
     	transactions.get(0).Status__c = 'Complete';
     	update transactions;
     	String testAccountNumber = '12345678';
    	String testSortCode = '123456';
    	String testAccountName = 'Test name';
    	Date testStartDate = Date.valueOf('2019-10-10');

     	String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" reference="' + membership.Membership_Number__c;
			   xmlBody += 'DIRECT DBT" payer-name="MR C JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="3" aosn="00547721"  ';
		       xmlBody += 'transaction-code="0C" payer-new-name="'+testAccountName+'" orig-sort-code="206563" orig-account-number="53405702" effective-date="'+testStartDate+'" original-proc-date="2019-06-11" originator-name="CCC"  ';
		       xmlBody += 'payer-new-account-number="'+testAccountNumber+'" payer-new-sort-code="'+testSortCode+'"></MessagingAdvice></MessagingAdvices>\n';

		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'ADDACS');

		Payment_Method__c paymentMethodCancelled = [SELECT Id, Status__c FROM Payment_Method__c WHERE Membership__c = :membership.Id AND Bank_Account_Number__c = NULL];
		List<Payment_Method__c> paymentMethodNew = [SELECT Id, Status__c, Bank_Account_Number__c, Sort_Code__c FROM Payment_Method__c WHERE Membership__c = :membership.Id AND 
													Bank_Account_Name__c =:testAccountName AND Bank_Account_Number__c =:testAccountNumber AND Sort_Code__c =:testSortcode AND Start_Date__c =:testStartDate];
		List<Transaction__c> trans0C = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0C' AND Payment_Method__c = :paymentMethodCancelled.Id];
		List<Transaction__c> trans0N = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0N' AND Payment_Method__c = :paymentMethodCancelled.Id];

		System.assertEquals('Cancelled', paymentMethodCancelled.Status__c);
		System.assertEquals(1, paymentMethodNew.size());
		System.assertEquals(1, trans0C.size());
		System.assertEquals(1, trans0N.size());
		System.assertEquals('Complete', trans0C.get(0).Status__c);
    }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an ADDACS xml which references one of the existing memberships with code 'B' 
  	* @result expect the referenced membeship's payment method's status to have been set to 'Cancelled' 
  	*/
    @isTest
    static void testADDACSTransactionUpdateReasonCodeB(){
     	Id reportId = UpdateRejectedTransactionsController.createBACSReport('ADDACS');
     	Account membership = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];
     	Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Membership__c = :membership.Id];
    	List<Transaction__c> transactions = [SELECT Id, Status__c, Transaction_Type__c FROM Transaction__c WHERE Payment_Method__c = :paymentMethod.Id AND Status__c = 'Pending' AND Transaction_Type__c = '0N'];
     	transactions.get(0).Status__c = 'Complete';
     	update transactions;
     	

     	String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership.Membership_Number__c;
			   xmlBody += 'DIRECT DBT" payer-name="MR C JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="B" aosn="00547721"  ';
		       xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"></MessagingAdvice></MessagingAdvices>\n';

		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'ADDACS');

		paymentMethod = [SELECT Id, Status__c FROM Payment_Method__c WHERE Membership__c = :membership.Id];
		
		System.assertEquals('Cancelled', paymentMethod.Status__c);
		
    }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an ADDACS xml which references one of the existing memberships with code 'E' with a new account number + sort code
  	* @result expect the referenced membeship's old payment method's status to have been set to 'Cancelled' and a new payment method to have been created with the new account number + sort code + start date of today
  	*/
    @isTest
    static void testADDACSTransactionUpdateReasonCodeE(){
     	Id reportId = UpdateRejectedTransactionsController.createBACSReport('ADDACS');
     	Account membership = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];

     	String testSortcode = '123456';
     	String testAccountNumber = '12345678';
     	
     	String newName = 'Testy';

     	String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" reference="' + membership.Membership_Number__c;
			   xmlBody += 'DIRECT DBT" payer-name="MR C JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="E" aosn="00547721"  ';
		       xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"  ';
		       xmlBody += 'payer-new-name="'+newName+'" payer-new-sort-code="'+testSortcode+'" payer-new-account-number="'+testAccountNumber+'"></MessagingAdvice></MessagingAdvices>\n';

		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'ADDACS');

		List<Payment_Method__c> cancelledPaymentMethod = [SELECT Id, Bank_Account_Name__c FROM Payment_Method__c WHERE Membership__c = :membership.Id AND Status__c = 'Cancelled'];
		List<Payment_Method__c> newPaymentMethod = [SELECT Id, Bank_Account_Name__c FROM Payment_Method__c WHERE Membership__c = :membership.Id AND Status__c = 'Active' 
													AND Start_Date__c = :Date.today() AND Bank_Account_Number__c = :testAccountNumber AND Sort_Code__c = :testSortcode];

		System.assertEquals(1, cancelledPaymentMethod.size());
		System.assertEquals(1, newPaymentMethod.size());
     }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an ADDACS xml which references one of the existing memberships with code 'R' 
  	* @result expect an error to have been creating which contains the membership number of the existing membership
  	*/
    @isTest
    static void testADDACSErrorReport(){
    	Id reportId = UpdateRejectedTransactionsController.createBACSReport('ADDACS');
    	Account membership1 = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];

    	// create attachment
		String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership1.Membership_Number__c;
			  xmlBody += 'DIRECT DBT" payer-name="MR B JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="R" aosn="00547721"  ';
		      xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"></MessagingAdvice></MessagingAdvices>\n';

		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'ADDACS');

		String errorLog = [SELECT Id, VersionData FROM ContentVersion WHERE Title = 'Error Log'].VersionData.toString();

		System.assert(errorLog.contains(membership1.Membership_Number__c));

	}


	/*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an AUDDIS xml which references one of the existing memberships with code '2' 
  	* @result expect the referenced payment method's status to have been set to 'DD Rejected', its payment method to have been set to rejected and it to have 2 transactions, one 0N, one 0C
  	*/
    @isTest
    static void testAUDDISTransactionUpdateReasonCode2(){
    	Id reportId = UpdateRejectedTransactionsController.createBACSReport('AUDDIS');
    	Account membership1 = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];

    	// create attachment
		String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership1.Membership_Number__c;
			  xmlBody += 'DIRECT DBT" payer-name="MR B JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="2" aosn="00547721"  ';
		      xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"></MessagingAdvice></MessagingAdvices>\n';


		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'AUDDIS');

		// check update success
		Account updatedMembership = [SELECT Id, Membership_Status__c FROM Account WHERE Id = :membership1.Id];

		Payment_Method__c paymentMethod = [SELECT Id, Status__c FROM Payment_Method__c WHERE Membership__c = :membership1.Id];
		
		List<Transaction__c> trans0C = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0C' AND Payment_Method__c = :paymentMethod.Id];
		List<Transaction__c> trans0N = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0N' AND Payment_Method__c = :paymentMethod.Id];

		System.assertEquals('DD Rejected', updatedMembership.Membership_Status__c);
		System.assertEquals('Rejected', paymentMethod.Status__c);
		System.assertEquals('Rejected', trans0N.get(0).Status__c);
		System.assertEquals('Complete', trans0C.get(0).Status__c);

    }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an AUDDIS xml which references one of the existing memberships with code 'C' 
  	* @result expect the referenced payment method's status to have been set to 'Cancelled' with two transactions, one 0N, one 0C, also a new payment method to have been created with the new sort code + account number
  	*/
    @isTest
    static void testAUDDISTransactionUpdateReasonCodeC(){
        Id reportId = UpdateRejectedTransactionsController.createBACSReport('AUDDIS');
        Account membership = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];
        Payment_Method__c paymentMethod = [SELECT Id FROM Payment_Method__c WHERE Membership__c = :membership.Id];
        List<Transaction__c> transactions = [SELECT Id, Status__c, Transaction_Type__c FROM Transaction__c WHERE Payment_Method__c = :paymentMethod.Id AND Status__c = 'Pending' AND Transaction_Type__c = '0N'];
        transactions.get(0).Status__c = 'Complete';
        update transactions;
        
        String testAccountNumber = '12345678';
        String testSortCode = '123456';
        
        String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership.Membership_Number__c;
        xmlBody += 'DIRECT DBT" payer-name="MR C JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="C" aosn="00547721"  ';
        xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"  ';
        xmlBody += 'payer-new-account-number="'+testAccountNumber+'" payer-new-sort-code="'+testSortCode+'"></MessagingAdvice></MessagingAdvices>\n';
        
        generateXmlDocAttachment(reportId, xmlBody);
        
        // run update method
        UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'AUDDIS');
        Account updatedMembership = [SELECT Id, Membership_Status__c FROM Account WHERE Id = :membership.Id];
        
        Payment_Method__c paymentMethodNew = [SELECT Id, Status__c, Bank_Account_Number__c, Sort_Code__c FROM Payment_Method__c WHERE Membership__c = :membership.Id AND Bank_Account_Number__c =: testAccountNumber AND Sort_Code__c =: testSortCode];
        Payment_Method__c paymentMethodCancelled = [SELECT Id, Status__c FROM Payment_Method__c WHERE Membership__c = :membership.Id AND Bank_Account_Number__c = NULL];
        
        
        List<Transaction__c> trans0N = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0N' AND Payment_Method__c = :paymentMethodCancelled.Id AND Status__c = 'Complete'];
        List<Transaction__c> trans0C = [SELECT Id, Status__c FROM Transaction__c WHERE Transaction_Type__c = '0C' AND Payment_Method__c = :paymentMethodCancelled.Id AND Status__c = 'Complete'];
        
        System.assertEquals('Cancelled', paymentMethodCancelled.Status__c);
        System.assertEquals(testAccountNumber, paymentMethodNew.Bank_Account_Number__c);
        System.assertEquals(testSortCode, paymentMethodNew.Sort_Code__c);
        
        System.assertEquals(1, trans0N.size());
        System.assertEquals(1, trans0C.size());
    }

    /*
	* @method updateRejectedTransactions
  	* @case when inserting uploading an AUDDIS xml which references both of the existing memberships, one with code 'C', one with code 'M'
  	* @result expect an error log to have been generated, which contains the membership number of both the existing memberships
  	*/
    @isTest
    static void testAUDDISErrorReport(){
    	Id reportId = UpdateRejectedTransactionsController.createBACSReport('AUDDIS');
    	Account membership1 = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc1'];
    	Account membership2 = [SELECT Membership_Number__c FROM Account WHERE Name='TestAcc2'];

    	// create attachment
		String xmlBody = '<MessagingAdvices><MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership1.Membership_Number__c;
			  xmlBody += 'DIRECT DBT" payer-name="MR B JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="3" aosn="00547721"  ';
		      xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC"></MessagingAdvice>';

		      xmlBody += '<MessagingAdvice user-number="998762" record-type="D" effective-date="2019-06-14" reference="' + membership2.Membership_Number__c;
		      xmlBody += 'DIRECT DBT" payer-name="MR C JONES" payer-account-number="00000000" payer-sort-code="000000" reason-code="M" aosn="00547721"  ';
		      xmlBody += 'transaction-code="0C" orig-sort-code="206563" orig-account-number="53405702" original-proc-date="2019-06-11" originator-name="CCC">';
		      xmlBody += '</MessagingAdvice></MessagingAdvices>\n';

		generateXmlDocAttachment(reportId, xmlBody);

		// run update method
		UpdateRejectedTransactionsController.updateRejectedTransactions(reportId, 'AUDDIS');

		String errorLog = [SELECT Id, VersionData FROM ContentVersion WHERE Title = 'Error Log'].VersionData.toString();

		System.assert(errorLog.contains(membership1.Membership_Number__c));
		System.assert(errorLog.contains(membership2.Membership_Number__c));

	}




    /*
     *    generateXmlDocAttachment
     *    util method to generate xml report attachment
     *	  return void
     */
    static void generateXmlDocAttachment(Id reportId, String xmlBody){
    	ContentVersion cv = new ContentVersion();
    	cv.VersionData = Blob.valueOf(xmlBody);
    	cv.Title = 'test';
    	cv.PathOnClient = 'document.xml';
    	insert cv;

    	List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];

    	ContentDocumentLink cdl = new ContentDocumentLink();
    	cdl.LinkedEntityId = reportId;
    	cdl.ContentDocumentId = documents.get(0).Id;
    	cdl.ShareType = 'V';
    	insert cdl;

    }
}