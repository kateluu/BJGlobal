public with sharing class officeAutoPilot_API {
	
	public static boolean isTest = false;
	
	private String contactDbApi 		= 'http://api.moon-ray.com/cdata.php';
	private String productDbApi 		= 'http://api.moon-ray.com/pdata.php';
	private String formDbApi 		= 'http://api.moon-ray.com/fdata.php';
	
	private String app_id 					= '';
	private String app_key 					= '';
	private String app_reqType 				= '';
	private String app_data 				= '';
	private String app_f_add 				= '';
	private String app_return_id			= '';
	private String app_xmldata				= '';
	private String app_api 					= '';
	private String app_result				= '';
	
	public officeAutoPilot_API(String appId, String appKey) {
		this.app_id 		= appId;
		this.app_key	 	= appKey;				
	}
	
	private Map<String, String> build_Contact_Details(officeAutoPilot_Object contactInfo) {
		Map<String, String> returnMap = new Map<String, String>();

		String ContactId 					= '';
		String ContactInformation 			= '';
		String LeadandPersonDetails 		= '';
		String SequencesandTags 			= '';
		
		ContactId = contactInfo.id; 					
		ContactInformation += '<field name="First Name">'+ contactInfo.first_name+'</field>'; 			
		ContactInformation += '<field name="Last Name">'+ contactInfo.last_name+'</field>'; 				
		ContactInformation += '<field name="E-Mail">'+ contactInfo.email+'</field>'; 					
		ContactInformation += '<field name="Home Phone">'+ contactInfo.home_phone+'</field>'; 			
		ContactInformation += '<field name="Title">'+ contactInfo.title+'</field>'; 					
		ContactInformation += '<field name="Office Phone">'+ contactInfo.office_phone+'</field>'; 			
		ContactInformation += '<field name="Cell Phone">'+ contactInfo.cell_phone+'</field>'; 			
		ContactInformation += '<field name="Fax">'+ contactInfo.fax+'</field>'; 					
		ContactInformation += '<field name="Company">'+ contactInfo.company+'</field>'; 				
		ContactInformation += '<field name="Address">'+ contactInfo.address+'</field>'; 				
		ContactInformation += '<field name="Address 2">'+ contactInfo.address_2+'</field>'; 				
		ContactInformation += '<field name="City">'+ contactInfo.city+'</field>'; 					
		ContactInformation += '<field name="State">'+ contactInfo.state+'</field>'; 					
		ContactInformation += '<field name="Zip Code">'+ contactInfo.zip_code+'</field>'; 				
		ContactInformation += '<field name="Website">'+ contactInfo.website+'</field>'; 				
		ContactInformation += '<field name="Country">'+ contactInfo.country+'</field>'; 				
		ContactInformation += '<field name="Position">'+ contactInfo.position+'</field>'; 				
		ContactInformation += '<field name="Guests Attending">'+ contactInfo.guest_attending+'</field>'; 		
		//LeadandPersonDetails += '<field name="Contact Owner">'+ contactInfo.contact_owner+'</field>';			
		LeadandPersonDetails += '<field name="Birthday">'+ contactInfo.birthday+'</field>'; 				
		LeadandPersonDetails += '<field name="Person Type">'+ contactInfo.person_type+'</field>'; 			
		LeadandPersonDetails += '<field name="Contact ID">'+ contactInfo.contact_id+'</field>'; 			
		LeadandPersonDetails += '<field name="Host Company">'+ contactInfo.host_company+'</field>'; 			
		LeadandPersonDetails += '<field name="Referred By">'+ contactInfo.referred_by+'</field>'; 			
		LeadandPersonDetails += '<field name="Number of Guests">'+ contactInfo.number_of_guests+'</field>'; 		
		SequencesandTags += '<field name="Sequences">'+ contactInfo.sequences+'</field>'; 				
		SequencesandTags += '<field name="Contact Tags">*/*Salesforce SponsoredLinX'+ contactInfo.contact_tags+'</field>';
		SequencesandTags += '<field name="Contact Tags" action="final">*/*Salesforce SponsoredLinX'+ contactInfo.contact_tags+'</field>'; 			
		
		returnMap.put('ContactId', 				ContactId);
		returnMap.put('ContactInformation', 	ContactInformation);
		returnMap.put('LeadandPersonDetails',	LeadandPersonDetails);
		returnMap.put('SequencesandTags',		SequencesandTags);
		return returnMap;			
	}
	
	public List<Map<String, String>> updateContact(List<officeAutoPilot_Object> officeObject) {
		this.app_api 					= 'contact';
		this.app_reqType 				= 'update';
		this.app_xmldata				= '';
		String Contact_Id 				= '';
		String Contact_Information 		= '';
		String Lead_and_Person_Details 	= '';
		String Sequences_and_Tags 		= '';
		Map<String, String> contactDetails = new Map<String, String>();		
		for(officeAutoPilot_Object oap_Obj : officeObject) {
			System.debug('oap_Obj: '+oap_Obj);
			contactDetails					= build_Contact_Details(oap_Obj);
			System.debug('contactDetails: '+contactDetails);
			Contact_Id			 			= contactDetails.get('ContactId');
			Contact_Information 			= contactDetails.get('ContactInformation');
			Lead_and_Person_Details			= contactDetails.get('LeadandPersonDetails');
			Sequences_and_Tags	 			= contactDetails.get('SequencesandTags');

			this.app_xmldata	+= '<contact id="'+Contact_Id+'">';
			this.app_xmldata	+= '<Group_Tag name="Contact Information">';
			this.app_xmldata	+= Contact_Information;
			this.app_xmldata	+= '</Group_Tag>';
			this.app_xmldata	+= '<Group_Tag name="Lead and Person Details">';
			this.app_xmldata	+= Lead_and_Person_Details;
			this.app_xmldata	+= '</Group_Tag>';
			this.app_xmldata	+= '<Group_Tag name="Sequences and Tags">';
			this.app_xmldata	+= Sequences_and_Tags;
			this.app_xmldata	+= '</Group_Tag>';
			this.app_xmldata	+= '</contact>';
		}		
		System.debug('xmldata:'+this.app_xmldata);
		return this.sendXml();
	} 
	
	private List<Map<String, String>> sendXml() {
		
		String sendXml = '';
		sendXml += 'appid='		+this.app_id+'&';
		sendXml += 'key='		+this.app_key+'&';
		sendXml += 'reqType='	+this.app_reqType+'&';
		sendXml += 'data='		+EncodingUtil.urlEncode(this.app_xmldata,'UTF-8')+'&';
		//sendXml += 'f_add='+this.app_id;
		sendXml += 'return_id=1';
		system.debug('sendXml: '+sendXml);
		
		HttpRequest req = new HttpRequest();
                
        if (this.app_api == 'contact') {
        	req.setEndpoint(this.contactDbApi);	
        } else if (this.app_api == 'product') {
        	req.setEndpoint(this.productDbApi);	
        } else if (this.app_api == 'forms') {
        	req.setEndpoint(this.formDbApi);	
        } else {
        	//return false;
        }

        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(sendXml); 
        system.debug(req);
        
        Dom.Document doc = new Dom.Document();
        
        if (!isTest) {
	        Http h = new Http();
	        HTTPResponse res = h.send(req);
	        system.debug('res'+res);
	        system.debug('body'+res.getBody());
	        doc = res.getBodyDocument();
        } else {
        	doc.load('<result><contact id="17866"><Group_Tag name="Contact Information"><field name="First Name">Serina</field><field name="Last Name">Hingis</field><field name="E-Mail">Serina@Hingis.com.au</field><field name="Home Phone"/><field name="Title"/><field name="Office Phone"/><field name="Cell Phone">0427888111</field><field name="Fax"/><field name="Company"/><field name="Address"/><field name="Address 2"/><field name="City"/><field name="State"/><field name="Zip Code"/><field name="Website "/><field name="Country"/><field name="Position"/><field name="Guests Attending"/></Group_Tag><Group_Tag name="Lead and Person Details"><field name="Contact Owner">Ben Bradshaw International</field><field name="Birthday"/><field name="Person Type"/><field name="Contact ID"/><field name="Host Company"/><field name="Referred By">Geoff</field><field name="Number of Guests"/></Group_Tag><Group_Tag name="Sequences and Tags"><field name="Sequences">*/*</field><field name="Contact Tags">*/*Lead*/*</field><field name="Contact Tags (Raw)">4</field></Group_Tag><Group_Tag name="Affiliate Data"><field name="First Referrer"/><field name="Affiliate Program"/><field name="Last Referrer"/><field name="Number of Sales"/><field name="$ Sales">$0.00</field></Group_Tag><Group_Tag name="Lead and Personal Information"><field name="Lead Source"/><field name="Campaign"/><field name="Ad"/><field name="Media"/></Group_Tag><Group_Tag name="Most Recent Charge"><field name="Charge Amount">$0.00</field><field name="Total $ Unpaid Transactions">$0.00</field></Group_Tag><Group_Tag name="Most Recent Invoice"><field name="Invoice #"/><field name="Total Invoice Amount">$0.00</field></Group_Tag><Group_Tag name="Credit Card"><field name="Card Type"/><field name="Card Expiration Month"/><field name="Card Expiration Year"/><field name="Card Number (Last 4)"/><field name="Charge Result"/><field name="Card Expiration Date"/></Group_Tag></contact><status>Success</status></result>');	
        }
                
        Dom.XMLNode result = doc.getRootElement();
        
        List<Map<String, String>> resultids = new List<Map<String, String>>();
        Map<String, String> resultid = new Map<String, String>();
        
        for (Dom.XMLNode contact: result.getChildElements()) {
        	//system.debug('Contact: '+contact);
        	resultid = new Map<String, String>();
        	system.debug('Contact getName: '+contact.getName());
        	if(contact.getName() == 'contact') {
        		system.debug('Contact ID: '+contact.getAttribute('id', null));
        		resultid.put('id',contact.getAttribute('id', null));
        	}
        	for (Dom.XMLNode groups: contact.getChildElements()) {
        		system.debug('groups: '+groups);
        		system.debug('groups name: '+groups.getAttribute('name', null));
        		if(groups.getAttribute('name', null) == 'Lead and Person Details') {
        			
        			for (Dom.XMLNode fields: groups.getChildElements()) {
        				system.debug('fields name: '+fields.getAttribute('name', null));
        				if(fields.getAttribute('name', null) == 'Contact ID') {
        					resultid.put('salesforceid',fields.getText());
        					resultids.add(resultid);	
        				}
        			}
        		}	
        	}
        }
        system.debug('Result IDs: '+resultids);
        return resultids;
	}
	
	public static testMethod void officeAutoPilotTest() {
		String API_AppId 	= '2_2527_UggH9SlDz';
		String API_Key 		= 'bW1uOzU6ONaS5fM';
		List<officeAutoPilot_Object> contact_information = new List<officeAutoPilot_Object>();
		officeAutoPilot_Object contact = new officeAutoPilot_Object();
		
		contact_information.add(contact);
		
		officeAutoPilot_API.isTest = true;
		
		officeAutoPilot_API oapApi = new officeAutoPilot_API(API_AppId, API_Key);
		
		oapApi.updateContact(contact_information);
	}
}