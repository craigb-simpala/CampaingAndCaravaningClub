@isTest
private class NewMembershipControllerTest {

    static testMethod void MembershipControllerTest() {

        Date LMDob = Date.newInstance(1972, 1, 1);
        Date SMDob = Date.newInstance(1970, 1, 1);
        Date AMDob = Date.newInstance(1969, 1, 1);
        Date C1Dob = Date.newInstance(2009, 1, 1);
        Date C2Dob = Date.newInstance(2010, 1, 1);
        Date C3Dob = Date.newInstance(2011, 1, 1);
        Date C4Dob = Date.newInstance(2012, 1, 1);
        Date C5Dob = Date.newInstance(2013, 1, 1);
        Date C6Dob = Date.newInstance(2014, 1, 1);
        Date sDate = Date.newInstance(2015, 1, 1);
        Date eDate = Date.newInstance(2016, 12, 31);
     	Date jd = sDate;
        
         Lead lead = new Lead(LastName = 'Golf', Email = 'yo@yo.com', sections__c = 'Association of Lightweight Camper', Company='Testco', hasPartner__c =true,
      						Secondary_Member_First_Name__c = 'Mrs Golf', Secondary_Member_Surname__c = 'Golf', Secondary_Member_Email__c = 'golf@yo.com',
      						Number_of_Children__c = '6', Child_1_First_Name__c ='Child 1', Child_1_Surname__c='Golf',  Child_2_First_Name__c ='Child 2', 
      						Child_2_Surname__c='Golf', Child_3_First_Name__c ='Child 3', Child_3_Surname__c='Golf',  Child_4_First_Name__c ='Child 4',
      						Child_4_Surname__c='Golf', Child_5_First_Name__c ='Child 5', Child_5_Surname__c='Golf', Child_6_First_Name__c ='Child 6', 
      						Child_6_Surname__c='Golf', hasAssociate__c = false, Lead_Member_Age__c =43,
      						Lead_Member_Date_of_Birth__c = LMDob, Secondary_Member_Date_of_Birth__c = SMDob, Child_1_Date_of_Birth__c = C1Dob,
      						Child_2_Date_of_Birth__c = C2Dob, Child_3_Date_of_Birth__c = C3Dob,
      						Child_4_Date_of_Birth__c = C4Dob, Child_5_Date_of_Birth__c = C5Dob, Child_6_Date_of_Birth__c = C6Dob, city='MAnchester',
      						state='U.K', PostalCode ='M502ZY', Country='United Kingdom', joining_date__c = jd, leadstep__c =3, Membership_Code__c='testing',
      						Max_LeadStep__c=4, Payment_Method__c='Direct Debit', street='Carolina Way, QuaysReach', Bank_Account_Number__c='2233445566', 
      						Sort_Code__c='111111', Voucher_Code__c='voucher', Secondary_Member_Title__c = 'Mr.');
      insert lead;

      
      RecordType secRt = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Section' limit 1 ];
       
      Club_Product__c seccp = new Club_Product__c(name = 'testing',Product_Detail__c = 'testing Club Product', RecordTypeId =secRt.Id);
      insert seccp;
      Price__c secp = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= seccp.id, Price__c = 54);
      insert secp;
      
      RecordType rt = [Select Id from RecordType Where SobjectType = 'Club_Product__c' AND DeveloperName='Associate_Membership' limit 1 ];
      Club_Product__c cp = new Club_Product__c(name = 'testing1',Product_Detail__c = 'testing Club Product', RecordTypeId =rt.Id);
      insert cp;  
          
      Price__c p = new Price__c(Start_Date__c = sDate, End_Date__c = eDate, Product__c= cp.id, Price__c = 44);
      insert p; 
      
      Promotional_Code__c promoCode = new Promotional_Code__c( name = 'voucher',Description__c = 'this is a description',Expiry_Date__c = sDate.addDays(365), Number_Allowed__c = 5,Number_Used__c=0, Valid_From__c=sDate);
      insert promoCode;
      
