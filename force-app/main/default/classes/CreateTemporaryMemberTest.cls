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
private class CreateTemporaryMemberTest {
  //   static testMethod void htmlPostTest() {
  //     Date LMDob = Date.newInstance(1972, 1, 1);
  //     Date SMDob = Date.newInstance(1970, 1, 1);
  //     Date AMDob = Date.newInstance(1969, 1, 1);
  //     Date C1Dob = Date.newInstance(2009, 1, 1);
  //     Date C2Dob = Date.newInstance(2010, 1, 1);
  //     Date C3Dob = Date.newInstance(2011, 1, 1);
  //     Date C4Dob = Date.newInstance(2012, 1, 1);
  //     Date C5Dob = Date.newInstance(2013, 1, 1);
  //     Date C6Dob = Date.newInstance(2014, 1, 1);
  //     Date sDate = Date.newInstance(2015, 1, 1);
  //     Date eDate = Date.newInstance(2016, 12, 31);
  //     Date jd = date.today();
  //     String JSONMsg = '{"message":"success"}';
  //     constants c = new constants();
  //     Dealer_Advert__c dealerAd = new Dealer_Advert__c();

  //     Lead lead = new Lead(
  //       LastName = 'Golf',
  //       Email = 'yo@yo.com',
  //       sections__c = 'Association of Lightweight Camper',
  //       Company = 'Testco',
  //       hasPartner__c = true,
  //       Secondary_Member_First_Name__c = 'Mrs Golf',
  //       Secondary_Member_Surname__c = 'Golf',
  //       Secondary_Member_Email__c = 'golf@yo.com',
  //       Number_of_Children__c = '6',
  //       Child_1_First_Name__c = 'Child 1',
  //       Child_1_Surname__c = 'Golf',
  //       Child_2_First_Name__c = 'Child 2',
  //       Child_2_Surname__c = 'Golf',
  //       Child_3_First_Name__c = 'Child 3',
  //       Child_3_Surname__c = 'Golf',
  //       Child_4_First_Name__c = 'Child 4',
  //       Child_4_Surname__c = 'Golf',
  //       Child_5_First_Name__c = 'Child 5',
  //       Child_5_Surname__c = 'Golf',
  //       Child_6_First_Name__c = 'Child 6',
  //       Child_6_Surname__c = 'Golf',
  //       hasAssociate__c = true,
  //       Associate_Member_First_Name__c = 'Assoic',
  //       Associate_Member_Surname__c = 'Assoc Surname',
  //       Associate_Member_Title__c = 'Mr.',
  //       Lead_Member_Age__c = 43,
  //       Lead_Member_Date_of_Birth__c = LMDob,
  //       Secondary_Member_Date_of_Birth__c = SMDob,
  //       Child_1_Date_of_Birth__c = C1Dob,
  //       Child_2_Date_of_Birth__c = C2Dob,
  //       Associate_Member_Date_of_Birth__c = AMDob,
  //       Child_3_Date_of_Birth__c = C3Dob,
  //       Child_4_Date_of_Birth__c = C4Dob,
  //       Child_5_Date_of_Birth__c = C5Dob,
  //       Child_6_Date_of_Birth__c = C6Dob,
  //       city = 'MAnchester',
  //       state = 'U.K',
  //       PostalCode = 'M502ZY',
  //       Country = 'United Kingdom',
  //       joining_date__c = jd,
  //       leadstep__c = 3,
  //       Membership_Code__c = 'testing',
  //       Max_LeadStep__c = 4,
  //       Payment_Method__c = 'Direct Debit',
  //       street = 'Carolina Way, QuaysReach',
  //       Bank_Account_Number__c = '2233445566',
  //       Sort_Code__c = '111111',
  //       Voucher_Code__c = 'voucher',
  //       Secondary_Member_Title__c = 'Mr.'
  //     );
  //     insert lead;

  //     dealerAd.RecordTypeId = c.dealerAdvertDealerRecordTypeId;
  //     dealerAd.Name = 'test dealer';
  //     dealerAd.active__c = true;
  //     dealerAd.Valid_show__c = false;
  //     dealerAd.Show_Start_Date__c = Date.today().addDays(-7);
  //     dealerAd.Show_End_Date__c = Date.today();
  //     insert dealerAd;
  //     // TO DO: implement unit test
  //     RestRequest req = new RestRequest(); // Build the REST Request for testing
  //     CreateTemporaryMember ctm = new CreateTemporaryMember();
  //     CreateTemporaryMember.Membership mem = new CreateTemporaryMember.Membership();
  //     // req.params.put('mem.DealerCode', dealerAd.Id);
  //     // mem.MembershipName = 'Test';
  //     //   mem.JoiningFeeWaived = true;
  //     //   mem.MembershipSource = 'web';
  //     ///    mem.MembershipType = 'Digital';
  //     //    mem.MemberAddress = new CreateTemporaryMember.Address();
  //     ///  mem.PrimaryMember  = new CreateTemporaryMember.PrimaryMember();
  //     //     mem.SecondaryMember = new  CreateTemporaryMember.SecondaryMember();
  //     /* Member associateMember;
  //               List<Member> ChildMember;
  //               CampingUnit CampingUnit;
  //               List<String> Section;
  //               String FriendsMembershipNumber;
  //               String KitIssued;
  //               String Gift; */
  //     // mem.DealerCode=dealerAd.Id;
  //     //  Boolean MailStop;
  //     // Boolean EmailStop;
  //     String jsonStr = '{"Membership" : {"MembershipName" : "An error", "MembershipSource" : false}}';
  //     req.addParameter('brand', 'brand1');
  //     req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
  //     req.requestURI = '<a target="_blank" href="/services/apexrest/v1.0/TempMember'; //" rel="nofollow">https;//salesforce.com/services/apexrest/v1.0/CaseService';</a>
  //     req.httpMethod = 'POST'; // Perform a POST
  //     req.requestBody = Blob.valueof(jsonStr); // Add JSON Message as a POST

