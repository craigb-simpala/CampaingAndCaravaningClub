@IsTest
private class CorrespondenceRestTest {
    @TestSetup
    static void setup() {
        Account a = new Account();
        Association__c da = new Association__c();
        Association__c region = new Association__c();
        constants c = new constants();

        region.RecordTypeId = c.accRegionRecordTypeId;
        region.Name = 'Testing Region';
        region.Region_Code__c = '101';
        insert region;

        da.RecordTypeId = c.accDaRecordTypeId;
        da.Name = 'Test D A';
        da.Parent_Region__c = region.Id;
        da.Region_Code__c = region.Region_Code__c;
        insert da;


        a.Name = 'Test Membership';
        a.District_Association__c = da.Id;
        a.BillingPostalCode = 'TE1 0YZ';
        insert a;
    }

    @IsTest
    static void updateMemberDetailsTest() {

        Account account = [SELECT Id FROM Account LIMIT 1];

        CorrespondenceRest.RequestDataWrapper cDataWrapper = new CorrespondenceRest.RequestDataWrapper();
        cDataWrapper.membership = account.Id;
        cDataWrapper.correspondenceType = 'Replacement Card';

        RestContext.request = getRestRequest(JSON.serialize(cDataWrapper));

        Test.startTest();
        CorrespondenceRest.ResponseWrapper responseWrapper = CorrespondenceRest.updateMemberDetails();

        System.debug('JS = ' + JSON.serialize(responseWrapper));

        Test.stopTest();

        List<Correspondence__c> correspondences = [SELECT Id FROM Correspondence__c];

        System.assert(responseWrapper.success);
        System.assertEquals(201, responseWrapper.statusCode);
        System.assertEquals(1, correspondences.size());
    }

    @IsTest
    static void updateMemberDetailsNegative() {

        Account account = [SELECT Id FROM Account LIMIT 1];

        CorrespondenceRest.RequestDataWrapper cDataWrapper = new CorrespondenceRest.RequestDataWrapper();
        cDataWrapper.membership = account.Id;
        cDataWrapper.correspondenceType = 'test';

        RestContext.request = getRestRequest(JSON.serialize(cDataWrapper));

        Test.startTest();
        CorrespondenceRest.ResponseWrapper responseWrapper = CorrespondenceRest.updateMemberDetails();
        System.debug('JS = ' + JSON.serialize(responseWrapper));


        Test.stopTest();

        List<Correspondence__c> correspondences = [SELECT Id FROM Correspondence__c];

        System.assert(!responseWrapper.success);
        System.assertEquals(400, responseWrapper.statusCode);
        System.assertEquals(0, correspondences.size());
    }

    private static RestRequest getRestRequest(String jsonBody) {
        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonBody);
        request.requestURI = '/services/apexrest/correspondence';
        return request;
    }

}