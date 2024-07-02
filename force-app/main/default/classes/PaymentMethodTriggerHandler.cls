/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 14-07-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   16-06-2022   Kev Cadger (Wipro)   Initial Version
 **/
public with sharing class PaymentMethodTriggerHandler extends TriggerHandler {
  public PaymentMethodTriggerHandler() {
    preventRecursiveTrigger(false);
  }

  public override void beforeInsert(List<SObject> newObjects) {
    Set<id> accountIds = new Set<id>();
    Constants sc = new Constants();
    List<Correspondence__c> corres = new List<Correspondence__c>();

    Set<id> accountId = new Set<id>();
    List<Payment_Method__c> newPMs = (List<Payment_Method__c>) newObjects;

    for (Payment_Method__c newPaymentMethod : newPMs) {
      if (newPaymentMethod.One_off_payment_date__c == null)
        accountIds.add(newPaymentMethod.Membership__c);
    }

    List<Payment_Method__c> newPM = (List<Payment_Method__c>) newObjects;

    for (Payment_Method__c newPayMeth : newPM) {
      accountId.add(newPayMeth.Membership__c);
    }

    Map<Id, Account> mapPmAcc = new Map<Id, Account>(
      [
        SELECT
          Id,
          Email__c,
          Renewal_Date__c,
          Payment_Method2__c,
          (
            SELECT
              Id,
              Status__c,
              RecordTypeId,
              Bank_Account_Name__c,
              Bank_Account_Number__c,
              Sort_Code__c
            FROM DD_Mandates__r
          ),
          (
            SELECT Id, CloseDate, Amount
            FROM Opportunities
            WHERE RecordTypeId != :sc.OppChangeRecordTypeId
            ORDER BY CloseDate DESC
          ),
          (
            SELECT Id, Salutation, FirstName, LastName
            FROM Contacts
            WHERE RecordTypeId = :sc.leadContactRecordTypeId
          )
        FROM Account
        WHERE Id IN :accountid
      ]
    );

    if (!mapPmAcc.isEmpty()) {
      for (Payment_Method__c pm : newPM) {
        if (
          pm.Membership__c != null && mapPmAcc.containsKey(pm.Membership__c)
        ) {
          Account membership = mapPmAcc.get(pm.Membership__c);

          // Set Membership_Email__c.
          pm.Membership_Email__c = membership.Email__c;

          // if payment record is direct debit and membership email is null or dummy, create correspondence record
          if (
            pm.RecordTypeId == sc.ddebitRecordTypeId &&
            (membership.Email__c == null ||
            membership.Email__c == 'example@example.com') //
          ) {
            List<Payment_Method__c> oldPay = mapPmAcc.get(pm.Membership__c)
              .DD_Mandates__r;

            if (oldPay.size() == 0) {
              //&& (membership.Email__c == null || membership.Email__c == 'example@example.com')
              Correspondence__c corrs = new Correspondence__c();
              corrs.Membership__c = pm.Membership__c;
              corrs.Correspondence_Type__c = 'New Member DD';
              corrs.Bank_Account_Name__c = pm.Bank_Account_Name__c;
              corrs.Bank_Account_Number__c = pm.Bank_Account_Number__c;
              corrs.Sort_Code__c = pm.Sort_Code__c;
              corrs.Total_Fee__c = pm.Mandate_Amount__c;
              corrs.Payment_Method__c = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosById()
                .get(pm.RecordTypeId)
                .getName();
              for (Contact lc : mapPmAcc.get(pm.Membership__c).Contacts) {
                corrs.Lead_Member_Salutation__c = lc.Salutation;
                corrs.Lead_Member_First_Name__c = lc.FirstName;
                corrs.Lead_Member_Last_Name__c = lc.LastName;
              }
              corrs.Correspondence_date__c = System.today();
              corres.add(corrs);
            } else {
              //boolean f1;
              boolean paymentMethodChange = false;
              for (Payment_Method__c opm : oldPay) {
                if (
                  opm.RecordTypeId == sc.ddebitRecordTypeId &&
                  opm.Status__c == 'Active'
                ) {
                  // if bank account number OR sort code OR bank account name change AND membership email not null or dummy
                  if (
                    pm.Bank_Account_Number__c != opm.Bank_Account_Number__c ||
                    pm.Sort_Code__c != opm.Sort_Code__c ||
                    pm.Bank_Account_Name__c != opm.Bank_Account_Name__c
                  ) {
                    //&& (membership.Email__c == null || membership.Email__c == 'example@example.com')
                    paymentMethodChange = true;
                    break;
                  }
                }
              }

              if (paymentMethodChange) {
                Correspondence__c corrs = new Correspondence__c();
                corrs.Membership__c = pm.Membership__c;
                corrs.Correspondence_Type__c = 'Amend DD';
                corrs.Bank_Account_Name__c = pm.Bank_Account_Name__c;
                corrs.Bank_Account_Number__c = pm.Bank_Account_Number__c;
                corrs.Sort_Code__c = pm.Sort_Code__c;
                corrs.Payment_Method__c = mapPmAcc.get(pm.Membership__c)
                  .Payment_Method2__c;
                if (pm.Mandate_Amount__c != 0) {
                  corrs.Total_Fee__c = pm.Mandate_Amount__c;
                } else {
                  corrs.Total_Fee__c = mapPmAcc.get(pm.Membership__c)
                    .Opportunities[0]
                    .Amount;
                }
                for (Contact lc : mapPmAcc.get(pm.Membership__c).Contacts) {
                  corrs.Lead_Member_Salutation__c = lc.Salutation;
                  corrs.Lead_Member_First_Name__c = lc.FirstName;
                  corrs.Lead_Member_Last_Name__c = lc.LastName;
                }
                corrs.Correspondence_date__c = system.today();
                corres.add(corrs);
              }
            }
          }
        }
      }
    }

    if (corres.size() > 0) {
      insert corres;
    }

    List<Payment_Method__c> oldpmlist = [
      SELECT Id, Status__c, End_Date__c
      FROM Payment_Method__c
      WHERE
        Membership__c IN :accountIds
        AND Status__c = 'Active'
        AND RecordTypeId = :sc.ddebitRecordTypeId
    ];

    for (Payment_Method__c pm : oldpmlist) {
      pm.status__c = 'Cancelled';
      pm.End_Date__c = system.today();
    }
    if (oldpmlist.size() > 0)
      update oldpmlist;
  }

  public override void afterInsert(
    List<SObject> newObjects,
    Map<Id, SObject> newMap
  ) {
    List<Transaction__c> transactions = new List<Transaction__c>();
    List<Payment_Method__c> pmlist = new List<Payment_Method__c>();
    List<Correspondence__c> correspondences = new List<Correspondence__c>();
    Constants sc = new Constants();
    Set<id> accountIds = new Set<id>();

    List<Payment_Method__c> newPMs = (List<Payment_Method__c>) newObjects;

    for (Payment_Method__c newPaymentMethod : newPMs) {
      accountIds.add(newPaymentMethod.Membership__c);
    }

    Map<Id, Account> leadusers = new Map<Id, Account>(
      [
        SELECT
          Id,
          Renewal_Date__c,
          (
            SELECT Id, Salutation, FirstName, LastName
            FROM Contacts
            WHERE RecordTypeId = :sc.leadContactRecordTypeId
          )
        FROM Account
        WHERE Id IN :accountids
      ]
    );

    for (Payment_Method__c newPaymentMethod : newPMs) {
      if (newPaymentMethod.RecordTypeid == sc.PaymentMethodDDRecordTypeId) {
        transactions.add(
          new Transaction__c(
            Transaction_Date__c = newPaymentMethod.Start_Date__c,
            recordtypeid = sc.trddebitRecordTypeId,
            Amount__c = newPaymentMethod.Mandate_Amount__c,
            Status__c = 'Pending',
            Transaction_Type__c = '0N',
            Payment_Method__c = newPaymentMethod.Id
          )
        );
      }
      /** if (newPaymentMethod.RecordTypeid == sc.PaymentMethodDDRecordTypeId) {
                Correspondence__c corr = new Correspondence__c();
                corr.Membership__c = newPaymentMethod.Membership__c;
                corr.Correspondence_Type__c='Auddis Letter';
                corr.Bank_Account_Name__c = newPaymentMethod.Bank_Account_Name__c;
                corr.Bank_Account_Number__c = newPaymentMethod.Bank_Account_Number__c;
                corr.Sort_Code__c = newPaymentMethod.Sort_Code__c;
                corr.Total_Fee__c = newPaymentMethod.Mandate_Amount__c;
                system.debug(newPaymentMethod.Membership__r.Id);
                for(Contact lc: leadusers.get(newPaymentMethod.Membership__c).Contacts){
                    corr.Lead_Member_Salutation__c =  lc.Salutation;
                    corr.Lead_Member_First_Name__c =  lc.FirstName;
                    corr.Lead_Member_Last_Name__c =  lc.LastName;
                }
                corr.Correspondence_date__c = system.today();
                correspondences.add(corr);
            }**/
    }
    insert transactions;
    /**if(correspondences.size() > 0)
     insert correspondences;**/
  }

  public override void afterUpdate(
    List<SObject> oldObjects,
    List<SObject> newObjects,
    Map<Id, SObject> oldMap,
    Map<Id, SObject> newMap
  ) {
    List<Transaction__c> transactions = new List<Transaction__c>();
    List<Payment_Method__c> pmlist = new List<Payment_Method__c>();
    List<Payment_Method__c> pmlist2 = new List<Payment_Method__c>();
    List<Correspondence__c> correspondences = new List<Correspondence__c>();
    Constants sc = new Constants();
    Set<id> accountIds = new Set<id>();

    List<Payment_Method__c> newPMs = (List<Payment_Method__c>) newObjects;
    Map<Id, Payment_Method__c> oldPMsMap = (Map<Id, Payment_Method__c>) oldMap;

    for (Payment_Method__c newPaymentMethod : newPMs) {
      accountIds.add(newPaymentMethod.Membership__c);
    }

    Map<Id, Account> leadusers = new Map<Id, Account>(
      [
        SELECT
          Id,
          Renewal_Date__c,
          Payment_Method2__c,
          Email__c,
          (
            SELECT Id, Salutation, FirstName, LastName
            FROM Contacts
            WHERE RecordTypeId = :sc.leadContactRecordTypeId
          )
        FROM Account
        WHERE Id IN :accountids
      ]
    );

    for (Payment_Method__c newPaymentMethod : newPMs) {
      Account membership = leadusers.get(newPaymentMethod.Membership__c);

      if (newPaymentMethod.RecordTypeid == sc.PaymentMethodDDRecordTypeId) {
        if (
          newPaymentMethod.Status__c !=
          oldPMsMap.get(newPaymentMethod.id).Status__c
        ) {
          if (newPaymentMethod.Status__c == 'Cancelled') {
            transactions.add(
              new Transaction__c(
                Transaction_Date__c = date.today(),
                Amount__c = newPaymentMethod.Mandate_Amount__c,
                // Status__c = 'Pending',
                Status__c = 'Complete',
                RecordTypeId = sc.trddebitRecordTypeId,
                Transaction_Type__c = '0C',
                Payment_Method__c = newPaymentMethod.Id
              )
            );
            pmlist2.add(newPaymentMethod);
          } else if (newPaymentMethod.Status__c == 'Rejected') {
            transactions.add(
              new Transaction__c(
                Transaction_Date__c = date.today(),
                Amount__c = newPaymentMethod.Mandate_Amount__c,
                // Status__c = 'Pending',
                Status__c = 'Complete',
                RecordTypeId = sc.trddebitRecordTypeId,
                Transaction_Type__c = '0C',
                Payment_Method__c = newPaymentMethod.Id
              )
            );
            pmlist.add(newPaymentMethod);
          }
        } else if (
          // if amount changed and update not triggered by batch class, create correspondence
          TriggerRecursionCheck.preventCorrespondenceCreation == false &&
          (membership.Email__c == null ||
          membership.Email__c == 'example@example.com') &&
          newPaymentMethod.Mandate_Amount__c !=
          oldPMsMap.get(newPaymentMethod.id).Mandate_Amount__c &&
          oldPMsMap.get(newPaymentMethod.id).Mandate_Amount__c != 0
        ) {
          Correspondence__c corrs = new Correspondence__c();
          corrs.Membership__c = newPaymentMethod.Membership__c;
          corrs.Correspondence_Type__c = 'Amend DD';
          corrs.Bank_Account_Name__c = newPaymentMethod.Bank_Account_Name__c;
          corrs.Bank_Account_Number__c = newPaymentMethod.Bank_Account_Number__c;
          corrs.Sort_Code__c = newPaymentMethod.Sort_Code__c;
          corrs.Payment_Method__c = leadusers.get(
              newPaymentMethod.Membership__c
            )
            .Payment_Method2__c;
          if (newPaymentMethod.Mandate_Amount__c != 0) {
            corrs.Total_Fee__c = newPaymentMethod.Mandate_Amount__c;
          } else {
            if (
              leadusers.get(newPaymentMethod.Membership__c)
                .Opportunities.size() > 0
            ) {
              corrs.Total_Fee__c = leadusers.get(newPaymentMethod.Membership__c)
                .Opportunities[0]
                .Amount;
            }
          }
          for (
            Contact lc : leadusers.get(newPaymentMethod.Membership__c).Contacts
          ) {
            corrs.Lead_Member_Salutation__c = lc.Salutation;
            corrs.Lead_Member_First_Name__c = lc.FirstName;
            corrs.Lead_Member_Last_Name__c = lc.LastName;
          }
          corrs.Correspondence_date__c = system.today();
          correspondences.add(corrs);
        }
      }
    }
    if (pmlist.size() > 0) {
      List<Transaction__c> transactionsToReject = [
        SELECT Id
        FROM Transaction__c
        WHERE Status__c = 'Pending' AND Payment_Method__c IN :pmlist
      ];
      Set<id> accids = new Set<Id>();
      for (Payment_Method__c pm : pmlist) {
        accids.add(pm.Membership__c);
      }
      List<Account> acs = [
        SELECT id, Membership_Status__c
        FROM Account
        WHERE id IN :accids
      ];
      for (Account a : acs) {
        a.Membership_Status__c = 'DD Rejected';
      }
      // update transaction statuses
      List<Transaction__c> rejectedTransactions = updateTransactionStatus(
        transactionsToReject,
        'Rejected'
      );
      update rejectedTransactions;

      update acs;
    }
    if (pmlist2.size() > 0) {
      List<Transaction__c> transactionsToReject = [
        SELECT Id
        FROM Transaction__c
        WHERE Status__c = 'Pending' AND Payment_Method__c IN :pmlist2
      ];
      //delete deltrans;
      List<Transaction__c> rejectedTransactions = updateTransactionStatus(
        transactionsToReject,
        'Cancelled'
      );
      update rejectedTransactions;
    }

    insert transactions;

    /* for (Payment_Method__c newPaymentMethod: newPMs) {
            if (newPaymentMethod.RecordTypeid == sc.PaymentMethodDDRecordTypeId) {
                Payment_Method__c oldPaymentMethod = oldPMsMap.get(newPaymentMethod.Id);                    
                if((newPaymentMethod.Bank_Account_Number__c != oldPaymentMethod.Bank_Account_Number__c) ||
                   (newPaymentMethod.Sort_Code__c != oldPaymentMethod.Sort_Code__c)){
                    Correspondence__c corr = new Correspondence__c();
                    corr.Membership__c = newPaymentMethod.Membership__c;
                    corr.Correspondence_Type__c='Auddis Letter';
                    corr.Bank_Account_Name__c = newPaymentMethod.Bank_Account_Name__c;
                    corr.Bank_Account_Number__c = newPaymentMethod.Bank_Account_Number__c;
                    corr.Sort_Code__c = newPaymentMethod.Sort_Code__c;
                    corr.Total_Fee__c = newPaymentMethod.Mandate_Amount__c;
                    system.debug(newPaymentMethod.Membership__r.Id);
                    for(Contact lc: leadusers.get(newPaymentMethod.Membership__c).Contacts){
                        corr.Lead_Member_Salutation__c =  lc.Salutation;
                        corr.Lead_Member_First_Name__c =  lc.FirstName;
                        corr.Lead_Member_Last_Name__c =  lc.LastName;
                    }
                    corr.Correspondence_date__c = system.today();
                    correspondences.add(corr);
                }
            }
        }*/
    if (correspondences.size() > 0) {
      insert correspondences;
    }
  }

  private List<Transaction__c> updateTransactionStatus(
    List<Transaction__c> transactions,
    String status
  ) {
    List<Transaction__c> transactionsToReturn = new List<Transaction__c>();

    for (Transaction__c trans : transactions) {
      trans.Status__c = status;
      transactionsToReturn.add(trans);
    }
    System.debug('rejecting transactions...');
    return transactionsToReturn;
  }
}