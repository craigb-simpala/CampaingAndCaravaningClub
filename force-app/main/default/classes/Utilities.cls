/**
 * @description       : Generic utilities that can be used across the org.
 * @author            : Kev Cadger (kevin.cadger@wipro.com)
 * @group             : Generic
 * @last modified on  : 01-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author                        Request                         Modification
 * 1.0   01-03-2022   Kev Cadger                    REQ-000109128                   Initial Version
 **/

public without sharing class Utilities {
  /**
   * @description Validate the direct debit info of the specified lead.
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022
   * @param Lead lead The lead to validate.
   * @return Boolean Whether the validation was successful.
   * Modifications Log
   * Ver   Date         Author                        Request                         Modification
   * 1.0   01-03-2022   Kev Cadger                    REQ-000109128                   Initial Version
   **/
  public static Boolean validateDirectDebitInfo(Lead lead) {
    // Intialise the variables.
    Boolean isValid = true;

    // Check the bank account name has been entered.
    if (String.isBlank(lead.Bank_Account_Name__c)) {
      // Add an error to the field.
      lead.Bank_Account_Name__c.addError('Please Enter Bank Account Name');
      isValid = false;
    }
    // Check the bank account number has been entered.
    if (String.isBlank(lead.Bank_Account_Number__c)) {
      // Add an error to the field.
      lead.Bank_Account_Number__c.addError('Please Enter Bank Account Number');
      isValid = false;
    } else if (lead.Bank_Account_Number__c == '00000000') {
      // Check the bank account number is valid.
      // Add an error to the field.
      lead.Bank_Account_Number__c.addError(
        'Please Enter a Valid Bank Account Number'
      );
      isValid = false;
    }
    // Check the bank name has been entered.
    if (String.isBlank(lead.Bank_Name__c)) {
      // Add an error to the field.
      lead.Bank_Name__c.addError('Please Enter Bank Name');
      isValid = false;
    }
    // Check the sort code has been entered.
    if (String.isBlank(lead.Sort_Code__c)) {
      lead.Sort_Code__c.addError('Please Enter Sort Code');
      isValid = false;
    } else if (lead.Sort_Code__c == '000000') {
      // Check the sort code is valid.
      lead.Sort_Code__c.addError('Please Enter a Valid Sort Code');
      isValid = false;
    }

    // Return isValid.
    return isValid;
  }

  // ! ---------------------------------------------------------------------------------------------------- ! //
  // * General Utilities * //

  /**
   * @description Logs the error details to the debug log.
   * @author Kev Cadger (Wipro) | 21-03-2022
   * @param Exception e The exception to log.
   **/
  public static void logException(Exception e) {
    System.debug(
      '-----Error Handling-----\n' +
      e.getMessage() +
      '\n' +
      e.getStackTraceString()
    );
  }

  /**
   * @description Converts the value to the specified data type.
   * @author Kev Cadger (Wipro) | 24-05-2022
   * @param String dataType The data type to convert to.
   * @param Object value The value to convert.
   * @return Object The value as the new data type.
   **/
  public static Object convertValueType(String dataType, Object value) {
    switch on dataType {
      when 'Date' {
        String myDate = String.valueOf(value);
        return Date.valueOf(myDate);
      }
      when 'DateTime' {
        return DateTime.valueOf(value);
      }
      when else {
        return value;
      }
    }
  }

  // ! ---------------------------------------------------------------------------------------------------- ! //
  // * Record Utilities * //

  /**
   * @description
   * @author Kev Cadger (Wipro) | 21-04-2022
   * @param Id recordId
   * @return Map<String, Object>
   **/
  @AuraEnabled
  public static Map<String, Object> getRecordFieldsAsMap(Id recordId) {
    try {
      // Get the sObject Type Name from the record id.
      String sObjectTypeName = recordId.getSobjectType()
        .getDescribe()
        .getName();
      // Get the query.
      String query =
        Utilities.getSObjectQueryAllFields(sObjectTypeName) +
        'WHERE Id = :recordId';
      // Get the record.
      SObject record = Database.query(query);
      // Get the record fields as a map.
      Map<String, Object> recordFields = new Map<String, Object>();
      recordFields.put('SObjectTypeName', sObjectTypeName);
      recordFields.putAll(record.getPopulatedFieldsAsMap());

      return recordFields;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static Id getRecordTypeId(
    String sobjectTypeName,
    String recordTypeDevName
  ) {
    return Schema.getGlobalDescribe()
      .get(sobjectTypeName)
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeDevName)
      .getRecordTypeId();
  }

  // ! ---------------------------------------------------------------------------------------------------- ! //
  // * Query Utilities * //

  /**
   * @description Gets a select query with all fields.
   * @author Kev Cadger (Wipro) | 23-03-2022
   * @param String sObjectName The specific object to get the fields for.
   * @return String The query.
   **/
  public static String getSObjectQueryAllFields(String sObjectName) {
    // Get all the fields from the specified SObject.
    List<String> sObjectFields = new List<String>(
      Schema.getGlobalDescribe()
        .get(sObjectName)
        .getDescribe()
        .fields.getMap()
        .keySet()
    );

    return getSObjectQuerySpecifiedFields(sObjectName, sObjectFields);
  }

  /**
   * @description Gets a select query with the specified fields.
   * @author Kev Cadger (Wipro) | 23-03-2022
   * @param String sObjectName The specific object to get the fields for.
   * @return String The query.
   **/
  public static String getSObjectQuerySpecifiedFields(
    String sObjectName,
    List<String> sObjectFields
  ) {
    // Build the query fields.
    String queryFields = String.join(sObjectFields, ', ').removeEnd(', ');
    // Build the query.
    String query = String.format(
      'SELECT {0} FROM {1} ',
      new List<String>{ queryFields, sObjectName }
    );
    // Return the query.
    return query;
  }
}