public without sharing class DirectDebitCheckerController {
  @AuraEnabled
  public static void updateDirectDebitDetails(
    Id recordId,
    Map<String, String> account
  ) {
    try {
      String sObjectTypeName = recordId.getSObjectType()
        .getDescribe()
        .getName();
      SObject record = Schema.getGlobalDescribe()
        .get(sObjectTypeName)
        .newSObject(recordId);

      switch on sObjectTypeName {
        when 'Lead' {
          record.put('Bank_Account_Name__c', account.get('holder'));
          record.put('Bank_Name__c', account.get('bank'));
          record.put('Bank_Account_Number__c', account.get('number').replaceAll(
            '[^0-9]',
            ''
          ));
          record.put('Sort_Code__c', account.get('sortCode').replaceAll(
            '[^0-9]',
            ''
          ));
        }
        when else {
          System.debug(
            'No mapping has been set up for ' +
            sObjectTypeName +
            ' records.'
          );
        }
      }

      update record;
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, Object> validateDirectDebitDetails(
    Map<String, String> account
  ) {
    try {
      Map<String, Object> result = new Map<String, Object>{ 'valid' => true };

      // Validate the banking details.
      hopewiserSoapbankcoder.ValidateReturnDetailResponse_element ret = validate(
        account.get('number'),
        account.get('sortCode')
      );

      // If the details are not valid.
      // || Status Code 4 = Sort code found. Account could not be verified.
      // || Status Code 5 = Sort code not found.
      if (
        ret.ValidityFlag.tolowercase() != 'y' || ret.StatusCode == 5
      ) {
        result = new Map<String, Object>{
          'valid' => false,
          'message' => ret.StatusText
        };
      }


      return result;
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static hopewiserSoapbankcoder.ValidateReturnDetailResponse_element validate(
    String accNumber,
    String accSortCode
  ) {
    hopewiserSoapbankcoder banklookup = new hopewiserSoapbankcoder();
    hopewiserSoapbankcoder.ValidateReturnDetailRequest_element bdets = new hopewiserSoapbankcoder.ValidateReturnDetailRequest_element();
    bdets.AccountNumber =
      accSortCode.replaceAll('[^0-9]', '') + accNumber.replaceAll('[^0-9]', '');
    bdets.Dataset = 'uk-vl-bankcode';

    docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
    docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
    Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
    sectoken.Username = hopewiser.username__c;
    sectoken.password = hopewiser.password__c;

    hopewiserSoapbankcoder.soapbankcoderInterfaceSoap11 r = new hopewiserSoapbankcoder.soapbankcoderInterfaceSoap11();
    sectype.UsernameToken = sectoken;
    r.Security = sectype;
    hopewiserSoapbankcoder.StatusResponse_element sr = r.Status();
    hopewiserSoapbankcoder.ValidateReturnDetailResponse_element ret = r.ValidateReturnDetail(
      accSortCode.replaceAll('[^0-9]', '') + accNumber.replaceAll('[^0-9]', ''),
      'uk-vl-bankcode'
    );

    return ret;
  }
}