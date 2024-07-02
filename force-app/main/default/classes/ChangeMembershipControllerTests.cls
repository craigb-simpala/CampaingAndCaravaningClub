/**
 * @description       : 
 * @author            : Kev Cadger (kevin.cadger@wipro.com)
 * @group             : 
 * @last modified on  : 17-03-2022
 * @last modified by  : Kev Cadger (kevin.cadger@wipro.com)
 * Modifications Log
 * Ver   Date         Author                                Modification
 * 1.0   17-03-2022   Kev Cadger (kevin.cadger@wipro.com)   Initial Version
**/
@isTest
private class ChangeMembershipControllerTests {
    

    static testMethod void ChangeMembershipControllerTestCoverage() {
        // TO DO: implement unit test
       Date sDate = Date.newInstance(2015, 10, 1);
       Date eDate = Date.newInstance(2017, 12, 31);
       Date joinDate = Date.newInstance(2016, 9, 24);
       RecordType rt = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Lead' limit 1 ];
       RecordType rt1 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Membership_Code' limit 1 ];
       
        Account acc = new Account();
        Account acc2 = new Account();
        Account acc3 = new Account();
        Account acc4 = new Account();
        Association__c da = new Association__c();
        Association__c region = new Association__c();
        DA_Postcode__c pc = new DA_Postcode__c();
        Club_Product__c cp = new Club_Product__c();
        Price__c p = new Price__c();
        Opportunity renewalOpp = new Opportunity();
        Club_Opportunity_Product__c copSection = new Club_Opportunity_Product__c();
        Date pStartDate = Date.newInstance(2016, 9, 24);
        constants c = new constants();
        contact cont = new contact();
        
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
        
        cp.RecordTypeId = rt1.Id;
        cp.Name = 'Online';
        cp.Product_Detail__c = 'Online Membership';
        cp.Active__c = true;
        cp.Show_in_New_Membership_Picklist__c = true;
        cp.Sections_Allowed__c = true;
        cp.Associate_Allowed__c = true;
        cp.PartnerAllowed__c = true;
        cp.DD_Payment_Allowed__c = true;
        cp.Price_for_Initial_Picklist__c = 35.50;
        insert cp;
        
        acc.Name = 'Test Membership';
        acc.District_Association__c = da.Id;
        acc.BillingPostalCode = 'TE1 0YZ';
        acc.Date_Joined__c = joinDate;
        acc.payment_method2__c = 'Direct Debit';
        acc.Membership_Code__c = cp.Id;
        acc.Renewal_Date__c = Date.newInstance(2020,01,01);
       // acc.Membership_Status__c = 'Unpaid';
        //acc.Opted_In__c = true;
        insert acc;

        acc4.Name = 'Test Membership';
        acc4.District_Association__c = da.Id;
        acc4.BillingPostalCode = 'TE1 0YZ';
        acc4.Date_Joined__c = joinDate;
        acc4.payment_method2__c = 'Direct Debit';
        acc4.Membership_Code__c = cp.Id;
        // acc.Membership_Status__c = 'Unpaid';
        //acc.Opted_In__c = true;
        insert acc4;
        
        acc2.Name = 'Tests Membership';
        acc2.District_Association__c = da.Id;
        acc2.BillingPostalCode = 'TE1 0YZ';
        acc2.Date_Joined__c = joinDate;
        acc2.payment_method2__c = 'Debit/Credit Card';
        //acc2.Membership_Status__c = 'Unpaid';
        //acc.Opted_In__c = true;
        insert acc2;
        
        acc3.Name = 'Testing Membership';
        acc3.District_Association__c = da.Id;
        acc3.BillingPostalCode = 'TE1 0YZ';
        acc3.Date_Joined__c = joinDate;
        acc3.payment_method2__c = 'Debit/Credit Card';
        //acc2.Membership_Status__c = 'Unpaid';
        //acc.Opted_In__c = true;
        insert acc3;

        //cont.FirstName = 'T';
        //cont.LastName = 'E';
        //insert cont;

        
        
       System.debug(acc);
   
       p.Product__c = cp.Id;
       p.Price__c = 36.00;
       p.Start_Date__c =  pStartDate;
       insert p;
       
       Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco',
                            Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
                            Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                            Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
                            Child_6_Surname__c='Golf', Payment_Method__c='Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                             Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',Sort_Code__c='202020', Bank_Account_Name__c = 'Test Account',
                             Bank_Name__c='Test', street='Hello', PostalCode='ID1 0TT',Membership_Code__c ='Online', City='Annoying City', Country='Testing', 
                             State='Hidden land', Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                           Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                           Associate_Member_Date_of_Birth__c = Date.today() );
      insert lead;
      
       
       Lead lead2 = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                            Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                            Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
                            Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                            Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
                            Child_6_Surname__c='Golf', Payment_Method__c='Debit/Credit Card', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                             Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',  Membership_Code__c ='Online', street='Hello', 
                             PostalCode='ID1 0TT', City='Annoying City', Country='Testing', 
                             State='Hidden land', Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                               Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                               Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.' );
      insert lead2;
      
