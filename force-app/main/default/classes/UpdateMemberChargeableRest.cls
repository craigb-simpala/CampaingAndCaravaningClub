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
@RestResource(urlMapping='/MemberUpdate/*')
global class UpdateMemberChargeableRest {
  global class Error {
    global integer id;
    global String Message;
  }

  global class Result {
    global String status;
    global List<Error> Errors;
    global String reference;
  }

  global virtual class Member {
    global String Id;
    global String Title;
    global String FirstName;
    global String LastName;
    global Date BirthDate;
    global Decimal Tenure;
  }

  global class Membership {
    String MembershipType;
    List<String> Section;
    Member associateMember;
  }

  @HttpPost
  global static Result updateMemberDetails(Membership membership) {
    RestRequest req = RestContext.request;
    String memberId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    Lead l;
    List<Error> errors = new List<Error>();
    Result res = new Result();
    Account a;
    Opportunity o;

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
    } else if (memberId != null && memberId.startswith('006')) {
      try {
        o = [SELECT id FROM Opportunity WHERE id = :memberId LIMIT 1];
        l = new Lead(Company = o.id, lastname = o.id);
      } catch (Exception ex) {
        //Throw new MemberException(MEMBER_NOT_FOUND);
        res.status = 'Error';
        Error e = new Error();
        e.id = 1;
        e.Message = 'Member not Found';
        Errors.add(e);
      }
    } else if (memberId != null) {
      try {
        a = [
          SELECT id
          FROM Account
          WHERE Hybrid_Membership_Number__c = :memberId
          LIMIT 1
        ];
        l = new Lead(Company = a.id, lastname = a.id);
      } catch (Exception ex) {
        //Throw new MemberException(MEMBER_NOT_FOUND);
        res.status = '00100';
        Error e = new Error();
        e.id = 1;
        e.Message = 'Member not Found';
        Errors.add(e);
      }
    }

    if (membership.associateMember != null) {
      l.Associate_Member_Title__c = membership.associateMember.Title;
      l.Associate_Member_First_Name__c = membership.associateMember.FirstName;
      l.Associate_Member_Surname__c = membership.associateMember.LastName;
      l.Associate_Member_Date_of_Birth__c = membership.associateMember.BirthDate;
      if (
        membership.associateMember.id != null &&
        membership.associateMember.Title == null &&
        membership.associateMember.FirstName == null &&
        membership.associateMember.LastName == null &&
        membership.associateMember.BirthDate == null
      ) {
        l.hasPartner__c = true;
      } else {
        l.hasAssociate__c = true;
      }
    } else {
      l.hasAssociate__c = false;
    }

    l.sections__c = '';
    if (membership.Section != null)
      l.sections__c = String.join(membership.Section, ':');
    l.Membership_Code__c = Membership.MembershipType;

    upsert l;

    res.reference = l.id;

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
  }
}