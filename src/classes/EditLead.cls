public with sharing class EditLead {
	public Boolean finished {get;set;}
	public Lead__c thisLead = new Lead__c();
	//public Lead thisLead{get;set;}
	public Lead__c getthisLead() {
    	return this.thisLead;
    }
    public void setthisLead(Lead__c value) {
    	this.thisLead = value;
    }
	
	public EditLead(ApexPages.StandardController controller){
		this.finished = false;
		Lead__c active = (Lead__c)controller.getRecord();
		this.thisLead = [SELECT Id,Name, Notes__c, Assigned_To__c, Assigned_To_Id__c, City__c, Company__c, Owner.FirstName, Owner.LastName, Country__c, Description__c, Email__c, First_Name__c, Followup__c, From_Source__c, From_Form__c, HTTP_Referer__c, HTTP_Useragent__c, Industry__c, IP_Address__c, Last_Name__c, Lead_Status__c, Lead_Value__c, Phone__c, Post_Code__c, Rating__c, session_id__c, Street__c, Title__c, Website__c FROM Lead__c WHERE Id=:active.Id][0];
		
	}
	public List<SelectOption> getSalespeople() {
		
		List<Account> accounts = [select Id, Name from Account where Employee_Department__c = 'Sales' and Type = 'Employee' and Active__c = true];
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--None--'));
		for(Account account : accounts){
    	    options.add(new SelectOption(account.Id,account.Name));
   		}
    	return options;
	}
	public PageReference save() {
		try{
			Account salesPerson = new Account();
			List<Account> sales = [SELECT Id,Name,Email__c FROM Account where Id =:thisLead.Assigned_To_Id__c];
			if(sales.size() > 0 ){
				salesPerson = sales[0];
				thisLead.Assigned_To__c = salesPerson.Name;
			}
		
			upsert this.thisLead;
			if(salesPerson.email__c != null){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses   = new String[] {salesPerson.email__c};
				//String[] bccAddresses  = new String[] {'william.zhang@sponsoredlinx.com'};
				mail.setToAddresses(toAddresses);
				//mail.setBccAddresses(bccAddresses);
				mail.setSenderDisplayName(Date.today().format());
				mail.setSubject('Sales Assigned');
				mail.setBccSender(false);
				mail.setUseSignature(false);
				
				string Email = '';
				if(this.thisLead.Name != null) 				Email += 'Name : ' + 			this.thisLead.Name + '<br/>';
				if(this.thisLead.Notes__c != null) 			Email += 'Notes : ' + 			this.thisLead.Notes__c + '<br/>';
				if(this.thisLead.Lead_Status__c != null) 	Email += 'Lead Status : ' + 	this.thisLead.Lead_Status__c + '<br/>';
				if(this.thisLead.First_Name__c != null) 	Email += 'First Name : ' + 		this.thisLead.First_Name__c + '<br/>';
				if(this.thisLead.Last_Name__c != null) 		Email += 'Last Name : ' + 		this.thisLead.Last_Name__c + '<br/>';
				if(this.thisLead.Company__c != null) 		Email += 'Company : ' + 		this.thisLead.Company__c + '<br/>';
				if(this.thisLead.Phone__c != null)			Email += 'Phone : ' + 			this.thisLead.Phone__c + '<br/>';
				if(this.thisLead.Email__c != null) 			Email += 'Email : ' + 			this.thisLead.Email__c + '<br/>';
				if(this.thisLead.Rating__c != null) 		Email += 'Rating : ' + 			this.thisLead.Rating__c + '<br/>';
				if(this.thisLead.Title__c != null) 			Email += 'Title : ' + 			this.thisLead.Title__c + '<br/>';
				if(this.thisLead.Street__c != null) 		Email += 'Street : ' + 			this.thisLead.Street__c + '<br/>';
				if(this.thisLead.Website__c != null) 		Email += 'Website : ' + 		this.thisLead.Website__c + '<br/>';
				if(this.thisLead.City__c != null) 			Email += 'City : ' + 			this.thisLead.City__c + '<br/>';
				if(this.thisLead.Post_Code__c != null) 		Email += 'Post Code : ' + 		this.thisLead.Post_Code__c + '<br/>';
				if(this.thisLead.Country__c != null) 		Email += 'Country : ' + 		this.thisLead.Country__c + '<br/>';
				if(this.thisLead.Industry__c != null) 		Email += 'Industry : ' + 		this.thisLead.Industry__c + '<br/>';
				if(this.thisLead.Lead_Value__c != null) 	Email += 'Lead Value : ' + 		this.thisLead.Lead_Value__c + '<br/>';
				if(this.thisLead.Description__c != null) 	Email += 'Description : ' + 	this.thisLead.Description__c + '<br/>';
				if(this.thisLead.Followup__c != null) 		Email += 'Followup : ' + 		this.thisLead.Followup__c + '<br/>';
				if(this.thisLead.Assigned_To__c != null) 	Email += 'Assigned To : ' + 	salesPerson.Name + '<br/>';
				if(this.thisLead.From_Source__c != null) 	Email += 'From Source : ' + 	this.thisLead.From_Source__c + '<br/>';
				if(this.thisLead.From_Form__c != null) 		Email += 'From Form : ' + 		this.thisLead.From_Form__c + '<br/>';
				if(this.thisLead.HTTP_Referer__c != null) 	Email += 'HTTP Referer : ' + 	this.thisLead.HTTP_Referer__c + '<br/>';
				if(this.thisLead.HTTP_Useragent__c != null) Email += 'HTTP Useragent : ' + 	this.thisLead.HTTP_Useragent__c + '<br/>';
				if(this.thisLead.IP_Address__c != null) 	Email += 'IP Address : ' + 		this.thisLead.IP_Address__c + '<br/>';
				if(this.thisLead.Session_ID__c != null) 	Email += 'Session ID : ' + 		this.thisLead.Session_ID__c + '<br/>';
				
				
				mail.setHtmlBody(Email);
		   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
	   		this.finished = true;
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		return null;
	}
    //public PageReference back() {
    	//PageReference LeadPage = new ApexPages.StandardController(this.thisLead).view();
        //LeadPage.setRedirect(true);
        //PageReference LeadView = new PageReference(/{objectprefeix}?fcf=00B90000001sHjW);
        
        //return LeadPage;
    //}
    
    public static testMethod void testEditLead(){
		Test.startTest();
		Lead__c ld = new Lead__c();
		upsert(ld);
		Account acc = new account();
		acc.name = 'test1';
		acc.Employee_Department__c = 'Sales';
		acc.Type = 'Employee';
		acc.email__c = 'bill.zhang@sponsorlinx.com';
		upsert(acc);
		ld.Assigned_To_Id__c = acc.id;
		ApexPages.standardController controller = new ApexPages.standardController(ld);
		EditLead ed = new EditLead(controller);
		ed.thisLead = ld;
		List<SelectOption> li = ed.getSalespeople();
		ed.save();
		Test.stopTest();
	}
}