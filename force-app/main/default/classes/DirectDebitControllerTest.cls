@IsTest
public without sharing class DirectDebitControllerTest {
  @IsTest
  static void testUpdateDirectDebitDetails_S() {
    Map<String, String> account = new Map<String, String>{
      'bank' => 'Test Bank',
      'holder' => 'Test Holder',
      'number' => '0000-0000',
      'sortCode' => '00-00-00'
    };

    Lead lead = (Lead) TestDataFactory.createSObject(new Lead());

    // Test.setMock(HttpCalloutMock.class, new hopewiserSoapbankcoderMockImpl());
    Test.startTest();
    DirectDebitCheckerController.updateDirectDebitDetails(lead.Id, account);
    lead = [
      SELECT
        Id,
        Bank_Name__c,
        Bank_Account_Name__c,
        Bank_Account_Number__c,
        Sort_Code__c
      FROM Lead
      WHERE Id = :lead.Id
    ];
    Test.stopTest();

    System.assertEquals(
      'Test Bank',
      lead.Bank_Name__c,
      'Bank Name was not updated correctly.'
    );
    System.assertEquals(
      'Test Holder',
      lead.Bank_Account_Name__c,
      'Account Holder was not updated correctly.'
    );
    System.assertEquals(
      '00000000',
      lead.Bank_Account_Number__c,
      'Account Number was not updated correctly.'
    );
    System.assertEquals(
      '000000',
      lead.Sort_Code__c,
      'Account Sort Code was not updated correctly.'
    );
  }

  @IsTest
  static void testUpdateDirectDebitDetails_F() {
    Map<String, String> account = new Map<String, String>{
      'bank' => 'Test Bank',
      'holder' => 'Test Holder',
      'number' => '',
      'sortCode' => ''
    };

    Lead lead = (Lead) TestDataFactory.createSObject(new Lead());

    // Test.setMock(HttpCalloutMock.class, new hopewiserSoapbankcoderMockImpl());
    Test.startTest();
    DirectDebitCheckerController.updateDirectDebitDetails(lead.Id, account);
    lead = [
      SELECT
        Id,
        Bank_Name__c,
        Bank_Account_Name__c,
        Bank_Account_Number__c,
        Sort_Code__c
      FROM Lead
      WHERE Id = :lead.Id
    ];
    Test.stopTest();
  }

  @IsTest
  static void testValidateDirectDebitDetails() {
    Map<String, String> account = new Map<String, String>{
      'bank' => 'Test Bank',
      'holder' => 'Test Holder',
      'number' => '0000-0000',
      'sortCode' => '00-00-00'
    };

    Test.setMock(WebServiceMock.class, new hopewiserSoapbankcoderMockImpl());
    Test.startTest();
    try {
      DirectDebitCheckerController.validateDirectDebitDetails(account);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();
  }
}