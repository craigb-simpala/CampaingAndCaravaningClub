/*
* @who   Alasdair Leggat <alasdair.leggat@weare4c.com>
* @what  Test class for VerifoneCalloutUtility
* @when  2019-11-04
*/

@isTest
public class VerifoneCalloutUtilityTest {

    @testSetup
    static void setup(){
        // test custom setting
        Verifone__c  verifoneCustomSetting = new Verifone__c(
            Accountid__c = '00000000',
            Endpoint__c = 'TEST_ENDPOINT',
            Merchantid__c = '00000000',
            Systemguid__c = '00000000',
            Return_URL__c = 'https://google.co.uk'
        );
        insert verifoneCustomSetting;
        
        // test lead
        Lead ld = new Lead(
            FirstName = 'FIRST_NAME',
            LastName = 'LAST_NAME',
            Email = 'test@email.com',
            Street = 'STREET',
            City = 'CITY',
            State = 'STATE',
            PostalCode = 'PO1 CO2',
            Country = 'COUNTRY',
            Amount__c = 1.0,
            Company = 'COMPANY'
        );
        insert ld;
    }
    
    @isTest
    static void testFormDataCreation(){
        // get lead
        Lead ld = [SELECT FirstName, LastName, Email, Street, City, State, PostalCode, Country, Amount__c
                   FROM Lead
                   WHERE FirstName = 'FIRST_NAME'
                   LIMIT 1].get(0);
        
        // instantiate utility class
        VerifoneCalloutUtility calloutUtil = new VerifoneCalloutUtility(ld);
        
        // assert lead fields inserted into form data
        System.assertEquals(true, calloutUtil.formData.contains('FIRST_NAME'));
        System.assertEquals(true, calloutUtil.formData.contains('LAST_NAME'));
        
    }
}