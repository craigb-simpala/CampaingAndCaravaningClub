public with sharing class RenewMembershipPaymentController {

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
    public static String createLead(String leadJson) {

        Lead lead = (Lead) JSON.deserialize(leadJson, Lead.class);
        insert lead;

        return lead.Id;
    }
}