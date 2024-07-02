/**
 * @description       : BACS Reports processing functionality.
 * @author            : Kev Cadger (Wipro)
 * @group             : BACS Reports
 * @last modified on  : 28-07-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver       Date           Request                 Author                          Modification
 * 01.00.00  03-05-2022     REQ-000109682           Kev Cadger (Wipro)              Initial Version
 * 01.01.00  16-05-2022     REQ-000109682           Kev Cadger (Wipro)              Split the Extract and Process classes into subclasses.
 **/
public without sharing class BACSReports {
  /**
   * @description
   * @author Kev Cadger (Wipro) | 19-05-2022
   * @param String reportType
   * @return Map<String, Id>
   **/
  public static Id createReport(String reportType, Id recordTypeId) {
    // Get the report config for the report type.
    BACS_Report_Config__c reportConfig = BACS_Report_Config__c.getInstance(
      reportType
    );
    // Initialise the BACS report.
    BACS_Report__c report = new BACS_Report__c(
      Name = reportConfig.Report_Name__c +
        ' - ' +
        DateTime.now().format('yyyy-MM-dd hh:mm'),
      RecordTypeId = recordTypeId
    );
    // Create the BACS report.
    insert report;
    // Return the BACS report id.
    return report.Id;
  }

  /**
   * @description
   * @author Kev Cadger (Wipro) | 16-05-2022
   * @param Id bacsReportId
   * @return List<BACS_Report_Detail__c>
   **/
  public static List<BACS_Report_Detail__c> getReportData(Id reportId) {
    return [
      SELECT
        Id,
        Account__c,
        Account__r.Name,
        Status__c,
        Membership_Number__c,
        Reason_Code__c,
        Effective_Date__c,
        Name__c,
        Name_New__c,
        Sort_Code__c,
        Sort_Code_New__c,
        Account_Number__c,
        Account_Number_New__c,
        Message__c
      FROM BACS_Report_Detail__c
      WHERE BACS_Report__c = :reportId
      ORDER BY Id
    ];
  }

  /**
   * @description
   * @author Kev Cadger (Wipro) | 16-05-2022
   * @param Id bacsReportId
   * @return List<BACS_Report_Detail__c>
   **/
  public static List<BACS_Report_Detail__c> getReportDataUnprocessed(
    Id reportId
  ) {
    return [
      SELECT
        Id,
        Account__c,
        Account__r.Name,
        Status__c,
        Membership_Number__c,
        Reason_Code__c,
        Effective_Date__c,
        Name__c,
        Name_New__c,
        Sort_Code__c,
        Sort_Code_New__c,
        Account_Number__c,
        Account_Number_New__c,
        Message__c
      FROM BACS_Report_Detail__c
      WHERE BACS_Report__c = :reportId AND Status__c IN ('Pending', 'Error')
      ORDER BY Id
    ];
  }

  // * Helper Classes * //

  // * * Report Extract Class
  /**
   * Modifications Log
   * Ver       Date           Request                 Author                          Modification
   * 01.00.00  16-05-2022     REQ-000109682           Kev Cadger (Wipro)              Initial Version
   **/
  public without sharing class Extract {
    // * Class Properties * //
    // * * Private Properties
    private BACS_Report_Config__c reportConfig = null;
    private Map<String, BACS_Report_Mapping__mdt> reportMapping = new Map<String, BACS_Report_Mapping__mdt>();
    private Map<String, Id> membershipMapping = new Map<String, Id>();

    /**
     * @description Constructor for the Extract sub-class. Gets the report config and mapping to be used.
     * @author Kev Cadger (Wipro) | 03-05-2022
     * @param String reportType The report type to be extracted.
     **/
    public Extract(String reportType) {
      // Get the report config for the report type.
      this.reportConfig = BACS_Report_Config__c.getInstance(reportType);

      // Get the report mapping for the report type.
      // For each report mapping.
      for (BACS_Report_Mapping__mdt mapping : [
        SELECT Attribute_Name__c, Field_API_Name__c, Type__c
        FROM BACS_Report_Mapping__mdt
        WHERE Report_Type__c = :reportType
      ]) {
        // Add the report mapping.
        reportMapping.put(mapping.Field_API_Name__c, mapping);
      }
    }

    /**
     * @description Extracts the report data.
     * @author Kev Cadger (Wipro) | 03-05-2022
     * @param Id reportId The report id to link the details to..
     * @param Id contentVersionId The content version id to get the XML data from.
     **/
    public void extractData(Id reportId, Id contentVersionId) {
      try {
        // Get the XML data
        String xmlData = getXMLData(contentVersionId);
        // Initialise the XML reader.
        XmlStreamReader reader = new XmlStreamReader(xmlData);
        // Get the report details.
        List<SObject> reportDetails = parseReportDetails(reportId, reader);
        // Update the membership link for the report details.
        updateMembershipLink(reportDetails);
        // Create the report details.
        Database.insert(reportDetails, true);
      } catch (Exception e) {
        Utilities.logException(e);
      }
    }

    // * Helper Methods * //

    /**
     * @description Get the XML data using the content version id.
     * @author Kev Cadger (Wipro) | 03-05-2022
     * @param Id contentVersionId Teh content version id to
     * @return String The XML data.
     **/
    private String getXMLData(Id contentVersionId) {
      return [
          SELECT VersionData
          FROM ContentVersion
          WHERE Id = :contentVersionId
        ]
        .VersionData.toString();
    }

    /**
     * @description Parses the XML data to get the report details.
     * @author Kev Cadger (Wipro) | 03-05-2022
     * @param Id reportId The report id to link the report details to.
     * @param XmlStreamReader reader The XML reader with the XML data.
     * @return List<SObject> The report details to be created.
     **/
    private List<SObject> parseReportDetails(
      Id reportId,
      XmlStreamReader reader
    ) {
      // Intialise the variables.
      List<SObject> reportDetails = new List<SObject>();

      // While there is a next line.
      Boolean hasNextLine = true;
      while (hasNextLine) {
        // If the event is the start element.
        if (reader.getEventType() == XmlTag.START_ELEMENT) {
          // If the local name matches the report config.
          if (reader.getLocalName() == reportConfig.Local_Name__c) {
            // Add the generated report detail.
            reportDetails.add(parseReportDetail(reportId, reader));
          }
        }

        // If there is a next line.
        if (reader.hasNext()) {
          // Go to the next line.
          reader.next();
        } else {
          // Set that there is no next line.
          hasNextLine = false;
          break;
        }
      }

      // Return the generated report details.
      return reportDetails;
    }

    /**
     * @description Parses the XML data to get the report detail.
     * @author Kev Cadger (Wipro) | 03-05-2022
     * @param Id reportId The report id to link the report detail to.
     * @param XmlStreamReader reader The XML reader with the XML data.
     * @return SObject The report detail to be created.
     **/
    private SObject parseReportDetail(Id reportId, XmlStreamReader reader) {
      // Intialise the variables.
      SObject reportDetail = getReportDetail(reportId, reader);

      // While there is a next element.
      Boolean hasNextElement = true;
      while (hasNextElement) {
        // If the event is the end element.
        if (reader.getEventType() == XmlTag.END_ELEMENT) {
          break;
        }
        // If there is a next element.
        if (reader.hasNext()) {
          // Go to the next element.
          reader.next();
        } //else {
        //     // Set that there is no next element.
        //     hasNextElement = false;
        //     break;
        // }
      }
      // Return the report detail.
      return reportDetail;
    }

    /**
     * @description Gets the report detail from the XML attribute.
     * @author Kev Cadger (Wipro) | 03-05-2022
     * @param Id reportId The report id to link the report detail to.
     * @param XmlStreamReader reader The XML reader with the XML data.
     * @return SObject The report detail to be created.
     **/
    private SObject getReportDetail(Id reportId, XmlStreamReader reader) {
      // Intialise the variables.
      SObject reportDetail = Schema.BACS_Report_Detail__c.getSObjectType()
        .newSObject();
      // Link the detail to the report.
      reportDetail.put('BACS_Report__c', reportId);

      // For each report mapping field name.
      for (String fieldName : reportMapping.keySet()) {
        // Get the report mapping linked to the field name.
        BACS_Report_Mapping__mdt mapping = reportMapping.get(fieldName);

        // If the attribute exists.
        if (reader.getAttributeValue(null, mapping.Attribute_Name__c) != null) {
          // Get the attribute value.
          Object attributeValue = reader.getAttributeValue(
            null,
            mapping.Attribute_Name__c
          );

          // Add the attribute value to the report detail.
          reportDetail.put(
            fieldName,
            Utilities.convertValueType(mapping.Type__c, attributeValue)
          );
        }
      }

      // Get the membership number.
      String membershipNumber = ((String) reportDetail.get('Reference__c'))
        .split('D')
        .get(0);
      // Add the membership number to the report detail.
      reportDetail.put('Membership_Number__c', membershipNumber);
      // Add the membership number to the membership mapping.
      membershipMapping.put(membershipNumber, null);

      // Return the report detail.
      return reportDetail;
    }

    /**
     * @description Links the report detail to the correct membership.
     * @author Kev Cadger (Wipro) | 24-05-2022
     * @param List<SObject> reportDetails The report details to create.
     **/
    private void updateMembershipLink(List<SObject> reportDetails) {
      // Get the memberships linked to the report details.
      // For each membership.
      for (Account membership : [
        SELECT Id, Hybrid_Membership_Number__c
        FROM Account
        WHERE Hybrid_Membership_Number__c IN :membershipMapping.keySet()
      ]) {
        // Update the membership mapping.
        membershipMapping.put(
          membership.Hybrid_Membership_Number__c,
          membership.Id
        );
      }

      // For each report detail.
      for (SObject reportDetail : reportDetails) {
        // Update the membership link.
        reportDetail.put(
          'Account__c',
          membershipMapping.get(
            (String) reportDetail.get('Membership_Number__c')
          )
        );
      }
    }
  }

  // * * Report Process Class
  /**
   * Modifications Log
   * Ver       Date           Request                 Author                          Modification
   * 01.00.00  16-05-2022     REQ-000109682           Kev Cadger (Wipro)              Initial Version
   **/
  public without sharing class Process {
    // * Class Properties * //
    // * * Private Properties
    //
    private String reportType;
    private List<BACS_Report_Detail__c> reportDetails = new List<BACS_Report_Detail__c>();
    // Data Mapping Properties
    private Set<String> membershipNumberSet = new Set<String>();
    private Map<Id, Account> membershipMapping = new Map<Id, Account>();
    private Map<Id, Payment_Method__c> membershipToPaymentMethodMapping = new Map<Id, Payment_Method__c>();
    private Map<Id, List<Transaction__c>> membershipToTransactionsMapping = new Map<Id, List<Transaction__c>>();
    private Set<Id> paymentMethodIdSet = new Set<Id>();
    //
    private Map<String, List<SObject>> recordsToUpsert = new Map<String, List<SObject>>();

    /**
     * @description
     * @author Kev Cadger (Wipro) | 24-05-2022
     * @param String reportType
     * @param List<BACS_Report_Detail__c> reportDetails
     **/
    public Process(
      String reportType,
      List<BACS_Report_Detail__c> reportDetails
    ) {
      this.reportType = reportType;
      this.reportDetails = reportDetails;

      // For each report detail.
      for (BACS_Report_Detail__c reportDetail : reportDetails) {
        // Intialise all of the membership mappings.
        this.membershipMapping.put(reportDetail.Account__c, null);
        this.membershipToPaymentMethodMapping.put(
          reportDetail.Account__c,
          null
        );
        this.membershipToTransactionsMapping.put(
          reportDetail.Account__c,
          new List<Transaction__c>()
        );
      }
      // Get the necessary data.
      getMembershipDetails();
      getPaymentMethodDetails();
      getTransactionDetails();
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 24-05-2022
     **/
    public void processData() {
      // Initialise the save point.
      // Savepoint savepoint = Database.setSavepoint();
      Set<Id> membershipsProcessed = new Set<Id>();

      try {
        // For each report detail.
        for (BACS_Report_Detail__c reportDetail : reportDetails) {
          // Get the membership.
          Account membership = membershipMapping.get(reportDetail.Account__c);
          try {
            // If the membership was not found.
            if (membership == null) {
              reportDetail.Message__c = getMessage(
                '',
                '- Membership: Not found.'
              );
            } else if (membershipsProcessed.contains(membership.Id)) {
              reportDetail.Message__c = getMessage(
                'Duplicate',
                reportDetail.Message__c
              );
            } else {
              //Determine the report type.
              switch on reportType {
                when 'ADDACS' {
                  processADDACS(reportDetail, membership);
                }
                when 'ARUDD' {
                  processARUDD(reportDetail, membership);
                }
                when 'AUDDIS' {
                  processAUDDIS(reportDetail, membership);
                }
              }

              // Add the records to upsert.
              addRecordsToUpsert(
                'Account',
                new List<Account>{ membershipMapping.get(membership.Id) }
              );
              addRecordsToUpsert(
                'Payment_Method__c',
                new List<Payment_Method__c>{
                  membershipToPaymentMethodMapping.get(membership.Id)
                }
              );
              addRecordsToUpsert(
                'Transaction__c',
                membershipToTransactionsMapping.get(membership.Id)
              );

              // Update the report detail.
              reportDetail.Message__c = getMessage(
                'Processed',
                reportDetail.Message__c
              );

              membershipsProcessed.add(membership.Id);
            }
            reportDetail.Status__c = 'Processed';
          } catch (Exception e) {
            Utilities.logException(e);
            // Update the report detail.
            reportDetail.Message__c = getMessage(
              'Error',
              reportDetail.Message__c
            );
            reportDetail.Status__c = 'Error';
          }
        }
        // Add the records to upsert.
        addRecordsToUpsert('BACS_Report_Detail__c', reportDetails);

        List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
        // Upsert all of the required records.
        // For each sobject.
        for (String sobjectName : recordsToUpsert.keySet()) {
          // Get the records linked to the sobject.
          List<SObject> records = recordsToUpsert.get(sobjectName);

          // If the records list is not empty.
          if (!records.isEmpty()) {
            // Upsert the records for the sobject.
            upsertResults.addAll(Database.upsert(records));
          }
        }

        processUpsertResults(upsertResults);
      } catch (Exception e) {
        Utilities.logException(e);
        // Database.rollback(savepoint);
      }
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 25-05-2022
     * @param BACS_Report_Detail__c reportDetail
     **/
    private void processADDACS(
      BACS_Report_Detail__c reportDetail,
      Account membership
    ) {
      // Initialise the variables.
      Id membershipId = reportDetail.Account__c;
      String reasonCode = reportDetail.Reason_Code__c;
      String message = '';

      // * * Payment Method Processing
      Payment_Method__c paymentMethod = membershipToPaymentMethodMapping.get(
        membershipId
      );
      // If the payment method was not found.
      if (paymentMethod == null) {
        message = getMessage(message, '- Payment Method: Not found.');
      } else {
        // If the reason code is contained.
        if (checkContains('0-1-2-3-B-C-D', reasonCode)) {
          // Update the payment method.
          paymentMethod.Status__c = 'Cancelled';
          // If the reason code is contained.
          if (checkContains('0-1-2-B-D', reasonCode)) {
            // Update the membership.
            membership.Payment_Method2__c = 'No payment method';
          } else if (checkContains('3-C', reasonCode)) {
            // Create the new payment method.
            createNewPaymentMethod(reportDetail, paymentMethod.Start_Date__c);
          }
        } else if (checkContains('E', reasonCode)) {
          // Else if the reason code is contained.
          // If the new sort code is blank
          // && the new account number is blank
          // && the new name is NOT blank.
          if (
            String.isBlank(reportDetail.Sort_Code_New__c) &&
            String.isBlank(reportDetail.Account_Number_New__c) &&
            String.isNotBlank(reportDetail.Name_New__c)
          ) {
            // Update the payment method.
            paymentMethod.Bank_Account_Name__c = reportDetail.Name_New__c;
          } else {
            // Create the new payment method.
            createNewPaymentMethod(reportDetail, paymentMethod.Start_Date__c);
          }
        }
        // Update the payment method mapping.
        membershipToPaymentMethodMapping.put(membershipId, paymentMethod);
      }

      // * * Transaction Processing
      List<Transaction__c> transactions = membershipToTransactionsMapping.get(
        membershipId
      );
      // If the transaction list is empty.
      if (transactions.isEmpty()) {
        message = getMessage(message, '- Transactions: Not found.');
      } else if (checkContains('0-1-2-3-C', reasonCode)) {
        // Else if the reason code is contained.
        // For each transaction.
        for (Transaction__c tran : transactions) {
          // If the transaction type is '0C'.
          if (tran.Transaction_Type__c == '0C') {
            // Update the transaction.
            tran.Status__c = 'Complete';
          } else if (tran.Transaction_Type__c == '0N') {
            // Else if transaction type is '0N'.
            // If the reason code is contained.
            // && the payment method is not cancelled.
            if (
              checkContains('3', reasonCode) &&
              paymentMethod.Status__c != 'Cancelled'
            ) {
              // Update the transaction.
              tran.Status__c = 'Pending';
            } else if (checkContains('C', reasonCode)) {
              // Else if the reason code is contained.
              // Update the transaction.
              tran.Status__c = 'Complete';
            }
          }
        }
        // Update the transaction mapping.
        membershipToTransactionsMapping.put(membershipId, transactions);
      }

      // * * Membership Processing
      // If the reason code is contained.
      if (checkContains('R', reasonCode)) {
        message = getMessage(
          message,
          '- Membership: Reason code causes an error.'
        );
      }
      // Update the membership mapping.
      membershipMapping.put(membershipId, membership);

      // Update the report details.
      reportDetail.Message__c = message;
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 25-05-2022
     * @param BACS_Report_Detail__c reportDetail
     **/
    private void processARUDD(
      BACS_Report_Detail__c reportDetail,
      Account membership
    ) {
      // Initialise the variables.
      Id membershipId = reportDetail.Account__c;
      String reasonCode = reportDetail.Reason_Code__c;
      String message = '';

      // Payment Method Processing
      Payment_Method__c paymentMethod = membershipToPaymentMethodMapping.get(
        membershipId
      );
      // If the payment method was not found.
      if (paymentMethod == null) {
        message = getMessage(message, '- Payment Method: Not found.');
      } else {
        // Update the payment method.
        paymentMethod.Status__c = 'Rejected';
        // Update the payment method mapping.
        membershipToPaymentMethodMapping.put(membershipId, paymentMethod);
      }

      // Transaction Processing
      List<Transaction__c> transactions = membershipToTransactionsMapping.get(
        membershipId
      );
      // If the transaction list is empty.
      if (transactions.isEmpty()) {
        message = getMessage(message, '- Transactions: Not found.');
      } else {
        // Update the latest transaction.
        transactions[0].Status__c = 'Rejected';

        // // For each transaction.
        // for (Transaction__c tran : transactions) {
        //   // Update the transaction.
        //   tran.Status__c = tran.Transaction_Type__c == '0C'
        //     ? 'Complete'
        //     : 'Rejected';
        // }
        // Update the transaction mapping.
        membershipToTransactionsMapping.put(membershipId, transactions);
      }

      // * * Membership Processing
      // Update the membership.
      membership.Membership_Status__c = 'DD Rejected';
      // Update the membership mapping.
      membershipMapping.put(membershipId, membership);

      // Update the report details.
      reportDetail.Message__c = message;
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 25-05-2022
     * @param BACS_Report_Detail__c reportDetail
     **/
    private void processAUDDIS(
      BACS_Report_Detail__c reportDetail,
      Account membership
    ) {
      // Initialise the variables.
      Id membershipId = reportDetail.Account__c;
      String reasonCode = reportDetail.Reason_Code__c;
      String message = '';

      // Payment Method Processing
      Payment_Method__c paymentMethod = membershipToPaymentMethodMapping.get(
        membershipId
      );
      // If the payment method was not found.
      if (paymentMethod == null) {
        message = getMessage(message, '- Payment Method: Not found.');
      } else {
        // If the reason code is contained.
        if (checkContains('1-2-5-6-B-K-L-I-F-G-N', reasonCode)) {
          // Update the payment method.
          paymentMethod.Status__c = 'Rejected';
        } else if (checkContains('C', reasonCode)) {
          // Else if the reason code is contained.
          // Update the payment method.
          paymentMethod.Status__c = 'Cancelled';
          // Create the new payment method.
          createNewPaymentMethod(reportDetail, paymentMethod.Start_Date__c);
        }
        // Update the payment method mapping.
        membershipToPaymentMethodMapping.put(membershipId, paymentMethod);
      }

      // Transaction Processing
      List<Transaction__c> transactions = membershipToTransactionsMapping.get(
        membershipId
      );
      // If the transaction list is empty.
      if (transactions.isEmpty()) {
        message = getMessage(message, '- Transactions: Not found.');
      } else {
        // If the reason code is contained.
        if (checkContains('1-2-3-5-6-B-C-K-L-I-F-G-N', reasonCode)) {
          // For each transaction.
          for (Integer i = 0; i < transactions.size(); i++) {
            // Initialise any variables.
            Transaction__c tran = transactions[i];

            // If the transaction type is '0C'.
            if (tran.Transaction_Type__c == '0C') {
              // Update the transaction.
              tran.Status__c = 'Complete';
            } else if (tran.Transaction_Type__c == '0N') {
              // Else if transaction type is '0N' {
              // If the reason code is contained.
              if (checkContains('C', reasonCode)) {
                // Update the transaction.
                tran.Status__c = 'Complete';
              } else if (checkContains('1-2-3-5-6-B-K-L-I-F-G-N', reasonCode)) {
                // Else if the reason code is contained.
                // Update the transaction.
                tran.Status__c = 'Rejected';
              }
            } else if (
              checkContains('01-17', tran.Transaction_Type__c) && i == 1
            ) {
              tran.Status__c = 'Rejected';
            }
          }

          // for (Transaction__c tran : transactions) {
          //   // If the transaction type is '0C'.
          //   if (tran.Transaction_Type__c == '0C') {
          //     // Update the transaction.
          //     tran.Status__c = 'Complete';
          //   } else if (tran.Transaction_Type__c == '0N') {
          //     // Else if transaction type is '0N' {
          //     // If the reason code is contained.
          //     if (checkContains('C', reasonCode)) {
          //       // Update the transaction.
          //       tran.Status__c = 'Complete';
          //     } else if (checkContains('1-2-3-5-6-B-K-L-I-F-G-N', reasonCode)) {
          //       // Else if the reason code is contained.
          //       // Update the transaction.
          //       tran.Status__c = 'Rejected';
          //     }
          //   }
          // }
        }
        // Update the transaction mapping.
        membershipToTransactionsMapping.put(membershipId, transactions);
      }

      // * * Membership Processing
      // If the reason code is contained.
      if ('1-2-5-6-B-K-L-I-F-G-N'.contains(reasonCode)) {
        // Update the membership.
        membership.Membership_Status__c = 'DD Rejected';
      } else if ('C'.contains(reasonCode)) {
        // Update the membership.
        membership.Payment_Method2__c = 'No payment method';
      } else if ('3-H-M-O-P-Q'.contains(reasonCode)) {
        message = getMessage(
          message,
          '- Membership: Reason code causes an error.'
        );
      }
      // Update the membership mapping.
      membershipMapping.put(membershipId, membership);

      // Update the report details.
      reportDetail.Message__c = message;
    }

    private void processUpsertResults(
      List<Database.UpsertResult> upsertResults
    ) {
      for (Database.UpsertResult upsertResult : upsertResults) {
        if (!upsertResult.isSuccess()) {
          for (Database.Error error : upsertResult.getErrors()) {
            System.debug('There was an error:');
            System.debug(error.getStatusCode() + ': ' + error.getMessage());
            System.debug('Fields affected: ' + error.getFields());
          }
        }
      }
    }

    // * Query Methods * //

    /**
     * @description
     * @author Kev Cadger (Wipro) | 24-05-2022
     **/
    private void getMembershipDetails() {
      // Get the membership details.
      // For each membership.
      for (Account membership : [
        SELECT
          Id,
          Hybrid_Membership_Number__c,
          Membership_Status__c,
          Payment_Method2__c
        FROM Account
        WHERE Id IN :membershipMapping.keySet()
      ]) {
        // Add the membership to the mapping.
        membershipMapping.put(membership.Id, membership);
        // Add the membership number to the set.
        membershipNumberSet.add(membership.Hybrid_Membership_Number__c);
      }
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 24-05-2022
     **/
    private void getPaymentMethodDetails() {
      // Get the payment method details.
      // For each payment method.
      for (Account membership : [
        SELECT
          Id,
          (
            SELECT
              Id,
              Bank_Account_Name__c,
              Bank_Account_Number__c,
              Sort_Code__c,
              Start_Date__c,
              Status__c
            FROM DD_Mandates__r
            WHERE
              RecordTypeId = :Utilities.getRecordTypeId(
                'Payment_Method__c',
                'Direct_Debit'
              )
              AND Status__c = 'Active'
            ORDER BY CreatedDate DESC
            LIMIT 1
          )
        FROM Account
        WHERE Id IN :membershipMapping.keySet()
      ]) {
        // If the payment method is not empty.
        if (!membership.DD_Mandates__r.isEmpty()) {
          // Add the payment method to the mapping.
          membershipToPaymentMethodMapping.put(
            membership.Id,
            membership.DD_Mandates__r[0]
          );
          paymentMethodIdSet.add(membership.DD_Mandates__r[0].Id);
        }
      }
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 24-05-2022
     **/
    private void getTransactionDetails() {
      // Get the transaction details.
      // For each transaction.
      for (Transaction__c tran : [
        SELECT Id, Membership__c, Transaction_Type__c, Status__c
        FROM Transaction__c
        WHERE
          Membership__c IN :membershipMapping.keySet()
          AND Payment_Method__c IN :paymentMethodIdSet
          AND Status__c != 'Rejected'
        ORDER BY Transaction_Date__c DESC
      ]) {
        // Add the transaction to the mapping.
        membershipToTransactionsMapping.get(tran.Membership__c).add(tran);
      }
    }

    // * Create Methods * //

    private void createNewPaymentMethod(
      BACS_Report_Detail__c reportDetail,
      Date startDate
    ) {
      // Initialise the payment method details.
      String bankAccountName = String.isNotBlank(reportDetail.Name_New__c)
        ? reportDetail.Name_New__c
        : reportDetail.Name__c;
      String bankAccountNumber = String.isNotBlank(
          reportDetail.Account_Number_New__c
        )
        ? reportDetail.Account_Number_New__c
        : reportDetail.Account_Number__c;
      String bankSortCode = String.isNotBlank(reportDetail.Sort_Code_New__c)
        ? reportDetail.Sort_Code_New__c
        : reportDetail.Sort_Code__c;
      Date bankStartDate = String.isNotBlank(
          String.valueOf(reportDetail.Effective_Date__c)
        )
        ? reportDetail.Effective_Date__c
        : startDate;

      // Initialise the new payment method.
      Payment_Method__c paymentMethod = new Payment_Method__c(
        Bank_Account_Name__c = bankAccountName,
        Bank_Account_Number__c = bankAccountNumber,
        Membership__c = reportDetail.Account__c,
        RecordTypeId = Utilities.getRecordTypeId(
          'Payment_Method__c',
          'Direct_Debit'
        ),
        Sort_Code__c = bankSortCode,
        Start_Date__c = bankStartDate,
        Status__c = 'Active'
      );

      // Add the payment method to the records to upsert.
      addRecordsToUpsert(
        'Payment_Method__c',
        new List<SObject>{ paymentMethod }
      );
    }

    // * Helper Methods * //

    /**
     * @description
     * @author Kev Cadger (Wipro) | 25-05-2022
     * @param String curMessage
     * @param String newMessage
     * @return String
     **/
    private String getMessage(String curMessage, String newMessage) {
      return (// If the current message is not blank.
        String.isNotBlank(curMessage) // Add the new message to the current message.
        ? curMessage +
          '\n' +
          newMessage // Add the new message as the current message.
        : newMessage);
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 25-05-2022
     * @param String check
     * @param String value
     * @return Boolean
     **/
    private Boolean checkContains(String check, String value) {
      // Return whether the check contains the value.
      return check.contains(value);
    }

    /**
     * @description
     * @author Kev Cadger (Wipro) | 24-05-2022 #
     * @param String sobjectName
     * @param SObject record
     **/
    private void addRecordsToUpsert(String sobjectName, List<SObject> records) {
      // While the index is less than the number of records.
      Integer i = 0;
      while (i < records.size()) {
        // If the record is null.
        if (records[i] == null) {
          // Remove it from the list.
          records.remove(i);
          // Move to the next record.
          continue;
        }
        // Increase the index.
        i++;
      }

      // If the sobject name is not in the keyset.
      if (!recordsToUpsert.containsKey(sobjectName)) {
        // Add the sobject name and initialise the new list with the record.
        recordsToUpsert.put(sobjectName, records);
      } else {
        // Add the records to the sobject name list.
        recordsToUpsert.get(sobjectName).addAll(records);
      }
    }
  }
}