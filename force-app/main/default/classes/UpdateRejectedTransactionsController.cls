/**
 * @description       : Apex controller for UpdateRejectedTransaction Lightning Aura component.
 * @author            : Alasdair Leggat (alasdair.leggat@weare4c.com)
 * @group             : Controller
 * @last modified on  : 24-03-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author                                            Request                         Modification
 * 1.0   11-06-2019   Alasdair Leggat (alasdair.leggat@weare4c.com)                                     Initial Version
 * 1.1   14-03-2022   Kev Cadger (Wipro)                                REQ-000109493                   Added in a check to ensure that there is a reference for the element.
**/

public class UpdateRejectedTransactionsController {

    public static Id ddRecordTypeId = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId();
    /*
     *    createBACSReport
     *    Method to create BACS report with record type based on report to be attached
     *    Return Id
     */
    @AuraEnabled
    public static Id createBACSReport(String reportType) {
        String returnValue;
        String recordName;
        String recordTypeID = Schema.SObjectType.BACS_Report__c.getRecordTypeInfosByName().get(reportType).getRecordTypeId();

        if (reportType == 'ARUDD') {
            recordName = 'Rejections';
        } else if (reportType == 'ADDACS') {
            recordName = 'Amendments';
        } else if (reportType == 'AUDDIS') {
            recordName = 'Instructions';
        }

        BACS_Report__c report = new BACS_Report__c(
                Name = recordName + '--' + String.valueOf(Datetime.now()),
                RecordTypeId = recordTypeID
        );

        try {
            insert report;
            returnValue = report.Id;
        } catch (Exception e) {
            System.debug('Exception creating new BACS report: ' + e);
        }
        return returnValue;
    }


    /*
     *    updateRejectedTransactions
     *    Method to update Transaction records to rejected
     *    Return Id
     */
    @AuraEnabled
    public static String updateRejectedTransactions(Id BACSRecordId, String reportType) {
        try {
            // get xml doc from BACS record
            String xmlDocData = getXMLDocumentContent(BACSRecordId);

            // parse xml doc and get relevent data
            List<ReturnedDebitItem> debitItems = parseXMLDocument(xmlDocData, reportType);

            // get membership numbers
            Set<String> membershipNumbers = getMembershipNumbers(debitItems);

            // get memberships
            Map<String, Account> memberships = getMemberships(membershipNumbers);

            // get payment method records
            Map<String, Payment_Method__c> paymentMethods = getPaymentMethods(membershipNumbers);

            // update memberships and payment methods
            ParseResults membershipParseResults = upsertRecords('Membership', reportType, debitItems, memberships);
            List<Database.UpsertResult> membershipSaveResults = membershipParseResults.upsertResults;

            ParseResults paymentMethodParseResults = upsertRecords('PaymentMethod', reportType, debitItems, paymentMethods);
            List<Database.UpsertResult> paymentMethodSaveResults = paymentMethodParseResults.upsertResults;

            // get transaction records
            Map<String, List<Transaction__c>> transactions = getTransactions(paymentMethods);

            // update payment method and transaction records
            List<Database.UpsertResult> transactionSaveResults = upsertRecords('Transaction', reportType, debitItems, transactions);

            // create list of all save results
            List<Database.UpsertResult> saveResults = new List<Database.UpsertResult>();
            saveResults.addAll(membershipSaveResults);
            saveResults.addAll(paymentMethodSaveResults);
            if (transactionSaveResults != null) {
                saveResults.addAll(transactionSaveResults);
            }

            String updateResult = getBACSReportLink(BACSRecordId);
            updateResult += getUpdateResult(saveResults);
            //updateResult += checkForMissingSFRecords(memberships, membershipNumbers);

            // create error log and attach to BACS report record
            createErrorLog(BACSRecordId, membershipSaveResults, paymentMethodSaveResults, transactionSaveResults, memberships, membershipNumbers, membershipParseResults.errorLog);


            // return update results
            return updateResult;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            return '';
        }
    }


