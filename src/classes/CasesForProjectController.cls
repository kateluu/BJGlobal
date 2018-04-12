public with sharing class CasesForProjectController {
	private List<Cases__c> cs;
	private SFDC_Projects__c project {get; set;}
	
	public CasesForProjectController(ApexPages.StandardController controller) {
		this.project = (SFDC_Projects__c)controller.getRecord();
	}
	
	public List<Cases__c> getCs() {
		SFDC_Projects__c project = [select id, Account__c from SFDC_Projects__c where id = :project.id];
		if(project.Account__c == null) return null;
		cs = [select Id, Name, Status__c, Case_Reason__c, Priority__c, CreatedDate, CreatedById, Internal_Comments__c from Cases__c where account__c = :project.Account__c];
		return cs;
	}
	
	public static testMethod void coverageTest() {
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		Cases__c ca = new Cases__c();
		ca.account__c = acc.id;
		ca.daily_budget__c = 20;
		ca.X2012_Action_Taken_to_Save__c  = 'fdaskl';
		insert ca;
		
		SFDC_Projects__c p = new SFDC_Projects__c();
    	p.account__c = acc.id;
    	p.name = 'name';
    	p.Sold_by__c = 'ss';
    	p.Phone_Number__c = '123456789';
    	p.Email__c = 'fdas@jlkdfs.com';
    	insert p;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(p);
		CasesForProjectController cc = new CasesForProjectController(sc);
		List<Cases__c> cases = cc.getCs();
		
	}
}