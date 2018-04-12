public with sharing class EditOpportunity {
	public SLXOpportunity__c opp {get; set;}
	public ApexPages.standardController sc = null;
	public list<SelectOption> salespersonOptions {get; set;}

	public EditOpportunity (ApexPages.StandardController controller) {
		this.opp = (SLXOpportunity__c)controller.getRecord();
		
		salespersonOptions = new list<SelectOption>{new SelectOption('','--None--')};
        for (User u : [SELECT Id, Name FROM User WHERE isActive = true AND UserRole.name IN ('Sales Manager Assistant Digital Strategy', 'Digital Strategy Sales', 'Digital Strategy Manager', 'Sales Manager Assistant SLX', 'Sales Manager Assistant GMT', 'SLX Sales') ]) {
            salespersonOptions.add( new SelectOption(u.Id, u.Name));
        }
	}
	
	public PageReference loadContactInfo() {
		if (opp.account__c != null) {
			Account acc = [select Id, Name, Website from Account where id =: opp.Account__c limit 1];
			opp.Website__c = acc.Website;
			
			try{
	            Contact c = [select Name, Phone, Email from Contact where Title = 'Marketing' and Account.Name =: acc.Name limit 1];
	   			opp.Contact_Name__c = c.Name;
	   			opp.Contact_Phone_Number__c = c.Phone;
	   			opp.Contact_Email__c = c.Email;
	        } catch (Exception e) {
	            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to load contact details');
	            ApexPages.addMessage(myMsg);
	        }
	        
	        try{
	   			Sign_Up__c signup = [select id, Daily_Budget__c from Sign_Up__c where Account__c =: acc.Id limit 1];
	   			opp.Adwords_Daily_Budget__c = signup.Daily_Budget__c;
	        } catch (Exception e) {
	            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to load sign up details');
	            ApexPages.addMessage(myMsg);
	        }
		}
        	   			
        return null;
	}
	
	public PageReference save () {
		try{
			Account acc = [SELECT Id, Name FROM Account WHERE id =: opp.Account__c LIMIT 1];
			User salesperson = [SELECT Name FROM User WHERE Id=:opp.OwnerId LIMIT 1];
			opp.Name = acc.Name;
			opp.Send_to_Salesperson__c = salesperson.Name;
			upsert(opp);
		}
		catch (Exception e){
			ApexPages.addMessages(e);
			return null;
		}
		string s = '/' + ('' + opp.get('Id')).subString(0, 3);
		return new Pagereference(s);
	}
	
	public PageReference save_new () {
		try{
			Account acc = [SELECT Id, Name FROM Account WHERE id =: opp.Account__c LIMIT 1];
			User salesperson = [SELECT Name FROM User WHERE Id=:opp.OwnerId LIMIT 1];
			opp.Name = acc.Name;
			opp.Send_to_Salesperson__c = salesperson.Name;
			upsert(opp);
		}
		catch (Exception e){
			ApexPages.addMessages(e);
			return null;
		}
		string s = '/' + ('' + opp.get('Id')).subString(0, 3) + '/e?';
		return new Pagereference(s);
	}

	
	public static testMethod void test1(){
		Account acc = new Account();
		acc.Name = 'Test Account111';
		acc.Company__c = 'SponsoredLinX';
		acc.username__c = 'test11d11@test.com';
		acc.password__c = 'test';
		insert acc;
		
		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.title = 'Marketing';
		contact.FirstName = 'bob';
		contact.LastName = 'down';
		contact.Email = 'down@bob.com';
		contact.MailingStreet='sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity='brisbane';
		contact.MailingPostalCode='4500';
		contact.MailingState='Queensland';
		contact.MailingCountry='Australia';
		insert contact;

		Test.startTest();
		SLXOpportunity__c o = new SLXOpportunity__c();
		ApexPages.standardController controller = new ApexPages.standardController(o);
		EditOpportunity oppCon = new EditOpportunity(controller);
		o.Account__c = acc.id;
		o.Product_Type__c = 'Adwords Management';
		o.Send_to_Salesperson__c = 'Gretel Phillips';
		o.website__c = 'www.test.com';
		oppCon.loadContactInfo();
		controller.save();
		Test.stopTest();
	}
	
	public static testMethod void test2(){
		Account acc = new Account();
		acc.Name = 'Test Account111';
		acc.Company__c = 'SponsoredLinX';
		acc.username__c = 'test11d11@test.com';
		acc.password__c = 'test';
		insert acc;

		Test.startTest();
		SLXOpportunity__c o = new SLXOpportunity__c();
		ApexPages.standardController controller = new ApexPages.standardController(o);
		EditOpportunity oppCon = new EditOpportunity(controller);
		o.Account__c = acc.id;
		o.Product_Type__c = 'Adwords Management';
		o.Send_to_Salesperson__c = 'Gretel Phillips';
		o.website__c = 'www.test.com';
		oppCon.loadContactInfo();
		oppCon.save_new();
		Test.stopTest();
	}
}