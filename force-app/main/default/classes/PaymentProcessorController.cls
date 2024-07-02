/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 18-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   20-07-2022   Kev Cadger (Wipro)   Initial Version
 **/
public without sharing class PaymentProcessorController {

    @AuraEnabled
    public static Map<String, Object> processPaymentCard(
            Map<String, Object> cardDetails,
            Integer amount, Id recordId
    ) {
        System.debug('recordId is ' + recordId);
        try {
            return VerifoneAPIHelper.createCardTransaction(cardDetails, amount, recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> processPaymentCash() {
        try {
            // Set the results to return.
            return new Map<String, Object>{
                    'isSuccess' => true,
                    'message' => 'The membership will now be processed.',
                    'title' => 'Payment Successful',
                    'token' => 'Cash/Cheque',
                    'variant' => 'success'
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> processPaymentDirectDebit() {
        try {
            // Set the results to return.
            return new Map<String, Object>{
                    'isSuccess' => true,
                    'message' => 'The membership will now be processed.',
                    'title' => 'Payment Successful',
                    'token' => 'Direct Debit',
                    'variant' => 'success'
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id processMembership(
            Id recordId,
            String paymentMethod,
            String paymentToken,
            Decimal amount
    ) {
        Savepoint savepoint = Database.setSavepoint();

        try {
            if (recordId.getSobjectType().getDescribe().getName() == 'Lead') {
                Lead lead = (Lead) Lead.getSObjectType().newSObject(recordId);
                lead.Payment_Method__c = paymentMethod;
                update lead;

                ProcessMembershipFromLead leadProcessClass = new ProcessMembershipFromLead(
                        recordId,
                        paymentToken
                );
                return leadProcessClass.processMembership();

            } else if (recordId.getSobjectType().getDescribe().getName() == 'Account') {
                Account account = (Account) Account.getSObjectType().newSObject(recordId);
                account.Payment_Method2__c = paymentMethod;
                update account;

                ProcessMembershipFromAccount accountProcessClass = new ProcessMembershipFromAccount(
                        recordId,
                        paymentToken,
                        amount
                );

                return accountProcessClass.processMembership();
            }

            return null;
        } catch (Exception e) {
            Database.rollback(savepoint);
            Utilities.logException(e);
            throw new AuraHandledException(
                    'Please contact your System Administrator.'
            );
        }
    }

    private class ProcessMembershipFromAccount {

        private final String accountId = null;
        private final String paymentToken = null;
        private Decimal amount = 0;

        private Account account = new Account();

        public ProcessMembershipFromAccount(Id accountId, String token, Decimal amount) {
            this.accountId = accountId;
            this.paymentToken = token;
            this.amount = amount;
        }

        public Id processMembership() {
            getData();
            insertPaymentMethod();

            return account.Id;
        }

        private void getData() {
            account = Database.query(
                    Utilities.getSObjectQueryAllFields(
                            Account.getSObjectType().getDescribe().getName()
                    ) +
                            'WHERE Id = \'' +
                            accountId +
                            '\''
            );
        }

       private void insertPaymentMethod() {

            Payment_Method__c paymentMethod = new Payment_Method__c(
                    // Authorization_code__c = paymentToken,
                    CC_Token__c = paymentToken,
                    Mandate_Amount__c = amount,
                    Membership__c = accountId,
                    Membership_Email__c = account.Email__c,
                    RecordTypeId = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName()
                            .get(account.Payment_Method2__c)
                            .getRecordTypeId(),
                    Start_Date__c = Date.today(),
                    Status__c = 'Active'
            );

            switch on account.Payment_Method2__c {
                when 'Debit/Credit Card' {
                    account.Membership_Status__c = paymentToken != null
                            ? 'Paid'
                            : 'Unpaid';
                }
                when 'Direct Debit' {

                    account.Membership_Status__c = amount > 0
                            ? 'DD Pending'
                            : 'Paid';
                }
                when else {
                    account.Membership_Status__c = 'Paid';
                }
            }

            insert paymentMethod;

            if (account.Payment_Method2__c != 'Direct Debit') {
                insertPaymentTransaction(paymentMethod.Id);
            }
        }

      private void insertPaymentTransaction(Id paymentMethodId) {
        insert new Transaction__c(
                Amount__c = amount,
                // Authorization_code__c = paymentToken,
                Payment_Method__c = paymentMethodId,
                RecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName()
                        .get(account.Payment_Method2__c)
                        .getRecordTypeId(),
                Transaction_Date__c = account.Payment_Method2__c == 'Debit/Credit Card'
                        ? Date.today()
                        : null
        );
      }
    }

    private class ProcessMembershipFromLead {
        private Database.LeadConvertResult leadConversionResult = null;
        private String paymentToken = null;

        private Lead lead = new Lead();
        private Account account = new Account();
        private Contact contactPrimary = new Contact();
        private Contact contactSecondary = new Contact();
        private Opportunity opportunity = new Opportunity();

        private Promotional_Code__c promotionalCode = null;
        private Dealer_Advert__c dealerAdvertCode = null;

        public ProcessMembershipFromLead(Id leadId, String token) {
            leadConversionResult = UtilitiesSObject.convertLead(leadId);
            if (!leadConversionResult.isSuccess()) {
                throw new AuraHandledException('The lead was not converted');
            }
            paymentToken = token;
        }

        public Id processMembership() {
            getData();
            insertExistingMember();
            upsertContacts();
            insertOpportunityClubProducts();
            insertPaymentMethod();
            updateAccount();
            updateOpportunity();
            updatePromotionalCode();

            return account.Id;
        }

        private void getData() {
            lead = Database.query(
                    Utilities.getSObjectQueryAllFields(
                            Lead.getSObjectType().getDescribe().getName()
                    ) +
                            'WHERE Id = \'' +
                            leadConversionResult.getLeadId() +
                            '\''
            );

            account = Database.query(
                    Utilities.getSObjectQueryAllFields(
                            Account.getSObjectType().getDescribe().getName()
                    ) +
                            'WHERE Id = \'' +
                            leadConversionResult.getAccountId() +
                            '\''
            );

            contactPrimary = Database.query(
                    Utilities.getSObjectQueryAllFields(
                            Contact.getSObjectType().getDescribe().getName()
                    ) +
                            'WHERE Id = \'' +
                            leadConversionResult.getContactId() +
                            '\''
            );

            opportunity = Database.query(
                    Utilities.getSObjectQueryAllFields(
                            Opportunity.getSObjectType().getDescribe().getName()
                    ) +
                            'WHERE Id = \'' +
                            leadConversionResult.getOpportunityId() +
                            '\''
            );

            List<Promotional_Code__c> promotionalCodes = [
                    SELECT
                            Id,
                            Name,
                            Description__c,
                            Expiry_Date__c,
                            Number_Allowed__c,
                            Number_of_Valid_Codes__c,
                            Number_Used__c,
                            Valid_for_Memberships__c,
                            Valid_From__c
                    FROM Promotional_Code__c
                    WHERE Name = :lead.Voucher_Code__c
            ];
            if (!promotionalCodes.isEmpty()) {
                promotionalCode = promotionalCodes[0];
            }

            List<Dealer_Advert__c> dealerAdvertCodes = [
                    SELECT
                            Id,
                            Name,
                            Active__c,
                            Valid_Show__c,
                            Show_Start_Date__c,
                            Show_End_Date__c
                    FROM Dealer_Advert__c
                    WHERE Id = :lead.Dealer_Ad_Code__c
            ];
            if (!dealerAdvertCodes.isEmpty()) {
                dealerAdvertCode = dealerAdvertCodes[0];
            }
        }

        private void insertExistingMember() {
            if (lead.Existing_Members_Number__c != null) {
                Contact contact = [
                        SELECT Id
                        FROM Contact
                        WHERE
                                Account.Hybrid_Membership_Number__c = :lead.Existing_Members_Number__c
                                AND RecordTypeId = :Utilities.getRecordTypeId(
                                        Contact.getSObjectType().getDescribe().getname(),
                                        'Lead'
                                )
                ];

                insert new Member_Get_Member__c(
                        Existing_Member__c = contact.Id,
                        Gift__c = lead.Gift__c,
                        Introduced_Membership__c = account.Id
                );
            }
        }

        private void upsertContacts() {
            List<Contact> contactsToUpsert = new List<Contact>();

            // Lead Contact
            contactPrimary.Age_Concession__c = lead.Age_Concession__c;
            contactPrimary.Birthdate = lead.Lead_Member_Date_of_Birth__c;
            contactPrimary.Date_Joined__c = Date.today();
            contactPrimary.Online_Account_Created__c = lead.Lead_Member_Online_Account__c;
            contactPrimary.RecordTypeId = Utilities.getRecordTypeId(
                    'Contact',
                    'Lead'
            );
            contactsToUpsert.add(contactPrimary);

            if (lead.hasPartner__c) {
                getPartnerContact(contactsToUpsert);
            }

            if (lead.hasAssociate__c) {
                getAssociateContact(contactsToUpsert);
            }

            if (lead.Number_of_Children__c != null) {
                getChildContacts(contactsToUpsert, lead);
            }

            upsert contactsToUpsert;

            if (lead.hasPartner__c) {
                contactSecondary = contactsToUpsert[1]; // Get the partner contact.
            }
        }

        private void insertOpportunityClubProducts() {
            opportunity.Amount = 0;

            List<Club_Opportunity_Product__c> clubOpportunityProducts = new List<Club_Opportunity_Product__c>();

            getMembershipClubOpportunityProduct(clubOpportunityProducts);

            if (lead.hasAssociate__c) {
                getAssociateClubOpportunityProduct(clubOpportunityProducts);
            }

            if (String.isNotBlank(lead.sections__c)) {
                getSectionClubOpportunityProducts(clubOpportunityProducts);
            }

            insert clubOpportunityProducts;

            insertMemberSections(clubOpportunityProducts);
        }

        private void insertMemberSections(
                List<Club_Opportunity_Product__c> clubOpportunityProducts
        ) {
            List<Member_Section__c> memberSections = new List<Member_Section__c>();

            for (
                    Club_Opportunity_Product__c clubOpportunityProduct : clubOpportunityProducts
            ) {
                memberSections.add(
                        new Member_Section__c(
                                Club_Opportunity_Product__c = clubOpportunityProduct.Id,
                                Member__c = contactPrimary.Id
                        )
                );

                if (lead.hasPartner__c) {
                    memberSections.add(
                            new Member_Section__c(
                                    Club_Opportunity_Product__c = clubOpportunityProduct.Id,
                                    Member__c = contactSecondary.Id
                            )
                    );
                }
            }

            insert memberSections;
        }

        private void insertPaymentMethod() {
            Payment_Method__c paymentMethod = new Payment_Method__c(
                    // Authorization_code__c = paymentToken,
                    CC_Token__c = paymentToken,
                    Mandate_Amount__c = lead.Amount__c,
                    Membership__c = lead.ConvertedAccountId,
                    Membership_Email__c = lead.Email,
                    RecordTypeId = Schema.SObjectType.Payment_Method__c.getRecordTypeInfosByName()
                            .get(lead.Payment_Method__c)
                            .getRecordTypeId(),
                    Start_Date__c = Date.today(),
                    Status__c = 'Active'
            );

            switch on lead.Payment_Method__c {
                when 'Debit/Credit Card' {
                    account.Membership_Status__c = paymentToken != null
                            ? 'Paid'
                            : 'Unpaid';
                }
                when 'Direct Debit' {
                    paymentMethod.Bank_Account_Name__c = lead.Bank_Account_Name__c;
                    paymentMethod.Bank_Account_Number__c = lead.Bank_Account_Number__c;
                    paymentMethod.Bank_Name__c = lead.Bank_Name__c;
                    paymentMethod.Sort_Code__c = lead.Sort_Code__c.replaceAll(
                            '[^0-9]',
                            ''
                    );

                    account.Membership_Status__c = lead.Amount__c > 0
                            ? 'DD Pending'
                            : 'Paid';
                }
                when else {
                    account.Membership_Status__c = 'Paid';
                }
            }

            insert paymentMethod;

            opportunity.Payment_Method__c = paymentMethod.Id;

            if (lead.Payment_Method__c != 'Direct Debit') {
                insertPaymentTransaction(paymentMethod.Id);
            }
        }

        private void insertPaymentTransaction(Id paymentMethodId) {
            insert new Transaction__c(
                    Amount__c = lead.Amount__c,
                    // Authorization_code__c = paymentToken,
                    Payment_Method__c = paymentMethodId,
                    RecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName()
                            .get(Lead.Payment_Method__c)
                            .getRecordTypeId(),
                    Transaction_Date__c = lead.Payment_Method__c == 'Debit/Credit Card'
                            ? Date.today()
                            : null
            );
        }

        private void updateAccount() {
            account.Email__c = contactPrimary.Email;
            account.Mobile_Phone__c = contactPrimary.MobilePhone;
            account.Payment_Method2__c = lead.Payment_Method__c;

            if (account.BillingPostalCode != null) {
                List<String> postcodeParts = account.BillingPostalCode.split(' ');

                if (postcodeParts.size() > 1) {
                    List<DA_Postcode__c> districtAssociations = [
                            SELECT Id, Association_Name__c
                            FROM DA_Postcode__c
                            WHERE
                                    Postcode_Part_1__c = :postcodeParts[0]
                                    AND (Postcode_Part_2__c = :postcodeParts[1].substring(0, 1)
                                    OR Postcode_Part_2__c = NULL)
                            LIMIT 1
                    ];

                    if (!districtAssociations.isEmpty()) {
                        account.District_Association__c = districtAssociations[0]
                                .Association_Name__c;
                    }
                }
            }

            update account;
        }

        private void updateOpportunity() {
            opportunity.Dealer_Ad_Code__c = lead.Dealer_Ad_Code__c;
            opportunity.CloseDate = Date.today();
            opportunity.StageName = 'Complete';

            if (promotionalCode != null) {
                opportunity.Promotional_Code__c = promotionalCode.Id;
            }

            update Opportunity;
        }

        private void updatePromotionalCode() {

            if (promotionalCode != null) {
                promotionalCode.Number_Used__c = promotionalCode.Number_Used__c == null
                        ? 1
                        : promotionalCode.Number_Used__c + 1;

                update promotionalCode;
            }
        }

        /**
         ** Contacts - Helper Functions
         **/

        private void getPartnerContact(List<Contact> additionalContacts) {
            additionalContacts.add(
                    new Contact(
                            AccountId = account.Id,
                            Age_Concession__c = lead.SM_Age_Concession__c,
                            Birthdate = lead.Secondary_Member_Date_of_Birth__c,
                            Date_Joined__c = Date.today(),
                            Email = lead.Secondary_Member_Email__c,
                            FirstName = lead.Secondary_Member_First_Name__c,
                            LastName = lead.Secondary_Member_Surname__c,
                            Online_Account_Created__c = lead.Secondary_Member_Online_Account__c,
                            RecordTypeId = Utilities.getRecordTypeId('Contact', 'Secondary'),
                            Salutation = lead.Secondary_Member_Title__c
                    )
            );
        }

        private void getAssociateContact(List<Contact> additionalContacts) {
            additionalContacts.add(
                    new Contact(
                            AccountId = account.Id,
                            Birthdate = lead.Associate_Member_Date_of_Birth__c,
                            Date_Joined__c = Date.today(),
                            FirstName = lead.Associate_Member_First_Name__c,
                            LastName = lead.Associate_Member_Surname__c,
                            RecordTypeId = Utilities.getRecordTypeId('Contact', 'Associate'),
                            Salutation = lead.Associate_Member_Title__c
                    )
            );
        }

        private void getChildContacts(
                List<Contact> additionalContacts,
                SObject leadObj
        ) {
            Integer numberOfChildren = Integer.valueOf(lead.Number_of_Children__c);

            for (Integer i = 1; i < numberOfChildren + 1; i++) {
                additionalContacts.add(
                        new Contact(
                                AccountId = account.Id,
                                Birthdate = Date.valueOf(
                                        leadObj.get('Child_' + i + '_Date_of_Birth__c')
                                ),
                                Date_Joined__c = Date.today(),
                                FirstName = String.valueOf(
                                        leadObj.get('Child_' + i + '_First_Name__c')
                                ),
                                LastName = String.valueOf(
                                        leadObj.get('Child_' + i + '_Surname__c')
                                ),
                                RecordTypeId = Utilities.getRecordTypeId('Contact', 'Child'),
                                Salutation = String.valueOf(leadObj.get('Child_' + i + '_Title__c'))
                        )
                );
            }
        }

        /**
         ** Opportunity Club Products - Helper Functions
         **/

        private void getMembershipClubOpportunityProduct(
                List<Club_Opportunity_Product__c> clubOpportunityProducts
        ) {
            for (Club_Product__c clubProduct : [
                    SELECT
                            Id,
                            Membership_Length__c,
                            RecordTypeId,
                            (
                                    SELECT Joining_Fee__c, Price__c
                                    FROM Prices__r
                                    WHERE
                                            Payment_Type__c = :lead.Payment_Method__c
                                            AND Start_Date__c <= TODAY
                                            AND (End_Date__c >= TODAY
                                            OR End_Date__c = NULL)
                                    ORDER BY Start_Date__c
                            )
                    FROM Club_Product__c
                    WHERE
                            RecordTypeId = :Utilities.getRecordTypeId(
                                    Club_Product__c.getSObjectType().getDescribe().getName(),
                                    'Membership_Code'
                            )
                            AND Name = :lead.Membership_Code__c
                            AND Show_in_New_Membership_Picklist__c = TRUE
                    ORDER BY Name
            ]) {
                account.Membership_Code__c = clubProduct.Id;
                account.Renewal_Date__c = getRenewalDate(clubProduct);

                Club_Opportunity_Product__c clubOpportunityProduct = new Club_Opportunity_Product__c(
                        Account__c = account.Id,
                        Opportunity__c = opportunity.Id,
                        Price__c = 0,
                        Product__c = clubProduct.Id,
                        RecordTypeId = Utilities.getRecordTypeId(
                                Club_Opportunity_Product__c.getSObjectType()
                                        .getDescribe()
                                        .getName(),
                                'Membership_Code'
                        ),
                        Status__c = 'Active'
                );

                if (promotionalCode == null && !clubProduct.Prices__r.isEmpty()) {
                    // ? KC - Taken out after testing feedback
                    // if (promotionalCode != null && !clubProduct.Prices__r.isEmpty()) {
                    clubOpportunityProduct.Price__c = clubProduct.Prices__r[0].Price__c;

                    if (!lead.Joining_Fee_Waived__c) {
                        clubOpportunityProduct.Price__c += clubProduct.Prices__r[0]
                                .Joining_Fee__c;
                    }
                    opportunity.Amount += clubOpportunityProduct.Price__c;
                }

                clubOpportunityProducts.add(clubOpportunityProduct);
            }
        }

        private void getAssociateClubOpportunityProduct(
                List<Club_Opportunity_Product__c> clubOpportunityProducts
        ) {
            for (Club_Product__c clubProduct : [
                    SELECT
                            Id,
                            RecordTypeId,
                            (
                                    SELECT Joining_Fee__c, Price__c
                                    FROM Prices__r
                                    WHERE
                                            Payment_Type__c = :lead.Payment_Method__c
                                            AND Start_Date__c <= TODAY
                                            AND (End_Date__c >= TODAY
                                            OR End_Date__c = NULL)
                                    ORDER BY Start_Date__c
                            )
                    FROM Club_Product__c
                    WHERE
                            RecordTypeId = :Utilities.getRecordTypeId(
                                    Club_Product__c.getSObjectType().getDescribe().getName(),
                                    'Associate_Membership'
                            )
                    ORDER BY Name
            ]) {
                Club_Opportunity_Product__c clubOpportunityProduct = new Club_Opportunity_Product__c(
                        Account__c = account.Id,
                        Opportunity__c = opportunity.Id,
                        Price__c = clubProduct.Prices__r[0].Price__c,
                        Product__c = clubProduct.Id,
                        RecordTypeId = Utilities.getRecordTypeId(
                                Club_Opportunity_Product__c.getSObjectType()
                                        .getDescribe()
                                        .getName(),
                                'Associate_Membership'
                        ),
                        Status__c = 'Active'
                );

                opportunity.Amount += clubOpportunityProduct.Price__c;

                clubOpportunityProducts.add(clubOpportunityProduct);
            }
        }

        private void getSectionClubOpportunityProducts(
                List<Club_Opportunity_Product__c> clubOpportunityProducts
        ) {
            Set<String> sectionNames = new Set<String>(
                    lead.Sections__c.split(':', -2)
            );

            List<SectionSelectWrapper> sections = new List<SectionSelectWrapper>();

            for (Club_Product__c clubProduct : [
                    SELECT
                            Id,
                            RecordTypeId,
                            (
                                    SELECT Price__c
                                    FROM Prices__r
                                    WHERE
                                            Start_Date__c <= TODAY
                                            AND (End_Date__c >= TODAY
                                            OR End_Date__c = NULL)
                                    ORDER BY Start_Date__c
                            )
                    FROM Club_Product__c
                    WHERE
                            RecordTypeId = :Utilities.getRecordTypeId(
                                    Club_Product__c.getSObjectType().getDescribe().getName(),
                                    'Section'
                            )
                            AND Name IN :sectionNames
                    ORDER BY Name
            ]) {
                Club_Opportunity_Product__c clubOpportunityProduct = new Club_Opportunity_Product__c(
                        Account__c = account.Id,
                        Opportunity__c = opportunity.Id,
                        Price__c = clubProduct.Prices__r[0].Price__c,
                        Product__c = clubProduct.Id,
                        RecordTypeId = Utilities.getRecordTypeId(
                                Club_Opportunity_Product__c.getSObjectType()
                                        .getDescribe()
                                        .getName(),
                                'Section'
                        ),
                        Status__c = 'Active'
                );

                if (
                        dealerAdvertCode != null &&
                                dealerAdvertCode.Valid_Show__c &&
                                dealerAdvertCode.Show_Start_Date__c <= Date.today() &&
                                dealerAdvertCode.Show_End_Date__c >= Date.today()
                ) {
                    clubOpportunityProduct.Price__c = 0;
                }

                opportunity.Amount += clubOpportunityProduct.Price__c;

                clubOpportunityProducts.add(clubOpportunityProduct);
            }
        }
        private Date getRenewalDate(Club_Product__c clubProduct) {
            if (
                    lead.Membership_Code__c == 'Young Camper' &&
                            lead.Lead_Member_Date_of_Birth__c != null
            ) {
                Date birthDateThisYear = Date.newInstance(
                        Date.today().year(),
                        lead.Lead_Member_Date_of_Birth__c.month(),
                        lead.Lead_Member_Date_of_Birth__c.day()
                );
                Date nextMonth = Date.today().addMonths(1).toStartOfMonth();
                Integer renewalYear = nextMonth.monthsBetween(birthDateThisYear) >= 0
                        ? Date.today().year()
                        : Date.today().year() + 1;

                return Date.newInstance(
                        renewalYear,
                        lead.Lead_Member_Date_of_Birth__c.month(),
                        lead.Lead_Member_Date_of_Birth__c.day()
                );
            }
            System.debug('Date Joined: ' + account.Date_Joined__c);
            return account.Date_Joined__c.addMonths(
                    Integer.valueOf(clubProduct.Membership_Length__c)
            );
        }
    }


}