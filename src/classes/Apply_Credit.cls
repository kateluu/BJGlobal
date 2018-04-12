public with sharing class Apply_Credit {
	
	public Account acc {get;set;}
	public Account_Product__c SelectedAccountProduct = new Account_Product__c(); 
	public String SelectedAccountProductId {get;set;}
	public List<Account_Product__c> AccountProductList = new List<Account_Product__c>();
	public Boolean showSelectAccountProduct {get;set;}
	public Boolean showCreditDetails {get;set;}
	public Boolean showCreditCreated {get;set;}
	public List<Credit__c> SelectedAccountProductCredits = new List<Credit__c>();
	public Credit__c ThisCredit ;
	public Boolean showSelectAccountProductInitial {get;set;}
	
	public Apply_Credit(ApexPages.StandardController controller){
		acc = (Account)controller.getRecord();
		boolean hasError = false;
		
		this.showSelectAccountProductInitial = true;
		this.showSelectAccountProduct = false;
		this.showCreditDetails = false;
		this.showCreditCreated = false;
		
		try{
    		this.AccountProductList = [SELECT Id,Name,Product_Price__c,Product_Number__c, Recurring_Frequency__c, Recurring_Period__c,Last_Invoice_Number__c, CurrencyIsoCode From Account_Product__c where Account__c =:acc.Id];
    	} catch (Exception e) {
    		System.debug('Exception: '+e);
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load products');
    		ApexPages.addMessage(myMsg);
    		hasError = true;
    	}
		
	}
	
	public PageReference createCreditDetails() {
		this.showSelectAccountProductInitial = false;
		this.showSelectAccountProduct = true;
		this.showCreditDetails = true;
		this.showCreditCreated = false;
		
		try {
        	this.SelectedAccountProduct = [SELECT Id,Name,Product_Price__c,Recurring_Frequency__c,Recurring_Period__c, Last_Invoice_Date__c,SLX_Product__c,Last_Invoice_Number__c,Payment_Option__c, CurrencyIsoCode FROM Account_Product__c where Id=:this.SelectedAccountProductId];
		} catch(Exception e) {
            System.debug('Execption: '+e.getMessage());
        }
        try {
	        this.SelectedAccountProductCredits = [SELECT Id,Name,Credit_Used__c,Credit_Left__c,Valid_From__c,Processed__c,Amount__c,Account_Product__r.Name, CurrencyIsoCode FROM Credit__c where Account_Product__c=:this.SelectedAccountProduct.Id];
        } catch(Exception e) {
        	System.debug('Execption: '+e.getMessage());
        }
        
        
        //Set Default Values
		GenerateNewCreditObject();

        return null;
 	}
	
	public PageReference save() {
		boolean hasError = false;
    	if(this.ThisCredit.Amount__c < 0){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Amount needs to be possitive');
    		ApexPages.addMessage(myMsg);
    		hasError = true;
    	}
    	if(this.ThisCredit.Amount__c == 0){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Amount needs to be greater than zero');
    		ApexPages.addMessage(myMsg);
    		hasError = true;
    	}
    			
		if(!hasError){
			insert this.ThisCredit;
			GenerateNewCreditObject();
			try{
		        this.SelectedAccountProductCredits = [SELECT Id,Name,Processed__c,Amount__c,Valid_From__c,Account_Product__r.Name, Credit_Used__c, Credit_Left__c, CurrencyIsoCode FROM Credit__c where Account_Product__c=:this.SelectedAccountProduct.Id];
	        }
	        catch(Exception e) {
	        
	        }
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
	        									Account_Product__r.Name,
	        									Account_Product__r.OwnerID,
	        									Account_Product__r.Payment_Option__c,
	        									Account_Product__r.Name_On_Card__c,
	        									Account_Product__r.Card_Number__c,
	        									Account_Product__r.Card_Month_Expiry__c,
	        									Account_Product__r.Card_Year_Expiry__c,
	        									Account_Product__r.Card_CVN__c, Account__c, 
	        									Checked__c, 
	        									Invoice_Number__c, 
	        									Invoice_Total__c, 
	        									Amount_Paid__c, 
	        									Amount_Due__c, 
	        									Due_Date__c,
	        									Issue_Date__c, 
	        									Status__c, 
	        									CurrencyIsoCode 
	        								FROM Invoice__c 
	        								WHERE Account__c=:acc.Id 
	        								AND (Status__c = 'PARTIALLY PAID' or Status__c = 'AUTHORISED' or Status__c = 'PARTIALLY CREDITED') 
	        								AND Amount_Due__c > 0 
	        								order by Issue_Date__c];
		
		try{
			for(Invoice__c thisInvoice : invoice){
				list<Credit__c> RelatedCredits = new list<Credit__c>();
        		System.debug('Date.Today ='+date.today());
        		System.debug('thisInvoice.Account_Product__c = '+thisInvoice.Account_Product__c);
        		System.debug('thisInvoice.ID = '+thisInvoice.ID);
        		RelatedCredits = [SELECT Id, Name, Account__c, Account_Product__c, Credit_Used__c, Credit_Left__c, Amount__c, Valid_From__c, CurrencyIsoCode FROM Credit__c WHERE Account_Product__c=:thisInvoice.Account_Product__c AND Valid_From__c <=:thisInvoice.Issue_Date__c AND Credit_Left__c > 0];
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
					CreditPayment.CurrencyIsoCode = thisInvoice.CurrencyIsoCode;
					CreditPayment.Account_Product__c = thisInvoice.Account_Product__c; 
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
		}
		
	PageReference ApplyCreditPage = new PageReference('/apex/Apply_Credit');
        	ApplyCreditPage.getParameters().put('id',this.acc.id);
        	//MakeAPaymentPage.getParameters().put('msg','Transaction Completed');
        	ApplyCreditPage.setRedirect(true);
        	return ApplyCreditPage;
		return null;
	}
	    public PageReference returnToAccount() {
    	PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }
	public void GenerateNewCreditObject(){
		this.ThisCredit = new Credit__c();
		this.ThisCredit.Valid_From__c = date.today();
        this.ThisCredit.Amount__c = 0;
        this.ThisCredit.Credit_Used__c = 0;
        this.ThisCredit.Account_Product__c = this.SelectedAccountProduct.Id;
        this.ThisCredit.Account__c = this.acc.Id;
        this.ThisCredit.CurrencyIsoCode = this.SelectedAccountProduct.CurrencyIsoCode;
	}
	public List<SelectOption> getAccountProducts() {
		List<SelectOption> AccountProducts = new List<SelectOption>();
		if(this.showSelectAccountProductInitial)AccountProducts.add(new SelectOption('','---'));
		for(Account_Product__c thisAccountProductList : AccountProductList) {
			AccountProducts.add(new SelectOption(thisAccountProductList.Id,thisAccountProductList.Product_Number__c + ' - '+thisAccountProductList.Name));
		}
		return AccountProducts;
	}
	public Account_Product__c getSelectedAccountProduct() {
		return SelectedAccountProduct;
	}
	public void setSelectedAccountProduct(Account_Product__c SelectedAccountProduct) {
		this.SelectedAccountProduct = SelectedAccountProduct;
	}
	public Credit__c getThisCredit() {
		return ThisCredit;
	}
	public void setThisCredit(Credit__c ThisCredit) {
		this.ThisCredit = ThisCredit;
	}
	public list<Credit__c> getSelectedAccountProductCredits() {
		return SelectedAccountProductCredits;
	}
	public void setSelectedAccountProductCredits(list<Credit__c> SelectedAccountProductCredits) {
		this.SelectedAccountProductCredits = SelectedAccountProductCredits;
	}
	
	
	public static testMethod void testMethod0() {
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
		
		Invoice__c inv = new Invoice__c(Name='test Invoice', Amount_Credited__c=0, Account__c=acc.Id, Status__c='AUTHORISED', Amount_Due__c = 10, Account_Product__c = prod.Id, Issue_Date__c = date.today());
    	insert inv;
        
    	ApexPages.standardController controller = new ApexPages.standardController(acc);
    	Apply_Credit testClass = new Apply_Credit(controller);
    	testClass.createCreditDetails();
    	testClass.GenerateNewCreditObject();
    	
    	Credit__c ThisCredit = new Credit__c();
 	    ThisCredit.Valid_From__c = date.today().addDays(-1);
 	    ThisCredit.Amount__c = 50;
 	    ThisCredit.Credit_Used__c = 0;
 	    ThisCredit.Account_Product__c = prod.Id;
  	    ThisCredit.Account__c = acc.Id;
    	
    	testClass.ThisCredit = ThisCredit;
    	testClass.returnToAccount();
    	testClass.getAccountProducts();
    	testClass.getSelectedAccountProduct();
    	testClass.setSelectedAccountProduct(prod);
    	testClass.getThisCredit();
    	testClass.setThisCredit(ThisCredit);
    	testClass.getSelectedAccountProductCredits();
   
    	testClass.save();
    	
    	Test.stopTest();
    }
    
    public static testMethod void testMethod1() {
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
        
    	ApexPages.standardController controller = new ApexPages.standardController(acc);
    	Apply_Credit testClass = new Apply_Credit(controller);
    	testClass.createCreditDetails();
    	testClass.GenerateNewCreditObject();
    	
    	Credit__c ThisCredit = new Credit__c();
 	    ThisCredit.Valid_From__c = date.today().addDays(-1);
 	    ThisCredit.Amount__c = 50;
 	    ThisCredit.Credit_Used__c = 0;
 	    ThisCredit.Account_Product__c = prod.Id;
  	    ThisCredit.Account__c = acc.Id;
    	
    	testClass.ThisCredit = ThisCredit;
    	testClass.returnToAccount();
    	testClass.getAccountProducts();
    	testClass.getSelectedAccountProduct();
    	testClass.setSelectedAccountProduct(prod);
    	testClass.getThisCredit();
    	testClass.setThisCredit(ThisCredit);
    	testClass.getSelectedAccountProductCredits();
   
    	testClass.save();
    	
    	Test.stopTest();
    }
    
    public static testMethod void testMethod2() {
		Test.startTest();
		
		Account acc = new Account(name='test2',company__c='test2',username__c='test2',password__c='test2');
		insert acc;
		Contact con = new Contact(FirstName='test2',LastName='test2',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
    	ApexPages.standardController controller = new ApexPages.standardController(acc);
    	Apply_Credit testClass = new Apply_Credit(controller);
    	testClass.createCreditDetails();    	
    	testClass.GenerateNewCreditObject();
    	
    	Credit__c ThisCredit = new Credit__c();
 	    ThisCredit.Valid_From__c = date.today().addDays(-1);
 	    ThisCredit.Amount__c = -50;
 	    ThisCredit.Credit_Used__c = 0;
  	    ThisCredit.Account__c = acc.Id;
    	
    	testClass.ThisCredit = ThisCredit;
    	
    	testClass.save();
    	
    	Test.stopTest();
    }
    
    public static testMethod void testMethod3() {
		Test.startTest();
		
		Account acc = new Account(name='test2',company__c='test2',username__c='test2',password__c='test2');
		insert acc;
		Contact con = new Contact(FirstName='test2',LastName='test2',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
    	
    	ApexPages.standardController controller = new ApexPages.standardController(acc);
    	Apply_Credit testClass = new Apply_Credit(controller);
    	testClass.createCreditDetails();    	
    	testClass.GenerateNewCreditObject();
    	
    	Credit__c ThisCredit = new Credit__c();
 	    ThisCredit.Valid_From__c = date.today();
 	    ThisCredit.Amount__c = 0;
 	    ThisCredit.Credit_Used__c = 0;
  	    ThisCredit.Account__c = acc.Id;
    	
    	testClass.ThisCredit = ThisCredit;
    	
    	testClass.save();
    	
    	Test.stopTest();
    }
		
			

}