@isTest(SeeAllData=true)

private class TestClass { 

   static testMethod void myTestClass() { 
        Account a=new Account();
        a.Name='Test Account12345';
        a.username__c = 'testtest';
        a.password__c = 'teset';
        insert a;
        
        Contact contact = new Contact();
        contact.title = 'Marketing';
        contact.Email = 'Marketing@13.com';
        contact.LastName = 'Marketing';
        contact.FirstName = 'Marketing';
        contact.AccountId = a.id;        
        insert contact;

		User salesperson = [SELECT Id, Name FROM User WHERE Name = 'Gretel Phillips' LIMIT 1];
        
        SLXOpportunity__c o=new SLXOpportunity__c();
        o.Name='Test Account';
        o.Product_Type__c = 'Email marketing';
        o.OwnerId = salesperson.Id;
        o.Send_to_Salesperson__c = salesperson.Name;
        o.Account__c = a.Id;   
        o.Website__c = 'www.test.com'; 
        o.Adwords_Daily_Budget__c = 20;
        o.importance__c = 'Medium';
        insert o;
		
		o.Status__c  = 'Closed Lost';
		update o;
    }
    
    private static testMethod void testDeleteNote() {
    		account acc = new account();
    		acc.name = 'testNoteEditTrigger1';
    		insert acc;
    		note n = new note();
    		n.ParentId = acc.id;
            n.title = 'testnote1';
		    insert n;
		    delete n;
    }
        
     private static testMethod void testUpdateNote() {
    		account acc = new account();
    		acc.name = 'testNoteEditTrigger2';
    		insert acc;
    		note n = new note();
    		n.ParentId = acc.id;
            n.title = 'testnote2';
            insert n;
	   		n.title = 'updatedtitle';
		    update n;
    }
    
    private static testMethod void testCaseDelete () {
    	account acc = new account();
    	acc.name = 'test';
    	insert acc;
    	Cases__c c = new Cases__c();
    	c.Account__c = acc.id;
    	c.Daily_Budget__c = 10;
    	c.status__c = 'New';
    	c.X2012_Action_Taken_to_Save__c = 'NA';
    	insert c;
    	
    	delete c;
    }
    
    private static testMethod void testSignupNoteInsert () {
    	account acc = new account();
    	acc.name = 'test';
    	insert acc;
    	Sign_Up__c s = new Sign_Up__c();
		s.Name = 'Fred';
		s.Account__c = acc.Id;
		s.Product_Family__c='AdWords';
		s.Product_Package__c='Standard Package';
 		insert s;
 		
 		Sign_Up_note__c signupnote = new Sign_up_note__c();
 		signupnote.Sign_Up__c = s.id;
 		signupnote.contact_person__c = 'test';
 		signupnote.Agreed_daily_budget__c = 50;
 		signupnote.Agreed_target_locations__c = 'Brisbane';
 		signupnote.Areas_covered_in_healthcheck__c = 'ctr';
 		signupnote.Campaign_start_date__c = Date.today();
 		signupnote.Current_adwords_account__c = '123234234';
 		signupnote.Adwords_Id__c = '000-000-0000';
    	signupnote.Current_daily_budget__c = 40;
    	signupnote.Healthcheck_done__c = true;
    	signupnote.How_would_you_best_describe_the_client__c = 'assertive';
    	signupnote.Industry__c = 'Accounting';
    	signupnote.Position_in_the_company__c = 'gm';
    	signupnote.What_two_areas_are_most_important_to_cli__c = 'More sales and leads';
    	
    	insert signupnote;
    }
    
