// * @who   Patrick Duncan <patrick.duncan@weare4c.com>
// * @what  Apex Controller for AddressLookup aura component 
// * @when  19/7/2019
global class AddressLookupController{
	
    // *  @description Function that makes a callout to the Hopewiser Api to get a list of addresses and return them to a flow
    // *  @param  parameters  A list with one element, a string with a postcode and optionally a house number seperated with '-----'
    // *  @return A list of addresses matching the supplied details
	@InvocableMethod
    public static List<List<String>> lookupAddress(List<String> parameters) {
            String postCode;
            String houseNumber;
            String[] parameterStrings = parameters.get(0).split('-----');
            if(parameterStrings.size()==2 || parameterStrings.size()==1){
                postCode = parameterStrings[0];
                houseNumber = parameterStrings.size()==2?parameterStrings[1]:'';

            }
            else{
                List<String> error = new List<String>{'Invalid parameters'};
                return new List<List<String>>{error};
            }
    		hopewiserSoapaddrsvr postCodeSearch = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType postcodeLookupOptions = new hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType formattedLabelOptions = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            formattedLabelOptions.IncludeCounty = 'Always';
            hopewiserSoapaddrsvr.dataType dataType1 = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType dataType2 = new hopewiserSoapaddrsvr.dataType();
            dataType1.Item = new String[]{'country'};

            String MAF = '';
            
            docsOasisOpenOrgWss200401Oasis20040.usernameTokenType securityToken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
            Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
            securityToken.Username = hopewiser.username__c;
            securityToken.password = hopewiser.password__c;
            System.debug('username: '+hopewiser.username__c+' password: '+hopewiser.password__c);
            
            docsOasisOpenOrgWss200401Oasis20040.securityType securityType = new docsOasisOpenOrgWss200401Oasis20040.securityType();
            securityType.UsernameToken = securityToken;

            hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 soapAddressInterface = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
            soapAddressInterface.Security = securityType;
     
            // hopewiserSoapaddrsvr.PostcodeLookupRequest_element request = new hopewiserSoapaddrsvr.PostcodeLookupRequest_element ();
            // request.Postcode = postCode;
            // request.Premise = houseNumber;
            // request.MAF = MAF;
            // request.RequestOptions = postcodeLookupOptions;
            // request.FormattedLabelOptions = formattedLabelOptions;
            // request.Data = dataType1;
            // request.ExtraData = dataType2;
            // System.debug (request.Data);

            hopewiserSoapaddrsvr.PostcodeLookupResponse_element response = soapAddressInterface.PostcodeLookup(postCode,houseNumber,MAF,postcodeLookupOptions,formattedLabelOptions,dataType1,dataType2);
            System.debug('response: '+response);
            System.debug('MAF: '+MAF);

            return new List<List<String>>{convertResults(response)};
    }

    // *  @description Function sets the address of a lead record
    // *  @param  recordId  Id of the lead
    // *  @param  address to be set, each element seperated with ', '
    @AuraEnabled
    public static void setAddress(Id recordId, String address){
        List<Lead> results = [SELECT Id FROM Lead WHERE Id = :recordId];
        if(results.size()==1){
            String[] addressFields = address.split(', ');
            String street = addressFields[0];
            String city = addressFields[1];
            String postCode = addressFields[2];
            results.get(0).Street = street;
            results.get(0).City = city;
            results.get(0).PostalCode = postCode;
            results.get(0).Country = 'United Kingdom';
            try{
                update results;
            }
            catch(Exception e){
                CustomExceptionData data = new CustomExceptionData('Could not save record', e.getMessage(), 123);
                throw new AuraHandledException(JSON.serialize(data));
            }
        }
        else{
            CustomExceptionData data = new CustomExceptionData('Could not save record', 'No record found for Id: '+recordId, 123);
            throw new AuraHandledException(JSON.serialize(data));

        }
    }

    // *  @description Function that converts Hopewiser response into a list of addresses
    // *  @param  response  The response
    // *  @param  The list of addresses
    private static List<String> convertResults(hopewiserSoapaddrsvr.PostcodeLookupResponse_element response){
        List<String> addresses = new List<String>();
        if(response.Match != null){ // && !response.Match.isEmpty()
            for(hopewiserSoapaddrsvr.addressMatchType addressMatch: response.Match){
                // System.debug ('country : ' + addressMatch.Data);

                hopewiserSoapaddrsvr.dataValueType dataContext = addressMatch.Data;
                // for (hopewiserSoapaddrsvr.itemValueType x : dataContext.Item) {
                //     System.debug ('DATA : ' + x.name);
                //     System.debug ('DATA 1: ' + x.input);
                // }

                hopewiserSoapaddrsvr.addressType addressType = addressMatch.Address;
                String county = addressType.County;
                String pcode = addressType.Postcode;
                String town = addressType.Town;
                String line1 = addressType.Line1;
                String line2 = addressType.Line2;
                String line3 = addressType.Line3;
                String line4 = addressType.Line4;
                String line5 = addressType.Line5;
                String street = getStreetFromLines(new String[]{line1,line2,line3,line4,line5});
                String fullAddress = street + ', ' + town + ', ' + pcode;
                System.debug('county: '+county);
                addresses.add(fullAddress);
            }
        }
        else{
            // CustomExceptionData data = new CustomExceptionData('No results found', 'No results found', 123);
            // throw new AuraHandledException(JSON.serialize(data));
            return new List<String>{'No results found'};

        }
        return addresses;
    }

    // *  @description Function that concatenates the lines of an address into single string
    // *  @param  response  The lines
    // *  @param  The string
    private static String getStreetFromLines(String[] lines){
        String street = '';
        for(Integer i=0;i<5;i++){
            if(lines[i]!=null && lines[i]!=''){
                street += lines[i] +' ';
            }
        }
        return street.trim();
    }

    //Inner class for custom error logging
    public class CustomExceptionData {
        public String name;
        public String message;
        public Integer code;

        public CustomExceptionData(String name, String message, Integer code) {
            this.name = name;
            this.message = message;
            this.code = code;
            }
        }
}