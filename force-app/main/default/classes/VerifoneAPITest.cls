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
public without sharing class VerifoneAPITest {
  @IsTest
  static void testNoAPISetting() {
    Test.setMock(HttpCalloutMock.class, new VerifoneAPIMock(true));

    String message = '';

    Test.startTest();
    try {
      VerifoneAPI.postCardToken(new Map<String, Object>());
    } catch (Exception e) {
      message = e.getMessage();
      Utilities.logException(e);
    }
    Test.stopTest();

    System.assertEquals(
      true,
      message.startsWith('API Setting'),
      'The error message was not as expected.'
    );
  }

  @IsTest
  static void testNoAPIEndpoints() {
    createAPISetting();

    Test.setMock(HttpCalloutMock.class, new VerifoneAPIMock(true));

    String message = '';

    Test.startTest();
    try {
      VerifoneAPI.postCardToken(new Map<String, Object>());
    } catch (Exception e) {
      message = e.getMessage();
      Utilities.logException(e);
    }
    Test.stopTest();

    System.assertEquals(
      true,
      message.startsWith('API Endpoint'),
      'The error message was not as expected.'
    );
  }

  @IsTest
  static void testPostCardToken() {
    createAPISetting();
    createAPIEndpoints();

    Test.setMock(HttpCalloutMock.class, new VerifoneAPIMock(true));

    Map<String, Object> cardDetails = new Map<String, Object>{
      'card_number' => '4000000000001000',
      'expiry_month' => '01',
      'expiry_year' => '23',
      'cvv' => '123'
    };
    HttpResponse response = null;
    Map<String, Object> responseBody = null;

    Test.startTest();
    try {
      response = VerifoneAPI.postCardToken(cardDetails);
      responseBody = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    System.assertEquals(
      'OK',
      response.getStatus(),
      'The status was not correct.'
    );
    System.assertEquals(
      'TestCardId',
      responseBody.get('_id'),
      'The _id was not correct'
    );
  }

  @IsTest
  static void testPostTransaction() {
    createAPISetting();
    createAPIEndpoints();

    Test.setMock(HttpCalloutMock.class, new VerifoneAPIMock(true));
    HttpResponse response = null;
    Map<String, Object> responseBody = null;

    Lead ld = new Lead();
    ld.LastName = 'test';
    ld.Email = 'test@test.com';
    ld.Company = 'test';
    insert ld;

    Test.startTest();
    try {
      response = VerifoneAPI.postTransaction('cardId', 1000, ld.Id);
      responseBody = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    System.assertEquals(
      'OK',
      response.getStatus(),
      'The status was not correct.'
    );
    System.assertEquals(
      'TestTranId',
      responseBody.get('_id'),
      'The _id was not correct'
    );
  }

  @IsTest
  static void testGetVerifoneError() {
    createAPISetting();

    Test.startTest();
    system.assertEquals(
      'Bad / Invalid request',
      VerifoneAPI.getVerifoneError(400).get('title'),
      'Error title for status code 400 is not correct.'
    );
    system.assertEquals(
      'Unauthenticated User / Missing API Key',
      VerifoneAPI.getVerifoneError(401).get('title'),
      'Error title for status code 401 is not correct.'
    );
    system.assertEquals(
      'Operation Declined by Processor',
      VerifoneAPI.getVerifoneError(403).get('title'),
      'Error title for status code 403 is not correct.'
    );
    system.assertEquals(
      'Transaction, Account or Organisation Not Found',
      VerifoneAPI.getVerifoneError(404).get('title'),
      'Error title for status code 404 is not correct.'
    );
    system.assertEquals(
      'Unexpected Error',
      VerifoneAPI.getVerifoneError(500).get('title'),
      'Error title for status code 500 is not correct.'
    );
    system.assertEquals(
      'Unsupported Payment Method / Processor',
      VerifoneAPI.getVerifoneError(501).get('title'),
      'Error title for status code 501 is not correct.'
    );
    system.assertEquals(
      'Service Unavailable',
      VerifoneAPI.getVerifoneError(503).get('title'),
      'Error title for status code 503 is not correct.'
    );
    system.assertEquals(
      'Process Failed',
      VerifoneAPI.getVerifoneError(0).get('title'),
      'Error title for any other status code is not correct.'
    );
    Test.stopTest();
  }

  // !----------
  // * Helper Methods

  @TestVisible
  private static void createAPISetting() {
    ApiSetting__c setting = new ApiSetting__c(
      Account__c = '5d15d6f91a8e7b2d3a83cc6d',
      Base_URL__c = 'https://sandbox.omni.verifone.cloud/v1',
      Key_Token__c = 'TestKeyToken',
      Name__c = 'Verifone',
      Organisation__c = '5d15d6b71a8e7b2d3a83cc5e'
    );
    insert setting;
  }

  @TestVisible
  private static void createAPIEndpoints() {
    Id settingId = [
      SELECT Id
      FROM APISetting__c
      WHERE Name__c = 'Verifone'
      LIMIT 1
    ]
    .Id;

    List<APIEndpoint__c> endpoints = new List<APIEndpoint__c>();
    endpoints.add(
      new APIEndpoint__c(
        ApiSetting__c = settingId,
        Extension__c = '/card',
        Name__c = 'Create Card Token',
        Method__c = 'POST'
      )
    );
    endpoints.add(
      new APIEndpoint__c(
        ApiSetting__c = settingId,
        Extension__c = '/transaction',
        Name__c = 'Create Card Transaction',
        Method__c = 'POST'
      )
    );

    insert endpoints;
  }

  // !-------------------------------------------------------! //
  // * Helper Classes

  public class VerifoneAPIMock implements HttpCalloutMock {
    private Boolean isSuccess = true;

    public VerifoneAPIMock(Boolean isSuccess) {
      this.isSuccess = isSuccess;
    }

    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');

      if (isSuccess) {
        getSuccessfulResponse(request, response);
      } else {
        getFailedResponse(request, response);
      }

      return response;
    }

    private void getSuccessfulResponse(
      HttpRequest request,
      HttpResponse response
    ) {
      Map<String, Object> responseBody = new Map<String, Object>();

      response.setStatus('OK');
      response.setStatusCode(200);

      if (request.getEndpoint().endsWith('/card')) {
        if (request.getMethod() == 'POST') {
          responseBody.put('_id', 'TestCardId');
        }
      } else if (request.getEndpoint().endsWith('/transaction')) {
        if (request.getMethod() == 'POST') {
          responseBody.put('_id', 'TestTranId');
        }
      }

      response.setBody(JSON.serialize((Object) responseBody));
    }

    private void getFailedResponse(HttpRequest request, HttpResponse response) {
      Map<String, Object> responseBody = new Map<String, Object>();

      response.setStatus('Bad Request');
      response.setStatusCode(400);

      if (request.getEndpoint().endsWith('/card')) {
        if (request.getMethod() == 'POST') {
          responseBody.put('code', 107);
          responseBody.put(
            'details',
            new Map<String, Object>{
              'body.card_number' => 'is invalid or missing'
            }
          );
          responseBody.put(
            'message',
            'At least one parameter is invalid. Examine the details property for more information.'
          );
        }
      } else if (request.getEndpoint().endsWith('/transaction')) {
        if (request.getMethod() == 'POST') {
          responseBody.put('code', 107);
          responseBody.put(
            'details',
            new Map<String, Object>{
              'body.amount' => 'should be a positive integer'
            }
          );
          responseBody.put(
            'message',
            'At least one parameter is invalid. Examine the details property for more information.'
          );
        }
      }

      response.setBody(JSON.serialize((Object) responseBody));
    }
  }
}