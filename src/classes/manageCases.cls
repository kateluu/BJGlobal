public with sharing class manageCases {
	public Cases__c thisCase = new Cases__c(); 
	public Cases__c lookupCase = new Cases__c();
	public List<String> SelectedRefundInvoices {get;set;}
	public List<String> SelectedCreditInvoices {get;set;}
	public List<String> SelectedAccountProducts {get;set;}
	
	public List<Account_Product__c> accountProductList = new List<Account_Product__c>();
	public Boolean renderList {get;set;}
	public Boolean renderMsg {get;set;}
	public string updatedMsg{get;set;}
	//public list<string> SelectedAccountProducts {get;set;}	
			
			
	public PageReference accountChanged(){
		getRefundInvoices();
		getCreditInvoices();
		getAccountProducts();
		return null;
	}
	public List<SelectOption> getAccountProducts() {
		List<SelectOption> options = new List<SelectOption>();
		List<Account_Product__c> AccountProducts = new List<Account_Product__c>();
		if(thisCase.Account__c != null){
			AccountProducts = [SELECT Id,Name,Account__c, Product_Number__c FROM Account_Product__c WHERE Account__c =:thisCase.Account__c];
		}
		for(Account_Product__c AccountProduct : AccountProducts){
			options.add(new SelectOption(AccountProduct.Id,AccountProduct.Product_Number__c + ' - ' + AccountProduct.Name));
		}
		return options;
	}
	
	public List<SelectOption> getRefundInvoices() {
		System.debug('Test');
    	List<SelectOption> options = new List<SelectOption>();
    	List<Invoice__c> Invoices = new List<Invoice__c>();
    	if(thisCase.Account__c != null){
    		System.debug('Test2');
    		Invoices = [SELECT Id,Name,Account_Product__r.Product_Number__c, Invoice_Number__c,Account__c, Account_Product__r.Name, Status__c, Issue_Date__c FROM Invoice__c WHERE Account__c =:thisCase.Account__c];
    	} 
    	try{
    	for(Invoice__c Invoice : Invoices){
       		options.add(new SelectOption(Invoice.Invoice_Number__c,Invoice.Invoice_Number__c + ' - ' + Invoice.Account_Product__r.Product_Number__c + ' - ' + Invoice.Issue_Date__c.format() + ' - ' + Invoice.Status__c + ' - ' + Invoice.Account_Product__r.Name));    	
	 	}
    	}
    	catch(Exception E){}
    	return options;
	}
	public List<SelectOption> getCreditInvoices() {
		System.debug('Test');
    	List<SelectOption> options = new List<SelectOption>();
    	List<Invoice__c> Invoices = new List<Invoice__c>();
    	if(thisCase.Account__c != null){
    		System.debug('Test2');
    		Invoices = [SELECT Id,Name,Invoice_Number__c,Account__c, Account_Product__r.Product_Number__c, Issue_Date__c, Status__c, Account_Product__r.Name  FROM Invoice__c WHERE Account__c =:thisCase.Account__c];
    	} 
    	try{
    	for(Invoice__c Invoice : Invoices){
       		options.add(new SelectOption(Invoice.Invoice_Number__c,Invoice.Invoice_Number__c + ' - ' + Invoice.Account_Product__r.Product_Number__c + ' - ' + Invoice.Issue_Date__c.format() + ' - ' + Invoice.Status__c + ' - ' + Invoice.Account_Product__r.Name));
    	
	 	}
    	}
    	catch(Exception E){
    		
    	}
    	return options;
	}
		
	
	public Cases__c getthisCase() {
		return this.thisCase;
	}
	public void setthisCase(Cases__c value) {
		this.thisCase = value;
	}
	public Cases__c getlookupCase() {
		return this.lookupCase;
	}
	public void setlookupCase(Cases__c value) {
		this.lookupCase = value;
	}
	
	public manageCases(ApexPages.StandardController controller){
		
	
		
		
		
	}
	public void openCase() {
		List<Cases__c>selectCases = new List<Cases__c>();
		System.Debug('Previous case id = ' + this.lookupCase.X2012_Related_to_previous_case__c);
		System.Debug('Id = ' + this.lookupCase.Id);
		selectCases = [Select SEO_Package__c, X2012_Website_URL__c,Account_Products_List__c, X2012_Void_Invoice_s__c, X2012_Related_to_previous_case__c, X2012_Refund_Invoice_s__c, X2012_Original_Request_Date__c, X2012_Final_Action_FOR_MANAGERS__c, X2012_E_mail_or_Phone_Summary__c, X2012_Cancellation_Waiver_approved__c, X2012_Cancellation_Waiver_Requested__c, X2012_CM_Proposed_Action__c, X2012_CM_Comments__c, X2012_Action_Taken_to_Save__c, X2012_2_Weeks_Notice_to_be_applied__c, SystemModstamp, Subject__c, Status__c, Solution__c, Sales_Person__c, Refund_Amount__c, Reassign_To__c, Priority__c, OwnerId, Owner.FirstName, Owner.LastName, Offered_Senior_Client_Manager__c, Offered_Credit__c, Offered_2_Weeks_Free_Management__c, Offered_1_Weeks_Free_Management__c, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Internal_Comments__c, Id, Downgrade__c, Downgrade_Amount__c, Description__c, Daily_Budget__c, Credit_Amount__c, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Competitor__c, Client_Manager__c, Client_Manager_Reassign__c, Client_Manager1__c, Case_Resolution__c, Case_Reason__c, Case_Origin__c, CaseType__c, Cancellation_Date__c, Billing_Resolution__c, Account__c, Account_Resolution__c, Account_2__c, Refund_Invoices_Start_Date__c, Refund_Invoices_End_Date__c, Credit_Invoices_Start_Date__c, Credit_Invoices_End_Date__c, Credit_Invoices_List__c, Refund_Invoices_List__c, Final_Action_Timestamp__c From Cases__c WHERE Id=:this.lookupCase.X2012_Related_to_previous_case__c Limit 1];
		try{
			this.thisCase = selectCases[0]; 
		}
		catch(Exception E){
			
		}
		this.selectCase();
	}
	public PageReference selectCase(){ 
		
		//accountChanged();
		if(this.thisCase.Refund_Invoices_List__c != null) this.SelectedRefundInvoices = this.thisCase.Refund_Invoices_List__c.split(',');
		if(this.thisCase.Credit_Invoices_List__c != null) this.SelectedCreditInvoices = this.thisCase.Credit_Invoices_List__c.split(',');
		if(this.thisCase.Account_Products_List__c != null) this.SelectedAccountProducts = this.thisCase.Account_Products_List__c.split(',');
		
		this.updateProductList();
		
		
	
		
			
		
		
		return null;
	}
	
	public PageReference updateProductList(){
		
		//			Cases__c activeCase = (Cases__c)controller.getRecord();
		Cases__c cases = new Cases__c();
		System.debug('Case opened = '+cases.Id);
		try{
		//cases = [SELECT Id,Name,Account_Products_List__c FROM Cases__c WHERE Id=:activeCase.Id][0];
		cases = this.thisCase;
		}
		catch(Exception E){
		}
		//if(this.thisCase.Account_Products_List__c != null)	this.SelectedAccountProducts = this.thisCase.Account_Products_List__c.split(',');
		if(this.SelectedAccountProducts != null){
					this.thisCase.Account_Products_List__c = '';
		for(string SelectedAccountProduct: this.SelectedAccountProducts){
			this.thisCase.Account_Products_List__c += SelectedAccountProduct + ',';
		}
		}
		Account_Product__c TempAccountProduct = new Account_Product__c(); 
		this.accountProductList = new list<Account_Product__c>();
		try {
			//this.accountProductList = [SELECT Name,Description__c,Product_Number__c,Product_Price__c,Product_Status__c,Recurring_Frequency__c,Recurring_Period__c,Start_Date__c,CreatedDate,activeat__c,pauseat__c,cancelat__c FROM Account_Product__c WHERE Account__c=:cases.Account__c];
			for(string thisAccountProductId : SelectedAccountProducts){
				try{
				TempAccountProduct = [SELECT Name,Description__c,Product_Number__c,Product_Price__c,Product_Status__c,Recurring_Frequency__c,Recurring_Period__c,Start_Date__c,CreatedDate,activeat__c,pauseat__c,cancelat__c FROM Account_Product__c WHERE Id=:thisAccountProductId][0];
				this.accountProductList.add(TempAccountProduct);
				}
				catch(Exception E){
					
				}
			}
			if(this.accountProductList.size()>0){
				this.renderList = true;
				this.renderMsg = false;					
			} else {
				this.renderList = false;
				this.renderMsg = true;
			}		
		} catch(Exception e) {}
		return null;
	}
	public PageReference saveCase(){
		this.thisCase.Refund_Invoices_List__c = '';
		for(string SelectedRefundInvoice: this.SelectedRefundInvoices){
			this.thisCase.Refund_Invoices_List__c += SelectedRefundInvoice + ',';
		}
		this.thisCase.Credit_Invoices_List__c = '';
		for(string SelectedCreditInvoice: this.SelectedCreditInvoices){
			this.thisCase.Credit_Invoices_List__c += SelectedCreditInvoice + ',';
		}
		this.thisCase.Account_Products_List__c = '';
		for(string SelectedAccountProduct: this.SelectedAccountProducts){
			this.thisCase.Account_Products_List__c += SelectedAccountProduct + ',';
		}
		if(this.thisCase.Cancellation_Date__c == NULL){
				this.thisCase.Cancellation_Date__c = date.today();	
			}
		upsert this.thisCase;
		this.openCase();
		return null;
	}
	public void updateFinalActionTimestamp(){
		this.thisCase.Final_Action_Timestamp__c = DateTime.now();
	}
		public List<Account_Product__c> getaccountProductList() {
		return this.accountProductList;
	}
	public PageReference clear() {
		this.updatedMsg = 'Changes not saved';
		
		return null;
	}
	public PageReference save() {
		this.updatedMsg = 'Updated';
		update this.accountProductList;
		return null;
	}
	public static testMethod void testaccountProductList() {
		Test.startTest();
		
		Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		ApexPages.standardController controller = new ApexPages.standardController(new Cases__c(Account__c=account.Id,Description__c='dfdfd'));
		
		accountProductList apl = new accountProductList(controller);
		apl.getaccountProductList();
		
		
		Test.stopTest();
	}
	
	public static testMethod void testMethod1() {
    Test.startTest();
    
    	 	Account testAcc = new Account();
    	//Account testAc = [SELECT Unique_Id__c,Name_On_Card__c,Card_Number__c,Card_Month_Expiry__c,Card_Year_Expiry__c FROM Account WHERE Name='TestAccount'][0];
    	testAcc.Name = 'Test';
    	testAcc.Payment_Option__c = 'Eway';
    	testAcc.Name_On_Card__c = 'test';
    	testAcc.Card_Number__c = '1234123412341234';
    	testAcc.Card_Month_Expiry__c = '5';
    	testAcc.Card_Year_Expiry__c = '1010';
    	testAcc.Card_CVN__c = '123';
    	insert testAcc;
    	
    	Cases__c testCase = new Cases__c();
    	testCase.Account__c = testAcc.Id;
    	testCase.X2012_Action_Taken_to_Save__c = 'NA';
    	insert testCase;
    	
    	Invoice__c testInv = new Invoice__c();
    	testInv.Amount_Due__c = 100;
    	testInv.Amount_Paid__c = 50;
    	testInv.Account__c = testAcc.Id;
    	testInv.Status__c = 'AUTHORISED';
    	testInv.Invoice_Number__c = 'abc123';
    	insert testInv;
    	
    	Account_Product__c testAccPr = new Account_Product__c();
	    testAccPr.Product_Price__c = 10;
	    testAccPr.Account__c = testAcc.Id;
	    insert testAccPr;
    	 //INVOICE -- WHERE Account__c=:acc.Id AND (Status__c = 'PARTIALLY PAID' or Status__c = 'AUTHORISED') AND Amount_Due__c > 0
    
    
	    ApexPages.standardController controller = new ApexPages.standardController(testAcc);
	    manageCases testClass = new manageCases(controller);
	    testClass.thisCase = testCase;
	    //testClass.accountChanges();
	    testClass.getAccountProducts();
	    testClass.getRefundInvoices();
	    testClass.getthisCase();
	    testClass.getlookupCase();
	    testClass.openCase();
	    //testClass.saveCase();
	    testClass.updateFinalActionTimestamp();
	    testClass.accountChanged();
	    testClass.getCreditInvoices();
	    //testClass.setthisCase(value)
	    string test1 = 'test';
	    string test2 = 'test2';
	    list<String> testString = new list<String>();
	    testString.add(test1);
	    testString.add(test2);
	    testClass.SelectedRefundInvoices = testString;
	    testClass.SelectedCreditInvoices = testString;
	    
	    
	    testClass.SelectedAccountProducts = testString;
	    testClass.getaccountProductList();
	    //testClass.SelectedAccountProducts.add(test2);
	    testClass.saveCase();
	    testClass.clear();
	    testClass.save();
	    
	    Test.stopTest();
	    
	}

}