  //     RestResponse res = new RestResponse();
  //     RestContext.request = req;
  //     RestContext.response = res;
  //     CreateTemporaryMember.CreateTempMember(mem);
  //   }

  @IsTest
  static void testThisThing() {
    CreateTemporaryMember.testThisThing();
  }

  /**
   * @description Tests that the Membership Name is null.
   * @author Kev Cadger (Wipro) | 10-08-2022
   **/
  @IsTest
  static void testCreateTempMember_MembershipNameIsNull() {
    System.debug('testCreateTempMember_MembershipNameIsNull');
    Map<String, Object> jsonBody = new Map<String, Object>{
      'Membership' => new Map<String, Object>{ 'MembershipName' => null }
    };
    RestContext.request = getRestRequest(jsonBody);

    CreateTemporaryMember.Membership testMember = (CreateTemporaryMember.Membership) JSON.deserialize(
      JSON.serialize(jsonBody.get('Membership')),
      CreateTemporaryMember.Membership.class
    );
    CreateTemporaryMember.Result result = null;

    Test.startTest();
    try {
      result = CreateTemporaryMember.CreateTempMember(testMember);
    } catch (Exception e) {
      Utilities.logException(e);
    }

    Test.stopTest();

    System.assertEquals(
      'Error',
      result.status,
      'The status should show "Error".'
    );
  }

  /**
   * @description Tests that the Primary Member is null.
   * @author Kev Cadger (Wipro) | 10-08-2022
   **/
  @IsTest
  static void testCreateTempMember_PrimaryMemberIsNull() {
    System.debug('testCreateTempMember_PrimaryMemberIsNull');
    Map<String, Object> jsonBody = new Map<String, Object>{
      'Membership' => new Map<String, Object>{
        'MembershipName' => 'Test Membership Name',
        'PrimaryMember' => null
      }
    };
    RestContext.request = getRestRequest(jsonBody);

    CreateTemporaryMember.Membership testMember = (CreateTemporaryMember.Membership) JSON.deserialize(
      JSON.serialize(jsonBody.get('Membership')),
      CreateTemporaryMember.Membership.class
    );
    CreateTemporaryMember.Result result = null;

    Test.startTest();
    try {
      result = CreateTemporaryMember.CreateTempMember(testMember);
    } catch (Exception e) {
      Utilities.logException(e);
    }

    Test.stopTest();

    System.assertEquals(
      'Error',
      result.status,
      'The status should show "Error".'
    );
  }

  @IsTest
  static void testCreateTempMember_PrimaryMemberDetailsAreNull() {
    System.debug('testCreateTempMember_PrimaryMemberDetailsAreNull');
    Map<String, Object> jsonBody = new Map<String, Object>{
      'Membership' => new Map<String, Object>{
        'MembershipName' => 'Test Membership Name',
        'PrimaryMember' => new Map<String, Object>{
          'LastName' => null,
          'BirthDate' => null
        }
      }
    };
    RestContext.request = getRestRequest(jsonBody);

    CreateTemporaryMember.Membership testMember = (CreateTemporaryMember.Membership) JSON.deserialize(
      JSON.serialize(jsonBody.get('Membership')),
      CreateTemporaryMember.Membership.class
    );
    CreateTemporaryMember.Result result = null;

    Test.startTest();
    try {
      result = CreateTemporaryMember.CreateTempMember(testMember);
    } catch (Exception e) {
      Utilities.logException(e);
    }

    System.debug('Request: ' + RestContext.request);
    System.debug('Result: ' + result);
    System.debug('Response: ' + RestContext.response);

    Test.stopTest();
  }

