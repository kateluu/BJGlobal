public with sharing class AccountProductListForProjectController {  
	private List<Account_Product__c> aps;
	private SFDC_Projects__c project {get; set;}
	
	public AccountProductListForProjectController(ApexPages.StandardController controller) {
		this.project = (SFDC_Projects__c)controller.getRecord();
	}
	
	public List<Account_Product__c> getAps() {
		SFDC_Projects__c project = [select id, Account__c from SFDC_Projects__c where id = :project.id];
		if(project.Account__c == null) return null;
		aps = [select Name,	Product_Number__c, Description__c, Product_Price__c, Recurring_Period__c, Product_Status__c, CreatedDate from Account_Product__c where account__c = :project.Account__c];
		return aps;
	}
	
	public static testMethod void coverageTest() {
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		Account_product__c ap = new Account_product__c();
		ap.Account__c = acc.id;
        ap.Product_Price__c = 69;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
		insert ap;
		
		SFDC_Projects__c p = new SFDC_Projects__c();
    	p.account__c = acc.id;
    	p.name = 'name';
    	p.Sold_by__c = 'ss';
    	p.Phone_Number__c = '123456789';
    	p.Email__c = 'fdas@jlkdfs.com';
    	insert p;
    	
    	ApexPages.standardController sc = new ApexPages.standardController(p);
		AccountProductListForProjectController con = new AccountProductListForProjectController(sc);
		List<Account_Product__c> l = con.getAps();
		
	}
}