       Test.setCurrentPage(Page.NewMembership);
       NewMembershipController controller = new NewMembershipController(new ApexPages.StandardController(lead));
       /*NewMembershipController.sectionSelectWrapper s = new NewMembershipController.sectionSelectWrapper(seccp, 78.9, true);
       NewMembershipController.sectionSelectWrapper scp = new NewMembershipController.sectionSelectWrapper(seccp);
       NewMembershipController.sectionSelectWrapper scpsel = new NewMembershipController.sectionSelectWrapper(seccp, true);
       List <NewMembershipController.sectionSelectWrapper> ls = new List<NewMembershipController.sectionSelectWrapper>();
       ls.add(s);*/
       Map<Integer,hopewiserSoapaddrsvr.addressMatchType> hpamtMap = new Map<Integer,hopewiserSoapaddrsvr.addressMatchType>();
       hopewiserSoapaddrsvr.addressMatchType hpamt = new hopewiserSoapaddrsvr.addressMatchType();
       hopewiserSoapaddrsvr.addressType addr = new hopewiserSoapaddrsvr.addressType();
       addr.Line1 = '4';
       addr.Line2 = 'Carolina Way';
       addr.Line3 = 'Quays Reach';
       addr.Line4 = 'M50 ZY';
       addr.Line5 = 'Manchester';
       hpamt.Address = addr;
       hpamtMap.put(5, hpamt);
       hopewiserSoapaddrsvr.addressMatchType hpamt2 = new hopewiserSoapaddrsvr.addressMatchType();
       hopewiserSoapaddrsvr.addressType addr2 = new hopewiserSoapaddrsvr.addressType();
       addr2.Line1 = '3';
       addr2.Line2 = 'Carolina Way';
       addr2.Line3 = 'Quays Reach';
       addr2.Line4 = 'M50 ZY';
       addr2.Line5 = 'Manchester';
       addr2.Town = 'Greater Manchester';
       addr2.County = 'U.K';
       hpamt2.Address = addr2;
       hpamtMap.put(0, hpamt2);
        hopewiserSoapaddrsvr.addressMatchType hpamt3 = new hopewiserSoapaddrsvr.addressMatchType();
        hopewiserSoapaddrsvr.addressType addr3 = new hopewiserSoapaddrsvr.addressType();
        addr3.Line1 = null;
        addr3.Line2 = null;
        addr3.Line3 = null;
        addr3.Line4 = null;
        addr3.Line5 = null;
        addr3.Town = null;
        addr3.County = null;
        hpamt3.Address = addr3;
        hpamtMap.put(0, hpamt3);
       //controller.sections = ls;
        controller.search();
       controller.costTotal= 6;
       controller.seladdr = '5';
       controller.addMatch = hpamtMap;
       controller.searchSurname = 'Golf';
       controller.step1();
       controller.step2();
       controller.dob = Date.newInstance(1972, 1, 1);
       controller.HouseNumber = '4';
       controller.pcode = 'M50 2ZY';
       controller.mHouseNumber = '4';
       controller.mstreet= 'Quays Reach';
       controller.mcity= 'Manchester';
       controller.selectedMovie = 'Sandyx';
       controller.searchTerm = 'y';
       controller.mselAddr='4';
       controller.mseladdr2='';
       controller.calculateLMAge();
       controller.calculateSMAge();
       controller.costTotal = 48.9;
       String payform = controller.payform;
       controller.changems();
       String spc=controller.searchPostcode;
       String shn=controller.searchHouseNumber;
       String msa=controller.mselAddr;
       String msa2=controller.mselAddr2;
       Decimal mtCost =   controller.mtCost;
       Decimal joinCost = controller.joinCost;
      String minMembershipAge = controller.minMembershipAge;
      String maxMembershipAge = controller.maxMembershipAge;
      Id dealerCodeId = controller.dealerCodeId;
      boolean associateAllowed = controller.associateAllowed;
      boolean sectionsAllowed = controller.sectionsAllowed;
      boolean partnerAllowed = controller.partnerAllowed;
      boolean childrenAllowed = controller.childrenAllowed;
      boolean ddPayAllowed = controller.ddPayAllowed;
      boolean cardPayAllowed= controller.cardPayAllowed;
      boolean cashPayAllowed = controller.cashPayAllowed;
      List<SelectOption> PaymentOptions = controller.PaymentOptions;
       List<Club_Product__c> cpList = new List<Club_Product__c>();
       cpList.add(cp);
       cpList.add(seccp);
       controller.mtList =cpList;
       List<SelectOption> membershipTypeOptions = controller.membershipTypeOptions;
       List<SelectOption> maddressOptions = controller.maddressOptions;
       List<SelectOption> maddressOptions2 = controller.maddressOptions2;
       //List<SelectOption> addressOptions = controller.addressOptions;
       hopewiserSoapaddrsvr.AddressExpandResponse_element results2 = controller.results2;
       hopewiserSoapaddrsvr.AddressDetailsResponse_element address = controller.address;
       controller.changeChildren();
       controller.filladdress();
       
       controller.Child5Bday = C5Dob.format();
       controller.Child6Bday = C6Dob.format();
       controller.promoValidation();
       controller.changePromoCode();
       //hopewiserSoapbankcoder.ValidateReturnDetailResponse_element validate = controller.validate();
       //List<SelectOption> addressOptions = controller.addressOptions;
       //controller.maddrsearch();
       //controller.addrsearch();
       PageReference searcht = controller.search();
       PageReference step3 = controller.step3();
       PageReference step4 = controller.step4();
       PageReference step5 = controller.step5();
       PageReference step6 = controller.step6();
       PageReference step7 = controller.step7();
       PageReference step8 = controller.step8();
       pagereference changepayment = controller.changepayment();
       pagereference changepartner = controller.changepartner();
       pagereference changeassoc = controller.changeassoc();
       pagereference changemt = controller.changemt();
       //PageReference confirm =  controller.confirm();
       voucher__c voucher = controller.voucher;
       Dealer_Advert__c dealercode = controller.dealercode;
       PageReference changeLocation = controller.changeLocation();
       Decimal amCost = controller.amCost;
       List<Account> searchMemberNumber = NewMembershipController.searchMemberNumber('searchTerm'); 
       List<Dealer_Advert__c> searchDealers = NewMembershipController.searchDealers('searchTerm'); 
    }
}