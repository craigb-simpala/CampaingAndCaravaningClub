public with sharing class ChangeMembershipPaymentController {

    @AuraEnabled(Cacheable=true)
    public static List<String> getPaymentOptions(String membershipCodes){

        List<Club_Product__c> clubProducts = [SELECT Allowed_Payment_Types__c FROM Club_Product__c WHERE Name = :membershipCodes];


        if(clubProducts.isEmpty()) return new List<String>();

        List<String> paymentTypes = new List<String>();

        if(clubProducts.get(0).Allowed_Payment_Types__c != null){
            for(String paymentType : clubProducts.get(0).Allowed_Payment_Types__c.split(';')){
                paymentTypes.add(paymentType);
            }
        }

        return paymentTypes;
    }

    @AuraEnabled
    public static String updateLead(String leadJson) {

        Lead lead = (Lead) JSON.deserialize(leadJson, Lead.class);

        try {
            update lead;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return lead.Id;
    }
}