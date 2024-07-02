/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 18-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver       Date           Author                          Modification
 * 01.00.00  00-00-0000     Kev Cadger (Wipro)              Initial Version
 **/

@IsTest
public class TestDataDefaults {
  // ! -------------------------------------------------- ! //
  // * Interface * //
  /**
   * Interface used to ensure all classes have the same base structure.
   */

  public interface SObjectDefaults {
    Map<Schema.SObjectField, Object> getDefaultValues();
  }

  // ! -------------------------------------------------- ! //
  // * Standard Objects * //
  /**
   * Default values for standard objects.
   */

  public class AccountDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Account.Name => 'TestAccount'
      };
    }
  }

  public class CaseDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Case.Description => 'This is a test case.'
      };
    }
  }

  public class ContactDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Contact.FirstName => 'Testy',
        Contact.Email => 'testy.mctest@testunit.com'
      };
    }
  }

  public class ContentVersionDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, object>{
        ContentVersion.PathOnClient => 'Test',
        ContentVersion.Title => 'Test Content Version',
        ContentVersion.VersionData => Blob.valueOf('Test Content Version')
      };
    }
  }

  public class LeadDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Lead.Company => 'TestAccount',
        Lead.LastName => 'TestLastName'
      };
    }
  }

  public class OpportunityDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Opportunity.CloseDate => Date.today().addDays(60),
        Opportunity.Name => 'TestOpportunity',
        Opportunity.StageName => ''
      };
    }
  }

  public class OrderDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Order.EffectiveDate => Date.today(),
        Order.Name => 'TestOrder',
        Order.Pricebook2Id => Test.getStandardPricebookId(),
        Order.Status => 'Draft'
      };
    }
  }

  public class OrderItemDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        OrderItem.Quantity => 1,
        OrderItem.UnitPrice => 0.0
      };
    }
  }

  public class UserDefaults implements SObjectDefaults {
    public Map<Schema.SobjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        User.Alias => 'TestUser',
        User.Email => 'testy.mctest@testunit.com',
        User.EmailEncodingKey => 'UTF-8',
        User.FirstName => 'Testy',
        User.LastName => 'McTest',
        User.LanguageLocaleKey => 'en_US',
        User.LocaleSidKey => 'en_US',
        User.TimeZoneSidKey => 'America/LoUser.s_Angeles',
        User.Username => 'testy.mctest' +
        DateTime.now() +
        '@testunit.com'
      };
    }
  }

  // ! -------------------------------------------------- ! //
  // * Custom Objects * //
  /**
   * Default values for custom objects.
   */

  public class ClubProductDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Club_Product__c.Active__c => true,
        Club_Product__c.Associate_Allowed__c => true,
        Club_Product__c.Children_Allowed__c => true,
        Club_Product__c.Membership_Length__c => 12,
        Club_Product__c.Name => 'TestClubProduct',
        Club_Product__c.PartnerAllowed__c => true,
        Club_Product__c.Price_for_Initial_Picklist__c => 50,
        Club_Product__c.RecordTypeId => Utilities.getRecordTypeId(
          Club_Product__c.getSObjectType().getDescribe().getName(),
          'Membership_Code'
        ),
        Club_Product__c.Show_in_New_Membership_Picklist__c => true
      };
    }
  }

  public class DealerAdvertDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Dealer_Advert__c.Active__c => true,
        Dealer_Advert__c.Name => 'TestShow'
      };
    }
  }

  public class PaymentMethodDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Payment_Method__c.Bank_Account_Name__c => 'Mr Testy McTest',
        Payment_Method__c.Bank_Account_Number__c => '00010001',
        Payment_Method__c.Bank_Name__c => 'Test Bank',
        Payment_Method__c.Mandate_Amount__c => 10,
        Payment_Method__c.Sort_Code__c => '001001',
        Payment_Method__c.Start_Date__c => Date.today().addDays(-7),
        Payment_Method__c.Status__c => 'Active'
      };
    }
  }

  public class PriceDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Price__c.Joining_Fee__c => 0,
        Price__c.Price__c => 10,
        Price__c.Start_Date__c => Date.today().addDays(-30).toStartOfMonth()
      };
    }
  }

  public class PromotionalCodeDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Promotional_Code__c.Description__c => 'Instant Membership Pack',
        Promotional_Code__c.Name => 'TestPromoCode',
        Promotional_Code__c.Number_Allowed__c => 1,
        Promotional_Code__c.Valid_for_Memberships__c => 'Paper',
        Promotional_Code__c.Valid_From__c => Date.today().addDays(-1)
      };
    }
  }

  public class TransactionDefaults implements SObjectDefaults {
    public Map<Schema.SObjectField, Object> getDefaultValues() {
      return new Map<Schema.SObjectField, Object>{
        Transaction__c.Amount__c => 10,
        Transaction__c.Status__c => 'Pending',
        Transaction__c.Transaction_Date__c => Date.today()
      };
    }
  }

  // ! -------------------------------------------------- ! //
  // * Helper Methods - Standard Objects * //
  /**
   * Extension methods for standard objects
   */

  public class LeadDataExtension {
    public void setAssociateMemberDetails(Lead lead) {
      lead.hasAssociate__c = true;
      lead.Associate_Member_Date_of_Birth__c = Date.today().addYears(45);
      lead.Associate_Member_First_Name__c = 'Associate';
      lead.Associate_Member_Surname__c = 'Member';
      lead.Associate_Member_Title__c = 'Sir';
    }

    public void setPartnerMemberDetails(Lead lead) {
      lead.hasPartner__c = true;
      lead.Secondary_Member_Date_of_Birth__c = Date.today().addYears(45);
      lead.Secondary_Member_Email__c = 'secondmember@testcompany.com';
      lead.Secondary_Member_First_Name__c = 'Secondary';
      lead.Secondary_Member_Surname__c = 'Member';
      lead.Secondary_Member_Online_Account__c = false;
      lead.Secondary_Member_Title__c = 'Sir';
    }

    public void setChildMemberDetails(lead lead, Integer numChildren) {
      if (numChildren > 6) {
        numChildren = 6;
      }
      lead.Number_of_Children__c = String.valueOf(numChildren);

      for (Integer i = 1; i < numChildren + 1; i++) {
        lead.put(
          'Child_' +
          i +
          '_Date_of_Birth__c',
          Date.today().addYears(-10)
        );
        lead.put('Child_' + i + '_First_Name__c', 'Child' + i);
        lead.put('Child_' + i + '_Surname__c', 'Member');
        lead.put('Child_' + i + '_Title__c', 'Miss');
      }
    }
  }
}