/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UpdateMemberChargeableRestTest {
  static Account acc;
  static Lead lead;
  static Club_Opportunity_Product__c cop;
  static constants sc;
  static Contact cAssocMember;
  static Opportunity opp;

  static void init() {
    TestDataFactory.createTestRecords();
    sc = new constants();
    acc = [SELECT Id, Membership_Status__c, date_joined__c FROM Account];
    //lead = [Select Id, LastName,Email,sections__c FROM Lead];
    //cop = [Select Id, recordtypeId from Club_Opportunity_Product__c limit 1];
    //cAssocMember = [select title,firstname,lastname,birthdate from Contact where date_ended__c = null and accountid=:acc.id and recordtypeid=:sc.associateContactRecordTypeId limit 1];
  }

  static testMethod void htmlPostTest() {
    // TO DO: implement unit test
    init();
    acc.Old_MN__c = '111111';
    update acc;
    String JSONMsg = '{"message":"success"}';
    RestRequest req = new RestRequest(); // Build the REST Request for testing
    UpdateMemberChargeableRest ctm = new UpdateMemberChargeableRest();
    UpdateMemberChargeableRest.Membership mem = new UpdateMemberChargeableRest.Membership();
    String jsonStr = '{"Membership" : {"MembershipName" : "An error", "MembershipSource" : false}}';
    req.addParameter('memberId', '111111');
    req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
    req.requestURI = '<a target="_blank" href="https://campingandcaravanningclub--test.my.salesforce.com/services/apexrest/v1.0/MemberUpdate/111111'; //" rel="nofollow">https;//salesforce.com/services/apexrest/v1.0/CaseService';</a>
    req.httpMethod = 'POST'; // Perform a POST
    req.requestBody = Blob.valueof(jsonStr); // Add JSON Message as a POST

    RestResponse res = new RestResponse();
    RestContext.request = req;
    RestContext.response = res;
    UpdateMemberChargeableRest.updateMemberDetails(mem);
  }

  @IsTest
  static void testThisThing() {
    UpdateMemberChargeableRest.testThisThing();
  }
}