    //test EditLead Trigger
    private static testMethod void testEditLeadTrigger() {
		Account acc = new account();
		acc.name = 'test1';
		acc.Employee_Department__c = 'Sales';
		acc.Type = 'Employee';
		acc.email__c = 'bill.zhang@sponsorlinx.com';
		upsert(acc);
		
		Lead__c ld = new Lead__c();
		ld.name = 'test lead';
		ld.Phone__c = '11111111';
		ld.Assigned_To_Id__c = acc.id;
		insert(ld);
		
		Account acc2 = new account();
		acc2.name = 'test2';
		acc2.Employee_Department__c = 'Sales';
		acc2.Type = 'Employee';
		acc2.email__c = 'bill.zhang@sponsorlinx.com';
		upsert(acc2);
		
		ld.Assigned_To_Id__c = acc2.id;
		ld.Notes__c = 'test';
		ld.First_Name__c='will';
		ld.Last_name__c = 'zhang';
		ld.Company__c = 'test';
		ld.Email__c = 'test@test.com';
		ld.Rating__c = 'test';
		ld.Title__c = 'test';
		ld.Street__c = 'test';
		ld.Website__c = 'test';
		ld.From_Source__c = 'test';
		ld.HTTP_Referer__c = 'test';
		ld.Post_Code__c = 1235;
		ld.Industry__c = 'test';
		ld.Lead_Value__c = 50;
		ld.Followup__c = date.today();
		ld.Lead_Status__c = 'test';
		ld.HTTP_Useragent__c = 'test';
		ld.IP_Address__c = '123.123.123.123';
		upsert(ld);
    }
    
    //test caseUpsert trigger change account product owner section
    private static testMethod void testCaseUpsertOwnerChange() {
		Account acc = new account();
		acc.name = 'test1';
		acc.email__c = 'bill.zhang@sponsorlinx.com';
		upsert(acc);
		
		Contact con = new Contact();
		con.title = 'Billing';
		con.firstName = 'bill';
		con.lastName = 'zhang';
		con.accountId = acc.id;
		upsert(con);
		
		Account_Product__c ap = new Account_Product__c();
		ap.ownerId = UserInfo.getUserId();
		ap.Product_Price__c = 49;
		ap.account__c = acc.id;
		ap.product_status__c = 'Active';
		ap.recurring_period__c = 'Weekly';
		upsert(ap); 
		
		User u = [select id from user where name like 'Amber%' limit 1];
		
		Cases__c ca = new Cases__c();
		ca.X2012_Action_Taken_to_Save__c = 'blah blah';
		ca.Client_Manager_Reassign__c = true;
		ca.Reassign_To__c = u.id;
		ca.account__c = acc.id;
		upsert(ca);
		
		Account_Product__c ap1 = [select ownerId from Account_Product__c where id =: ap.id limit 1];
		Account acc1 = [select ownerId from Account where id =: acc.id limit 1];
		
		system.assertEquals(ap1.ownerId, u.id);
		system.assertEquals(acc1.ownerId, u.id);
    }
    
    public static testMethod void ForecastRevenueTest() {
		Profile p = [SELECT Id FROM Profile WHERE Name='SLX Client Operations Manager'];
		UserRole r = [select Id from UserRole where Name='SLX (Aus) Client Operations Manager'];
	    User u = new User(Alias = 'standt', Email='test@sponsoredlinx.com', 
	    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	    LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
	    TimeZoneSidKey='America/Los_Angeles', UserName='test@sponsoredlinx.com');
			
	    System.runAs(u) {
	       	System.debug('Current User: ' + UserInfo.getUserName());
	       	System.debug('Current Profile: ' + UserInfo.getProfileId()); 
	       
   			Account acc = new Account();
			acc.Name = 'Test Account';
			acc.Company__c = 'SponsoredLinX';
			acc.username__c = 'test@test.com';
			acc.password__c = 'test';
			insert acc;
			
			Account_product__c ap = new Account_product__c();
			ap.Account__c = acc.id;
			ap.Ownerid = u.Id; 
			ap.name = 'Adwords';
	        ap.Product_Price__c = 500.0;
	        ap.Recurring_Period__c ='Weekly';
	        ap.Payment_Option__c = 'Eway';
	        ap.product_status__c = 'Active';
			insert ap;
			
			ForecastRevenue con = new ForecastRevenue();
			con.selectedCM = 'My Team';
			con.loadCMs();
	    }
		
	}
	
}