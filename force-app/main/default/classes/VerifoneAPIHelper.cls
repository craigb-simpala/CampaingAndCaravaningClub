/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 17-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   22-07-2022   Kev Cadger (Wipro)   Initial Version
 **/
public without sharing class VerifoneAPIHelper {
  private static final List<String> SUCCESS_STATUSES = new List<String>{ // Set the transaction success status list.
    'AUTHORIZED',
    'SETTLEMENT_REQUESTED',
    'SETTLEMENT_SUBMITTED',
    'SETTLEMENT_COMPLETED'
  };
  private static Map<String, Object> results = new Map<String, Object>{
    'isSuccess' => false
  };

  public static Map<String, Object> createCardTransaction(
    Map<String, Object> cardDetails,
    Integer amount, Id recordId
  ) {
    System.debug('######createCardTransaction1 '+ cardDetails + amount +recordId);
    try {
      // Intialise any variables.
      String cardId = null;

      // Create the card token.
      HttpResponse responseCard = VerifoneAPI.postCardToken(cardDetails);

      // If the card creation was successful.
      if (responseCard.getStatusCode() == 200) {
        System.debug('######createCardTransaction2 ');
        // Get the response body.
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
          responseCard.getBody()
        );

        System.debug('Art = ' + JSON.serialize(responseBody));

        // Set the card id.
        cardId = String.valueOf(responseBody.get('_id'));
      } else {
        results.putAll(
          VerifoneAPI.getVerifoneError(responseCard.getStatusCode())
        );
        System.debug('results 1 = '  + JSON.serialize(results));

      }

      // If the card id was fetched.
      if (cardId != null) {
        System.debug('######createCardTransaction3 post transaction ');
        // Create the transaction creation was successful.
        HttpResponse responseTran = VerifoneAPI.postTransaction(cardId, amount, recordId);

        // If the transaction response is successful.
        if (responseTran.getStatusCode() == 200) {
          // Get the response body.
          Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
            responseTran.getBody()
          );

          // Set the success status based on the transaction success status list.
          results.putAll(
            new Map<String, Object>{
              'isSuccess' => SUCCESS_STATUSES.contains(
                String.valueOf(responseBody.get('status'))
              ),
              'message' => 'The membership will now be processed.',
              'title' => 'Payment Successful',
              'token' => responseBody.get('card'),
              'variant' => 'success'
            }
          );
        } else {

          results.putAll(
            VerifoneAPI.getVerifoneError(responseCard.getStatusCode())
          );
          System.debug('results 2 = '  + JSON.serialize(results));

        }
      }
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
    System.debug('results 3 = '  + JSON.serialize(results));

    return results;
  }
}