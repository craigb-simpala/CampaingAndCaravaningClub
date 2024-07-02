public with sharing class ReinstatePaymentController {


    @AuraEnabled
    public static MembershipInfo getMembershipInfo(String recordId) {

        List<Account> accounts = [SELECT Renewal_Date__c, Payment_Method2__c, Membership_Code__r.Name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, BillingState
                                    FROM Account WHERE Id = :recordId];

        if(accounts.isEmpty()) return new MembershipInfo();

        Account accountToUse = accounts.get(0);

        Lead lead = setupLead(accountToUse);

        List<Club_Product__c> clubProducts = [SELECT RecordType.Name, Name, Product_Detail__c,
                                                    (SELECT Price__c, Start_Date__c, End_Date__c, Payment_Type__c FROM Prices__r ORDER BY Start_Date__c)
                                              FROM Club_Product__c  ORDER BY Name];

        Decimal membershipCost = calculateMembershipCost(accountToUse, lead, clubProducts);
        Decimal associateMemberCost = calculateAssociateMemberCost(accountToUse);
        List<Section> allSections = getAllSections(accountToUse);
        List<Section> selectedSections = getSelectedSections(allSections, accountToUse, lead);

        Decimal totalCost = calculateTotalCost(membershipCost, associateMemberCost, selectedSections);

        return new MembershipInfo(membershipCost, associateMemberCost, totalCost, selectedSections, lead);
    }

    private static Lead setupLead(Account account) {

        constants sc = new constants();

        List<Contact> primaryMembers = [SELECT Salutation, Title, FirstName, LastName, Birthdate, Email FROM Contact WHERE AccountId = :account.Id AND RecordTypeId = :sc.leadContactRecordTypeId LIMIT 1];

        Lead lead = new Lead();
        lead.LastName = account.Id;
        lead.Company = account.Id;
        lead.Status = 'Open';
        lead.Payment_Method__c = account.Payment_Method2__c;
        lead.Email = primaryMembers.isEmpty() ? '' : primaryMembers.get(0).Email;
        lead.Membership_Code__c = account.Membership_Code__r.Name;
        lead.Street = account.BillingStreet;
        lead.PostalCode = account.BillingPostalCode;
        lead.City = account.BillingCity;
        lead.Country = account.BillingCountry;
        lead.State = account.BillingState;

        return lead;
    }

    private static Decimal calculateMembershipCost(Account account, Lead lead, List<Club_Product__c> clubProducts) {
        Decimal memberShipCost = 0;

        Date renewalDate = account.Renewal_Date__c;

        while(renewalDate <= Date.today()){

            for(Club_Product__c clubProduct : clubProducts){
                if(clubProduct.Name == lead.Membership_Code__c && clubProduct.RecordType.Name == 'Membership Code'){

                    Boolean found = false;

                    for(Price__c priceFromClubProduct : clubProduct.Prices__r){
                        if(priceFromClubProduct.Start_Date__c <=renewalDate && (priceFromClubProduct.End_Date__c >=renewalDate || priceFromClubProduct.End_Date__c==null) && priceFromClubProduct.Payment_Type__c == lead.Payment_Method__c){
                            memberShipCost += priceFromClubProduct.Price__c;
                            found = true;
                            break;
                        }
                    }

                    if(!found){
                        for(Price__c priceFromClubProduct : clubProduct.Prices__r){
                            if(priceFromClubProduct.Start_Date__c <=renewalDate && (priceFromClubProduct.End_Date__c >=renewalDate || priceFromClubProduct.End_Date__c==null)){
                                memberShipCost += priceFromClubProduct.Price__c;
                                found = true;
                                break;
                            }
                        }
                    }
                }
            }
            renewalDate = renewalDate.addMonths(12);
        }

        return memberShipCost;
    }

    private static Decimal calculateAssociateMemberCost(Account account) {
        constants sc = new constants();

        Decimal associateMemberCost = 0;

        Date renewalDate = account.Renewal_Date__c;

        List<Club_Opportunity_Product__c> clubOpportunityProducts = [SELECT Product__r.Product_Detail__c, Product__r.Name FROM Club_Opportunity_Product__c
                                                                        WHERE Account__c = :account.Id
                                                                        AND Status__c = 'Cancelled'
                                                                        AND RecordTypeId = :sc.amsectRecordTypeId];

        List<Club_Product__c> clubProducts =  [SELECT Name, Product_Detail__c, (SELECT Price__c,Start_Date__c,End_Date__c FROM Prices__r  ORDER BY Start_Date__c)
                                                FROM Club_Product__c WHERE RecordType.Name='Associate Membership' ORDER BY Name];

        while(renewalDate <= Date.today()){

            for(Club_Opportunity_Product__c c : clubOpportunityProducts){

                for(Club_Product__c clubProduct : clubProducts){

                    for(Price__c priceFromClubProduct : clubProduct.Prices__r){
                        if(priceFromClubProduct.Start_Date__c <= renewalDate && (priceFromClubProduct.End_Date__c >= renewalDate || priceFromClubProduct.End_Date__c == null)){
                            if(associateMemberCost==null) associateMemberCost = 0;
                            associateMemberCost += priceFromClubProduct.Price__c;
                        }
                    }
                }
            }
            renewalDate = renewalDate.addMonths(12);
        }
        return associateMemberCost;
    }

    private static List<Section> getAllSections(Account account) {
        List<Section> sections = new List<Section>();


        for (Club_Product__c clubProduct : [SELECT Name, Product_Detail__c, (SELECT Price__c, Start_Date__c, End_Date__c FROM Prices__r ORDER BY Start_Date__c)
                                            FROM Club_Product__c WHERE RecordType.Name = 'Section' ORDER BY Name]) {

            Decimal totalPrice = 0;

            Date renewalDate = account.Renewal_Date__c;

            while (renewalDate <= Date.today()) {

                for (Price__c priceFromClubProduct : clubProduct.Prices__r) {

                    if (priceFromClubProduct.Start_Date__c <= renewalDate && (priceFromClubProduct.End_Date__c >= renewalDate || priceFromClubProduct.End_Date__c == null)) {
                        totalPrice += priceFromClubProduct.Price__c;
                    }
                }
                renewalDate = renewalDate.addMonths(12);
            }
            sections.add(new Section(clubProduct.Name, clubProduct.Product_Detail__c, totalPrice));
        }
        return sections;
    }

    private static List<Section> getSelectedSections(List<Section> sections, Account account, Lead lead) {

        List<Section> selectedSections = new List<Section>();

        constants sc = new constants();
        List<String> cancelledClubProducts = new List<String>();

        for (Club_Opportunity_Product__c opportunityProduct : [SELECT Product__r.Product_Detail__c, Product__r.Name FROM Club_Opportunity_Product__c
                                            WHERE Account__c = :account.Id
                                            AND Status__c = 'Cancelled'
                                            AND RecordTypeId = :sc.sectionRecordTypeId]){
            cancelledClubProducts.add(opportunityProduct.Product__r.Name);
        }

        lead.sections__c = String.join(cancelledClubProducts,':');

        if(lead.sections__c != null){

            Set<String> selectedSectionNames = new Set<String>(lead.sections__c.split(':',-2));

            for (Section section : sections){

                if(selectedSectionNames.contains(section.name)){
                    section.selected = true;
                    selectedSections.add(section);
                }
            }
        }
        return selectedSections;
    }

    private static Decimal calculateTotalCost(Decimal membershipCost, Decimal associateMemberCost, List<Section> selectedSections) {
        Decimal totalCost = 0;

        if(membershipCost != null) totalCost += membershipCost;
        if(associateMemberCost != null) totalCost += associateMemberCost;

        for(Section section : selectedSections){
            if(section.selected) totalCost += section.price;
        }

        return totalCost;
    }


    @AuraEnabled
    public static String createLead(String leadJson) {

        Lead lead = (Lead) JSON.deserialize(leadJson, Lead.class);

        try {
            insert lead;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return lead.Id;
    }

    public class MembershipInfo {
        @AuraEnabled
        public Decimal membershipCost;
        @AuraEnabled
        public Decimal associateMemberCost;
        @AuraEnabled
        public Decimal totalCost;
        @AuraEnabled
        public List<Section> selectedSections;
        @AuraEnabled
        public Lead lead;


        public MembershipInfo() {}

        public MembershipInfo(Decimal membershipCost, Decimal associateMemberCost, Decimal totalCost, List<Section> selectedSections, Lead lead) {
            this.membershipCost = membershipCost;
            this.associateMemberCost = associateMemberCost;
            this.totalCost = totalCost;
            this.selectedSections = selectedSections;
            this.lead = lead;
        }
    }

    public class Section {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String productDetail;
        @AuraEnabled
        public Decimal price;
        @AuraEnabled
        public Boolean selected;

        public Section(String name, String productDetail, Decimal price) {
            this.name = name;
            this.productDetail = productDetail;
            this.price = price;
            this.selected = false;
        }
    }
}