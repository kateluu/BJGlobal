public with sharing class ShowAllTabsController {

	public Map<String, String> tabUrlMap {get; set;}
	public Admin_page__c ap {get; set;}
	public List<SelectOption> listOptions {get; set;}
	private ApexPages.StandardController controller;
	private string adminPagePrefix {get; set;}

	public ShowAllTabsController(ApexPages.StandardController controller) {
		ap = (Admin_page__c)controller.getRecord();
		this.controller = controller; 
		tabUrlMap = new Map<String, String>{};
		listOptions = new List<SelectOption>();
		
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		for(String sObj : gd.keySet()){
		   Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
		   if (r.getKeyPrefix() != null) {
				string tempUrl = URl.getSalesforceBaseUrl().toExternalForm() + '/' + r.getKeyPrefix();
			   	tabUrlMap.put(r.getLabel(), tempUrl);
		   }
		   if(r.getLabel() == 'Admin Page') {
		   		adminPagePrefix = r.getKeyPrefix();
		   }
		}
		tabUrlMap.put('Create Account', URl.getSalesforceBaseUrl().toExternalForm()+'/apex/createAccount');

		//Map.keyset returns only a Set, you have to convert it to a List to sort it.
		Set<String> tmp = tabUrlMap.keySet();
		List<String> labels = new List<String>();
		labels.addAll(tmp);
		labels.sort();
		
		for(String label : labels) {
				listOptions.add(new SelectOption(label, label));
		}
	}

	public pageReference save () {
		ap.url__c = tabUrlMap.get(ap.Name);
		try{
			upsert(ap);
		}
		catch (Exception e){
			ApexPages.addMessages(e);
			return null;
		}
		PageReference page = new PageReference('/' + adminPagePrefix);
		return page;
	}

	public PageReference save_new () {
		ap.url__c = tabUrlMap.get(ap.Name);
		try{
			upsert(ap);
		}
		catch (Exception e){
			ApexPages.addMessages(e);
			return null;
		}
		PageReference page = new PageReference('/apex/ShowAllTabs');
		return page;
	}
	
	public PageReference redirect () {
		ID tmp = ApexPages.currentPage().getParameters().get('id');
		Admin_page__c ap = [select url__c from admin_page__c where id =: tmp];
		PageReference page = new PageReference(ap.url__c);
		return page;
	}
	
	public static testMethod void testShowAllTabs(){
		Test.startTest();
		Admin_page__c ap = new Admin_page__c();
		ApexPages.standardController controller = new ApexPages.standardController(ap);
		ShowAllTabsController sController = new ShowAllTabsController(controller);
		ap.name = 'Account';
		sController.save();
		ap.name = 'Case';
		sController.save_new();
		Test.stopTest();
	}
}