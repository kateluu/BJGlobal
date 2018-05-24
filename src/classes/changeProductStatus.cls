public with sharing class changeProductStatus {
	public String productid    = System.currentPagereference().getParameters().get('productid');
	public String caseid   	   = System.currentPagereference().getParameters().get('caseid');
	public String casenumber   = System.currentPagereference().getParameters().get('case');
	public String productname {get;set;}
	public String accountname {get;set;}
	public String accountfirstname {get;set;}
	public String statusValue {get;set;}
	public String currentStatus {get;set;}
	public String emailTemplateText {get;set;}
	public Boolean renderDebugWindow {get;set;}
	public String casereason {get;set;}
	public ID accountid {get;set;}
	public Account_Product__c inputAccountProduct {get; set;}
	public String cancelEmailType {get;set;}
	public Company__c company {get; set;}
	public Boolean sendPauseEmail {get; set;}
	public Boolean isTest = false; //test flag
	public Cases__c cases {get; set;}
	
	public changeProductStatus() {
		Account_Product__c accProduct = [SELECT Name,Account__c,Product_Status__c,SLX_Product__r.company_name__c, Monthly_Price__c FROM Account_Product__c WHERE Id=:productid];
		this.accountid = accProduct.Account__c;
		Account account = [SELECT Name FROM Account WHERE Id=:this.accountid];
		this.inputAccountProduct = new Account_Product__c();
		cases = [select Case_Reason__c, Cancelled_Revenue__c from Cases__c where id =: caseid];
		this.casereason = cases.Case_Reason__c;
		this.company = [select 
							Name, 
							Customer_Service_Email__c, 
							Phone__c, 
							Website__c,
							OrgWideEmail__c
						from 
							Company__c 
						where 
							Name =: accProduct.SLX_Product__r.company_name__c];
		
		this.productname = accProduct.Name;
		this.accountname = account.Name;
		this.currentStatus = accProduct.Product_Status__c;
		
		//do a default select on radio buttons
		if (currentStatus == 'Active') {
			this.statusValue = 'Paused';
		} else {
			this.statusValue = 'Active';
		}
		this.renderDebugWindow = false;
		this.sendPauseEmail = true;
	}
	
	public List<SelectOption> getproductStatusList() {
        List<SelectOption> options = new List<SelectOption>();
        if(this.currentStatus!='Active') { options.add(new SelectOption('Active','Active')); }
        if(this.currentStatus!='Paused') { options.add(new SelectOption('Paused','Paused')); }
        if(this.currentStatus!='Cancelled') { options.add(new SelectOption('Cancelled','Cancelled')); }
        return options;
   }
   
   public List<SelectOption> getCancelEmailTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('With 2 Weeks Payable','With 2 Weeks Payable'));
        options.add(new SelectOption('Without 2 Weeks Payable','Without 2 Weeks Payable'));
        options.add(new SelectOption('No Email','No Email'));
        return options;
   }
  
   public PageReference updateStatus() {
   		this.renderDebugWindow = true;
   		Boolean hasError = false;
   		String template_content;
   		String template_subject;
   		List<Contact> contacts;
   		
   		Account_Product__c accProduct = [SELECT Id,Name,Account__c,Product_Status__c,Sold_to_Pause__c,activeat__c,pauseat__c,cancelat__c, convertCurrency(Monthly_Price__c) FROM Account_Product__c WHERE Id=:this.productid];
   		
   		if(this.statusValue == 'Active') {
   			if(inputAccountProduct.activeat__c == null){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Active At date cannot be null');
        		ApexPages.addMessage(myMsg);
	        	hasError = true;
   			} else if(inputAccountProduct.activeat__c <= Date.Today()){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Active At date cannot be ealier or equal to today');
        		ApexPages.addMessage(myMsg);
	        	hasError = true;	
   			}
   		}
	   	if(this.statusValue == 'Cancelled') {
	   		if(inputAccountProduct.cancelat__c == null){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Cancel At date cannot be null');
        		ApexPages.addMessage(myMsg);
	       		hasError = true;
   			} else if(inputAccountProduct.cancelat__c <= Date.Today()){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Cancel At date cannot be ealier or equal to today');
	       		ApexPages.addMessage(myMsg);
	       		hasError = true;	
   			}
	   	}
	   	if(this.statusValue == 'Paused') {
	   		if(inputAccountProduct.pauseat__c == null){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Pause At date cannot be null');
        		ApexPages.addMessage(myMsg);
	       		hasError = true;
   			} else if(inputAccountProduct.pauseat__c <= Date.Today()){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Pause At date cannot be ealier or equal to today');
	       		ApexPages.addMessage(myMsg);
	       		hasError = true;	
   			}
   			if(inputAccountProduct.activeat__c == null){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Active At date cannot be null');
        		ApexPages.addMessage(myMsg);
	       		hasError = true;
   			} else if(inputAccountProduct.activeat__c <= Date.Today()){
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Active At date cannot be ealier or equal to today');
        		ApexPages.addMessage(myMsg);
	       		hasError = true;	
   			}
   			if (inputAccountProduct.activeat__c <= inputAccountProduct.pauseat__c) {
   				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Active At date must be later than Pause At date');
        		ApexPages.addMessage(myMsg);
	       		hasError = true;	
   			}
	   	}
   		
   		if(hasError == false) {
   			try {
	   			if(statusValue == 'Cancelled') {
	   				accProduct.cancelat__c = inputAccountProduct.cancelat__c;	
	   				accProduct.End_Date__c = inputAccountProduct.cancelat__c;
	   				accProduct.activeat__c = null;
	   				accProduct.pauseat__c = null;
	   				if(!String.IsBlank(this.casereason) && this.casereason.contains('BTS:')){
	   					accProduct.Chargebacks__c = true;
	   				}
	   				//cases.Cancelled_Revenue__c = accProduct.Monthly_Price__c;
	   				//update cases;
	   			} else if (statusValue == 'Active') {
		   			accProduct.activeat__c = inputAccountProduct.activeat__c;
	   			} else if (statusValue == 'Paused') {
	   				accProduct.activeat__c = inputAccountProduct.activeat__c;
	   				accProduct.pauseat__c = inputAccountProduct.pauseat__c;
	   				if(!String.IsBlank(this.casereason) && this.casereason.contains('Sales: Sold to pause')){
	   					accProduct.Sold_to_Pause__c = true;
	   				}
	   			}
   			
   			
   				update accProduct;	
   			} catch(Exception e) {
	        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e.getMessage());
	        	ApexPages.addMessage(myMsg);
	        	hasError = true;
   			}
   		}
   		
   		if(hasError == false) {
   			String templatename; 
	   		try {	   			  				
	   			if(this.statusValue == 'Active') {
	   				templatename = 'product_status_change_has_been_issued';
		   		}
		   		if(this.statusValue == 'Cancelled') {
		   			if(this.cancelEmailType == 'With 2 Weeks Payable') {
		   				templatename = 'request_to_cancel_service';
		   			} else {
		   				templatename = 'request_to_cancel_service_without_2_weeks_payable';
		   			}	
		   		}
		   		if(this.statusValue == 'Paused') {
		   			if(String.valueof(accProduct.Name).containsIgnoreCase('SEO')) {
		   				templatename = 'request_to_pause_seo_service';
		   			} else {
		   				templatename = 'request_to_pause_service';
		   			}
		   		}
	   			EmailTemplate email_template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName =:templatename];
				template_content = email_template.Body;
				template_subject = email_template.Subject;
				System.debug('template_content:'+template_content);
	   		} catch(Exception e) {
	   			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load the template:'+templatename);
	        	ApexPages.addMessage(myMsg);
	   			hasError = true;
	   		}
   		}
   		   		
   		try {
			contacts = [Select Id, Name, firstName, lastName, Email From Contact Where AccountId =:this.accountid And Title = 'Billing'];
   		} catch(Exception e) {
   			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load the billing contact for '+this.accountname);
	        ApexPages.addMessage(myMsg);
   			hasError = true;
   		}
   		
   		if(hasError == false) {
			Contact contact;
			if(contacts.size() > 0) {				
				contact = contacts[0];
				
				template_content = template_content.replace('[FIRSTNAME]', 		contact.firstName);
				template_content = template_content.replace('[CASENUMBER]', 	this.casenumber);
				template_content = template_content.replace('[PRODUCTSTATUS]', 	this.statusValue);					
				template_content = template_content.replace('[PRODUCTNAME]', 	this.productname);
				template_content = template_content.replace('[COMPANY_NAME]', 	this.company.Name);
				template_content = template_content.replace('[COMPANY_PHONE]', 	this.company.phone__c);
				template_content = template_content.replace('[COMPANY_WEBSITE]', 	this.company.website__c);
				template_content = template_content.replace('[CUSTOMER_SERVICE_EMAIL]', 	this.company.customer_service_email__c);
								
				if(this.statusValue == 'Active') {	
					template_content = template_content.replace('[STATUSDATE]', 	inputAccountProduct.activeat__c.format());
					template_content = template_content.replace('[NEWSTATUS]', 		'Active');
					template_content = template_content.replace('[REACTIVATION]', 	'Your service shall automatically be resumed from ' + inputAccountProduct.activeat__c.format() + ' and your client manager will be in contact thereafter to assume management of your account once again.');
					template_content = template_content.replace('[ACCOUNTINFO]', 	this.accountname);
		   		} else if(this.statusValue == 'Cancelled') {
		   			template_content = template_content.replace('[STATUSDATE]', 	inputAccountProduct.cancelat__c.format());	
		   		} else if(this.statusValue == 'Paused') {
		   			template_content = template_content.replace('[PAUSEDATE]', 	inputAccountProduct.pauseat__c.format());
	   				template_content = template_content.replace('[REACTIVATION]', 	'Your service shall automatically be resumed from ' + inputAccountProduct.activeat__c.format() + ' and your client manager will be in contact thereafter to assume management of your account once again.');
		   		}
				System.debug('template_content:'+template_content);
				this.emailTemplateText = template_content;
								
				Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
				String[] toAddresses = new List<String>();
				if(isTest) {
					toAddresses.add('bill.zhang@sponsoredlinx.com');
				} else {
					toAddresses.add(contact.email);
				}
				mail1.setToAddresses(toAddresses);
				mail1.setReplyTo(this.company.customer_service_email__c);
				mail1.setSubject(template_subject);
				mail1.setSaveAsActivity(true);
				mail1.setUseSignature(false);
				mail1.setPlainTextBody(template_content);
				mail1.setOrgWideEmailAddressId(this.company.OrgWideEmail__c);
				
				Task task1 			= new Task();
				task1.WhoId 		= contact.Id;
				task1.WhatID 		= this.caseid;
				task1.Subject 		= 'Email:'+template_subject;
				task1.Description 	= template_content;
				task1.Type 			= 'Email';
				task1.ActivityDate 	= Date.Today();
				
				if((this.statusValue == 'Cancelled' && this.cancelEmailType == 'No Email') || (this.statusValue == 'Paused' && !this.sendPauseEmail)) {
					
				} else {
					Messaging.SendEmailResult[] results1 = Messaging.sendEmail(new Messaging.Email[] { mail1 });
					if (results1.get(0).isSuccess()) {
					    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Successfully sent product status change email to client');
	    				ApexPages.addMessage(myMsg);
	    				task1.Status = 'Completed';
	    				insert task1;	
					} else {
						ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Failed to send product status change email to client');
	    				ApexPages.addMessage(myMsg);
	    				task1.Status = 'Failed To Send';	
					}
				}
								
				EmailTemplate account_template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'product_status_change_has_been_issued'];
				String email_content = account_template.Body;
				String email_subject = account_template.Subject;
				
				if(this.statusValue == 'Active') {
					email_content = email_content.replace('[STATUSDATE]', 	inputAccountProduct.activeat__c.format());
					email_content = email_content.replace('[REACTIVATION]', '');	
		   		}

		   		if(this.statusValue == 'Paused') {
		   			email_content = email_content.replace('[STATUSDATE]', 	inputAccountProduct.pauseat__c.format());
		   			if(inputAccountProduct.activeat__c != null) {
		   				email_content = email_content.replace('[REACTIVATION]', 	'Also scheduled to reactivate product on '+inputAccountProduct.activeat__c.format());
		   				System.debug('template_content:'+email_content);
		   			} else {
		   				email_content = email_content.replace('[REACTIVATION]', '');
		   			}
		   		}

		   		if(this.statusValue == 'Cancelled') {
		   			email_content = email_content.replace('[STATUSDATE]', 	inputAccountProduct.cancelat__c.format());
		   			email_content = email_content.replace('[REACTIVATION]', '');	
		   		}

		   		email_content = email_content.replace('[NEWSTATUS]', this.statusValue);
		   		email_content = email_content.replace('[PRODUCTNAME]',this.productname);
		   		email_content = email_content.replace('[CASENUMBER]', this.casenumber);
		   		email_content = email_content.replace('[ACCOUNTINFO]', '(id:' + this.accountid + ') ' + this.accountname);
		   		email_content = email_content.replace('[COMPANY_NAME]', 	this.company.Name);
				email_content = email_content.replace('[COMPANY_PHONE]', 	this.company.phone__c);
				email_content = email_content.replace('[COMPANY_WEBSITE]', 	this.company.website__c);
				email_content = email_content.replace('[CUSTOMER_SERVICE_EMAIL]', 	this.company.customer_service_email__c);

				Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
				String[] toAddresses2 = new List<String>();
				if(isTest) {
					toAddresses2.add('devteam@sponsoredlinx.com');
				} else {
					toAddresses2.add('accounts@sponsoredlinx.com');
					toAddresses2.add('kate.lewis@sponsoredlinx.com');					
					toAddresses2.add('tracey.daken@sponsoredlinx.com');
					toAddresses2.add('monica.halim@sponsoredlinx.com');
				}
				mail2.setToAddresses(toAddresses2);
				mail2.setSubject(email_subject);
				mail2.setSaveAsActivity(true);
				mail2.setUseSignature(false);
				mail2.setPlainTextBody(email_content);
				mail2.setOrgWideEmailAddressId(this.company.OrgWideEmail__c);
				
				Task task2 			= new Task();
				task2.WhoId 		= contact.Id;
				task2.WhatID 		= this.caseid;
				task2.Subject 		= 'Email:'+email_subject;
				task2.Description 	= email_content;
				task2.Type 			= 'Email';
				task2.ActivityDate 	= Date.Today();
								
				Messaging.SendEmailResult[] results2 = Messaging.sendEmail(new Messaging.Email[] { mail2 });
				if (results2.get(0).isSuccess()) {
				    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Successfully sent product status change email to accounts');
    				ApexPages.addMessage(myMsg);
    				task2.Status = 'Completed';
    				insert task2;	
				} else {
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Failed to send product status change email to accounts');
    				ApexPages.addMessage(myMsg);
    				task2.Description += myMsg;
    				task2.Status = 'Failed To Send';
    				insert task2;	
				}
			} else {	
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load the billing contact for '+this.accountname);
	        	ApexPages.addMessage(myMsg);
			}
   		}
   		
   		if(hasError == false) {
   			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Success: Data has been updated');
	        ApexPages.addMessage(myMsg);
   		}
	   	return null;
   }
   
	public static testMethod void testchangeProductStatus() {
		Test.startTest();
		Account acc = new Account();
        acc.name = 'acc1';
        insert acc;
        
        Contact testContact = new Contact();
    	testContact.AccountId = acc.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.Email = 'test@test.com';
    	insert testContact; 
    	
    	Company__c com = new Company__c();
    	com.name = 'test company';
    	com.website__c = 'test.com';
    	com.phone__c = '101010010100';
    	com.customer_service_email__c = 'test@test.com';
    	insert com;
    	
    	Slx_Product__c product = new Slx_Product__c();
    	product.company_name__c = com.name;
    	product.product_price__c = 100;
    	insert product;
    	
        Account_product__c ap = new Account_product__c();
        ap.Account__c = acc.id;
        ap.Product_Status__c = 'Active';
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.name = 'AdWords Weekly Standard Management';
        ap.Slx_Product__c = product.id;
        insert ap;
        
        Cases__c ca = new Cases__c();
        ca.Account__c = acc.id;
        ca.Daily_Budget__c = 20;
        ca.X2012_Action_Taken_to_Save__c = 'NA';
        insert ca;
        string casename = [select name from cases__c where id = :ca.id].name;
        system.debug('*****'+casename);
		
		System.currentPagereference().getParameters().put('productid',ap.id);
		System.currentPagereference().getParameters().put('caseid',ca.id);	
		System.currentPagereference().getParameters().put('case',casename);
		
		changeProductStatus cps = new changeProductStatus();
		cps.getproductStatusList();
		
		cps.currentStatus = 'Active';
		cps.statusValue = 'Paused';
		cps.updateStatus();
		
		cps.currentStatus = 'Paused';
		cps.statusValue = 'Active';
		cps.updateStatus();
		
		cps.currentStatus = 'Active';
		cps.statusValue = 'Cancelled';
		cps.updateStatus();
		
		cps.inputAccountProduct.pauseat__c = Date.today().addDays(-1);
		cps.inputAccountProduct.activeat__c = Date.today().addDays(-5);
		cps.inputAccountProduct.cancelat__c = Date.today().addDays(-5);
		
		cps.currentStatus = 'Active';
		cps.statusValue = 'Paused';
		cps.updateStatus();
		
		cps.currentStatus = 'Paused';
		cps.statusValue = 'Active';
		cps.updateStatus();
		
		cps.currentStatus = 'Active';
		cps.statusValue = 'Cancelled';
		cps.updateStatus();
		
		cps.inputAccountProduct.pauseat__c = Date.today().addDays(1);
		cps.inputAccountProduct.activeat__c = Date.today().addDays(5);
		cps.inputAccountProduct.cancelat__c = Date.today().addDays(5);
		
		cps.currentStatus = 'Active';
		cps.statusValue = 'Paused';
		//cps.updateStatus();
		cps.statusValue = 'Cancelled';
		cps.updateStatus();
		
		cps.currentStatus = 'Paused';
		cps.statusValue = 'Active';
		cps.updateStatus();
		cps.statusValue = 'Cancelled';
		cps.updateStatus();
		
		cps.currentStatus = 'Cancelled';
		cps.statusValue = 'Active';
		cps.updateStatus();
		cps.statusValue = 'Paused';
		cps.updateStatus();
		
  		Test.stopTest();		
	}
}