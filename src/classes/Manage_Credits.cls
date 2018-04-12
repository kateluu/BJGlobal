public with sharing class Manage_Credits {
	public Account acc {get;set;}
	public list<Credit__c> RelatedCredits;
	public list<Account_Product__c> RelatedAccountProducts {get;set;}
	public Boolean Successful {get;set;}
	public Boolean generateErrors {get;set;}
	
	public Manage_Credits(ApexPages.StandardController controller){
		acc = (Account)controller.getRecord();
		boolean hasError = false;
		this.Successful = false;
		this.generateErrors = false;
	
		RelatedCredits = new list<Credit__c>();
		RelatedAccountProducts = new list<Account_Product__c>();
		
		try{
    		this.RelatedCredits = [SELECT Id,Name,Amount__c,Account_Product__c,Account_Product_Number__c,Account_Product__r.Name, Credit_Used__c,Credit_Left__c,Valid_From__c,Processed__c From Credit__c where Account__c =:acc.Id ORDER BY Name Asc];
    		if (this.generateErrors == true) { String s; s.toUpperCase(); }
    	} catch (Exception e) {
    		System.debug('Exception: '+e);
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load products');
    		ApexPages.addMessage(myMsg);
    		hasError = true;
    	}
    	try{
    		this.RelatedAccountProducts = [SELECT Id,Name, Product_Number__c From Account_Product__c where Account__c =:acc.Id];
    		if (this.generateErrors == true) { String s; s.toUpperCase(); }
    	} catch (Exception e) {
    		System.debug('Exception: '+e);
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load products');
    		ApexPages.addMessage(myMsg);
    		hasError = true;
    	}
	
	
	}
	public PageReference save() {
		update RelatedCredits;
		
		list<Invoice__c> invoice = [SELECT Id, 
											Name,
											Amount_Credited__c, 
											Account__r.Payment_Option__c,
											Account__r.Name_On_Card__c,
											Account__r.Card_Number__c, 
											Account__r.Card_CVN__c,
											Account__r.Card_Month_Expiry__c,
											Account__r.Card_Year_Expiry__c, 
											Account_Product__c, 
											Account_Product__r.OwnerId,
											Account_Product__r.Name,
											Account_Product__r.Payment_Option__c,
											Account_Product__r.Name_On_Card__c,
											Account_Product__r.Card_Number__c,
											Account_Product__r.Card_Month_Expiry__c,
											Account_Product__r.Card_Year_Expiry__c,
											Account_Product__r.Card_CVN__c, 
											Account__c, 
											Checked__c, 
											Invoice_Number__c, 
											Invoice_Total__c, 
											Amount_Paid__c, 
											Amount_Due__c, 
											Due_Date__c,
											Issue_Date__c 
									FROM Invoice__c 
									WHERE Account__c=:acc.Id 
									AND (Status__c = 'PARTIALLY PAID' or Status__c = 'AUTHORISED') 
									AND Amount_Due__c > 0
									order by
        								Issue_Date__c desc
        							];
		
		try{
			for(Invoice__c thisInvoice : invoice){
				list<Credit__c> RelatedCredits = new list<Credit__c>();
        		System.debug('Date.Today ='+date.today());
        		System.debug('thisInvoice.Account_Product__c = '+thisInvoice.Account_Product__c);
        		RelatedCredits = [SELECT Id, Name, Account__c, Account_Product__c, Credit_Used__c, Credit_Left__c, Amount__c, Valid_From__c FROM Credit__c WHERE Account_Product__c=:thisInvoice.Account_Product__c AND Valid_From__c <=:thisInvoice.Issue_Date__c AND Credit_Left__c > 0];
        		for(Credit__c thisRelatedCredit : RelatedCredits){
        			Payment__c CreditPayment = new Payment__c();
        			CreditPayment.Account__c = thisInvoice.Account__c;
					CreditPayment.Invoice_Reference__c = thisInvoice.Invoice_Number__c;
					CreditPayment.Payment_Reference__c = 'Credit from Credit ID - '+String.valueOf(thisRelatedCredit.Name);
					CreditPayment.Credit__c = thisRelatedCredit.Id;
					CreditPayment.Invoice_Number__c = thisInvoice.Invoice_Number__c;
					CreditPayment.Payment_Name__c = 'Credit Payment';
					CreditPayment.Payment_Date__c = Date.today();
					CreditPayment.Invoice__c = thisInvoice.Id;
					CreditPayment.Payment_Type__c = 'Credit';
					CreditPayment.Account_Product__c = thisInvoice.Account_product__c;
					CreditPayment.Payment_Owner__c = thisInvoice.Account_Product__r.OwnerId;
					decimal CreditLeft = thisRelatedCredit.Credit_Left__c;
					decimal InvoiceAmountDue = thisInvoice.Amount_Due__c;
					decimal InvoiceAmountPaid = thisInvoice.Amount_Paid__c;
					decimal CreditUsed = thisRelatedCredit.Credit_used__c;
					decimal InvoiceAmountCredited = thisInvoice.Amount_Credited__c;
				
					if(CreditLeft >= InvoiceAmountDue){
						CreditLeft = CreditLeft - InvoiceAmountDue;
						CreditPayment.Payment_Amount__c = InvoiceAmountDue;
						CreditUsed = CreditUsed + InvoiceAmountDue;
						InvoiceAmountDue = 0;
						InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
						InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
						thisInvoice.Status__c = 'CREDITED';
					} 
					else {
						InvoiceAmountDue = InvoiceAmountDue - CreditLeft;
						CreditPayment.Payment_Amount__c = CreditLeft;
						CreditUsed = CreditUsed + CreditLeft;
						CreditLeft = 0;
						InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
						InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
						thisInvoice.Status__c = 'PARTIALLY CREDITED';
					}
				
					thisInvoice.Amount_Due__c = InvoiceAmountDue;
					thisInvoice.Amount_Paid__c = InvoiceAmountPaid;
					thisInvoice.Amount_Credited__c = InvoiceAmountCredited;
					
					Credit__c updateCredit = new Credit__c();
					updateCredit = [SELECT Id,Credit_Used__c FROM Credit__c WHERE Id=:thisRelatedCredit.Id][0];
					updateCredit.Credit_Used__c = CreditUsed;
					update updateCredit;
					if(CreditPayment.Payment_Amount__c > 0) {
						insert CreditPayment;
						//this.PageRefresh = true;
					}
					System.debug('Before invoice update');
					update thisInvoice;
					System.debug('After invoice update'); 
					
        		}
			}
		}
		catch(Exception E){
			
		}
		
		
		//RelatedCredits = new list<Credit__c>();
		//boolean hasError = false;
		//try{
//    		this.RelatedCredits = [SELECT Id,Name,Amount__c,Account_Product__c,Account_Product__r.Name, Credit_Used__c,Valid_From__c,Processed__c From Credit__c where Account__c =:acc.Id];
    	//} catch (Exception e) {
//    		System.debug('Exception: '+e);
    		//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load products');
    		//ApexPages.addMessage(myMsg);
    		//hasError = true;
    	//}
    	this.Successful = true;
    	PageReference ManageCredits = new PageReference('/apex/Manage_Credits');
    	ManageCredits.getParameters().put('id',this.acc.id);
    	ManageCredits.setRedirect(true);
        return ManageCredits;
    	
    	
    	
    	//return null;
	}
	public list<Credit__c> getRelatedCredits() {
		return RelatedCredits;
	}
	public void setRelatedCredits(list<Credit__c> RelatedCredits) {
		this.RelatedCredits = RelatedCredits;
	}
	public List<SelectOption> getRelatedAccountProductOptions() {
		List<SelectOption> RelatedAccountProductOptions = new List<SelectOption>();
		RelatedAccountProductOptions.add(new SelectOption('','---'));
		for(Account_Product__c thisRelatedAccountProducts : RelatedAccountProducts) {
			RelatedAccountProductOptions.add(new SelectOption(thisRelatedAccountProducts.Id,thisRelatedAccountProducts.Product_Number__c + ' - ' +thisRelatedAccountProducts.Name));
		}
		return RelatedAccountProductOptions;
	}
	
		    public PageReference returnToAccount() {
    	PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }
    
    
    
    
    
   public static testMethod void testMethod1() {
    	//Account testAc = [SELECT Unique_Id__c,Name_On_Card__c,Card_Number__c,Card_Month_Expiry__c,Card_Year_Expiry__c FROM Account WHERE Name='TestAccount'][0];
    	
    	test.startTest();
    	Account testAc = new Account();
    	
    	Credit__c testCrd = new Credit__c();
    	testCrd.Amount__c = 10;
    	list<Credit__c> listTestCrd = new list<Credit__c>();
    	listTestCrd.add(testCrd);
    	insert listTestCrd;
    	
    	List<SelectOption> testOptions = new List<SelectOption>();
    	
    	ApexPages.standardController controller = new ApexPages.standardController(testAc);
    	Manage_Credits testClass = new Manage_Credits(controller);
    	
    	testClass.generateErrors = true;
    	
    	testClass.setRelatedCredits(listTestCrd);
    	testClass.getRelatedCredits();
    	testOptions = testClass.getRelatedAccountProductOptions();
    	
    	testClass.save();
    	testClass.returnToAccount();
    	test.stopTest();
    	 
    }
    
    public static testMethod void testMethod2() {
		Test.startTest();
		
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Account_Product__c prod = new Account_Product__c();
		prod.Name = 'Recurring Product';
		prod.Product_Price__c = 45;
		prod.Recurring_Frequency__c = 1;
		prod.Recurring_Period__c = 'Weekly';
		prod.Last_Invoice_Number__c = '';
        insert prod;
		
		Invoice__c inv = new Invoice__c(Name='test Invoice', Amount_Credited__c=0, Account__c=acc.Id, Status__c='AUTHORISED', Amount_Due__c = 60, Account_Product__c = prod.Id, Issue_Date__c = date.today());
    	insert inv;
    	
    	Credit__c ThisCredit = new Credit__c();
 	    ThisCredit.Valid_From__c = date.today().addDays(-1);
 	    ThisCredit.Amount__c = 50;
 	    ThisCredit.Credit_Used__c = 0;
 	    ThisCredit.Account_Product__c = prod.Id;
  	    ThisCredit.Account__c = acc.Id;
  	    
  	    list<Credit__c> listTestCrd = new list<Credit__c>();
    	listTestCrd.add(ThisCredit);
    	insert listTestCrd;
    	
  	    ApexPages.standardController controller = new ApexPages.standardController(acc);
    	Manage_Credits testClass = new Manage_Credits(controller);
    	testClass.setRelatedCredits(listTestCrd);
    	testClass.getRelatedCredits();

    	
    	testClass.save();
    	testClass.returnToAccount();
    	
    	
    	
    	testClass.save();
    	
    	Test.stopTest();
    }
    public static testMethod void testMethod3() {
		Test.startTest();
		
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Account_Product__c prod = new Account_Product__c();
		prod.Name = 'Recurring Product';
		prod.Product_Price__c = 45;
		prod.Recurring_Frequency__c = 1;
		prod.Recurring_Period__c = 'Weekly';
		prod.Last_Invoice_Number__c = '';
        insert prod;
		
		Invoice__c inv = new Invoice__c(Name='test Invoice', Amount_Credited__c=0, Account__c=acc.Id, Status__c='AUTHORISED', Amount_Due__c = 60, Account_Product__c = prod.Id, Issue_Date__c = date.today());
    	insert inv;
    	
    	Credit__c ThisCredit = new Credit__c();
 	    ThisCredit.Valid_From__c = date.today().addDays(-1);
 	    ThisCredit.Amount__c = 80;
 	    ThisCredit.Credit_Used__c = 0;
 	    ThisCredit.Account_Product__c = prod.Id;
  	    ThisCredit.Account__c = acc.Id;
  	    
  	    list<Credit__c> listTestCrd = new list<Credit__c>();
    	listTestCrd.add(ThisCredit);
    	insert listTestCrd;
    	
  	    ApexPages.standardController controller = new ApexPages.standardController(acc);
    	Manage_Credits testClass = new Manage_Credits(controller);
    	testClass.setRelatedCredits(listTestCrd);
    	testClass.getRelatedCredits();
    	
    	testClass.save();
    	testClass.returnToAccount();
    	
    	
    	
    	testClass.save();
    	
    	Test.stopTest();
    }
    
    
    
	
	
	
}