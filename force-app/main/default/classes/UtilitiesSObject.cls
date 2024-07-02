/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 17-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   01-08-2022   Kev Cadger (Wipro)   Initial Version
 **/
public without sharing class UtilitiesSObject {
  public static Database.LeadConvertResult convertLead(Id leadId) {
    String leadConvertedStatus = [
      SELECT MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ]
    .MasterLabel;

    Lead lead = Database.query(
      Utilities.getSObjectQueryAllFields(
        Lead.getSObjectType().getDescribe().getName()
      ) + 'WHERE Id = :leadId'
    );

    if (lead.Joining_Date__c == null) {
      lead.Joining_Date__c = Date.today();
      update lead;
    }

    Database.LeadConvert leadConversion = new Database.LeadConvert();
    leadConversion.setLeadId(lead.Id);
    leadConversion.setConvertedStatus(leadConvertedStatus);
    leadConversion.setOpportunityName('New Membership - ' + lead.LastName);

    return Database.convertLead(leadConversion);
  }
}