    /*
     *    getXMLDocumentContent
     *    Method to get xml document content from ContentVersion attached to BACS record
     *    Return String
     */
    private static String getXMLDocumentContent(Id BACSRecordId) {
        ContentVersion xmlDoc;

        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :BACSRecordId];

        if (!documentLinks.isEmpty()) {
            ContentDocumentLink documentLink = documentLinks.get(0);
            xmlDoc = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :documentLink.ContentDocumentId];

        }
        return xmlDoc.VersionData.toString();
    }

    /**
    * @description Method to parse XML document content.
    * @author Alasdair Leggat (alasdair.leggat@weare4c.com) | 11-06-20219
    * @param String xmlDoc The XML document content.
    * @param String reportType The report type the content relates to.
    * @return List<ReturnedDebitItem> The debit items to be processed.
    * Modifications Log
    * Ver   Date         Author                                            Request                         Modification
    * 1.0   11-06-2019   Alasdair Leggat (alasdair.leggat@weare4c.com)                                     Initial Version
    * 1.1   14-03-2022   Kev Cadger (Wipro)                                REQ-000109493                   Added in a check to ensure that there is a reference for the element.
    **/
    private static List<ReturnedDebitItem> parseXMLDocument(String xmlDoc, String reportType) {
        List<ReturnedDebitItem> debitItems = new List<ReturnedDebitItem>();
        XmlStreamReader reader = new XmlStreamReader(xmlDoc);
        // set local name based on xml doc type
        String localName;
        if (reportType == 'ARUDD') {
            localName = 'ReturnedDebitItem';
        } else if (reportType == 'ADDACS' || reportType == 'AUDDIS') {
            localName = 'MessagingAdvice';
        }


        // traverse document and create ReturnedDebitItem objects
        Boolean hasNextElement = true;
        while (hasNextElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == localName) {
                    // If there is a reference.
                    if (String.isNotBlank(reader.getAttributeValue(null, 'ref')) || String.isNotBlank(reader.getAttributeValue(null, 'reference'))) {
                        ReturnedDebitItem debitItem = parseXmlElement(reader, reportType);
                        debitItems.add(debitItem);
                    }
                }
            }

            // check for next element, break if doesn't exist
            if (reader.hasNext()) {
                reader.next();
            } else {
                hasNextElement = false;
                break;
            }
        }

        return debitItems;
    }


    /*
     *    parseReturnedDebitItem
     *    Method to parse individial returnedDebitItem elements in xml doc
     *    Return ReturnedDebitItem
     */
    private static ReturnedDebitItem parseXmlElement(XmlStreamReader reader, String reportType) {
        ReturnedDebitItem debitItem = new ReturnedDebitItem();

        // get information from relevent place in xml docs based on type
        if (reportType == 'ARUDD') {
            // membership numbers are a string of number chars followed by 'DIRECT DBT' or 'DIRECT DEBIT'
            debitItem.referenceNumber = reader.getAttributeValue(null, 'ref').split('D').get(0);
            debitItem.returnDescription = reader.getAttributeValue(null, 'returnDescription');
        } else if (reportType == 'ADDACS' || reportType == 'AUDDIS') {
            debitItem.referenceNumber = reader.getAttributeValue(null, 'reference').split('D').get(0);
            debitItem.returnDescription = reader.getAttributeValue(null, 'reason-code');

            // if changes made to account, get details, otherwise set to null
            debitItem.newAccountName = reader.getAttributeValue(null, 'payer-new-name');
            debitItem.newSortCode = reader.getAttributeValue(null, 'payer-new-sort-code');
            debitItem.newAccountNumber = reader.getAttributeValue(null, 'payer-new-account-number');

            if (reader.getAttributeValue(null, 'effective-date') != null) {
                debitItem.startDate = Date.valueOf(reader.getAttributeValue(null, 'effective-date'));
            } else {
                debitItem.startDate = Date.today();
            }


        }

        Boolean hasNextElement = true;
        while (hasNextElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            }

            // check for next element, break if doesn't exist
            if (reader.hasNext()) {
                reader.next();
            } else {
                hasNextElement = false;
                break;
            }
        }
        return debitItem;
    }


    /*
     *    getMembershipNumbers
     *    Method to get membership numbers from returned debit items
     *    Return Set<String>
     */
    private static Set<String> getMembershipNumbers(List<ReturnedDebitItem> debitItems) {
        Set<String> membershipNumbers = new Set<String>();

        for (ReturnedDebitItem debitItem : debitItems) {
            membershipNumbers.add(debitItem.referenceNumber);
        }

        return membershipNumbers;
    }


    /*
     *    getMemberships
     *    Method to get membership (Account) records
     *    Return Map<String, Account>
     */
    private static Map<String, Account> getMemberships(Set<String> membershipNumbers) {
        Map<String, Account> membershipMap = new Map<String, Account>();
        List<Account> memberships = [
                SELECT Id, Hybrid_Membership_Number__c, Membership_Status__c
                FROM Account
                WHERE Hybrid_Membership_Number__c IN :membershipNumbers
        ];

        if (memberships.isEmpty()) {
            return null;
        }

        for (Account membership : memberships) {
            membershipMap.put(membership.Hybrid_Membership_Number__c, membership);
        }

        System.debug('------------- membershipMap: ' + membershipMap);
        return membershipMap;
    }


    /*
     *    getPaymentMethods
     *    Method to get payment method records
     *    Return Map<String, Payment_Method__c>
     */
    private static Map<String, Payment_Method__c> getPaymentMethods(Set<String> membershipNumbers) {
        Map<String, Payment_Method__c> paymentMethodMap = new Map<String, Payment_Method__c>();

        Id directDebitRecordType = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId();

        List<Payment_Method__c> paymentMethods = [
                SELECT Id, Status__c, Membership_Number__c, Membership__c, Start_Date__c, Bank_Account_Name__c, Sort_Code__c, Bank_Account_Number__c, (SELECT Id FROM Transactions__r ORDER BY CreatedDate DESC LIMIT 1)
                FROM Payment_Method__c
                WHERE Membership_Number__c IN :membershipNumbers
                AND RecordTypeId = :directDebitRecordType
                AND Status__c = 'Active'
                ORDER BY CreatedDate DESC
        ];

        System.debug('------------- paymentMethods: ' + paymentMethods);
        if (paymentMethods.isEmpty()) {
            return null;
        }

        for (Payment_Method__c paymentMethod : paymentMethods) {
            String memberhipNumber = paymentMethod.Membership_Number__c;

            // make sure only latest payment metho for membership is included
            if (paymentMethodMap.keySet().contains(memberhipNumber)) {
                continue;
            }

            paymentMethodMap.put(memberhipNumber, paymentMethod);
        }

        System.debug('------------- paymentMethodMap: ' + paymentMethodMap);
        return paymentMethodMap;
    }


    /*
      *    getTransactions
      *    Method to get payment method records
      *    Return Map<String, Transaction__c>
      */
    private static Map<String, List<Transaction__c>> getTransactions(Map<String, Payment_Method__c> paymentMethods) {
        Set<Id> paymentMethodIds = new Set<Id>();
        Set<String> fuzzyMembershipNumbers = new Set<String>();
        for (Payment_Method__c pm : paymentMethods.values()) {
            //paymentMethodIds.add(pm.Id);
            fuzzyMembershipNumbers.add(pm.Membership_Number__c + '%');
        }

        List<Transaction__c> transactions = [
                SELECT Id, Status__c, Membership_Number__c, Transaction_Type__c, Membership_DD_Ident__c, Payment_Method__r.Status__c
                FROM Transaction__c
                //WHERE Payment_Method__c IN :paymentMethodIds
                WHERE Membership_DD_Ident__c LIKE :fuzzyMembershipNumbers
                AND Status__c != 'Rejected'
                ORDER BY Transaction_Date__c DESC
        ];

        Map<String, List<Transaction__c>> transactionMap = new Map<String, List<Transaction__c>>();

        if (transactions.isEmpty()) {
            return null;
        }

        for (Transaction__c trans : transactions) {
            //String membershipNumber = trans.Membership_Number__c;
            String membershipNumber = trans.Membership_DD_Ident__c.split('D').get(0);

            // check if map contains membership number, add transaction to List...
            if (transactionMap.keySet().contains(membershipNumber)) {
                transactionMap.get(membershipNumber).add(trans);
            } else { //... else instantiate list of Transaction and add transaction
                transactionMap.put(membershipNumber, new List<Transaction__c>{
                        trans
                });
            }

        }

        return transactionMap;
    }


    /*
     *    updateRecords
     *    Overloaded method to update records
     *    Return List<Database.SaveResult>
     */
    private static ParseResults upsertRecords(String sObjectType, String reportType, List<ReturnedDebitItem> debitItems, Map<String, sObject> records) {

        List<sObject> recordsToUpdate;
        ParseResults parseResults;

        // check sObjectType
        if (sObjectType == 'Membership') {
            // update memberships
            parseResults = updateMemberships(debitItems, records, reportType);
            recordsToUpdate = (List<Account>) parseResults.recordsToUpsert;
        } else if (sObjectType == 'PaymentMethod') {
            // update payment statuses
            parseResults = new ParseResults();
            recordsToUpdate = (List<Payment_Method__c>) upsertPaymentMethods(debitItems, records, reportType);
        }

        List<Database.UpsertResult> updateResult = Database.upsert(recordsToUpdate, false);
        System.debug('updateResult: ' + updateResult);
        parseResults.upsertresults = updateResult;

        return parseResults;

    }


    /*
     *    updateRecords
     *    Overloaded method to update records
     *    Return List<Database.SaveResult>
     */
    private static List<Database.UpsertResult> upsertRecords(String sObjectType, String reportType, List<ReturnedDebitItem> debitItems, Map<String, List<sObject>> records) {

        if (records == null) {
            return null;
        }

        List<sObject> recordsToUpsert;

        // check sObjectType
        if (sObjectType == 'Transaction') {
            // update transactions
            recordsToUpsert = (List<Transaction__c>) updateTransactions(debitItems, records, reportType);
        }
        List<Database.UpsertResult> updateResult = Database.upsert(recordsToUpsert, false);
        return updateResult;

    }


    /*
     *    updateMemberships
     *    Method to update membership (Account) records
     *    Return List<Account>
     */
    private static ParseResults updateMemberships(List<ReturnedDebitItem> debitItems, Map<String, sObject> records, String reportType) {
        // cast records to list of payment method
        Map<String, Account> memberships = (Map<String, Account>) records;


        List<Account> membershipsToUpdate = new List<Account>();

        ParseResults parseResults = new ParseResults();

        if (reportType == 'ARUDD') {
            for (Account membership : memberships.values()) {
                membership.Membership_Status__c = 'DD Rejected';
                membershipsToUpdate.add(membership);
            }

        } else if (reportType == 'AUDDIS') {
            for (ReturnedDebitItem debitItem : debitItems) {
                if ('1-2-5-6-B-K-L-I-F-G-N'.contains(debitItem.returnDescription)) {
                    Account membership = memberships.get(debitItem.referenceNumber);
                    membership.Membership_Status__c = 'DD Rejected';
                    membershipsToUpdate.add(membership);
                } else if ('3-H-M-O-P-Q'.contains(debitItem.returnDescription)) {
                    parseResults.errorLog += reportType + ', ' + debitItem.returnDescription + ', ' + debitItem.referenceNumber + '\n';

                }
            }

        } else if (reportType == 'ADDACS') {
            for (ReturnedDebitItem debitItem : debitItems) {
                if ('R'.contains(debitItem.returnDescription)) {
                    parseResults.errorLog += reportType + ', ' + debitItem.returnDescription + ', ' + debitItem.referenceNumber + '\n';
                }
            }
        }
        parseResults.recordsToUpsert = membershipsToUpdate;
        return parseResults;
    }


    /*
     *    updatePaymentMethods
     *    Method to update payment method records
     *    Return List<Payment_Method__c>
     */
    private static List<Payment_Method__c> upsertPaymentMethods(List<ReturnedDebitItem> debitItems, Map<String, sObject> records, String reportType) {
        // cast records to list of payment method
        Map<String, Payment_Method__c> paymentMethods = (Map<String, Payment_Method__c>) records;

        List<Payment_Method__c> paymentMethodsToUpsert = new List<Payment_Method__c>(); //TODO make upsert
        if (reportType == 'ARUDD') {
            for (Payment_Method__c paymentMethod : paymentMethods.values()) {
                paymentMethod.Status__c = 'Rejected';
                paymentMethodsToUpsert.add(paymentMethod);
            }

        } else if (reportType == 'ADDACS') {
            ///loop over debitItems and set payment method status
            for (ReturnedDebitItem debitItem : debitItems) { ///
                if ('0-1-2-3-B-C-D'.contains(debitItem.returnDescription)) {
                    if (!paymentMethods.containsKey(debitItem.referenceNumber)) {
                        continue;
                    }
                    Payment_Method__c paymentMethod = paymentMethods.get(debitItem.referenceNumber);
                    paymentMethod.Status__c = 'Cancelled';
                    paymentMethodsToUpsert.add(paymentMethod);

                    // create new payment method only if new information returned from the bank
                    if ('3-C'.contains(debitItem.returnDescription) &&
                            (debitItem.newSortCode != null ||
                                    debitItem.newAccountNumber != null ||
                                    debitItem.newAccountName != null ||
                                    debitItem.startDate != null)) {
                        paymentMethodsToUpsert.add(new Payment_Method__c(
                                Sort_Code__c = debitItem.newSortCode == null ? paymentMethod.Sort_Code__c : debitItem.newSortCode,
                                Bank_Account_Number__c = debitItem.newAccountNumber == null ? paymentMethod.Bank_Account_Number__c : debitItem.newAccountNumber,
                                Start_Date__c = debitItem.startDate == null ? paymentMethod.Start_Date__c : debitItem.startDate,
                                Bank_Account_Name__c = debitItem.newAccountName == null ? paymentMethod.Bank_Account_Name__c : debitItem.newAccountName,
                                RecordTypeId = ddRecordTypeId,
                                Membership__c = paymentMethod.Membership__c,
                                Status__c = 'Active'
                        ));
                    }
                } else if ('E'.contains(debitItem.returnDescription)) {
                    System.debug('debitItem: ' + debitItem);
                    if (!paymentMethods.containsKey(debitItem.referenceNumber)) {
                        continue;
                    }
                    Payment_Method__c paymentMethod = paymentMethods.get(debitItem.referenceNumber);
                    if (debitItem.newSortCode == null && debitItem.newAccountNumber != null) {
                        paymentMethod.Status__c = 'Cancelled';

                        paymentMethodsToUpsert.add(new Payment_Method__c(
                                Sort_Code__c = paymentMethod.Sort_Code__c,
                                Bank_Account_Number__c = debitItem.newAccountNumber,
                                RecordTypeId = ddRecordTypeId,
                                Membership__c = paymentMethod.Membership__c,
                                Status__c = 'Active',
                                Bank_Account_Name__c = paymentMethod.Bank_Account_Name__c,
                                Start_Date__c = debitItem.startDate
                        ));
                    } else if (debitItem.newSortCode != null && debitItem.newAccountNumber == null) {
                        paymentMethod.Status__c = 'Cancelled';

                        paymentMethodsToUpsert.add(new Payment_Method__c(
                                Sort_Code__c = debitItem.newSortCode,
                                Bank_Account_Number__c = paymentMethod.Bank_Account_Number__c,
                                RecordTypeId = ddRecordTypeId,
                                Membership__c = paymentMethod.Membership__c,
                                Status__c = 'Active',
                                Bank_Account_Name__c = paymentMethod.Bank_Account_Name__c,
                                Start_Date__c = debitItem.startDate
                        ));
                    } else if (debitItem.newSortCode != null && debitItem.newAccountNumber != null) {
                        paymentMethod.Status__c = 'Cancelled';

                        paymentMethodsToUpsert.add(new Payment_Method__c(
                                Sort_Code__c = debitItem.newSortCode,
                                Bank_Account_Number__c = debitItem.newAccountNumber,
                                RecordTypeId = ddRecordTypeId,
                                Membership__c = paymentMethod.Membership__c,
                                Status__c = 'Active',
                                Bank_Account_Name__c = paymentMethod.Bank_Account_Name__c,
                                Start_Date__c = debitItem.startDate
                        ));
                    } else if (debitItem.newSortCode == null && debitItem.newAccountNumber == null && debitItem.newAccountName != null) {
                        paymentMethod.Bank_Account_Name__c = debitItem.newAccountName;
                    }
                    paymentMethodsToUpsert.add(paymentMethod);
                }
            }
        } else if (reportType == 'AUDDIS') {
            for (ReturnedDebitItem debitItem : debitItems) {
                // set payment method to cancelled for required return codes
                if (!paymentMethods.containsKey(debitItem.referenceNumber)) {
                    continue;
                }
                if ('1-2-5-6-B-K-L-I-F-G-N'.contains(debitItem.returnDescription)) {
                    Payment_Method__c paymentMethod = paymentMethods.get(debitItem.referenceNumber);
                    paymentMethod.Status__c = 'Rejected';
                    paymentMethodsToUpsert.add(paymentMethod);
                } else if ('C'.contains(debitItem.returnDescription)) {
                    Payment_Method__c paymentMethod = paymentMethods.get(debitItem.referenceNumber);
                    paymentMethod.Status__c = 'Cancelled';
                    Payment_Method__c newPaymentMethod = new Payment_Method__c(
                            Sort_Code__c = debitItem.newSortCode,
                            Bank_Account_Number__c = debitItem.newAccountNumber,
                            RecordTypeId = ddRecordTypeId,
                            Membership__c = paymentMethod.Membership__c
                    );
                    paymentMethodsToUpsert.add(paymentMethod);
                    paymentMethodsToUpsert.add(newPaymentMethod);
                }
            }
        }

        System.debug('------------- paymentMethodsToUpsert: ' + paymentMethodsToUpsert);

        return paymentMethodsToUpsert;

    }


    /*
     *    updateTransactions
     *    Method to update transaction records
     *    Return List<Transaction__c>
     */
    private static List<Transaction__c> updateTransactions(List<ReturnedDebitItem> debitItems, Map<String, List<sObject>> records, String reportType) {
        // cast records to list of transaction
        Map<String, List<Transaction__c>> transactionMap = (Map<String, List<Transaction__c>>) records;
        if (transactionMap == null) {
            return null;
        }

        List<Transaction__c> transactionsToUpdate = new List<Transaction__c>();

        if (reportType == 'ARUDD') {
            for (ReturnedDebitItem debitItem : debitItems) {
                List<Transaction__c> transactions = transactionMap.get(debitItem.referenceNumber);
                if (transactions == null) {
                    continue;
                }

                // loop over transactions
                for (Transaction__c trans : transactions) {
                    // reject latest non 0C transaction
                    if (trans.Transaction_Type__c != '0C') {
                        trans.Status__c = 'Rejected';
                        transactionsToUpdate.add(trans);
                        break;
                    } else if (trans.Transaction_Type__c == '0C') {
                        trans.Status__c = 'Complete';
                        transactionsToUpdate.add(trans);
                    }
                }
            }
        } else if (reportType == 'ADDACS') {
            for (ReturnedDebitItem debitItem : debitItems) {
                if ('0-1-2-3-C'.contains(debitItem.returnDescription)) {
                    List<Transaction__c> transactions = transactionMap.get(debitItem.referenceNumber);

                    if (transactions == null) {
                        continue;
                    }

                    // loop over transactions
                    for (Transaction__c trans : transactions) {
                        // if transaction is 0C type, set to complete
                        if (trans.Transaction_Type__c == '0C') {
                            if ('0-1-2-3-C-E'.contains(debitItem.returnDescription)) {
                                trans.Status__c = 'Complete';
                            }
                        } else if (trans.Transaction_Type__c == '0N') {
                            if ('3'.contains(debitItem.returnDescription) && trans.Payment_Method__r.Status__c != 'Cancelled') {
                                trans.Status__c = 'Pending';

                            } else if ('C'.contains(debitItem.returnDescription)) {
                                trans.Status__c = 'Complete';
                            }
                        }
                        transactionsToUpdate.add(trans); //TODO MAKE UPSERT 
                    }
                }
            }

        } else if (reportType == 'AUDDIS') {
            for (ReturnedDebitItem debitItem : debitItems) {
                List<Transaction__c> transactions = transactionMap.get(debitItem.referenceNumber);

                if (transactions == null) {
                    continue;
                }

                // set transaction to complete for required return codes
                if ('1-2-3-5-6-B-C-K-L-I-F-G-N'.contains(debitItem.returnDescription)) {
                    for (Transaction__c trans : transactions) {
                        if (trans.Transaction_Type__c == '0N') {
                            if ('C'.contains(debitItem.returnDescription)) {
                                trans.Status__c = 'Complete';
                            } else if ('1-2-3-5-6-B-K-L-I-F-G-N'.contains(debitItem.returnDescription)) {
                                trans.Status__c = 'Rejected';
                            }
                        } else if (trans.Transaction_Type__c == '0C') {
                            trans.Status__c = 'Complete';
                        }
                        transactionsToUpdate.add(trans);
                    }
                }
            }
        }

        System.debug('------------- transactionsToUpdate: ' + transactionsToUpdate);

        return transactionsToUpdate;
    }


    /*
     *    createErrorLog
     *    Method to create error log for reports
     *    Return void
     */
    private static void createErrorLog(Id BACSRecordId, List<Database.UpsertResult> membershipSaveResults, List<Database.UpsertResult> paymentMethodSaveResults, List<Database.UpsertResult> transactionSaveResults, Map<String, Account> memberships, Set<String> membershipNumbers, String currentErrorLog) {
        // write csv content, start with column headers
        String csvContent = currentErrorLog + '\nrecordId, reference number, missing record?\n';


        // add info for each sObject
        csvContent += createSObjectCSVLines('Membership', membershipSaveResults, memberships, membershipNumbers);
        csvContent += createSObjectCSVLines('PaymentMethod', paymentMethodSaveResults, null, null);

        if (transactionSaveResults != null) {
            csvContent += createSObjectCSVLines('Transaction', transactionSaveResults, null, null);
        }

        // attach error log to BACS report
        attachErrorLogToBACSReport(csvContent, BACSRecordId);

        // System.debug('------------- csvContent: ' + csvContent);
    }


    /*
     *    createSObjectCSVLines
     *    Method to create lines for sObjects to add to csv
     *    Return String
     */
    private static String createSObjectCSVLines(String sObjectType, List<Database.UpsertResult> saveResults, Map<String, Account> memberships, Set<String> membershipNumbers) {
        String sObjectCSVLines = '';
        Set<Id> failedRecordUpdateIds = new Set<Id>();

        // get record ids that failed to update
        for (Database.UpsertResult result : saveResults) {
            if (!result.isSuccess()) {
                failedRecordUpdateIds.add(result.getId());
            }
        }

        // create lines for csv depending on sObject type
        if (sObjectType == 'Membership') {
            List<Account> failedMembershipUpdates = [SELECT Id, Hybrid_Membership_Number__c FROM Account WHERE Id IN :failedRecordUpdateIds];

            // loop over memberships and add info to sObjectCSVLines
            for (Account membership : failedMembershipUpdates) {
                sObjectCSVLines += membership.Id + ', ' + membership.Hybrid_Membership_Number__c + ', no' + '\n';
            }

            // add info for missing membership records
            sObjectCSVLines += checkForMissingSFRecords(memberships, membershipNumbers);

        } else if (sObjectType == 'PaymentMethod') {
            List<Payment_Method__c> failedPaymentMethodUpdates = [SELECT Id, Membership_Number__c FROM Payment_Method__c WHERE Id IN :failedRecordUpdateIds];

            // loop over payment methods and add info to sObjectCSVLines
            for (Payment_Method__c paymentMethod : failedPaymentMethodUpdates) {
                sObjectCSVLines += paymentMethod.Id + ', ' + paymentMethod.Membership_Number__c + ', no' + '\n';
            }

        } else if (sObjectType == 'Transaction') {
            List<Transaction__c> failedTransactionUpdates = [SELECT Id, Membership_Number__c FROM Transaction__c WHERE Id IN :failedRecordUpdateIds];

            // loop over transactions methods and add info to sObjectCSVLines
            for (Transaction__c trans : failedTransactionUpdates) {
                sObjectCSVLines += trans.Id + ', ' + trans.Membership_Number__c + ', no' + '\n';
            }

        }

        return sObjectCSVLines;

    }


    /*
     *    attachErrorLogToBACSReport
     *    Method to attach error log to BACS report
     *    Return void
     */
    private static void attachErrorLogToBACSReport(String csvContent, Id BACSRecordId) {
        // create content version
        ContentVersion csv = new ContentVersion(
                ContentLocation = 'S',
                Title = 'Error Log',
                VersionData = Blob.valueOf(csvContent),
                PathOnClient = 'ErrorLog.csv'
        );

        try {
            insert csv;
        } catch (DmlException e) {
            System.debug('Error inserting csv: ' + e);
        }

        // get content document id
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :csv.Id].get(0).ContentDocumentId;

        // create content document link
        ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = BACSRecordId,
                ShareType = 'V'
        );

        try {
            insert cdl;
        } catch (DmlException e) {
            System.debug('Error inserting Content Document Link: ' + e);
        }


    }


    /*
     *    getBACSReportLink
     *    method to create a link to the newly created BACS report
     *    return String
     */
    private static String getBACSReportLink(Id BACSRecordId) {
        return '<p> Information for <a href="/' + BACSRecordId + '"> BACS report </a></p>';
    }


    /*
     *    getUpdateResult
     *    Method to get result from Database.update
     *    Return String
     */
    private static String getUpdateResult(List<Database.UpsertResult> saveResults) {
        String updateResult = '';

        // loop over save results
        for (Database.UpsertResult saveResult : saveResults) {
            Id recordId = saveResult.getId();
            // check if successful
            if (!saveResult.isSuccess()) {
                // if not, alert user on Lightning Aura component UI
                updateResult += '<p class="errorMsg"> Record with id: ' + recordId + ' not updated</p>';
            } else {
                updateResult += '<p class="successMsg"> Record with id: <a href="/' + recordId + '">' + recordId + '</a> successfully updated</p>';
            }
        }

        return updateResult;
    }


    /*
     *    checkForMissingSFRecords
     *    Method to check for records present in uploaded report that don't exist in SF
     *    Return String
     */
    private static String checkForMissingSFRecords(Map<String, Account> memberships, Set<String> membershipNumbers) {
        String missingRecords = '';
        Set<String> missingRecordMembershipNumbers = new Set<String>();

        // loop over membership numbers
        for (String membershipNumber : membershipNumbers) {
            // if membership number not in memberships keyset, add membership number to new set
            if (!memberships.keySet().contains(membershipNumber)) {
                missingRecordMembershipNumbers.add(membershipNumber);
            }
        }

        for (String membershipNumber : missingRecordMembershipNumbers) {
            missingRecords += '-- N/A --, ' + membershipNumber + ', yes\n';
        }

        return missingRecords;

    }


    /*
     *    ReturnedDebitItem
     *    Class to hold data from individual xml elements xml doc
     */
    private class ReturnedDebitItem {
        String referenceNumber;
        String returnDescription;
        String newSortCode;
        String newAccountNumber;
        String newAccountName;
        Date startDate;
    }

    private class ParseResults {
        List<sObject> recordsToUpsert;
        List<Database.UpsertResult> upsertResults;
        String errorLog;

        private ParseResults() {
            errorLog = 'Report type, Error Code, Reference Number \n';
        }
    }
}