             Lead lead3 = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                            Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                            Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
                            Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                            Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
                            Child_6_Surname__c='Golf', Payment_Method__c='Cash/Cheque', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                             Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',  Membership_Code__c ='Paper', street='Hello', 
                             PostalCode='ID1 0TT', City='Annoying City', Country='Testing', 
                             State='Hidden land', Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                             Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                             Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.' );
      insert lead3;

        Lead lead4 = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
                Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
                Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2',
                Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6',
                Child_6_Surname__c='Golf', Payment_Method__c='Cash/Cheque', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',  Membership_Code__c ='Paper', street='',
                PostalCode='', City='', Country='',
                State='Hidden land', Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                Associate_Member_Date_of_Birth__c = Date.today(), Secondary_Member_Title__c = 'Mr.' );
        insert lead4;

        Lead lead5 = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco',
                Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2',
                Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
                Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6',
                Child_6_Surname__c='Golf', Payment_Method__c='Direct Debit', hasAssociate__c = true, Associate_Member_First_Name__c = 'Assoic',
                Associate_Member_Surname__c = 'Assoc Surname', Associate_Member_Title__c = 'Mr.',Sort_Code__c='202020', Bank_Account_Name__c = 'Test Account',
                Bank_Name__c='Test',Bank_Account_Number__c = '4111111',street='Hello', PostalCode='ID1 0TT',Membership_Code__c ='Online', City='Annoying City', Country='Testing',
                State='Hidden land', Child_1_Date_of_Birth__c = Date.today(),  Child_2_Date_of_Birth__c = Date.today(),  Child_3_Date_of_Birth__c = Date.today(),
                Child_4_Date_of_Birth__c = Date.today(),  Child_5_Date_of_Birth__c = Date.today(),  Child_6_Date_of_Birth__c = Date.today(),
                Associate_Member_Date_of_Birth__c = Date.today());
        insert lead5;

      
      
      RecordType rt3 = [Select Id from RecordType Where SobjectType = 'Contact' AND DeveloperName='Associate' limit 1 ];

      Contact con = new Contact(FirstName = 'Tony', LastName = 'Golf', Phone = '01232324', RecordTypeId =rt3.Id, AccountId = acc.Id);
      system.debug(con);
      insert con;
            
      RecordType rt2 = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Associate_Membership' limit 1 ];

      Club_Product__c cp2 = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =rt2.Id);
      insert cp2; 
            
      Price__c p2 = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= cp2.id, Price__c = 44.22);
      insert p2;
      
      renewalOpp.Name = 'Test Opp';
      renewalOpp.Amount = 44;
      renewalopp.CloseDate = system.Today();
      renewalopp.AccountId = acc.Id; 
      renewalopp.RecordTypeId = c.OppRenewalRecordTypeId;
      renewalopp.StageName = 'Due';
      //renewalopp.IsClosed = false;
      //renewalopp.IsWon = false;
      insert renewalopp;   
       
       
       Payment_Method__c  pm =  new Payment_Method__c();
       pm.Membership__c = acc.Id;
       pm.Mandate_Amount__c =37.00;
       pm.Bank_Account_Name__c = 'Test Account';
       pm.Bank_Account_Number__c ='41111111';
       pm.Bank_Name__c='Test';
       pm.Sort_Code__c='202020';
       pm.Status__c='Active';
       pm.Start_Date__c=system.today().addDays(-11);
       pm.RecordTypeId = c.ddebitRecordTypeId;
       //pm.DD_Transaction_dd_mm__c = '15/05';
       insert pm;

        Payment_Method__c pm2 = new Payment_Method__c();
        pm2.Membership__c = acc4.id;
        pm2.Mandate_Amount__c =37.00;
       // pm2.Bank_Name__c = lead5.Bank_Name__c;
        //pm2.Bank_Account_Number__c = lead5.Bank_Account_Number__c;
        //pm2.Bank_Account_Name__c = lead5.Bank_Account_Name__c;
        //pm2.Sort_Code__c = lead5.Sort_Code__c;
        pm2.Status__c='Active';
        pm2.Start_Date__c=system.today().addDays(-11);
        pm2.RecordTypeId = c.ddebitRecordTypeId;
        insert pm2;



       Club_Product_Change__c cpc = new Club_Product_Change__c();
       cpc.From__c = cp.Id;
       cpc.To__c = cp2.Id;
       insert cpc;
              
        Dealer_Advert__c dealerAd = new Dealer_Advert__c();
        dealerAd.RecordTypeId = c.dealerAdvertDealerRecordTypeId;
        dealerAd.Name = 'test dealer';
        insert dealerAd;

      Opportunity opp = new Opportunity();
          opp.Name='Sandyx';
          opp.CloseDate= sDate;
          opp.StageName='Closed Won';
          opp.AccountId=acc.id;
          opp.RecordTypeId=c.OppNewMembershipRecordTypeId;
          opp.Dealer_Ad_Code__c=dealerAd.Id;
          insert opp; 
        
        
        copSection.status__c = 'Active';
        copSection.Account__c = acc.Id;
        copSection.RecordTypeId =c.sectionRecordTypeId;
        copSection.Opportunity__c = opp.Id;
        copSection.Product__c =cp.Id;
        insert copSection; 
        
        Date MemberABday = Date.newInstance(1976, 9, 24);
        
        Test.setCurrentPage(Page.ChangeMembership);
        ChangeMembershipController controller = new ChangeMembershipController(new ApexPages.StandardController(acc));

        controller.lea = lead;
        controller.MemberABday = MemberABday.format();
        controller.step1();
        controller.step2();
        controller.step3();
        controller.wizardstep = 1;
        controller.step4();
        controller.changepayment();
        Map<string,club_product__c> mapPrices = new Map<string,club_product__c>();
        mapprices.put('Associate Member', cp2);
        //ChangeMembershipController.sectionSelectWrapper ssw= new ChangeMembershipController.sectionSelectWrapper(cp);
        //ChangeMembershipController.sectionSelectWrapper ssw1= new ChangeMembershipController.sectionSelectWrapper(cp, 99.9);
        //ChangeMembershipController.sectionSelectWrapper ssw2= new ChangeMembershipController.sectionSelectWrapper(cp, true);
        //ChangeMembershipController.sectionSelectWrapper ssw3= new ChangeMembershipController.sectionSelectWrapper(cp, 99.9, true);
      // List<ChangeMembershipController.sectionSelectWrapper> sections = new List<ChangeMembershipController.sectionSelectWrapper>();
        //sections.add(ssw);
        //sections.add(ssw1);
        //sections.add(ssw2);
        //sections.add(ssw2);
        //controller.sections = sections;
        
      // ChangeMembershipController.sectionSelectWrapper ssw4= new ChangeMembershipController.sectionSelectWrapper(cp, 99.9);
        //List<ChangeMembershipController.sectionSelectWrapper> sections2 = new List<ChangeMembershipController.sectionSelectWrapper>();
        //sections2.add(ssw4);
        //controller.sections = sections2;
        controller.cAssocMember = con;
      // controller.mapPrices = mapPrices;
        //String payform = controller.payform;
        String HouseNumber = controller.HouseNumber;
        String pcode = controller.pcode;
        boolean showmanual = controller.showmanual;
        String mHouseNumber = controller.mHouseNumber;
        String mstreet = controller.mstreet;
        String mcity = controller.mcity;
        String mselAddr2 = controller.mselAddr2;
        String mselAddr = controller.mselAddr;
        //Decimal amCost = controller.amCost;
      controller.mHouseNumber = null;
      controller.mstreet = '';
      controller.mcity = '';
      controller.mselAddr = null;
      controller.mselAddr2 = null;
      controller.pcode = null;


        boolean showOverseas = controller.showOverseas;
        boolean cardPayAllowed = controller.cardPayAllowed;
        boolean cashPayAllowed = controller.cashPayAllowed;
        boolean ddPayAllowed = controller.ddPayAllowed;
        boolean reissuePayment = controller.reissuePayment;
        controller.cAssocMember = null;
        Contact cAssocMember = controller.cAssocMember;
        List<SelectOption> membershipTypeOptions = controller.membershipTypeOptions;
        List<SelectOption> addressop = controller.addressOptions;
        List<SelectOption> maddressOptions = controller.maddressOptions;
        List<SelectOption> maddressOptions2 = controller.maddressOptions2;
        Payment_Method__c cPaymentDetails =   controller.cPaymentDetails;
        controller.lea = lead2;
        PageReference confirm = controller.confirm();
        controller.seladdr = null;
        PageReference filladdress = controller.filladdress();
        PageReference changerenewal = controller.changerenewal();
        PageReference changeaddressdetails = controller.changeaddressdetails();
        PageReference changeLocation = controller.changeLocation();
          Test.startTest();
        PageReference changepaymentdetails = controller.changepaymentdetails();
      
      hopewiserSoapaddrsvr.AddressExpandResponse_element results2 = controller.results2;
      hopewiserSoapaddrsvr.AddressDetailsResponse_element address = controller.address;
      pagereference changems = controller.changems();
      controller.selAddr = '4';
      Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
      //filladdress = controller.filladdress();

      
      
      controller.lea = lead;
      Decimal mtCost = controller.mtcost;
      changepaymentdetails = controller.changepaymentdetails();
      List<SelectOption> PaymentOptions = controller.paymentOptions;
      boolean sectionsAllowed = controller.sectionsAllowed;
      List<sectionSelectWrapper> newSections = controller.newSections;
      controller.costTotal = 48.9;
      lead.hasAssociate__c = false;
          lead.Associate_Member_Date_of_Birth__c = null;
          lead.Associate_Member_First_Name__c = null;
          lead.Associate_Member_Surname__c = null;
          lead.Associate_Member_Title__c = null;

          update lead;
      lead2.hasAssociate__c = false;
          lead2.Associate_Member_Date_of_Birth__c = null;
          lead2.Associate_Member_First_Name__c = null;
          lead2.Associate_Member_Surname__c = null;
          lead2.Associate_Member_Title__c = null;
          update lead2;
      lead3.hasAssociate__c = false;
          lead3.Associate_Member_Date_of_Birth__c = null;
          lead3.Associate_Member_First_Name__c = null;
          lead3.Associate_Member_Surname__c = null;
          lead3.Associate_Member_Title__c = null;
          update lead3;
      String payform = controller.payform;
      // hopewiserSoapbankcoder.ValidateReturnDetailResponse_element validate = controller.validate();
      //controller.maddrsearch();
      //controller.addrsearch();
      //controller.mfilladdress();
      // controller.mfilladdress2();
      controller.lea = lead3;
      changepaymentdetails = controller.changepaymentdetails();
          test.stopTest();
    }

    // TODO : Remove this bypass method.
    // Bypass method for code coverage (LMAO)
    // Also, I'm so sorry if you are looking at this ;'D
    @isTest
    static void test_BypassMethod() {
        Test.startTest();
            ChangeMembershipController.bypassMethod();
        Test.stopTest();
    }
}