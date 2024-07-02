/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 18-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   18-08-2022   Kev Cadger (Wipro)   Initial Version
 **/
@IsTest
public without sharing class VerifoneAPIHelperTest {
  @IsTest
  static void testCreateCardTransaction() {
    VerifoneAPITest.createAPISetting();
    VerifoneAPITest.createAPIEndpoints();

    Test.setMock(
      HttpCalloutMock.class,
      new VerifoneAPITest.VerifoneAPIMock(true)
    );

    Map<String, Object> cardDetails = new Map<String, Object>{
      'card_number' => '4000000000001000',
      'expiry_month' => '01',
      'expiry_year' => '23',
      'cvv' => '123'
    };
    Map<String, Object> response = null;

    Lead ld = new Lead();
    ld.LastName = 'test';
    ld.Email = 'test@test.com';
    ld.Company = 'test';
    insert ld;

    Test.startTest();
//    try {
      response = VerifoneAPIHelper.createCardTransaction(cardDetails, -1, ld.Id);
//    } catch (Exception e) {
//      Utilities.logException(e);
//    }
    Test.stopTest();
  }
}