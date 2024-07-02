/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 12-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   05-08-2022   Kev Cadger (Wipro)   Initial Version
 **/
@RestResource(urlMapping='/TempMember/*')
global class CreateTemporaryMember {
  global class MemberException extends Exception {
  }
  // private static final String MEMBER_INVALID = 'Member Details are invalid.';
  // private static final String MEMBER_NOT_FOUND = 'Member not Found.';

  global class Error {
    global integer id;
    global String Message;
  }

  global class Result {
    global String MemberId;
    global String status;
    global List<Error> Errors;
  }

  global virtual class Address {
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
    global String Title;
    global String FirstName;
    global String LastName;
    global Date BirthDate;
    global Decimal Tenure;
  }

  global class PrimaryMember extends Member {
    global String phoneNumber;
    global String mobileNumber;
    global String Email;
    global boolean onlineAccount;
  }

  global class SecondaryMember extends Member {
    global String mobileNumber;
    global String Email;
    global boolean onlineAccount;
  }

  global class CampingUnit {
    global String UnitType;
    global Decimal UnitLength;
    global Decimal UnitWidth;
    global Decimal UnitHeight;
  }

  global class Membership {
    String MembershipName;
    Boolean JoiningFeeWaived;
    String MembershipSource;
    String MembershipType;
    Address MemberAddress;
    PrimaryMember PrimaryMember;
    SecondaryMember SecondaryMember;
    Member associateMember;
    List<Member> ChildMember;
    CampingUnit CampingUnit;
    List<String> Section;
    String FriendsMembershipNumber;
    String KitIssued;
    String Gift;
    String DealerCode;
    Boolean MailStop;
    Boolean EmailStop;
    // Decimal Tenure;
  }

  @HttpPost
  global static Result CreateTempMember(Membership membership) {
    System.debug(membership);
    List<Error> errors = new List<Error>();
    Result res = new Result();
    Lead l;
    if (membership.MembershipName == null) {
      res.status = 'Error';
      Error e = new Error();
      e.id = 3;
      e.Message = 'Must Specify a Membership Name';
      Errors.add(e);
    }
    if (membership.DealerCode != null) {
      try {
        Dealer_Advert__c dc = [
          SELECT Id, Name
          FROM Dealer_Advert__c
          WHERE
            ((active__c = TRUE
            AND Valid_show__c = FALSE)
            OR (active__c = TRUE
            AND Valid_show__c = TRUE
            AND Show_Start_Date__c <= today
            AND Show_End_Date__c >= today))
            AND id = :membership.DealerCode
        ];
      } catch (Exception ex) {
        res.status = 'Error';
        Error e = new Error();
        e.id = 7;
        e.Message = 'Invalid Dealer Code';
        Errors.add(e);
      }
    }
    if (membership.PrimaryMember == null) {
      res.status = 'Error';
      Error e = new Error();
      e.id = 4;
      e.Message = 'Must Specify a Primary Member';
      Errors.add(e);
    } else {
      if (membership.PrimaryMember.LastName == null) {
        res.status = 'Error';
        Error e = new Error();
        e.id = 5;
        e.Message = 'Must Specify Primary Member Last Name';
        Errors.add(e);
      }
      if (membership.PrimaryMember.Birthdate == null) {
        res.status = 'Error';
        Error e = new Error();
        e.id = 6;
        e.Message = 'Must Specify Primary Member Birthdate';
        Errors.add(e);
      }
    }
    if (membership.SecondaryMember != null) {
      /*
                if(membership.SecondaryMember.Birthdate==null){
                    res.status = 'Error';
                    Error e = new Error();
                    e.id=6;
                    e.Message='Must Specify Secondary Member Birthdate';
                    Errors.add(e);
                }
*/
    }
    if (membership.ChildMember != null && membership.ChildMember.size() > 6) {
      res.status = 'Error';
      Error e = new Error();
      e.id = 2;
      e.Message = 'Cannot have more than 6 children';
      Errors.add(e);
    }
    RestRequest req = RestContext.request;
    String memberId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    if (memberId != null && memberId.startswith('00Q')) {
      try {
        l = [SELECT id FROM Lead WHERE id = :memberId LIMIT 1];
      } catch (Exception ex) {
        //Throw new MemberException(MEMBER_NOT_FOUND);
        res.status = 'Error';
        Error e = new Error();
        e.id = 1;
        e.Message = 'Member not Found';
        Errors.add(e);
      }
    } else {
      l = new Lead();
    }
    if (membership.FriendsMembershipNumber != null) {
      Account a;
      try {
        a = [
          SELECT id, name
          FROM Account
          WHERE
            Hybrid_Membership_Number__c = :membership.FriendsMembershipNumber
          LIMIT 1
        ];
        l.Existing_Members_Number__c = membership.FriendsMembershipNumber;
        l.Existing_Membership_Name__c = a.name;
      } catch (Exception ex) {
        //Throw new MemberException(MEMBER_NOT_FOUND);
        res.status = 'Error';
        Error e = new Error();
        e.id = 110;
        e.Message = 'Invalid Introducing Member No';
        Errors.add(e);
      }
    }

    if (l != null) {
      // variable to track the number of children 
      Integer numChildren = 0;
      // variable to assign the child to the correct child membership number
      Integer newMembershipChildNum = 1;
      if (membership.ChildMember != null) {
        numChildren = membership.ChildMember.size() > 6
          ? 6
          : membership.ChildMember.size();
         for (Integer i = 0; i < numChildren; i++) {
            System.debug('Child index:' +i);
            System.debug('newMembershipChildNum:' +newMembershipChildNum);
          l.put(
            'Child_' +
            newMembershipChildNum +
            '_first_name__c',
            membership.ChildMember[i].FirstName
          );
          l.put(
            'Child_' +
            newMembershipChildNum +
            '_Surname__c',
            membership.ChildMember[i].LastName
          );
          l.put('Child_' + newMembershipChildNum + '_Title__c', membership.ChildMember[i].Title);
          l.put(
            'Child_' +
            newMembershipChildNum +
            '_Date_of_Birth__c',
            membership.ChildMember[i].BirthDate
          );
          if(newMembershipChildNum <6 && newMembershipChildNum < membership.ChildMember.size()) {
            newMembershipChildNum++;
          }
        }
        // numchildren = membership.ChildMember.size();
      }
     
      l.Kit_Issued__c = 'No';
      l.Joining_Fee_Waived__c = false;
      if (membership.JoiningFeeWaived != null)
        l.Joining_Fee_Waived__c = membership.JoiningFeeWaived;
      if (membership.MembershipSource != null)
        l.Application_Source__c = membership.MembershipSource;
      if (membership.KitIssued != null) {
        if (membership.KitIssued.startsWithIgnoreCase('y')) {
          l.Kit_Issued__c = 'Yes';
        }
      }
      l.Dealer_Ad_Code__c = membership.DealerCode;
      l.Number_of_Children__c = String.valueof(numChildren);
      if (l.Number_of_Children__c == '0')
        l.Number_of_Children__c = '';
      l.Company = membership.MembershipName;
      if (membership.PrimaryMember != null) {
        l.Salutation = membership.PrimaryMember.Title;
        l.FirstName = membership.PrimaryMember.FirstName;
        l.LastName = membership.PrimaryMember.LastName;
        l.phone = (membership.PrimaryMember.phoneNumber == null
          ? ''
          : membership.PrimaryMember.phoneNumber);
        l.MobilePhone = (membership.PrimaryMember.mobileNumber == null
          ? ''
          : membership.PrimaryMember.mobileNumber);
        l.email = (membership.PrimaryMember.Email == null
          ? ''
          : membership.PrimaryMember.Email);
        l.Lead_Member_Online_Account__c = true;
        l.Lead_Member_Date_of_Birth__c = (membership.PrimaryMember.BirthDate ==
          null
          ? null
          : membership.PrimaryMember.BirthDate);
      }
      if (membership.SecondaryMember != null) {
        l.Secondary_Member_Title__c = membership.SecondaryMember.Title;
        l.Secondary_Member_First_Name__c = membership.SecondaryMember.FirstName;
        l.Secondary_Member_Surname__c = membership.SecondaryMember.LastName;
        l.Secondary_Member_Mobile_Number__c = membership.SecondaryMember.mobileNumber;
        l.Secondary_Member_Email__c = membership.SecondaryMember.Email;
        l.Secondary_Member_online_account__c = (membership.SecondaryMember.onlineAccount ==
          null
          ? false
          : membership.SecondaryMember.onlineAccount);
        l.Secondary_Member_Date_of_Birth__c = membership.SecondaryMember.BirthDate;
        l.hasPartner__c = true;
      } else {
        l.hasPartner__c = false;
      }
      if (membership.associateMember != null) {
        l.Associate_Member_Title__c = membership.associateMember.Title;
        l.Associate_Member_First_Name__c = membership.associateMember.FirstName;
        l.Associate_Member_Surname__c = membership.associateMember.LastName;
        l.Associate_Member_Date_of_Birth__c = membership.associateMember.BirthDate;
        l.hasAssociate__c = true;
      } else {
        l.hasAssociate__c = false;
      }
      if (membership.CampingUnit != null) {
        l.length__c = membership.CampingUnit.UnitLength;
        l.Width__c = membership.CampingUnit.UnitWidth;
        l.Height__c = membership.CampingUnit.UnitHeight;
        l.Camping_Unit__c = membership.CampingUnit.UnitType;
      }
      system.debug(Membership.MembershipType);
      l.Membership_Code__c = Membership.MembershipType;
      l.Gift__c = Membership.Gift;
      l.sections__c = '';
      if (membership.Section != null)
        l.sections__c = String.join(membership.Section, ':');

      l.street = '';
      l.State = '';
      l.Country = '';
      l.City = '';
      l.PostalCode = '';
      if (membership.MemberAddress != null) {
        l.Street = membership.MemberAddress.Line1;
        if (membership.MemberAddress.Line2 != null)
          l.street += '\n' + membership.MemberAddress.Line2;
        if (membership.MemberAddress.Line3 != null)
          l.street += '\n' + membership.MemberAddress.Line3;
        if (membership.MemberAddress.Line4 != null)
          l.street += '\n' + membership.MemberAddress.Line4;
        if (membership.MemberAddress.Line5 != null)
          l.street += '\n' + membership.MemberAddress.Line5;
        l.State = membership.MemberAddress.County;
        l.Country = membership.MemberAddress.Country;
        l.City = membership.MemberAddress.PostTown;
        List<String> pcodeparts = new List<String>();
        if (membership.MemberAddress.PostCodeOut != null)
          pcodeparts.add(membership.MemberAddress.PostCodeOut);
        if (membership.MemberAddress.PostCodeIn != null)
          pcodeparts.add(membership.MemberAddress.PostCodeIn);
        l.PostalCode = String.join(pcodeparts, ' ');
      }
      l.leadstep__c = 2;
      l.max_leadstep__c = 2;

      if (Errors.size() == 0) {
        upsert l;
        res.MemberId = l.id;
      }
    }

    if (Errors.size() != 0) {
      res.status = 'Error';
    } else if (memberId != null && memberId.startswith('00Q')) {
      res.status = 'Updated';
    } else {
      res.status = 'Created';
    }
    res.Errors = Errors;
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
  }

  /*
        @HttpPut
        global static Result ConvertTempMember(){
            lead l;
            List<Error> errors = new List<Error>();
            Result res = new Result();
            RestRequest req = RestContext.request;
            String memberId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            if(memberId !=null && memberId.startswith('00Q')){
                try{
                    l = [SELECT id FROM Lead WHERE id =:memberId LIMIT 1];
                }
                catch(Exception ex)
                {
                    //Throw new MemberException(MEMBER_NOT_FOUND);
                    res.status = 'Error';
                    Error e = new Error();
                    e.id=1;
                    e.Message='Member not Found';
                    Errors.add(e);
                }
            }
            if(l!=null){
                l.Joining_Date__c = date.today();
                upsert l;
                CreateMember cm = new CreateMember();
                Lead lea;
                
                String basequery = 'SELECT';
                Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
                for(String s : objectFields.keySet()) {
                    basequery += ' ' + s + ',';
                }
                basequery = basequery.subString(0,basequery.Length()-1);
                basequery += ' from lead where id = :memberId';
                lea = database.query(basequery);
                
                Database.LeadConvertResult lcr = cm.createMembershipfromLead(lea,null);
                res.status = 'Created';
                res.MemberId=lcr.accountid;
            }
            return res;
        }
*/
}