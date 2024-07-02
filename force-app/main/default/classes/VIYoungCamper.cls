/**
 * @description Validation class for Membership Type of Young Camper
 */
public with sharing class VIYoungCamper implements ValidationInterface {
    private static final String YOUTH_DIGITAL_MEMBERSHIP_TYPE = 'Youth - Digital';

    public void validate(Lead l) {
    }

    public void validateAtRenewal(Lead l) {
    }

    public Id autoswitch(Account acc, Contact con, Opportunity opp, Id clubProductFromId, Id clubProductToId) {
        Integer membersAgeOnRenewalDate = con.Birthdate != null ? con.Birthdate.monthsBetween(acc.Renewal_Date__c) / 12 : null;
        if (acc.Membership_Type_Name__c == YOUTH_DIGITAL_MEMBERSHIP_TYPE
                && con.Youth_Test_Passed_Date__c <= Date.today()
                && membersAgeOnRenewalDate >= 18
                ) {
            return clubProductToId;
        }
        return clubProductFromId;
    }
}