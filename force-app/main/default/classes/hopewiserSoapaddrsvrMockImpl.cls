@isTest
public class hopewiserSoapaddrsvrMockImpl implements WebServiceMock {
	public void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType) {
       
		System.debug(LoggingLevel.INFO, 'hopewiserSoapaddrsvrMockImpl.doInvoke() - ' +
			'\n request: ' + request +
			'\n response: ' + response +
			'\n endpoint: ' + endpoint +
			'\n soapAction: ' + soapAction +
			'\n requestName: ' + requestName +
			'\n responseNS: ' + responseNS +
			'\n responseName: ' + responseName +
			'\n responseType: ' + responseType);

		if(request instanceOf hopewiserSoapaddrsvr.AddressDetailsRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.AddressDetailsResponse_element());
		}
		else if(request instanceOf hopewiserSoapaddrsvr.AddressExpandRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.AddressExpandResponse_element());
		}
		else if(request instanceOf hopewiserSoapaddrsvr.AddressSearchRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.AddressSearchResponse_element());
		}
		else if(request instanceOf hopewiserSoapaddrsvr.ExtraDataRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.ExtraDataResponse_element());
		}
		else if(request instanceOf hopewiserSoapaddrsvr.PostcodeLookupRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.PostcodeLookupResponse_element());
		}
		else if(request instanceOf hopewiserSoapaddrsvr.StatusRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.StatusResponse_element());
		}
		else if(request instanceOf hopewiserSoapaddrsvr.VersionRequest_element) {
			response.put( 'response_x', new hopewiserSoapaddrsvr.VersionResponse_element());
		}
	}
}