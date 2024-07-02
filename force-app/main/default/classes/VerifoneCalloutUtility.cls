/*
* @who   Alasdair Leggat <alasdair.leggat@weare4c.com>
* @what  Utility class for the Verifone integration
* @when  2019-11-04
*/
public class VerifoneCalloutUtility {
    
    private Lead ld {get; set;}
    private String tokenExpiry {get; set;}
    
    @AuraEnabled public String formData {get; private set;}
    @AuraEnabled public String plainFormData {get; private set;}
    @AuraEnabled public Verifone__c verifoneCustomSetting {get; set;}
    
    public VerifoneCalloutUtility (Lead ld) {
        this.verifoneCustomSetting = getVerifoneSettings();
        this.ld = ld;
        
        // set token expiry for tomorrow's date
        Date today = Date.today();
        this.tokenExpiry = Datetime.now().addMonths(2).format('ddMMyyyy');
        
        generateFormData();
    }
    
    /*
     *    getVerifoneSettings
     *    Method to get Verifone custom setting
     *    return Verifone__c
     */
    private static Verifone__c getVerifoneSettings() {
        Verifone__c verifone = Verifone__c.getOrgDefaults();
        System.debug('VERIFONE SETTING: ' + verifone);
        return verifone != null? verifone: null;
    }
    
    /*
     *    generateFormData
     *    Method to generate form to send to Verifone endpoint
     *    return void
     */
    private void generateFormData() {
        String requestData = 
            '<?xml version="1.0" encoding="utf-16"?>'+
            '<eftrequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
                '<returnurl>' + verifoneCustomSetting.Return_URL__c + '</returnurl>'+
                '<javascriptenabled>Y</javascriptenabled>'+
                '<merchant>'+
                    '<merchantid>' + verifoneCustomSetting.Merchantid__c + '</merchantid>'+
                    '<systemguid>' + verifoneCustomSetting.Systemguid__c + '</systemguid>'+
                '</merchant>'+
                '<merchantreference>' + ld.Id + '</merchantreference>'+	
                '<accountid>' + verifoneCustomSetting.Accountid__c + '</accountid>'+
                '<capturemethod>11</capturemethod>'+
                '<processingidentifier>1</processingidentifier>'+
                '<transactionvalue>' + ld.Amount__c + '</transactionvalue>'+
                '<showorderconfirmation>false</showorderconfirmation>'+
                '<showpaymentresult>true</showpaymentresult>'+
                '<customer>'+
                    '<email>' + (String.isNotBlank(ld.Email)?ld.Email:'') + '</email>'+
                    '<firstname>' + (String.isNotBlank(ld.FirstName)?ld.FirstName:'') + '</firstname>'+
                    '<lastname>' + (String.isNotBlank(ld.LastName)?ld.LastName:'') + '</lastname>'+
                    '<address>'+
                        '<address1>' + (String.isNotBlank(ld.Street)?ld.Street:'') + '</address1>'+
                        '<town>' + (String.isNotBlank(ld.City)?ld.City:'') + '</town>'+
                        '<county>' + (String.isNotBlank(ld.State)?ld.State:'') + '</county>'+
                        '<postcode>' + (String.isNotBlank(ld.PostalCode)?ld.PostalCode:'') + '</postcode>'+
                        '<country>' + (String.isNotBlank(ld.Country)?ld.Country:'') + '</country>'+
                    '</address>'+
                    '<deliveryedit>true</deliveryedit>'+
                '</customer>'+
                '<registertoken>true</registertoken>'+
                '<tokenexpirationdate>' + tokenExpiry + '</tokenexpirationdate>'+
                '<hideDeliveryDetails>true</hideDeliveryDetails>'+
                '<hideBillingDetails>false</hideBillingDetails>'+
            '</eftrequest>';

		// encode characters        
        String formattedRequestData = requestData.replaceAll('<','&lt;').replaceAll('>','&gt;');
        
        String postData = 
            '<?xml version="1.0" encoding="utf-16"?>'+
            '<postdata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
                '<api>2</api>'+
                '<merchantid>' + verifoneCustomSetting.Merchantid__c + '</merchantid>'+
                '<requesttype>eftrequest</requesttype>'+
                '<requestdata>{0}</requestdata>'+
            '</postdata>';

        String formattedPostData = String.format(postData, new List<String>{formattedRequestData});

        this.plainFormData = String.format(postData, new List<String>{requestData});
        this.formData = formattedPostData.escapeXml();
    }
    
    
}