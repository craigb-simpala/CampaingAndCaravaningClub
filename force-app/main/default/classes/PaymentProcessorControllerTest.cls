/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 18-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   17-08-2022   Kev Cadger (Wipro)   Initial Version
 **/
@IsTest
public without sharing class PaymentProcessorControllerTest {
    @TestSetup
    static void makeData() {
        createClubProduct('Membership_Code');
        createClubProduct('Associate_Membership');
        createClubProduct('Section');
        TestDataFactory.createSObject(new Dealer_Advert__c());
        TestDataFactory.createSObject(new Promotional_Code__c());
    }

    @IsTest
    static void testProcessPaymentCard() {
        // Initialise any variables.
        Map<String, Object> result = null;
        Map<String, Object> cardDetails = new Map<String, Object>{
                'card_number' => '40000000000000000',
                'cvv' => '123',
                'expiry_month' => '01',
                'expiry_year' => '24'
        };
        Integer amount = 100;

        Test.startTest();
        try {
            PaymentProcessorController.processPaymentCard(cardDetails, amount, '');
        } catch (Exception e) {
            Utilities.logException(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testProcessPaymentCash() {
        Test.startTest();
        try {
            PaymentProcessorController.processPaymentCash();
        } catch (Exception e) {
            Utilities.logException(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testProcessPaymentDirectDebit() {
        Test.startTest();
        try {
            PaymentProcessorController.processPaymentDirectDebit();
        } catch (Exception e) {
            Utilities.logException(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testProcessMembershipCash() {
        Lead leadPaid = createLead();
        Lead leadUnpaid = createLead();
        leadUnpaid.Amount__c = 0;
        update leadUnpaid;

        Test.startTest();
        try {
            PaymentProcessorController.processMembership(
                    leadPaid.Id,
                    'Cash/Cheque',
                    'Test',
                    0
            );
            PaymentProcessorController.processMembership(
                    leadUnpaid.Id,
                    'Cash/Cheque',
                    null,
                    0
            );
        } catch (Exception e) {
            Utilities.logException(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testProcessMembershipCard() {
        Lead leadPaid = createLead();
        Lead leadUnpaid = createLead();

        Test.startTest();
        try {
            PaymentProcessorController.processMembership(
                    leadPaid.Id,
                    'Debit/Credit Card',
                    'Test',
                    0
            );
            PaymentProcessorController.processMembership(
                    leadUnpaid.Id,
                    'Debit/Credit Card',
                    null,
                    0
            );
        } catch (Exception e) {
            Utilities.logException(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void testProcessMembershipDebit() {
        Lead lead = createLead();

        Test.startTest();
        try {
            PaymentProcessorController.processMembership(
                    lead.Id,
                    'Direct Debit',
                    'Test',
                    0
            );
        } catch (Exception e) {
            Utilities.logException(e);
        }
        Test.stopTest();
    }

  @IsTest
  static void testProcessMembershipCashAccount() {
    Account account = createAccount();

    Test.startTest();
    try {
      PaymentProcessorController.processMembership(
              account.Id,
              'Cash/Cheque',
              'Test',
              99
      );
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();
  }

    // !------------------------------------------------------------! //
    // * Helper Methods

    private static void createClubProduct(String recordTypeName) {
        SObject clubProduct = TestDataFactory.createSObject(
                new Club_Product__c(
                        RecordTypeId = Utilities.getRecordTypeId(
                                Club_Product__c.getSObjectType().getDescribe().getName(),
                                recordTypeName
                        )
                )
        );

        TestDataFactory.createSObject(
                new Price__c(Payment_Type__c = 'Cash/Cheque', Product__c = clubProduct.Id)
        );
        TestDataFactory.createSObject(
                new Price__c(
                        Payment_Type__c = 'Debit/Credit Card',
                        Product__c = clubProduct.Id
                )
        );
        TestDataFactory.createSObject(
                new Price__c(
                        Payment_Type__c = 'Direct Debit',
                        Product__c = clubProduct.Id
                )
        );
    }

    private static Lead createLead() {
        TestDataDefaults.LeadDataExtension leadDataExtensions = new TestDataDefaults.LeadDataExtension();

        Lead lead = (Lead) TestDataFactory.getSObject(new Lead());
        leadDataExtensions.setPartnerMemberDetails(lead);
        leadDataExtensions.setAssociateMemberDetails(lead);
        leadDataExtensions.setChildMemberDetails(lead, 1);
        lead.Dealer_Ad_Code__c = [
                SELECT Id
                FROM Dealer_Advert__c
                WHERE Name = 'TestShow'
        ]
                .Id;
        lead.Membership_Code__c = 'TestClubProduct';
        lead.Sections__c = 'TestClubProduct';
        lead.Voucher_Code__c = 'TestPromoCode';

        upsert lead;
        return lead;
    }

    private static Account createAccount() {
      Account account = new Account();
      account.Name = 'Test Account';
      account.Email__c = 'test@gmail.com';
      insert account;

      return account;
    }
}