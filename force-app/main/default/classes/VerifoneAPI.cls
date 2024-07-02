/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 18-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   12-07-2022   Kev Cadger (Wipro)   Initial Version
 **/
public without sharing class VerifoneAPI {
  private static ApiSetting__c apiSetting = getAPISetting('Verifone');

  // ! -------------------------------------------------- ! //
  // * Card Methods

  public static HttpResponse postCardToken(Map<String, Object> cardDetails) {
    // Initialise any variables.
    String apiEndpointName = 'Create Card Token';
    APIEndpoint__c apiEndpoint = getAPIEndpoint(apiEndpointName);
    system.debug('######## apiEndpoint '+ apiEndpoint);
    system.debug('######## Verifone API postCardToken1 '+ cardDetails);

    // Add the organisation id to the card details.
    cardDetails.put('organisation', apiSetting.Organisation__c);
    system.debug('card details are'+cardDetails);

    // Intialise the http request.
    HttpRequest request = getHttpRequest(
      apiEndpoint.Endpoint__c,
      apiEndpoint.Method__c,
      cardDetails
    );
    // Get the http response.
    system.debug('######## VerifoneAPI postCardToken2 '+ request);
    HttpResponse response = new Http().send(request);
    
    system.debug('######## VerifoneAPI postCardToken3 '+ response);
    system.debug('######## VerifoneAPI postCardToken3 '+ response.getBody());
    return response;
  }

  public static HttpResponse postTransaction(String cardId, Integer amount, Id recordId) {
    // Initialise any variables.
    String apiEndpointName = 'Create Card Transaction';
    APIEndpoint__c apiEndpoint = getAPIEndpoint(apiEndpointName);
    System.debug('######postTransaction1 '+ apiSetting.Key_Token__c);

    // Initialise any variables.
    Map<String, Object> transactionDetails = new Map<String, Object>{
      'account' => apiSetting.Account__c,
      'amount' => amount,
      'card' => cardId,
      'customer_ip' => '127.0.0.1',
      'dynamic_descriptor' => 'Verifone Merchant',
      'shopper_interaction' => 'telephone_order',
      'merchant_reference' => recordId,
      'user_agent' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0'
    };

    // Intialise the http request.
    HttpRequest request = getHttpRequest(
      apiEndpoint.Endpoint__c,
      apiEndpoint.Method__c,
      transactionDetails
    );
    System.debug('######postTransaction2 '+request);
    System.debug('######postTransaction3 '+transactionDetails);

    // Get the http response.
    HttpResponse response = new Http().send(request);
    System.debug('######postTransaction4 '+response);
    system.debug('######## postTransaction5 '+ response.getBody());

    return response;
  }

  // ! -------------------------------------------------- ! //
  // * Helper Methods

  // * * Data Methods

  private static APISetting__c getAPISetting(String apiSettingName) {
    // Fetch the api setting.
    List<APISetting__c> apiSettings = [
      SELECT Id, Key_Token__c, Organisation__c, Account__c
      FROM APISetting__c
      WHERE Name__c = :apiSettingName
      LIMIT 1
    ];

    // If there is no setting.
    if (apiSettings.isEmpty()) {
      // Throw an exception.
      throwException('API Setting: ' + apiSettingName + ' not found.');
    }

    return apiSettings[0];
  }

  private static APIEndpoint__c getAPIEndpoint(String apiEndpointName) {
    // Fetch the api endpoint.
    List<APIEndpoint__c> apiEndpoints = [
      SELECT Endpoint__c, Method__c
      FROM APIEndpoint__c
      WHERE APISetting__c = :apiSetting.Id AND Name__c = :apiEndpointName
      LIMIT 1
    ];

    // If there is no endpoint.
    if (apiEndpoints.isEmpty()) {
      // Throw an exception.
      throwException('API Endpoint: ' + apiEndpointName + ' not found.');
    }

    return apiEndpoints[0];
  }

  // * * Other? // TODO Better Name lol

  private static HttpRequest getHttpRequest(
    String endpoint,
    String method,
    Map<String, Object> body
  ) {
    // Initialise the http request.
    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('X-APIKey', apiSetting.Key_Token__c);
    request.setMethod(method);
    request.setBody(JSON.serialize(body));

    return request;
  }

  // ! -------------------------------------------------- ! //
  // * Error Methods

  public static void throwException(String message) {
    throw new VerifoneException(message);
  }

  public static Map<String, Object> getVerifoneError(Integer statusCode) {
    Map<String, Object> error = new Map<String, Object>{
      'code' => statusCode,
      'variant' => 'error'
    };


    switch on statusCode {
      when 400 {
        error.put('title', 'Bad / Invalid request');
        error.put('message', 'Please contact your System Administrator.');
      }
      when 401 {
        error.put('title', 'Unauthenticated User / Missing API Key');
        error.put('message', 'Please contact your System Administrator.');
      }
      when 403 {
        error.put('title', 'Operation Declined by Processor');
        error.put('message', 'Please contact your System Administrator.');
      }
      when 404 {
        error.put('title', 'Transaction, Account or Organisation Not Found');
        error.put('message', 'Please contact your System Administrator.');
      }
      when 500 {
        error.put('title', 'Unexpected Error');
        error.put('message', 'Please contact your System Administrator.');
      }
      when 501 {
        error.put('title', 'Unsupported Payment Method / Processor');
        error.put('message', 'Please contact your System Administrator.');
      }
      when 503 {
        error.put('title', 'Service Unavailable');
        error.put('message', 'Please try again later.');
      }
      when else {
        error.put('title', 'Process Failed');
        error.put('message', 'Please contact your System Administrator.');
      }
    }

    return error;
  }

  // private static void logException_RequestFailed(HttpResponse response) {
  //   String message = String.format(
  //     '{0}\n{1}\n{2}',
  //     new List<String>{
  //       'Error Handling:',
  //       'Failed Request:',
  //       response.getBody()
  //     }
  //   );
  //   throw new VerifoneException(message);
  // }

  // private static void logException(Exception e) {
  //   String message = String.format(
  //     '{0}\n{1}\n{2}',
  //     new List<String>{
  //       'Error Handling:',
  //       e.getMessage(),
  //       e.getStackTraceString()
  //     }
  //   );
  //   throw new VerifoneException(message);
  // }

  public class VerifoneException extends Exception {
    public Integer code;
    public Object details;
    public String message;

    // public VerifoneException(
    //   Integer code,
    //   Map<String, Object> details,
    //   String message
    // ) {
    //   this.code = code;
    //   this.details = details;
    //   this.message = message;
    // }
  }
}