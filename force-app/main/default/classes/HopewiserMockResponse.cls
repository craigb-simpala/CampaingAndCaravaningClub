global with sharing class HopewiserMockResponse implements WebServiceMock {

	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

       
	   hopewiserSoapaddrsvr.PostcodeLookupResponse_element respElement = fakeResponse();
       response.put('response_x', respElement); 
   }

   private static hopewiserSoapaddrsvr.PostcodeLookupResponse_element fakeResponse(){
   		hopewiserSoapaddrsvr.PostcodeLookupResponse_element response = new hopewiserSoapaddrsvr.PostcodeLookupResponse_element();
       	hopewiserSoapaddrsvr.addressMatchType[] matches = new hopewiserSoapaddrsvr.addressMatchType[]{};
       	for(Integer i=0;i<3;i++){
       		hopewiserSoapaddrsvr.addressMatchType match = new hopewiserSoapaddrsvr.addressMatchType();
            hopewiserSoapaddrsvr.addressType addressType =  new hopewiserSoapaddrsvr.addressType();
       		if(i==0){
       			addressType.Line1 = '1/1';
       			addressType.Line2 = '11';
       	       	addressType.Line3 = 'Test Street';
       			addressType.Postcode = 'TEST 1';
           	   	addressType.Town = 'Teston';
       		}
       		else if(i==1){
       			addressType.Line1 = '22';
       	       	addressType.Line2 = 'Test Street';
       	       	addressType.Line2 = 'Test Street';
           	   	addressType.Town = 'Teston';
       			addressType.Postcode = 'TEST 2';
       		}
       		else{
       			addressType.Line1 = '3/2';
       			addressType.Line2 = '33';
       	       	addressType.Line3 = 'Test Street';
           	   	addressType.Town = 'Teston';
       			addressType.Postcode = 'TEST 3';

       		}
       		match.Address = addressType;
       		matches.add(match);
       }
       response.Match = matches;
       return response;
   }
    
}