@isTest
private class unitTestMat { 

	static testMethod void updateProjectSeoAnalysisTest() {
		Test.startTest();
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		SFDC_Projects__c newProject = new SFDC_Projects__c();
		newProject.Account__c		= account.Id;
		newProject.Name				= 'Minnie Mouse';
		newProject.Phone_Number__c	= '0421333444';
		newProject.Email__c			= 'test@test.com';
		newProject.Sold_by__c		= 'Mickey Mouse';
		insert newProject;
		
		Report_SEO_Analysis__c newAnalysis = new Report_SEO_Analysis__c();
		newAnalysis.Name = 'test report';
		newAnalysis.Project__c = newProject.Id;
		insert newAnalysis;		
		Test.stopTest();
	}
	static testMethod void leadStatusChangeOnOppTest() {
		Test.startTest();
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		Lead__c newLead = new Lead__c();
		newLead.Name = 'test lead';
		newLead.Phone__c = '0421333444';
		insert newLead;
		SLXOpportunity__c newOpp = new SLXOpportunity__c();
		newOpp.Account__c  = account.Id;
		newOpp.SLX_Lead__c = newLead.Id;
		newOpp.Name = 'test name';
		newOpp.Website__c = 'www.test.com';
		newOpp.Adwords_Daily_Budget__c = 20;
		newOpp.Importance__c = 'Medium0';
		insert newOpp;
		Test.stopTest();	
	}
	static testMethod void accountProjectShareTest() {
		Test.startTest();
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		SFDC_Projects__c project = new SFDC_Projects__c();
		project.Name = 'test project';
		project.Account__c = account.Id;
		project.Phone_Number__c = '0421123123';
		project.Email__c = 'test@test.com';
		project.Sold_by__c = 'test sold by';
		
		insert project;
		
		
		Test.stopTest();
	}
	static testMethod void updateCaseClientManagerTest() {
		Test.startTest();
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		
		Cases__c c = new Cases__c(Case_Reason__c='test',Subject__c='test');
		c.Account__c = account.id;
		c.X2012_Action_Taken_to_Save__c = 'NA';
		insert c;
		Test.stopTest();
	}
	static testMethod void testSyncProduct(){
		Test.startTest();
		Product2 prod = new Product2();
		prod.Name 					= 'test product';
		prod.Description			= 'test product';
		prod.company_name__c 		= 'SponsoredLinX';
		prod.ProductCode 			= 'asdasd';
		prod.product_max_usage__c 	= 30;
		prod.product_package__c 	= 'Standard';
		prod.Family 				= 'Adwords';
		prod.product_period__c 		= 'Weekly';
		prod.product_recurring__c 			= 'Yes';
		prod.IsActive			= true;
		insert prod;
		PricebookEntry pbe = new PricebookEntry();
		pbe.Product2Id = prod.Id;
		pbe.Pricebook2Id = '01s90000000HUzpAAG';
		pbe.UnitPrice = 45.45;
		insert pbe;
		
		prod.IsActive = false;
		update prod;
		
		delete prod; 
		
		
		Test.stopTest();	
	}
	static testMethod void testDuplicatePromo(){
		Promocode__c newPromo1 = new Promocode__c();
		newPromo1.Name = 'newPromo';
		newPromo1.Promocode_Description__c = 'newPromo'; 
		insert newPromo1;
		Promocode__c newPromo2 = new Promocode__c();
		newPromo2.Name = 'OldPromo';
		newPromo2.Promocode_Description__c = 'OldPromo';
		insert newPromo2;
		
		newPromo1.Name = 'OldPromo';
		newPromo2.Name = 'newPromo';
		try {
			update newPromo1;
		} catch(Exception e) { } 
		try {
			update newPromo2;
			newPromo2.Promocode_Description__c = 'OldPromo';
			update newPromo2;
		} catch(Exception e) { }	
	}
	static testMethod void testsignupinsertTrigger(){
		Test.startTest();
		
		Promotions__c promotion1				= new Promotions__c();
		promotion1.Name 							= 'Test 1 Promo';
		promotion1.Promotion_Description__c 		= promotion1.Name;
		promotion1.Setup_Discount__c				= 10;
		promotion1.Setup_Discount_Type__c		= '%';
		promotion1.Management_Discount__c		= 10;
		promotion1.Management_Discount_Type__c	= '%';
		promotion1.Trial_Period__c				= 0;
		promotion1.IsActive__c					= true; 
		insert promotion1;
		
		Promocode__c promocode1 = new Promocode__c();
		promocode1.name						= 'promo1';
		promocode1.IsActive__c				= true;
		promocode1.Promocode_Description__c	= 'test promo';
		promocode1.Promotions__c			= promotion1.id;
		insert promocode1;
		
		Promotions__c promotion2				= new Promotions__c();
		promotion2.Name 							= 'Test 2 Promo';
		promotion2.Promotion_Description__c 		= promotion2.Name;
		promotion2.Setup_Discount__c				= 10;
		promotion2.Setup_Discount_Type__c		= '$';
		promotion2.Management_Discount__c		= 10;
		promotion2.Management_Discount_Type__c	= '$';
		promotion2.Trial_Period__c				= 0;
		promotion2.IsActive__c					= true; 
		insert promotion2;
		
		Promocode__c promocode2 = new Promocode__c();
		promocode2.name						= 'promo2';
		promocode2.IsActive__c				= true;
		promocode2.Promocode_Description__c	= 'test promo';
		promocode2.Promotions__c			= promotion2.id;
		insert promocode2; 
		
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode1.id, 'Yes');
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode1.id, 'No');
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode2.id, 'Yes');
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode2.id, 'No');
		
		promocode2.IsActive__c				= false;
		//update promocode2;
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode2.id, 'Yes');
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode2.id, 'No');
		
		promotion1.Setup_Discount__c			= 0;
		promotion1.Setup_Discount_Type__c		= '%';
		promotion1.Management_Discount__c		= 0;
		promotion1.Management_Discount_Type__c	= '%';
		update promotion1;
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode1.id, 'Yes');
		SendSignupToXero.getPromoPriceForProduct(50.00, promocode1.id, 'No');
		
		//Sign_Up__c s = [Select Id,Account__c from Sign_Up__c Where Account__c != null Order By CreatedDate DESC Limit 1]; 
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.title = 'Billing';
		contact.FirstName = 'bob';
		contact.LastName = 'down';
		contact.Email = 'down@bob.com';
		contact.MailingStreet='sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity='brisbane';
		contact.MailingPostalCode='4500';
		contact.MailingState='Queensland';
		contact.MailingCountry='Australia';
		insert contact;
		
		Sign_Up__c s = new Sign_Up__c();
		s.Name = 'Fred';
		s.Account__c = account.Id;
		s.Product_Family__c='AdWords';
		s.Product_Package__c='Standard Package';
 		insert s;
 		Test.stopTest();
	}
	static testMethod void testcreateProductList() {
    	createProductList products = new createProductList();
    	System.currentPagereference().getParameters().put('accid','00190000004Cehl');
    	
    	try {
    	products.init();
    	products.getproductnames();
    	products.getbuttonIsDisabled();
    	products.getAccount();
    	products.getprodobject();
    	products.addproduct();
    	} catch(Exception e) {
    	}
    }
    static testMethod void testCaseUpdatetrigger() {
    	Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		Cases__c newCase = new Cases__c();
		//id, name, OwnerId, Account_Resolution__c, Status__c, Cancellation_Date__c
		newCase.Account__c		= account.Id;	
		newCase.Status__c 		= 'Cancelled';
		newCase.Case_Origin__c 	= 'Email';
		newCase.Daily_Budget__c = Decimal.valueOf('125.50');
		newCase.X2012_Action_Taken_to_Save__c = 'NA';	
		insert newCase;
		
		newCase.Account_Resolution__c 	= 'Cancellation';
		newCase.Status__c 				= 'Unresolved';
		newCase.Have_Confirmed_to_Turn_Off_AdWords_Acct__c = true;
		update newCase;
		
	}
	static testMethod void testClosedCasesUpdate() {
    	Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		Cases__c newCase = new Cases__c();
		//id, name, OwnerId, Account_Resolution__c, Status__c, Cancellation_Date__c
		newCase.Account__c		= account.Id;	
		newCase.Status__c 		= 'Cancelled';
		newCase.Case_Origin__c 	= 'Email';
		newCase.Daily_Budget__c = Decimal.valueOf('125.50');
		newCase.X2012_Action_Taken_to_Save__c = 'NA';	
		insert newCase;
		
		newCase.Account_Resolution__c 	= 'Cancellation';
		newCase.Status__c 				= 'Closed';
		update newCase;
		
		User u1 = [SELECT Id FROM User WHERE Alias='BBrad'];
		System.RunAs(u1){
			newCase.Account_Resolution__c 	= 'Cancellation';
			newCase.Status__c 				= 'Unresolved';
			newCase.Have_Confirmed_to_Turn_Off_AdWords_Acct__c = true;
			try{
				update newCase;
			}catch(Exception e){
				system.assert(e.getMessage().contains('please contact accounts department')); 
			}	
		}
	}
	
	static testMethod void testchangeProductStatus() {
		Test.startTest();
		Account acc = new Account();
        acc.name = 'acc1';
        acc.username__c = 'testasdfasdf@asdf.com';
        insert acc;
        
        Contact testContact = new Contact();
    	testContact.AccountId = acc.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	testContact.Email = 'test@test.com';
    	testContact.Phone = '132101223';
    	insert testContact; 
    	
        Account_product__c ap = new Account_product__c();
        ap.Account__c = acc.id;
        ap.Product_Status__c = 'Active';
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.name = 'ConvertoPages Management';
        insert ap;
        
        ap.Product_Status__c = 'Paused';
        ap.pauseat__c = date.today().addDays(2);
        ap.activeat__c = date.today().addDays(3);
        update ap;

  		Test.stopTest();		
	}
	
	static testMethod void testappNotification() {
		Test.startTest();
		Account acc = new Account();
        acc.name = 'acc1';
        acc.username__c = 'testasdfasdf@asdf.com';
        acc.deviceid__c = 'testdeviceidasfasdfasdf';
        insert acc;
        
        App_Notification__c an = new App_Notification__c();
        an.Account__c = acc.Id;
        an.Push_Notifications__c = 'Your client manager just tried to call';
		insert an;
		
  		Test.stopTest();		
	}
	
}