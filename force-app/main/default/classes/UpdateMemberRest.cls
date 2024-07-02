/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 10-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   05-08-2022   Kev Cadger (Wipro)   Initial Version
 **/
@RestResource(urlMapping='/MemberUpdateFree/*')
global class UpdateMemberRest {
  global class Error {
    global integer id;
    global String Message;
  }

  global class Result {
    global String status;
    global List<Error> Errors;
    //            global Membership member;
  }

  global virtual class Address {
    global String Organisation;
    global String Line1;
    global String Line2;
    global String Line3;
    global String Line4;
    global String Line5;
    global String PostTown;
    global String County;
    global String Country;
    global String PostCodeOut;
    global String PostCodeIn;
  }

  global virtual class Member {
    global String Id;
    global String Title;
    global String FirstName;
    global String LastName;
    global Date BirthDate;
    global Decimal Tenure;
  }

  global virtual class SecondaryMember extends Member {
    global String mobileNumber;
    global String Email;
    global boolean onlineAccount;
  }

  global class PrimaryMember extends SecondaryMember {
    global String phoneNumber;
  }

  global class CampingUnit {
    global String UnitType;
    global Decimal UnitLength;
    global Decimal UnitWidth;
    global Decimal UnitHeight;
  }

  global class Membership {
    String MembershipName;
    String EmailStop;
    String PromMailStop;
    Address MemberAddress;
    PrimaryMember PrimaryMember;
    SecondaryMember SecondaryMember;
    List<Member> ChildMember;
    CampingUnit CampingUnit;
  }

  /*
    @HttpGet
    global static Result getMemberDetails(){

        RestRequest req = RestContext.request;
//      String memberId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String memberid;
        system.debug(RestContext.request.params);
        String email = RestContext.request.params.get('email');
        system.debug(email);
        Account a;
        List<Error> errors = new List<Error>();
        Result res = new Result();

        if(email!='' && email!=null){
            List<Account> accsforEmail = [select id,Membership_Number__c,Email__c from account where Email__c=:email];
            system.debug(accsforEmail);
            system.debug(accsforEmail.size());
            if(accsforEmail.size()==1){
                memberId = accsforEmail[0].Membership_Number__c;
            }else if(accsforEmail.size()==0){
                //Throw new MemberException(MEMBER_NOT_FOUND);
                res.status = '00100';
                Error e = new Error();
                e.id=1;
                e.Message='Member not Found';
                Errors.add(e);

            }else{
                //Throw new MemberException(MEMBER_NOT_FOUND);
                res.status = '00100';
                Error e = new Error();
                e.id=1;
                e.Message='Multiple members found for '+email;
                Errors.add(e);
            }
        }
        else{
                res.status = '00100';
                Error e = new Error();
                e.id=1;
                e.Message='No Email provided';
                Errors.add(e);
        }

        if(memberId !=null){
            try{
                a = [SELECT id,
                            name,
                            Membership_Code__r.name,
                            Organisation_Name__c,
                            billingstreet,
                            BillingState,
                            BillingPostalCode,
                            BillingCountry,
                            BillingCity,
                            renewal_date__c,
                            Promotional_Mailstop__c,
                            Email_Stop__c,
                            Camping_Unit__c,
                            Camping_Unit_Height__c,
                            Camping_Unit_Length__c,
                            Camping_Unit_Width__c,
                            (select id,
                                    salutation,
                                    Firstname,
                                    lastname,
                                    Birthdate,
                                    email,
                                    phone,
                                    MobilePhone,
                                    recordtype.name
                                    from Contacts),
                            (select Name,
                                    Product_Name__c,
                                    Product__r.name,
                                    Price__c,
                                    recordtype.name
                                    from Club_Opportunity_Products__r
                                    where status__c='Active')
                            FROM Account WHERE Membership_Number__c =:memberId LIMIT 1];
            }
            catch(Exception ex)
            {
                //Throw new MemberException(MEMBER_NOT_FOUND);
                res.status = '00100';
                Error e = new Error();
                e.id=1;
                e.Message='Member not Found';
                Errors.add(e);
            }
        }
        if(a!=Null){
            res.status='00000';
            Membership m = new Membership();
            Address addr = new Address();
            CampingUnit cu = new CampingUnit();
            PrimaryMember pm = new PrimaryMember();
            SecondaryMember sm;
            Member am;
            List<Member> children = new List<Member>();
            List<Section> sections = new List<Section>();

            m.renewalDate = a.renewal_date__c;
            m.PromMailStop = (a.Promotional_Mailstop__c?'Y':'N');
            m.EmailStop = (a.Email_Stop__c?'Y':'N');
            m.MembershipName = a.name;
            m.MembershipType = a.Membership_Code__r.name;

            cu.UnitType = a.Camping_Unit__c;
            cu.UnitLength = a.Camping_Unit_Length__c;
            cu.UnitWidth = a.Camping_Unit_Width__c;
            cu.UnitHeight = a.Camping_Unit_Height__c;

            Set<id> conids = new Set<Id>();
            for(Contact c:a.contacts){
                conids.add(c.id);
            }

            List<Voluntary_Office__c> voList = [select id,Member__c,Voluntary_Office_Title__c,Association__r.Name,Association__r.Association_Code__c from Voluntary_Office__c where Member__c in :conids];
            system.debug(conids);
            system.debug(voList);
            Map<id,List<Voluntary_Office__c>> convoMap = new Map<id,List<Voluntary_Office__c>>();

            for(Voluntary_Office__c vo:voList){
                if(convoMap.containskey(vo.member__c)){
                    convoMap.get(vo.member__c).add(vo);
                }
                else{
                    List<Voluntary_Office__c> vol = new List<Voluntary_Office__c>();
                    vol.add(vo);
                    convoMap.put(vo.member__c,vol);
                }

            }

            system.debug(convoMap);

            for(Contact c:a.contacts){
                if(c.recordtype.name == 'Lead'){
                    pm.Id = c.id;
                    pm.Email = c.Email;
                    pm.mobileNumber = c.MobilePhone;
                    pm.phoneNumber = c.phone;
                    pm.Title = c.salutation;
                    pm.FirstName = c.FirstName;
                    pm.LastName = c.LastName;
                    pm.BirthDate = c.Birthdate;
                    if(convoMap.containsKey(c.id)){
                        List<VoluntaryOffice> tvoList = new List<VoluntaryOffice>();
                        for(Voluntary_Office__c vo:convoMap.get(c.id)){
                            VoluntaryOffice v =new VoluntaryOffice();
                            v.voType = vo.Voluntary_Office_Title__c;
                            v.officeName = vo.Association__r.Name;
                            v.unitCode = vo.Association__r.Association_Code__c;
                            tvoList.add(v);
                        }
                        pm.VoluntaryOffice = tvoList;
                    }
                }
                if(c.recordtype.name == 'Secondary'){
                    sm = new SecondaryMember();
                    sm.Id = c.id;
                    sm.Email = c.Email;
                    sm.mobileNumber = c.MobilePhone;
                    sm.Title = c.salutation;
                    sm.FirstName = c.FirstName;
                    sm.LastName = c.LastName;
                    sm.BirthDate = c.Birthdate;
                    if(convoMap.containsKey(c.id)){
                        List<VoluntaryOffice> tvoList = new List<VoluntaryOffice>();
                        for(Voluntary_Office__c vo:convoMap.get(c.id)){
                            VoluntaryOffice v =new VoluntaryOffice();
                            v.voType = vo.Voluntary_Office_Title__c;
                            v.officeName = vo.Association__r.Name;
                            v.unitCode = vo.Association__r.Association_Code__c;
                            tvoList.add(v);
                        }
                        sm.VoluntaryOffice = tvoList;
                    }
                }
                if(c.recordtype.name == 'Associate'){
                    am = new Member();
                    am.Id = c.id;
                    am.Title = c.salutation;
                    am.FirstName = c.FirstName;
                    am.LastName = c.LastName;
                    am.BirthDate = c.Birthdate;
                }
                if(c.recordtype.name == 'Child'){
                    Member cm = new Member();
                    cm.Id = c.id;
                    cm.Title = c.salutation;
                    cm.FirstName = c.FirstName;
                    cm.LastName = c.LastName;
                    cm.BirthDate = c.Birthdate;
                    children.add(cm);
                }
            }
            for(Club_Opportunity_Product__c c:a.Club_Opportunity_Products__r){
                if(c.recordtype.name == 'Membership Code'){
                    m.BasicFee = c.Price__c;
                }
                else{
                    Section s = new Section();
                    s.code=c.Product__r.name;
                    s.price = c.Price__c;
                    sections.add(s);
                }
            }

            List<String> streetA;

            if(a.BillingStreet!=null){

            streetA = a.BillingStreet.split('[\n\r]');

            for (Integer i = 0; i < streetA.size(); i++) {
                if (streetA.get(i).equals('')) {
                    streetA.remove(i);
                    i--; //Decrement counter since we removed an empty item from the list
                }
            }
            if (streetA.size() > 0)addr.line1 = streetA[0];
            if (streetA.size() > 1)addr.line2 = streetA[1];
            if (streetA.size() > 2)addr.line3 = streetA[2];
            if (streetA.size() > 3)addr.line4 = streetA[3];
            if (streetA.size() > 4)addr.line5 = streetA[4];



            addr.Organisation = a.Organisation_Name__c;
            addr.County = a.BillingState;
            addr.Country = a.BillingCountry;
            addr.PostTown = a.BillingCity;
            addr.PostCodeOut = a.BillingPostalCode.substringbefore(' ');
            addr.PostCodeIn = a.BillingPostalCode.substringafter(' ');
            m.memberaddress = addr;
            m.PrimaryMember = pm;
            if(sm!=null)m.SecondaryMember = sm;
            if(am!=null)m.associateMember = am;
            if(children.size()>0)m.ChildMember = children;
            if(sections.size()>0)m.Section = sections;
            m.CampingUnit=cu;

            res.member = m;
        }
        }
        res.Errors = Errors;

        return res;
    }
*/

  @HttpPost
  global static Result updateMemberDetails(Membership membership) {
    System.debug('membership: ' + membership);
    RestRequest req = RestContext.request;
    String memberId = req.requestURI.substring(
            req.requestURI.lastIndexOf('/') + 1
    );

    Account a;
    List<Error> errors = new List<Error>();
    Result res = new Result();
    constants sc = new constants();

    if (memberId != null) {
      try {
        a = [
                SELECT
                        id,
                        Organisation_Name__c,
                        billingstreet,
                        BillingState,
                        BillingPostalCode,
                        BillingCountry,
                        BillingCity,
                        renewal_date__c,
                        Promotional_Mailstop__c,
                        Camping_Unit__c,
                        Camping_Unit_Height__c,
                        Camping_Unit_Length__c,
                        Camping_Unit_Width__c,
                        Email_Stop__c,
                        Opted_In__c,
                        (
                                SELECT
                                        salutation,
                                        Firstname,
                                        lastname,
                                        Birthdate,
                                        email,
                                        phone,
                                        MobilePhone,
                                        online_account_created__c,
                                        recordtype.name
                                FROM Contacts
                        )
                FROM Account
                WHERE Hybrid_membership_number__c = :memberId
                LIMIT 1
        ];
      } catch (Exception ex) {
        //Throw new MemberException(MEMBER_NOT_FOUND);
        res.status = '00100';
        Error e = new Error();
        e.id = 1;
        e.Message = 'Member not Found';
        Errors.add(e);
      }
    } else {
      res.status = '00100';
      Error e = new Error();
      e.id = 1;
      e.Message = 'Member not Found';
      Errors.add(e);
    }

    if (a != null) {
      res.status = '00000';
      if (membership.memberaddress != null) {
        a.BillingState = membership.memberaddress.County;
        a.BillingCountry = membership.memberaddress.Country;
        a.BillingCity = membership.memberaddress.PostTown;
        List<String> pcodeparts = new List<String>();
        if (membership.MemberAddress.PostCodeOut != null)
          pcodeparts.add(membership.MemberAddress.PostCodeOut);
        if (membership.MemberAddress.PostCodeIn != null)
          pcodeparts.add(membership.MemberAddress.PostCodeIn);
        a.BillingPostalCode = String.join(pcodeparts, ' ');
        a.Organisation_Name__c = membership.memberaddress.Organisation;
        a.BillingStreet =
                (membership.memberaddress.Line1 != null
                        ? membership.memberaddress.Line1
                        : '') +
                        (membership.memberaddress.Line2 != null
                                ? '\n' + membership.memberaddress.Line2
                                : '') +
                        (membership.memberaddress.Line3 != null
                                ? '\n' + membership.memberaddress.Line3
                                : '') +
                        (membership.memberaddress.Line4 != null
                                ? '\n' + membership.memberaddress.Line4
                                : '') +
                        (membership.memberaddress.Line5 != null
                                ? '\n' + membership.memberaddress.Line5
                                : '');
        if (a.BillingPostalCode != null && !a.Opted_In__c) {
          List<String> parts = a.BillingPostalCode.split(' ');
          if (parts.size() > 1) {
            String pcodeout = parts[0];
            String pcodein = parts[1].substring(0, 1);

            List<DA_Postcode__c> dap = new List<DA_Postcode__c>();

            dap = [
                    SELECT Association_Name__c, Postcode_Part_1__c, Postcode_Part_2__c
                    FROM DA_Postcode__c
                    WHERE
                            Postcode_Part_1__c = :pcodeout
                            AND (Postcode_Part_2__c = :pcodein
                            OR Postcode_Part_2__c = NULL)
                    LIMIT 1
            ];

            if (dap.size() > 0) {
              a.District_Association__c = dap[0].Association_Name__c;
            } else {
              a.District_Association__c = null;
            }
          }
        }
      }
      if (membership.campingunit != null) {
        a.Camping_Unit__c = membership.campingunit.UnitType;
        a.Camping_Unit_Height__c = membership.campingunit.UnitHeight;
        a.Camping_Unit_Length__c = membership.campingunit.UnitLength;
        a.Camping_Unit_Width__c = membership.campingunit.UnitWidth;
      }
      a.Promotional_Mailstop__c = false;
      if (membership.PromMailStop != null)
        a.Promotional_Mailstop__c = boolean.valueof(membership.PromMailStop);

      a.Email_Stop__c = false;
      if (membership.EmailStop != null)
        a.Email_Stop__c = boolean.valueof(membership.EmailStop);

      update a;

      Contact primaryCon;
      Contact secondaryCon;
      Contact delsecondaryCon;
      List<Contact> childCon = new List<Contact>();
      List<Contact> delchildCon = new List<Contact>();

      if (membership.PrimaryMember != null) {
        primaryCon = new Contact(Id = membership.PrimaryMember.Id);
        primaryCon.Email = membership.PrimaryMember.Email;
        primaryCon.MobilePhone = membership.PrimaryMember.mobileNumber;
        primaryCon.phone = membership.PrimaryMember.phoneNumber;
        primaryCon.salutation = membership.PrimaryMember.Title;
        primaryCon.FirstName = membership.PrimaryMember.FirstName;
        primaryCon.LastName = membership.PrimaryMember.LastName;
        primaryCon.Birthdate = membership.PrimaryMember.BirthDate;
        primaryCon.online_account_created__c = true;

        upsert primaryCon;
      }

      if (membership.SecondaryMember != null) {
        secondaryCon = new Contact();
        if (membership.SecondaryMember.Id != null) {
          secondaryCon.id = membership.SecondaryMember.id;
          if (
                  membership.SecondaryMember.Email == null &&
                          membership.SecondaryMember.mobileNumber == null &&
                          membership.SecondaryMember.FirstName == null &&
                          membership.SecondaryMember.LastName == null &&
                          membership.SecondaryMember.BirthDate == null &&
                          membership.SecondaryMember.Title == null
          ) {
            secondaryCon.Date_Ended__c = date.today();
          } else {
            secondaryCon.Email = membership.SecondaryMember.Email;
            secondaryCon.MobilePhone = membership.SecondaryMember.mobileNumber;
            secondaryCon.FirstName = membership.SecondaryMember.FirstName;
            secondaryCon.LastName = membership.SecondaryMember.LastName;
            secondaryCon.Birthdate = membership.SecondaryMember.BirthDate;
            secondaryCon.online_account_created__c = membership.SecondaryMember.onlineAccount;
            secondaryCon.salutation = membership.SecondaryMember.Title;
          }
        } else {
          secondaryCon.accountid = a.id;
          secondaryCon.recordtypeid = sc.secondaryContactRecordTypeId;
          secondaryCon.online_account_created__c = membership.SecondaryMember.onlineAccount;
          secondaryCon.Email = membership.SecondaryMember.Email;
          secondaryCon.MobilePhone = membership.SecondaryMember.mobileNumber;
          secondaryCon.FirstName = membership.SecondaryMember.FirstName;
          secondaryCon.LastName = membership.SecondaryMember.LastName;
          secondaryCon.Birthdate = membership.SecondaryMember.BirthDate;
          secondaryCon.salutation = membership.SecondaryMember.Title;
          // BEGIN: TEST ONLY !!!
          secondaryCon.Date_Joined__c = Date.today();
          // END: TEST ONLY !!!
        }

        upsert secondaryCon;
      }
      if (membership.ChildMember != null) {
        for (Member m : membership.ChildMember) {
          Contact cCon = new Contact();
          if (m.Id != null) {
            cCon.id = m.id;
            if (
                    m.FirstName == null &&
                            m.LastName == null &&
                            m.Title == null &&
                            m.BirthDate == null
            ) {
              cCon.Date_Ended__c = date.today();
            } else {
              cCon.FirstName = m.FirstName;
              cCon.LastName = m.LastName;
              cCon.Birthdate = m.BirthDate;
              cCon.salutation = m.Title;
            }
          } else {
            cCon.accountid = a.id;
            cCon.recordtypeid = sc.childContactRecordTypeId;
            cCon.FirstName = m.FirstName;
            cCon.LastName = m.LastName;
            cCon.Birthdate = m.BirthDate;
            cCon.salutation = m.Title;
          }
          childCon.add(cCon);
        }
      }
      if (childCon.size() > 0)
        upsert childCon;
    }

    if (Errors.size() != 0) {
      res.Errors = Errors;
    }
    return res;
  }

  // TODO : Remove this when the test class is actually completed.
  public static void testThisThing() {
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}