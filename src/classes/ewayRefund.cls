public with sharing class ewayRefund {
	//**********
	//Constants
	//**********
	private static String EWAY_LIVE_REFUND_GATEWAY_URL = 'https://www.eway.com.au/gateway/xmlpaymentrefund.asp';
	private static String EWAY_LIVE_CUSTOMER_ID = '10343624';
	private static String EWAY_LIVE_GMT_CUSTOMER_ID = '19520741';
	private static String EWAY_REFUND_PASSWORD = 'q9uMV+s>z';
		
	//**********
	//Properties
	//**********
	private ewayResponse response;
	private String ewayGatewayUrl 					= '';
	private String ewayCustomerId 					= '';
	private String ewayTotalAmount 					= '';
	private String ewayCardExpiryMonth 				= '';
	private String ewayCardExpiryYear 				= '';
	private String ewayCVN             				= '';
	private String ewayOriginalTrxnNumber 			= ''; 	
	private String ewayOption1 						= ''; 	
	private String ewayOption2 						= ''; 	
	private String ewayOption3 						= '';	
	private String ewayRefundPassword 				= '';	
	private String xmldata 							= '';
		
	//***********
	//Constructor
	//***********
	public ewayRefund() {
		this.response = new ewayResponse();		
	}
		
	//*******
	//Methods
	//*******
	public void setewayTotalAmount(String ewayTotalAmount) { 
		// 	12 	Included
		this.ewayTotalAmount = this.checkValue('ewayTotalAmount',ewayTotalAmount,12,true);
	}
	
	public void setewayCardExpiryMonth(String ewayCardExpiryMonth) {
		// 	2 	Included
		 this.ewayCardExpiryMonth = this.checkValue('ewayCardExpiryMonth',ewayCardExpiryMonth,2,true);
	}
	public void setewayCardExpiryYear(String ewayCardExpiryYear) { 
		//	2 	Included
		 this.ewayCardExpiryYear = this.checkValue('ewayCardExpiryYear',ewayCardExpiryYear,2,true);
	}
	
	public void setewayOriginalTrxnNumber(String ewayOriginalTrxnNumber) { 
		//	16
		 this.ewayOriginalTrxnNumber = this.checkValue('ewayOriginalTrxnNumber',ewayOriginalTrxnNumber,16,false);
	} 	
	public void setewayOption1(String ewayOption1) {
		// 	255
		 this.ewayOption1 = this.checkValue('ewayOption1',ewayOption1,255,false);
	} 	
	public void setewayOption2(String ewayOption2) {
		// 	255
		 this.ewayOption2 = this.checkValue('ewayOption2',ewayOption2,255,false);
	} 	
	public void setewayOption3(String ewayOption3) { 
		//	255
		 this.ewayOption3 = this.checkValue('ewayOption3',ewayOption3,255,false);
	}
	
	public void setMode(String mode) {
	    if (mode == 'Get More Traffic') {
			this.ewayCustomerId	= EWAY_LIVE_GMT_CUSTOMER_ID;
		} else {
			this.ewayCustomerId	= EWAY_LIVE_CUSTOMER_ID;
		} 
		this.ewayGatewayUrl 	= EWAY_LIVE_REFUND_GATEWAY_URL;
		this.ewayRefundPassword = EWAY_REFUND_PASSWORD;
	}
	
	private String checkValue(String field, String value, Integer length, Boolean required) {
		System.debug('***'+field+':'+value);
		try {
			value = value.trim();
			if (required == true) {
				if (value == null || value.length()==0) {
					if (field.length() > 0) {
						this.response.setewayErrors(field+' can not be empty');
					}
				}
			}
			if (value.length() > length) {
				if (field.length() > 0) {
					this.response.setewayErrors(field+' can not be longer then '+length);
				}
			}
		} catch (Exception e) {
			if (required == true) {
				if (field.length() > 0) {
					this.response.setewayErrors(field+' can not be empty');
				}
			}
		} 
		return value;	
	}
	
	private void checkRequired() {
		this.ewayCustomerId	 		= this.checkValue('',this.ewayCustomerId,8,true);
		this.ewayTotalAmount 		= this.checkValue('',this.ewayTotalAmount,12,true);
		this.ewayCardExpiryMonth 	= this.checkValue('',this.ewayCardExpiryMonth,2,true);
		this.ewayCardExpiryYear 	= this.checkValue('',this.ewayCardExpiryYear,2,true);
		this.ewayOriginalTrxnNumber = this.checkValue('',this.ewayOriginalTrxnNumber,16,true);
	}
	
	private void buildXML() {
		this.xmldata = '';
		this.xmldata += '<ewaygateway>';
		this.xmldata += '<ewayCustomerID>'+					EncodingUtil.urlEncode(this.ewayCustomerId,'UTF-8')						+'</ewayCustomerID>';
		this.xmldata += '<ewayTotalAmount>'+				EncodingUtil.urlEncode(this.ewayTotalAmount,'UTF-8')					+'</ewayTotalAmount>'; 
		this.xmldata += '<ewayCardExpiryMonth>'+			EncodingUtil.urlEncode(this.ewayCardExpiryMonth,'UTF-8')				+'</ewayCardExpiryMonth>'; 
		this.xmldata += '<ewayCardExpiryYear>'+				EncodingUtil.urlEncode(this.ewayCardExpiryYear,'UTF-8')					+'</ewayCardExpiryYear>'; 
		this.xmldata += '<ewayOriginalTrxnNumber>'+			EncodingUtil.urlEncode(this.ewayOriginalTrxnNumber,'UTF-8')				+'</ewayOriginalTrxnNumber>'; 
		this.xmldata += '<ewayOption1>'+					EncodingUtil.urlEncode(this.ewayOption1,'UTF-8')						+'</ewayOption1>';
		this.xmldata += '<ewayOption2>'+					EncodingUtil.urlEncode(this.ewayOption2,'UTF-8')						+'</ewayOption2>';
		this.xmldata += '<ewayOption3>'+					EncodingUtil.urlEncode(this.ewayOption3,'UTF-8')						+'</ewayOption3>';  
		this.xmldata += '<ewayRefundPassword>q9uMV+s>z</ewayRefundPassword>'; 
		this.xmldata += '</ewaygateway>';
	}
	
	private void sendXml() {
		if (this.response.getewayTrxnStatus() == 'True') {
	        HttpRequest req = new HttpRequest();
	        Http h = new Http();
	        req.setEndpoint(this.ewayGatewayUrl);
	        req.setMethod('POST');
	        req.setBody(this.xmldata); 
	        req.setTimeout(20000);
	        system.debug(this.xmldata);
	        system.debug(req);
	        this.response.loadResponse(h.send(req).getBodyDocument());
		} else {
			this.response.setewayTrxnReference(this.ewayOriginalTrxnNumber);
		}		
	}
	
	public String getxmldata() {
		String xmldump = '';
		xmldump += '<ewaygateway>\r\n';
		xmldump += '  <ewayCustomerID>'+					this.ewayCustomerId						+'</ewayCustomerID>\r\n';
		xmldump += '  <ewayTotalAmount>'+					this.ewayTotalAmount					+'</ewayTotalAmount>\r\n'; 
		xmldump += '  <ewayCardExpiryMonth>'+				this.ewayCardExpiryMonth				+'</ewayCardExpiryMonth>\r\n'; 
		xmldump += '  <ewayCardExpiryYear>'+				this.ewayCardExpiryYear					+'</ewayCardExpiryYear>\r\n'; 
		xmldump += '  <ewayOriginalTrxnNumber>'+			this.ewayOriginalTrxnNumber				+'</ewayOriginalTrxnNumber>\r\n'; 
		xmldump += '  <ewayOption1>'+						this.ewayOption1						+'</ewayOption1>\r\n';
		xmldump += '  <ewayOption2>'+						this.ewayOption2						+'</ewayOption2>\r\n';
		xmldump += '  <ewayOption3>'+						this.ewayOption3						+'</ewayOption3>\r\n';  
		xmldump += '</ewaygateway>\r\n';
		return xmldump;
	}
	
	public ewayResponse makeRefund() {
		this.checkRequired();
		this.buildXML();
		this.sendXml();
		return this.response;			
	}	
	
	public String getEWAY_TEST_GATEWAY_URL() {
		return EWAY_LIVE_REFUND_GATEWAY_URL;
	}

}