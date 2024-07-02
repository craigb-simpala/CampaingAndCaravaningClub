@RestResource(UrlMapping='/correspondence')
global class CorrespondenceRest {

    private static final String CORRESPONDENCE_TYPE_REPLACEMENT_CARD = 'Replacement Card';
    private static final constants sc = new constants();

    @HttpPost
    global static ResponseWrapper updateMemberDetails() {

        RestRequest req = RestContext.request;

        RequestDataWrapper requestData = (RequestDataWrapper) JSON.deserialize(req.requestBody.toString(), RequestDataWrapper.class);

        if(String.isBlank(requestData.membership) || String.isBlank(requestData.correspondenceType)) return buildResponse('', 'Invalid input parameters', false, 400);

        List<Account> memberships = [SELECT Payment_Method2__c, Renewal_Date__c, Last_Replacement_Card_Date__c FROM Account WHERE Id = :requestData.membership];        

        if(memberships.isEmpty()) return buildResponse('', 'The requested membership could not be found', false, 404);

        Account membershipToUse = memberships.get(0);

        if(membershipToUse.Last_Replacement_Card_Date__c == Date.today()) return buildResponse('', 'Replacement forbidden. Only one Replacement allowed per day', false, 403);

        Correspondence__c correspondenceToCreate = new Correspondence__c();

        if(requestData.correspondenceType == CORRESPONDENCE_TYPE_REPLACEMENT_CARD){
            buildCorrespondenceForReplacementCard(correspondenceToCreate, membershipToUse);
        } else {
            return buildResponse('', 'Incorrect Correspondence Type', false, 400);
        }

        try {
            insert correspondenceToCreate;
            updateMembership(membershipToUse);
        } catch (Exception ex) {
            return buildResponse('', ex.getMessage(), false, 500);
        }

        return buildResponse(correspondenceToCreate.Id, '', true, 201);
    }

    private static void buildCorrespondenceForReplacementCard(Correspondence__c correspondence, Account membership) {

        Contact nonRenewalLeadMember = getLeadMember(membership.Id);
        Contact secondaryMember = getSecondaryMember(membership.Id);

        correspondence.Membership__c = membership.Id;
        correspondence.Payment_Method__c = membership.Payment_Method2__c;
        correspondence.Member__c = nonRenewalLeadMember.Id;
        correspondence.Correspondence_date__c = Date.today();
        correspondence.Correspondence_Type__c = 'Replacement Card';
        correspondence.Lead_Member__c = nonRenewalLeadMember.Id;
        correspondence.Lead_Member_Salutation__c =  nonRenewalLeadMember.Salutation;
        correspondence.Lead_Member_First_Name__c =  nonRenewalLeadMember.FirstName;
        correspondence.Lead_Member_Last_Name__c =  nonRenewalLeadMember.LastName;
        correspondence.Youth_Test_Passed_Date__c =  nonRenewalLeadMember.Youth_Test_Passed_Date__c;
        correspondence.Tenure__c = nonRenewalLeadMember.Tenure2__c;
        correspondence.Renewal_Date__c = membership.Renewal_Date__c;

        if(secondaryMember != null){
            correspondence.Secondary_Member__c =  secondaryMember.Id;
            correspondence.Second_Member_Salutation__c =  secondaryMember.Salutation;
            correspondence.Second_Member_First_Name__c =  secondaryMember.FirstName;
            correspondence.Second_Member_Last_Name__c =  secondaryMember.LastName;
            correspondence.Tenure_Secondary__c = secondaryMember.Tenure2__c != null ? secondaryMember.Tenure2__c : 1.0;
        }
        correspondence.Sections__c = getNonRenewalSections(nonRenewalLeadMember);
    }

    private static void updateMembership(Account membership) {
        Account thisMembership = new Account();
        thisMembership.Id = membership.Id;
        thisMembership.Last_Replacement_Card_Date__c = Date.today();
        update thisMembership;
    }

    private static Contact getSecondaryMember(String membershipId) {
        List<Contact> secondaryMembers = [SELECT Salutation,FirstName,LastName, Tenure2__c, Age_Concession__c FROM Contact WHERE RecordTypeId = :sc.secondaryContactRecordTypeId AND AccountId = :membershipId AND Status__c = 'Active'];
        return secondaryMembers.isEmpty() ? null : secondaryMembers.get(0);
    }

    private static Contact getLeadMember(String membershipId) {
        List<Contact> leadMembers = [SELECT Id, Salutation,FirstName,LastName, Tenure2__c,Age_Concession__c, Youth_Test_Passed_Date__c, (SELECT Id,Price__c, Club_Opportunity_Product__c,
                                                    Club_Opportunity_Product__r.Hybrid_Membership_Number__c, Club_Opportunity_Product__r.Non_Renewer_flag__c, Club_Opportunity_Product__r.Opportunity__c,
                                                    Name,Club_Opportunity_Product__r.Product__c, Product_Name__c, Club_Opportunity_Product__r.Account__r.Membership_Code__c,
                                                    Status__c, Member__c, Membership_Number__c, Club_Opportunity_Product__r.RecordTypeId, Club_Opportunity_Product__r.Product__r.Name
                                            FROM Member_Sections__r
                                            WHERE Club_Opportunity_Product__r.RecordTypeId  = :sc.sectionRecordTypeId) FROM Contact WHERE RecordTypeId = :sc.leadContactRecordTypeId
                                            AND AccountId = :membershipId];
        return leadMembers.isEmpty() ? new Contact() : leadMembers.get(0);
    }

    private static String getNonRenewalSections(Contact nonRenewalLeadMember) {
        String nonRenewalSections = '';

        Double nonRenewalSectionPrice = 0;
        for(Member_Section__c cop : nonRenewalLeadMember.Member_Sections__r){
            if(cop.Status__c == 'Active'){
                if(nonRenewalSections != null){
                    nonRenewalSections += cop.Club_Opportunity_Product__r.Product__r.Name + ',';
                } else {
                    if(nonRenewalLeadMember.Member_Sections__r.size() > 1){
                        nonRenewalSections = cop.Club_Opportunity_Product__r.Product__r.Name + ',';
                    } else if (nonRenewalLeadMember.Member_Sections__r.size()== 1){
                        nonRenewalSections = cop.Club_Opportunity_Product__r.Product__r.Name;
                    }
                }

                if(nonRenewalSectionPrice != 0){
                    nonRenewalSectionPrice += cop.Price__c;
                } else {
                    nonRenewalSectionPrice = cop.Price__c;
                }

            }
        }

        nonRenewalSections = nonRenewalSections.removeEnd(',');
        return nonRenewalSections;
    }

    private static ResponseWrapper buildResponse(String recordId, String error, Boolean success, Integer statusCode) {
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.id = recordId;
        responseWrapper.error = error;
        responseWrapper.success = success;
        responseWrapper.statusCode = statusCode;
        return responseWrapper;
    }

    global class RequestDataWrapper {
        global String membership;
        global String correspondenceType;
    }

    global class ResponseWrapper {
        global String id;
        global String error;
        global Boolean success;
        global Integer statusCode;
    }
}