public with sharing class InvoicesForProjectController {
	private List<Invoice__c> ins;
	private SFDC_Projects__c project {get; set;}
	
	public InvoicesForProjectController(ApexPages.StandardController controller) {
		this.project = (SFDC_Projects__c)controller.getRecord();
	}
	
	public List<Invoice__c> getIns() {
		SFDC_Projects__c project = [select id, Account__c from SFDC_Projects__c where id = :project.id];
		if(project.Account__c == null) return null;
	  ins = [select Id, 
					Name, 
					Invoice_Number__c, 
					Amount_Credited__c, 
					Amount_Due__c,
					Amount_Paid__c, 
					Amount_Refunded__c, 
					Due_Date__c, 
					Invoice_Total__c,
					Issue_Date__c,
					Account_Product__r.Name,
					Account_Product__c,
					Reference__c,
					Status__c							
			   from Invoice__c
			   where Status__c != ''
			   and  Issue_Date__c >= 2011-01-01
			   and  Account__c =: project.Account__c
			   order by Issue_Date__c DESC];
		return ins;
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
		
		Invoice__c inv = new Invoice__c();
		inv.name = 'test invoice';
		inv.Payment_Option__c = 'Other';
		inv.Invoice_Number__c = 'test--001';
		inv.Invoice_Batch__c = null;
		inv.Payment_Batch__c = null;
		inv.Account__c = acc.Id;
		inv.account_product__c = ap.id;
		inv.Amount_Due__c = 4.50;
		inv.Exclude_Invoice__c = true;
		inv.Exclude_Reminder__c = true;
		insert inv;
		
		SFDC_Projects__c p = new SFDC_Projects__c();
    	p.account__c = acc.id;
    	p.name = 'name';
    	p.Sold_by__c = 'ss';
    	p.Phone_Number__c = '123456789';
    	p.Email__c = 'fdas@jlkdfs.com';
    	insert p;
    	
    	
    	
    	ApexPages.standardController sc = new ApexPages.standardController(p);
		InvoicesForProjectController con = new InvoicesForProjectController(sc);
		List<Invoice__c> l = con.getIns();
		
	}
}