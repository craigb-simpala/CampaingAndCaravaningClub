/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             : Tests
 * @last modified on  : 26-07-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver       Date           Author                          Modification
 * 01.00.00  00-00-0000     Kev Cadger (Wipro)              Initial Version
 **/

@IsTest
public without sharing class TestDataFactory {
  // * Class Properties * //
  private static final String TEST_DATA_DEFAULT_CLASS = 'TestDataDefaults';

  // ! ---------------------------------------------------------------------------------------------------- ! //
  // * SObject Functions - Get * //

  public static SObject getSObject(SObject record) {
    // Get the sobject type we are initialising.
    String sobjectName = record.getSObjectType().getDescribe().getName();
    // Get the sobject default class name.
    String defaultsClassName =
            TEST_DATA_DEFAULT_CLASS +
                    '.' +
                    sobjectName.replaceAll('__(c|C)$|__', '').replaceAll('_', '') +
                    'Defaults';

    return getDefaultValues(defaultsClassName, record);
  }

  public static List<SObject> getSObjects(
          SObject record,
          Integer numToGenerate
  ) {
    // Get the sobject type we are initialising.
    String sobjectName = record.getSObjectType().getDescribe().getName();

    List<SObject> records = new List<SObject>();

    // Get the
    record = getSObject(record);
    FieldDefinition recordNameField = getSObjectNameField(sobjectName);

    for (Integer i = 1; i <= numToGenerate; i++) {
      SObject recordClone = record.clone(false, true, false, false);

      if (recordNameField.DataType != 'Auto Number') {
        String currentName = (String) recordClone.get(
                recordNameField.QualifiedApiName
        );
        recordClone.put(
                recordNameField.QualifiedApiName,
                currentName + String.valueOf(i)
        );
      }

      records.add(recordClone);
    }

    return records;
  }

  // ! ---------------------------------------------------------------------------------------------------- ! //
  // * SObject Functions - Create * //

  public static SObject createSObject(SObject record) {
    record = getSObject(record);
    insert record;
    return record;
  }

  public static List<SObject> createSObjects(
          SObject record,
          Integer numToGenerate
  ) {
    List<SObject> records = getSObjects(record, numToGenerate);
    insert records;
    return records;
  }

  // * Helper Functions * //

  private static SObject getDefaultValues(
          String defaultsClassName,
          SObject record
  ) {
    // Initialise the defaults class.
    Type defaultsClassType = Type.forName(defaultsClassName);

    if (defaultsClassType == null) {
      System.debug(
              defaultsClassName + ' does not exist.\nNo default values were loaded.'
      );
    } else {
      TestDataDefaults.SObjectDefaults defaultsClass = (TestDataDefaults.SObjectDefaults) defaultsClassType.newInstance();
      Map<Schema.SObjectField, Object> defaultValues = defaultsClass.getDefaultValues();
      // Get the sobject fields already populated.
      // ? Used to not override any values already populated.
      Map<String, Object> populatedFields = record.getPopulatedFieldsAsMap();

      // For each field that has a default value.
      for (Schema.SObjectField field : defaultValues.keySet()) {
        // If the field is not populated.
        if (!populatedFields.containsKey(field.getDescribe().getName())) {
          // Update the field with the default value.
          record.put(field, defaultValues.get(field));
        }
      }
    }

    return record;
  }

  private static FieldDefinition getSObjectNameField(String sobjectName) {
    return [
            SELECT QualifiedApiName, DataType
            FROM FieldDefinition
            WHERE
                    EntityDefinition.QualifiedApiName = :sobjectName
                    AND IsNameField = TRUE
    ][0];
  }

  static Account acc;
  static Account renewAcc;
  static Association__c da;
  static Association__c region;
  static DA_Postcode__c pc;
  static Club_Product__c cp;
  static Club_Product__c cp2;
  static Club_Product__c cpSec;
  static Price__c p;
  static Price__c p2;
  static Price__c cpp;
  static Club_Opportunity_Product__c cop;
  static Club_Opportunity_Product__c copSection;
  static Member_Section__c memSec;
  static Payment_Method__c pm;
  static Payment_Method__c pmRenewal;
  static Transaction__c t;
  static Dealer_Advert__c dealerAd;
  static Date pStartDate;
  static constants c;
  static List<Payment_Method__c> pmList;
  static Opportunity opp;
  static Opportunity renewalOpp;
  static Date sDate;
  static Period period;
  public static Lead lead;
  static Cancellation__c can;
  static Contact con;
  static Date asDob;

  static void init() {
    pmList = new List<Payment_Method__c>();

    acc = new Account();
    renewAcc = new Account();
    da = new Association__c();
    region = new Association__c();
    pc = new DA_Postcode__c();
    cp = new Club_Product__c();
    cp2 = new Club_Product__c();
    cpSec = new Club_Product__c();
    p = new Price__c();
    p2 = new Price__c();
    cpp = new Price__c();
    cop = new Club_Opportunity_Product__c();
    copSection = new Club_Opportunity_Product__c();
    memSec = new Member_Section__c();
    pm = new Payment_Method__c();
    pmRenewal = new Payment_Method__c();
    t = new Transaction__c();
    dealerAd = new Dealer_Advert__c();
    pStartDate = Date.newInstance(2016, 9, 24);
    asDob = Date.newInstance(1972, 4, 28);
    c = new constants();
    opp = new Opportunity();
    renewalOpp = new Opportunity();
    sDate = Date.newInstance(2016, 10, 6);
    lead = new Lead();
    con = new Contact();
    period = new Period();
  }

  public static testMethod void createTestRecords() {
    init();

    region.RecordTypeId = c.accRegionRecordTypeId;
    region.Name = 'Testing Region';
    region.Region_Code__c = '101';
    insert region;

    da.RecordTypeId = c.accDaRecordTypeId;
    da.Name = 'Test D A';
    da.Parent_Region__c = region.Id;
    da.Region_Code__c = region.Region_Code__c;
    insert da;

    pc.Association_Name__c = da.Id;
    pc.Association_Code__c = da.Region_Code__c;
    pc.Parent_Region_Name__c = region.Name;
    pc.Postcode_Part_1__c = 'TE1';
    insert pc;

    cp.RecordTypeId = c.clubProdMembershipCodeRecordTypeId;
    cp.Name = 'Digital';
    cp.Product_Detail__c = 'Digital Membership';
    cp.Active__c = true;
    cp.Show_in_New_Membership_Picklist__c = true;
    cp.Sections_Allowed__c = true;
    cp.Associate_Allowed__c = true;
    cp.PartnerAllowed__c = true;
    cp.DD_Payment_Allowed__c = true;
    insert cp;

    cpSec.RecordTypeId = c.clubProdSectionRecordTypeId;
    cpSec.Name = 'Digital';
    cpSec.Product_Detail__c = 'Association of Lightweight Camper';
    cpSec.Active__c = true;
    cpSec.Show_in_New_Membership_Picklist__c = true;
    cpSec.Sections_Allowed__c = true;
    cpSec.Associate_Allowed__c = true;
    cpSec.PartnerAllowed__c = true;
    cpSec.DD_Payment_Allowed__c = true;
    insert cpSec;

    system.debug(
            'c.clubProdAssociateRecordTypeId ' + c.clubProdAssociateRecordTypeId
    );
    cp2.RecordTypeId = c.clubProdAssociateRecordTypeId;
    cp2.Name = 'Digital';
    cp2.Product_Detail__c = 'Digital Membership';
    cp2.Active__c = true;
    cp2.Show_in_New_Membership_Picklist__c = true;
    cp2.Sections_Allowed__c = true;
    cp2.Associate_Allowed__c = true;
    cp2.PartnerAllowed__c = true;
    cp2.DD_Payment_Allowed__c = true;
    insert cp2;

    acc.Name = 'Test Membership';
    acc.District_Association__c = da.Id;
    acc.BillingPostalCode = 'TE1 0YZ';
    acc.Date_Joined__c = system.today().addDays(-365);
    acc.Membership_Code__c = cp.Id;
    acc.Renewal_Date__c = Date.newInstance(2020, 1, 1);
    // acc.Payment_Method2__c = 'Direct Debit';
    insert acc;

    p.Product__c = cp.Id;
    p.Price__c = 36.00;
    p.Start_Date__c = pStartDate;
    insert p;

    p2.Product__c = cp2.Id;
    p2.Price__c = 36.00;
    p2.Start_Date__c = pStartDate;
    insert p2;

    cpp.Product__c = cpSec.Id;
    cpp.Price__c = 36.00;
    cpp.Start_Date__c = pStartDate;
    insert cpp;

    dealerAd.RecordTypeId = c.dealerAdvertDealerRecordTypeId;
    dealerAd.Name = 'test dealer';
    insert dealerAd;

    opp.Name = 'Sandyx';
    opp.CloseDate = sDate;
    opp.StageName = 'Closed Won';
    opp.AccountId = acc.id;
    opp.RecordTypeId = c.OppNewMembershipRecordTypeId;
    opp.Dealer_Ad_Code__c = dealerAd.Id;
    insert opp;

    con.FirstName = 'Tony';
    con.LastName = 'Golf';
    con.Phone = '01232324';
    con.RecordTypeId = c.leadContactRecordTypeId;
    con.AccountId = acc.id;
    con.mobilephone = '07985468888';
    con.email = 'tony@tony.com';
    insert con;

    Contact con2 = new Contact(
            FirstName = 'Tony',
            LastName = 'Jr.',
            Phone = '01232324',
            RecordTypeId = c.secondaryContactRecordTypeId,
            AccountId = acc.id,
            mobilephone = '07985468888',
            email = 'tony@tony.com'
    );
    insert con2;

    lead = new Lead(
            LastName = 'Golf',
            Email = 'yo@yo.com',
            sections__c = 'Association of Lightweight Camper',
            Company = acc.Id,
            hasPartner__c = true,
            Secondary_Member_First_Name__c = 'Mrs Golf',
            Secondary_Member_Surname__c = 'Golf',
            Secondary_Member_Email__c = 'golf@yo.com',
            Number_of_Children__c = '6',
            Child_1_First_Name__c = 'Child 1',
            Child_1_Surname__c = 'Golf',
            Child_2_First_Name__c = 'Child 2',
            Child_2_Surname__c = 'Golf',
            Child_3_First_Name__c = 'Child 3',
            Child_3_Surname__c = 'Golf',
            Child_4_First_Name__c = 'Child 4',
            Child_4_Surname__c = 'Golf',
            Child_5_First_Name__c = 'Child 5',
            Child_5_Surname__c = 'Golf',
            Child_6_First_Name__c = 'Child 6',
            Child_6_Surname__c = 'Golf',
            Payment_Method__c = 'Direct Debit',
            hasAssociate__c = true,
            Associate_Member_First_Name__c = 'Assoic',
            Associate_Member_Surname__c = 'Assoc Surname',
            Associate_Member_Title__c = 'Mr.',
            Sort_Code__c = '202020',
            Bank_Account_Name__c = 'Test Account',
            Bank_Account_Number__c = '41111111',
            Bank_Name__c = 'Test',
            Membership_Code__c = 'Online',
            Child_1_Date_of_Birth__c = Date.today(),
            Child_2_Date_of_Birth__c = Date.today(),
            Child_3_Date_of_Birth__c = Date.today(),
            Child_4_Date_of_Birth__c = Date.today(),
            Child_5_Date_of_Birth__c = Date.today(),
            Child_6_Date_of_Birth__c = Date.today(),
            Associate_Member_Date_of_Birth__c = Date.today(),
            Secondary_Member_Title__c = 'Mr.'
    );
    insert lead;

    pm.Membership__c = acc.Id;
    pm.Mandate_Amount__c = 37.00;
    pm.Bank_Account_Name__c = 'Test Account';
    pm.Bank_Account_Number__c = '41111111';
    pm.Bank_Name__c = 'Test';
    pm.Sort_Code__c = '202020';
    pm.Status__c = 'Active';
    pm.Start_Date__c = system.today().addDays(-11);
    pm.RecordTypeId = c.PaymentMethodDDRecordTypeId;
    //pm.DD_Transaction_dd_mm__c = '15/05';
    pm.Renewal_Payment_Pending__c = true;
    pmList.add(pm);
    insert pmList;

    cop.status__c = 'Active';
    cop.Price__c = 10;
    cop.Account__c = acc.Id;
    cop.RecordTypeId = c.mtRecordTypeId;
    cop.Opportunity__c = opp.Id;
    cop.Product__c = cp.Id;
    insert cop;

    copSection.status__c = 'Active';
    copSection.Price__c = 10;
    copSection.Account__c = acc.Id;
    copSection.RecordTypeId = c.sectionRecordTypeId;
    copSection.Opportunity__c = opp.Id;
    copSection.Product__c = cpSec.Id;
    insert copSection;
  }

  public static testMethod void createRenewalTestRecords() {
    init();
    Date joinDate = Date.newInstance(2016, 9, 24);

    region.RecordTypeId = c.accRegionRecordTypeId;
    region.Name = 'Testing Region';
    region.Region_Code__c = '101';
    insert region;

    da.RecordTypeId = c.accDaRecordTypeId;
    da.Name = 'Test D A';
    da.Parent_Region__c = region.Id;
    da.Region_Code__c = region.Region_Code__c;
    insert da;

    renewAcc.Name = 'Test Membership';
    renewAcc.District_Association__c = da.Id;
    renewAcc.BillingPostalCode = 'TE1 0YZ';
    renewAcc.Date_Joined__c = joinDate;
    renewAcc.payment_method2__c = 'Direct Debit';
    //acc.Opted_In__c = true;
    insert renewAcc;

    Contact cnt = new Contact(
            AccountId = renewAcc.Id,
            RecordTypeId = (new constants()).leadContactRecordTypeId
    );
    cnt.FirstName = 'Test';
    cnt.LastName = 'Contact';
    cnt.Phone = '01232324';
    cnt.AccountId = renewAcc.id;
    cnt.mobilephone = '07985468888';
    cnt.email = 'contact@test.com';
    insert cnt;

    renewalOpp.Name = 'Test Opp';
    renewalOpp.Amount = 44;
    renewalopp.CloseDate = system.Today();
    renewalopp.AccountId = renewAcc.Id;
    renewalopp.RecordTypeId = c.OppRenewalRecordTypeId;
    renewalopp.StageName = 'Due';
    insert renewalopp;

    lead = new Lead(
            LastName = 'Golf',
            Email = 'yo@yo.com',
            sections__c = 'Association of Lightweight Camper',
            Company = renewAcc.Id,
            hasPartner__c = true,
            Secondary_Member_First_Name__c = 'Mrs Golf',
            Secondary_Member_Surname__c = 'Golf',
            Secondary_Member_Email__c = 'golf@yo.com',
            Number_of_Children__c = '6',
            Child_1_First_Name__c = 'Child 1',
            Child_1_Surname__c = 'Golf',
            Child_2_First_Name__c = 'Child 2',
            Child_2_Surname__c = 'Golf',
            Child_3_First_Name__c = 'Child 3',
            Child_3_Surname__c = 'Golf',
            Child_4_First_Name__c = 'Child 4',
            Child_4_Surname__c = 'Golf',
            Child_5_First_Name__c = 'Child 5',
            Child_5_Surname__c = 'Golf',
            Child_6_First_Name__c = 'Child 6',
            Child_6_Surname__c = 'Golf',
            Payment_Method__c = 'Direct Debit',
            hasAssociate__c = true,
            Associate_Member_First_Name__c = 'Assoic',
            Associate_Member_Surname__c = 'Assoc Surname',
            Associate_Member_Title__c = 'Mr.',
            Sort_Code__c = '202020',
            Bank_Account_Name__c = 'Test Account',
            Bank_Account_Number__c = '41111111',
            Bank_Name__c = 'Test',
            Membership_Code__c = 'Online',
            Child_1_Date_of_Birth__c = Date.today(),
            Child_2_Date_of_Birth__c = Date.today(),
            Child_3_Date_of_Birth__c = Date.today(),
            Child_4_Date_of_Birth__c = Date.today(),
            Child_5_Date_of_Birth__c = Date.today(),
            Child_6_Date_of_Birth__c = Date.today(),
            Associate_Member_Date_of_Birth__c = Date.today(),
            Secondary_Member_Title__c = 'Mr.'
    );
    insert lead;

    cp.RecordTypeId = c.clubProdSectionRecordTypeId;
    cp.Name = 'Digital';
    cp.Product_Detail__c = 'Digital Membership';
    cp.Active__c = true;
    cp.Show_in_New_Membership_Picklist__c = true;
    cp.Sections_Allowed__c = true;
    cp.Associate_Allowed__c = true;
    cp.PartnerAllowed__c = true;
    cp.DD_Payment_Allowed__c = true;
    insert cp;

    p.Product__c = cp.Id;
    p.Price__c = 36.00;
    p.Start_Date__c = pStartDate;
    insert p;

    cp2.RecordTypeId = c.clubProdAssociateRecordTypeId;
    cp2.Name = 'Digital';
    cp2.Product_Detail__c = 'Digital Membership';
    cp2.Active__c = true;
    cp2.Show_in_New_Membership_Picklist__c = true;
    cp2.Sections_Allowed__c = true;
    cp2.Associate_Allowed__c = true;
    cp2.PartnerAllowed__c = true;
    cp2.DD_Payment_Allowed__c = true;
    insert cp2;

    p2.Product__c = cp2.Id;
    p2.Price__c = 36.00;
    p2.Start_Date__c = pStartDate;
    insert p2;

    copSection.status__c = 'Pending';
    copSection.Account__c = renewAcc.Id;
    copSection.RecordTypeId = c.amRecordTypeId;
    copSection.Opportunity__c = renewalopp.Id;
    copSection.Product__c = cp2.Id;
    insert copSection;
  }

  public static testMethod void createAccWithTwoYearsRenewalDateTestRecords() {
    createTestRecords();
    acc.Renewal_Date__c = Date.today().addDays(-740);
    update acc;
  }

  public static testMethod void createAccWithSixWeeksRenewalDateTestRecords() {
    createTestRecords();
    acc.Membership_Status__c = 'Ex-Member';
    acc.Renewal_Date__c = Date.today().addDays(+63);

    system.debug(
            'cop.status__c acc. renewal_date__c membership_status__c ' +
                    cop.status__c +
                    ' ' +
                    acc.Renewal_Date__c +
                    ' ' +
                    acc.Membership_Status__c
    );
    update acc;

    cp.Renewable__c = true;
    update cp;
  }

  public static testMethod void createAccWithTomorrowRenewalDateTestRecords() {
    createRenewalTestRecords();
    renewAcc.Renewal_Date__c = Date.today().addDays(1);
    renewAcc.Payment_Method2__c = 'Direct Debit';
    update renewAcc;

    pm.Membership__c = renewAcc.Id;
    pm.Mandate_Amount__c = 37.00;
    pm.Bank_Account_Name__c = 'Test Account';
    pm.Bank_Account_Number__c = '41111111';
    pm.Bank_Name__c = 'Test';
    pm.Sort_Code__c = '202020';
    pm.Status__c = 'Active';
    pm.Start_Date__c = system.today().addDays(-11);
    pm.RecordTypeId = c.PaymentMethodDDRecordTypeId;
    pmList.add(pm);
    insert pmList;
  }

  public static testMethod void createRenewalOppTestRecords() {
    createTestRecords();
    opp.RecordTypeId = c.OppRenewalRecordTypeId;
    opp.StageName = 'Due';
    acc.Payment_Method2__c = 'Direct Debit';
    update opp;
    // update acc;
  }

  public static testMethod void createCancellationRecord() {
    createTestRecords();
    can = new Cancellation__c(
            Cancellation_Type__c = 'Cancelled',
            Membership__c = acc.id,
            Stop_Communication__c = true
    );

    insert can;
  }

  public static testMethod void createCorrespondenceRecord() {
    createCancellationRecord();
    Correspondence__c cor = new Correspondence__c(
            Correspondence_Type__c = 'Cancellation',
            Cancellation__c = can.id
    );

    insert cor;
  }

  public static testMethod void createTransactionRecord() {
    createTestRecords();
    t = new Transaction__c(
            Transaction_Date__c = date.today(),
            Amount__c = pm.Mandate_Amount__c,
            Status__c = 'Rejected',
            Payment_Method__c = pm.Id,
            Transaction_Type__c = '17'
    );

    insert t;
  }
  public static testMethod void testDataforPaymentMethod() {
    createCancellationRecord();
    acc.Membership_Status__c = 'Cancelled';
    update acc;

    cop.Status__c = 'Cancelled';
    cop.Price__c = 38;
    update cop;

    p2.Change_Fee__c = 76;
    update p2;

    memSec.Club_Opportunity_Product__c = cop.Id;
    memSec.Member__c = con.Id;
    insert memSec;

    Contact cAssocMember = new Contact(
            title = 'Miss',
            firstname = 'Test',
            lastname = 'Me',
            birthdate = asDob,
            accountid = acc.id,
            recordtypeid = c.associateContactRecordTypeId
    );
    insert cAssocMember;

    pmRenewal.Membership__c = acc.Id;
    pmRenewal.Mandate_Amount__c = 37.00;
    pmRenewal.Bank_Account_Name__c = 'Test Account';
    pmRenewal.Bank_Account_Number__c = '41111111';
    pmRenewal.Bank_Name__c = 'Test';
    pmRenewal.Sort_Code__c = '202020';
    pmRenewal.Status__c = 'Active';
    pmRenewal.Start_Date__c = system.today().addDays(-11);
    pmRenewal.RecordTypeId = c.PaymentMethodDDRecordTypeId;
    insert pmRenewal;

    renewalOpp.Name = 'Test Opp';
    renewalOpp.Amount = 44;
    renewalopp.CloseDate = system.Today();
    renewalopp.AccountId = acc.Id;
    renewalopp.RecordTypeId = c.OppRenewalRecordTypeId;
    renewalopp.StageName = 'Due';
    insert renewalopp;
  }

  // Class used for configuration
  public class RenewalDataSetup {
    public String prodNameFrom;
    public String prodNameTo;
    public String paymentMethod;
    public Date memberBirthdate;
    public Date renewalDate;
    public Date youthTestDate;
    public String VIClass1;
    public String VIClass2;
    public Integer minAge1;
    public Integer minAge2;
    public Integer maxAge1;
    public Integer maxAge2;
  }

  //Prepares records for Membership Renewal and returns Account Id
  public static Id prepareRecordsForMembershipRenewal(
          RenewalDataSetup setupRec
  ) {
    Date dateJoined = Date.today().addDays(-7);

    Id membershipCodeRecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE
                    SobjectType = 'Club_Product__c'
                    AND DeveloperName = 'Membership_Code'
            LIMIT 1
    ]
            .Id;
    Id membershipCodeRecordTypeId2 = [
            SELECT Id
            FROM RecordType
            WHERE
                    SobjectType = 'Club_Opportunity_Product__c'
                    AND DeveloperName = 'Membership_Code'
            LIMIT 1
    ]
            .Id;
    Id contactLeadRecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Contact' AND DeveloperName = 'Lead'
            LIMIT 1
    ]
            .Id;

    Club_Product__c clubProductFrom = new Club_Product__c(
            RecordTypeId = membershipCodeRecordTypeId,
            Name = setupRec.prodNameFrom,
            Product_Detail__c = setupRec.prodNameFrom,
            Active__c = true,
            Show_in_New_Membership_Picklist__c = true,
            Auto_Renew__c = true,
            Min_Age_for_Membership__c = setupRec.minAge1,
            Max_Age_for_Membership__c = setupRec.maxAge1,
            Sections_Allowed__c = true,
            Associate_Allowed__c = true,
            PartnerAllowed__c = true,
            DD_Payment_Allowed__c = true,
            Cash_Payment_Allowed__c = true,
            Membership_Length__c = 12,
            Renewable__c = true,
            VIClass__c = setupRec.VIClass1,
            Allowed_Payment_Types__c = 'Cash/Cheque;Direct Debit;No payment method'
    );
    insert clubProductFrom;

    Club_Product__c clubProductTo = new Club_Product__c(
            RecordTypeId = membershipCodeRecordTypeId,
            Name = setupRec.prodNameTo,
            Product_Detail__c = setupRec.prodNameTo,
            Active__c = true,
            Show_in_New_Membership_Picklist__c = true,
            Auto_Renew__c = true,
            Min_Age_for_Membership__c = setupRec.minAge2,
            Max_Age_for_Membership__c = setupRec.maxAge2,
            Sections_Allowed__c = true,
            Associate_Allowed__c = true,
            PartnerAllowed__c = true,
            DD_Payment_Allowed__c = true,
            Cash_Payment_Allowed__c = true,
            Membership_Length__c = 12,
            Renewable__c = true,
            VIClass__c = setupRec.VIClass2,
            Allowed_Payment_Types__c = 'Cash/Cheque;Direct Debit;No payment method'
    );
    insert clubProductTo;

    // Create Price record

    Price__c price = new Price__c(
            Product__c = clubProductFrom.Id,
            Price__c = 0,
            Start_Date__c = dateJoined,
            Joining_Fee__c = 0,
            Payment_Type__c = setupRec.paymentMethod
    );
    insert price;

    Price__c price2 = new Price__c(
            Product__c = clubProductTo.Id,
            Price__c = 0,
            Start_Date__c = dateJoined,
            Joining_Fee__c = 0,
            Payment_Type__c = setupRec.paymentMethod
    );
    insert price2;

    // Create Product Change record

    Club_Product_Change__c clubProductChange = new Club_Product_Change__c(
            From__c = clubProductFrom.Id,
            To__c = clubProductTo.Id,
            Allow_Auto_Switch__c = true
    );
    insert clubProductChange;

    //Create Account for renewal
    Account acc = new Account(
            Name = 'Test Account',
            FreeSections__c = false,
            Membership_Code__c = clubProductFrom.Id,
            Membership_Renewal_Code__c = null,
            Date_Joined__c = dateJoined,
            Renewal_Date__c = setupRec.renewalDate,
            Payment_Method2__c = setupRec.paymentMethod,
            Application_Source__c = 'Telephone',
            Kit_Issued__c = 'No',
            Membership_Status__c = 'Paid',
            Email__c = 'john@test.com'
    );
    insert acc;

    //Create related contact
    Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Smith',
            Birthdate = setupRec.memberBirthdate,
            RecordTypeId = contactLeadRecordTypeId,
            AccountId = acc.Id,
            Youth_Test_Passed_Date__c = setupRec.youthTestDate
    );
    insert con;

    //Create related Opportunity
    Opportunity opp = new Opportunity(
            Name = 'New Membership',
            CloseDate = dateJoined,
            StageName = 'Complete',
            AccountId = acc.Id
    );
    insert opp;

    //Create related Club_Opportunity_Product__c
    Club_Opportunity_Product__c clubOpportunityProduct = new Club_Opportunity_Product__c(
            RecordTypeId = membershipCodeRecordTypeId2,
            Status__c = 'Active',
            Price__c = 0,
            Account__c = acc.Id,
            Product__c = clubProductFrom.Id,
            Opportunity__c = opp.Id
    );
    insert clubOpportunityProduct;

    return acc.Id;
  }
  public static void createAccReRunWithSixWeeksRenewalDateTestRecords() {}

}