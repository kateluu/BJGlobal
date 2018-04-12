public with sharing class infusionsoft_API {
	private String app_key                  = '';
	private String app_url                  = 'https://hi122.infusionsoft.com/api/xmlrpc';
	private String app_xmldata				= '';
	public static boolean isTest 		    = false;
	
	
	public infusionsoft_API(String app_key){
		this.app_key = app_key;
	}
	
	private Map<String, String> build_Contact_Details(Map<String, String> contactInfo){
		Map<String, String> returnMap = new Map<String, String>();
		String ContactInformation = '';
		for(String argument : contactInfo.keyset()){
			if(argument != 'Infusionsoft_id'){
				ContactInformation += '<member><name>'+argument+'</name><value><string>'+contactInfo.get(argument)+'</string></value></member>';
			}
		}
		returnMap.put('ContactInformation', 	ContactInformation);
		return returnMap;
	}
	
	public Map<String, String> addContact(Map<String, String> infusionMap) {
		this.app_xmldata				   = '';
		String Contact_Information 		   = '';
		Map<String, String> contactDetails = new Map<String, String>();
		contactDetails					   = build_Contact_Details(infusionMap);
		Contact_Information 			   = contactDetails.get('ContactInformation');
		this.app_xmldata				  += '<methodCall><methodName>ContactService.add</methodName><params>';
		this.app_xmldata				  += '<param><value><string>'+this.app_key+'</string></value></param>';
		this.app_xmldata				  += '<param><value><struct>'+Contact_Information+'</struct></value></param>';
		this.app_xmldata    		      += '</params></methodCall>';
		System.debug('xmldata:'+this.app_xmldata);
		return this.sendXml();
	}
	
	public Map<String, String> updateContact(Map<String, String> infusionMap) {
		this.app_xmldata				   = '';
		String Contact_Information 		   = '';
		Map<String, String> contactDetails = new Map<String, String>();
		contactDetails					   = build_Contact_Details(infusionMap);
		Contact_Information 			   = contactDetails.get('ContactInformation');
		this.app_xmldata				  += '<methodCall><methodName>ContactService.update</methodName><params>';
		this.app_xmldata				  += '<param><value><string>'+this.app_key+'</string></value></param>';
		this.app_xmldata				  += '<param><value><int>'+infusionMap.get('Infusionsoft_Id')+'</int></value></param>';
		this.app_xmldata				  += '<param><value><struct>'+Contact_Information+'</struct></value></param>';
		this.app_xmldata    			  += '</params></methodCall>';
		System.debug('xmldata:'+this.app_xmldata);
		return this.sendXml();
	}
	
	public Map<String, String> searchContact(Map<String, String> infusionMap) {
		this.app_xmldata				   = '';
		String Contact_Information 		   = '';
		Map<String, String> contactDetails = new Map<String, String>();
		contactDetails					   = build_Contact_Details(infusionMap);
		Contact_Information 			   = contactDetails.get('ContactInformation');
		this.app_xmldata				  += '<methodCall><methodName>ContactService.findByEmail</methodName><params>';
		this.app_xmldata				  += '<param><value><string>'+this.app_key+'</string></value></param>';
		this.app_xmldata				  += '<param><value><string>'+infusionMap.get('Email')+'</string></value></param>';
		this.app_xmldata				  += '<param><value><array><data><value><string>Id</string></value></data></array></value></param>';
		this.app_xmldata    			  += '</params></methodCall>';
		System.debug('xmldata:'+this.app_xmldata);
		HttpRequest req = new HttpRequest();
        req.setEndpoint(this.app_url);	
		req.setMethod('POST');
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(this.app_xmldata); 
        system.debug(req);
        
        Dom.Document doc = new Dom.Document();
        if (!isTest) {
	        Http h = new Http();
	        HTTPResponse res = h.send(req);
	        system.debug('res'+res);
	        system.debug('body'+res.getBody());
	        doc = res.getBodyDocument();
        }else{
        	doc.load('<methodResponse><params><param><value><array><data><value><struct><member><name>Id</name><value><i4>13435</i4></value></member></struct></value></data></array></value></param></params></methodResponse>');
        }
        
       	Dom.XMLNode result = doc.getRootElement();
        System.debug('Result'+result);
        
        Map<String, String> resultid = new Map<String, String>();
        
        for (Dom.XMLNode params: result.getChildElements()) {
        	if(params.getName() == 'params') {
        		for (Dom.XMLNode param: params.getChildElements()) {
        			if(param.getName() == 'param'){
        				for (Dom.XMLNode value: param.getChildElements()) {
        					if(value.getName() == 'value'){
        						for (Dom.XMLNode arr: value.getChildElements()) {
        							if(arr.getName() == 'array'){
        								for (Dom.XMLNode da: arr.getChildElements()) {
        									if(da.getName() == 'data'){
        										for (Dom.XMLNode val: da.getChildElements()){
        											if(val.getName() == 'value'){
        												for(Dom.XMLNode struct: val.getChildElements()){
        													if(struct.getName() == 'struct'){
        														for(Dom.XMLNode member: struct.getChildElements()){
        															if(member.getName() == 'member'){
        																for(Dom.XMLNode va :member.getChildElements()){
        																	if(va.getName()  == 'value'){
        																		for (Dom.XMLNode i4: va.getChildElements()) {
												        							if(i4.getName() == 'i4'){
												        								resultid.put('Infusionsoft_Id', i4.getText());
												        							}
												        						}
        																	}
        																}
        															}
        														}
        													}
        												}
        											}
        										}
        									}
        								}
        							}
        						}
        					}
        				}
        			}
        		}
        	}
        }
        system.debug('Result IDs: '+resultid);
        return resultid;
	}
	
	public Map<String, String> applyWinBackTag(Map<String, String> infusionMap){
		this.app_xmldata				   = '';
		this.app_xmldata				  += '<methodCall><methodName>ContactService.addToGroup</methodName><params>';
		this.app_xmldata				  += '<param><value><string>'+this.app_key+'</string></value></param>';
		this.app_xmldata				  += '<param><value><int>'+infusionMap.get('Infusionsoft_Id')+'</int></value></param>';
		this.app_xmldata				  += '<param><value><int>131</int></value></param>';
		this.app_xmldata    			  += '</params></methodCall>';
		System.debug('xmldata:'+this.app_xmldata);
		return this.sendXml();
	}
	
	public Map<String, String> optIn(Map<String, String> infusionMap){
		this.app_xmldata				   = '';
		this.app_xmldata				  += '<methodCall><methodName>APIEmailService.optIn</methodName><params>';
		this.app_xmldata				  += '<param><value><string>'+this.app_key+'</string></value></param>';
		this.app_xmldata				  += '<param><value><string>'+infusionMap.get('Email')+'</string></value></param>';
		this.app_xmldata				  += '<param><value><string>'+infusionMap.get('reason')+'</string></value></param>';
		this.app_xmldata    			  += '</params></methodCall>';
		System.debug('xmldata:'+this.app_xmldata);
		return this.sendXml();
	}
	
	public Map<String, String> optOut(Map<String, String> infusionMap){
		this.app_xmldata				   = '';
		this.app_xmldata				  += '<methodCall><methodName>APIEmailService.optOut</methodName><params>';
		this.app_xmldata				  += '<param><value><string>'+this.app_key+'</string></value></param>';
		this.app_xmldata				  += '<param><value><string>'+infusionMap.get('Email')+'</string></value></param>';
		this.app_xmldata				  += '<param><value><string>'+infusionMap.get('reason')+'</string></value></param>';
		this.app_xmldata    			  += '</params></methodCall>';
		System.debug('xmldata:'+this.app_xmldata);
		return this.sendXml();
	}
	
	private Map<String, String> sendXml() {
		HttpRequest req = new HttpRequest();
        req.setEndpoint(this.app_url);	
		req.setMethod('POST');
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(this.app_xmldata); 
        system.debug(req);
        
        Dom.Document doc = new Dom.Document();
        if (!isTest) {
	        Http h = new Http();
	        HTTPResponse res = h.send(req);
	        system.debug('res'+res);
	        system.debug('body'+res.getBody());
	        doc = res.getBodyDocument();
        }else{
        	doc.load('<methodResponse><params><param><value><i4>contactIDNumber</i4></value></param></params></methodResponse>');
        }
        
       	Dom.XMLNode result = doc.getRootElement();
        System.debug('Result'+result);
        
        Map<String, String> resultid = new Map<String, String>();
        
        for (Dom.XMLNode params: result.getChildElements()) {
        	if(params.getName() == 'params') {
        		for (Dom.XMLNode param: params.getChildElements()) {
        			if(param.getName() == 'param'){
        				system.debug(param.getText());
        				for (Dom.XMLNode value: param.getChildElements()) {
        					if(value.getName() == 'value'){
        						for (Dom.XMLNode i4: value.getChildElements()) {
        							if(i4.getName() == 'i4'){
        								resultid.put('Infusionsoft_Id', i4.getText());
        							}
        						}
        					}
        				}
        			}
        		}
        	}
        }
        system.debug('Result IDs: '+resultid);
        return resultid;
	}
	
	public static testMethod void officeAutoPilotTest() {
		String API_KEY = 'testkey';
		Map<String, String> infusionMap = new Map<String, String>();
		infusionMap.put('Website', 		   'website');
        infusionMap.put('Company', 		   'account.Name');
	    infusionMap.put('Infusionsoft_Id', 'account.Infusionsoft_Id__c');
	    infusionMap.put('_ClientManager0', 'account.Owner.Name'); 
	    infusionMap.put('FirstName', 	   'contact.FirstName');
	    infusionMap.put('LastName',  	   'contact.LastName');
		
		infusionsoft_API.isTest = true;
		infusionsoft_API infsoApi = new infusionsoft_API(API_KEY);
		
	    Map<String, String>  resultsId = new Map<String, String>();
        
	    resultsId = infsoApi.addContact(infusionMap);
        resultsId = infsoApi.updateContact(infusionMap);
        resultsId = infsoApi.optIn(infusionMap);
        resultsId = infsoApi.applyWinBackTag(infusionMap);
    }
}