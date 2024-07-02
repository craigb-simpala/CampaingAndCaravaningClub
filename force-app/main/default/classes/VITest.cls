@IsTest
private class VITest {
    @IsTest
    static void testBehavior() {
        Lead newLead = new Lead(
                FirstName = 'John',
                LastName = 'Smith',
                Company = 'Test Company'
        );
        insert newLead;

        Account acc = new Account(
                Name = 'Test Account'
        );
        insert acc;

        Contact con = new Contact(
                LastName = 'Smith'
        );
        insert con;

        Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                CloseDate = Date.today(),
                StageName = 'Due'
        );
        insert opp;

        Club_Product__c clubProduct1 = new Club_Product__c();
        insert clubProduct1;

        Club_Product__c clubProduct2 = new Club_Product__c();
        insert clubProduct2;

        VIDefault defaultVI = new VIDefault();
        defaultVI.validate(newLead);
        defaultVI.validateAtRenewal(newLead);
        defaultVI.autoswitch(acc, con, opp, clubProduct1.Id, clubProduct2.Id);

        VIYoungCamper youngCamperVI = new VIYoungCamper();
        youngCamperVI.validate(newLead);
        youngCamperVI.validateAtRenewal(newLead);
        youngCamperVI.autoswitch(acc, con, opp, clubProduct1.Id, clubProduct2.Id);
    }

    @IsTest
    static void testVIDigital() {
        Id membershipCodeRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Club_Product__c' AND DeveloperName = 'Membership_Code' LIMIT 1].Id;

        Club_Product__c clubProduct = new Club_Product__c(
                RecordTypeId = membershipCodeRecordTypeId,
                Name = 'Paper',
                Product_Detail__c = 'Paper Membership',
                Active__c = true,
                Show_in_New_Membership_Picklist__c = true,
                Auto_Renew__c = false,
                Min_Age_for_Membership__c = 18,
                Max_Age_for_Membership__c = null,
                Sections_Allowed__c = true,
                Associate_Allowed__c = true,
                PartnerAllowed__c = true,
                DD_Payment_Allowed__c = true,
                Cash_Payment_Allowed__c = true,
                Membership_Length__c = 12,
                Renewable__c = true,
                VIClass__c = 'Paper',
                Allowed_Payment_Types__c = 'Cash/Cheque;Direct Debit;No payment method'
        );
        insert clubProduct;

        Account acc = new Account(
                Name = 'Test Account',
                Membership_Code__c = clubProduct.Id,
                Date_Joined__c = Date.today()
        );
        insert acc;

        //Create related Opportunity
        Opportunity opp = new Opportunity(
                Name = 'New Membership',
                CloseDate = Date.today(),
                StageName = 'Complete',
                AccountId = acc.Id
        );
        insert opp;

        Lead newLead = new Lead(
                FirstName = 'John',
                LastName = 'Smith',
                Company = opp.Id
        );
        insert newLead;

        VIDigital digitalVI = new VIDigital();
        digitalVI.validate(newLead);
        digitalVI.validateAtRenewal(newLead);
    }
}