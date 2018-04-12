public with sharing class assignOpportunity {
	public String options {get; set;}
	public SLXOpportunity__c opp {get;set;}
	
	
	
	public assignOpportunity(ApexPages.StandardController controller){
		this.opp = (SLXOpportunity__c)controller.getRecord();
			
	
	}
	
	public List<SelectOption> getSalespersons() {
		
		List<Account> accounts = [select Id, Name from Account where Employee_Department__c = 'Sales' and Type = 'Employee' and Active__c = true];
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--None--'));
		for(Account account : accounts){
    	    options.add(new SelectOption(account.Id,account.Name));
   		}
    	return options;
	}
	
	public PageReference assign(){
		try{
			System.debug(this.opp);
			this.opp.Assign_to__c = this.options;
			update this.opp;
		}catch(Exception e){
			System.debug(e.getMessage());
		}
			
		PageReference curPage = ApexPages.currentPage();
		curPage.getParameters().put('success','true');
		curPage.getParameters().put('id', this.opp.Id);
		curPage.setRedirect(true);
	   	return curPage;
	}
	
	
	public static testMethod void testassignOpp() {
		Account acc = new Account();
		acc.Employee_Department__c = 'Sales';
		acc.Type = 'Employee';
		acc.Active__c = true;
		acc.username__c = 'test123456';
		acc.password__c = '123';
		acc.Name        = 'test';
		insert acc;
		SLXOpportunity__c opp = new SLXOpportunity__c();
		ApexPages.standardController controller = new ApexPages.standardController(opp);
		assignOpportunity a = new assignOpportunity(controller);
		a.getSalespersons();
		a.assign();
	
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

}