  @IsTest
  static void testCreateTempMember_TooManyChildMembers() {
    System.debug('testCreateTempMember_TooManyChildMembers');
    Map<String, Object> jsonBody = new Map<String, Object>{
      'Membership' => new Map<String, Object>{
        'ChildMember' => new List<CreateTemporaryMember.Member>{
          new CreateTemporaryMember.Member(),
          new CreateTemporaryMember.Member(),
          new CreateTemporaryMember.Member(),
          new CreateTemporaryMember.Member(),
          new CreateTemporaryMember.Member(),
          new CreateTemporaryMember.Member(),
          new CreateTemporaryMember.Member()
        },
        'MembershipName' => 'Test Membership Name',
        'PrimaryMember' => new Map<String, Object>{
          'LastName' => null,
          'BirthDate' => null
        }
      }
    };
    RestContext.request = getRestRequest(jsonBody);

    CreateTemporaryMember.Membership testMember = (CreateTemporaryMember.Membership) JSON.deserialize(
      JSON.serialize(jsonBody.get('Membership')),
      CreateTemporaryMember.Membership.class
    );
    CreateTemporaryMember.Result result = null;

    Test.startTest();
    try {
      result = CreateTemporaryMember.CreateTempMember(testMember);
    } catch (Exception e) {
      Utilities.logException(e);
    }

    Test.stopTest();

    System.assertEquals(
      'Error',
      result.status,
      'The status should show "Error".'
    );
  }

  //   @IsTest
  //   static void testCreateTempMember_Lead() {
  //     System.debug('testCreateTempMember_TooManyChildMembers');
  //     Map<String, Object> jsonBody = new Map<String, Object>{
  //       'Membership' => new Map<String, Object>{
  //         'AssociateMember' => new Map<String, Object>{
  //           'BirthDate' => Date.newInstance(1970, 1, 1),
  //           'LastName' => 'McTest'
  //         },
  //         'ChildMember' => new List<CreateTemporaryMember.Member>{
  //           new CreateTemporaryMember.Member(),
  //           new CreateTemporaryMember.Member(),
  //           new CreateTemporaryMember.Member(),
  //           new CreateTemporaryMember.Member(),
  //           new CreateTemporaryMember.Member(),
  //           new CreateTemporaryMember.Member(),
  //           new CreateTemporaryMember.Member()
  //         },
  //         'MembershipName' => 'Test Membership Name',
  //         'PrimaryMember' => new Map<String, Object>{
  //           'BirthDate' => Date.newInstance(1970, 1, 1),
  //           'LastName' => 'McTest',
  //           'MembershipId' => getNewMembershipId()
  //         },
  //         'SecondaryMember' => new Map<String, Object>{
  //           'BirthDate' => Date.newInstance(1970, 1, 1),
  //           'LastName' => 'McTest'
  //         }
  //       }
  //     };
  //     RestContext.request = getRestRequest(jsonBody);

  //     CreateTemporaryMember.Membership testMember = (CreateTemporaryMember.Membership) JSON.deserialize(
  //       JSON.serialize(jsonBody.get('Membership')),
  //       CreateTemporaryMember.Membership.class
  //     );
  //     CreateTemporaryMember.Result result = null;

  //     Test.startTest();
  //     try {
  //       result = CreateTemporaryMember.CreateTempMember(testMember);
  //     } catch (Exception e) {
  //       Utilities.logException(e);
  //     }

  //     System.debug('Request: ' + RestContext.request);
  //     System.debug('Result: ' + result);
  //     System.debug('Response: ' + RestContext.response);

  //     Test.stopTest();

  //     System.assertEquals(
  //       'Error',
  //       result.status,
  //       'The status should show "Error".'
  //     );
  //   }

  private static RestRequest getRestRequest(Map<String, Object> jsonBody) {
    RestRequest request = new RestRequest();
    request.addHeader('Content-Type', 'application/json');
    // request.addParameter('brand', 'brand1');
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(jsonBody.toString());
    request.requestURI = '/services/apexrest/TempMember/';
    return request;
  }

  //   private static Id getNewMembershipId() {
  //     Lead lead = new Lead(
  //       Associate_Member_First_Name__c = 'Associate',
  //       Associate_Member_Surname__c = 'van Test',
  //       Bank_Account_Number__c = '2233445566',
  //     //   Child_1_First_Name__c = 'Child1',
  //     //   Child_1_Surname__c = 'McTest',
  //       City = 'Manchester',
  //       Company = 'McTest',
  //       Country = 'United Kingdom',
  //       Email = 'test@test.com',
  //       LastName = 'McTest',
  //       Lead_Member_Date_of_Birth__c = Date.newInstance(1972, 1, 1),
  //       hasAssociate__c = true,
  //       hasPartner__c = true,
  //       Joining_Date__c = Date.today(),
  //       LeadStep__c = 3,
  //       Max_LeadStep__c = 4,
  //       Membership_Code__c = 'Testing',
  //     //   Number_of_Children__c = '1',
  //       Payment_Method__c = 'Direct Debit',
  //       PostalCode = 'M50 2ZY',
  //       Secondary_Member_Email__c = 'test@test.com',
  //       Secondary_Member_First_Name__c = 'Testier',
  //       Secondary_Member_Surname__c = 'McTest',
  //       Sort_Code__c = '111111',
  //       State = 'UK',
  //       Street = 'Carolina Way, QuaysReach',
  //       Voucher_Code__c = 'voucher'
  //     );

  //     insert lead;
  //     return lead.Id;
  //   }
}