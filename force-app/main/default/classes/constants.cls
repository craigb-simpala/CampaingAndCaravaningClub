public class constants {
    
    public String leadContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Lead').RecordTypeId;
    public String childContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Child').RecordTypeId;
    public String associateContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Associate').RecordTypeId;
    public String secondaryContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Secondary').RecordTypeId;
    public String accessContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Access').RecordTypeId;
    public String CcardRecordTypeId = Schema.SObjectType.Payment_Method__c.RecordTypeInfosByName.get('Debit/Credit Card').RecordTypeId;
    public String ddebitRecordTypeId = Schema.SObjectType.Payment_Method__c.RecordTypeInfosByName.get('Direct Debit').RecordTypeId;
    public String cashRecordTypeId = Schema.SObjectType.Payment_Method__c.RecordTypeInfosByName.get('Cash/Cheque').RecordTypeId;
    public String trCcardRecordTypeId = Schema.SObjectType.Transaction__c.RecordTypeInfosByName.get('Debit/Credit Card').RecordTypeId;
    public String trddebitRecordTypeId = Schema.SObjectType.Transaction__c.RecordTypeInfosByName.get('Direct Debit').RecordTypeId;
    public String trcashRecordTypeId = Schema.SObjectType.Transaction__c.RecordTypeInfosByName.get('Cash/Cheque').RecordTypeId;
    public String cpsectRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.RecordTypeInfosByName.get('Section').RecordTypeId;
    public String mtsectRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.RecordTypeInfosByName.get('Membership Code').RecordTypeId;
    public String amsectRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.RecordTypeInfosByName.get('Associate Membership').RecordTypeId;

    public final String OppRenewalRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Renewal').RecordTypeId;
    public final String OppChangeRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Change').RecordTypeId;
    public final String OppReinRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Reinstatement').RecordTypeId;
    public final String OppNewMembershipRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('New Membership').RecordTypeId;
    public final String amRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.RecordTypeInfosByName.get('Associate Membership').RecordTypeId;
    public final String sectionRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.RecordTypeInfosByName.get('Section').RecordTypeId;
    public final String mtRecordTypeId = Schema.SObjectType.Club_Opportunity_Product__c.RecordTypeInfosByName.get('Membership Code').RecordTypeId;
    public final String PaymentMethodDDRecordTypeId = Schema.SObjectType.Payment_Method__c.RecordTypeInfosByName.get('Direct Debit').RecordTypeId;
    public final String clubProdAssociateRecordTypeId = Schema.SObjectType.Club_Product__c.RecordTypeInfosByName.get('Associate Membership').RecordTypeId;
    public final String clubProdMembershipCodeRecordTypeId = Schema.SObjectType.Club_Product__c.RecordTypeInfosByName.get('Membership Code').RecordTypeId;
    public final String clubProdSectionRecordTypeId = Schema.SObjectType.Club_Product__c.RecordTypeInfosByName.get('Section').RecordTypeId;
    
     
    
    
    public final String dealerAdvertDealerRecordTypeId = Schema.SObjectType.Dealer_Advert__c.RecordTypeInfosByName.get('Dealer').RecordTypeId;
    
    public String complete = 'Complete';
    public String superseded = 'Superseded';
    public String active = 'Active'; 
    
    
    
    public String accDaRecordTypeId = Schema.SObjectType.Association__c.RecordTypeInfosByName.get('District Association').RecordTypeId;
    public String accRegionRecordTypeId = Schema.SObjectType.Association__c.RecordTypeInfosByName.get('Region').RecordTypeId;

    public static final String YOUNG_CAMPER_MEMBERSHIP_TYPE = 'Young Camper';

}