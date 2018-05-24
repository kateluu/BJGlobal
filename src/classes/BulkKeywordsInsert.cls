public with sharing class BulkKeywordsInsert {
	public String bulk_keywords {set; get;}
	public String geolocation {get;set;}
	public seoThemeKeywords__c seoThemeKeyword {get;set;}
	public seoWebsite__c seoWebsite {get;set;}

	public BulkKeywordsInsert(ApexPages.StandardController controller){
		seoThemeKeyword 	= (seoThemeKeywords__c)controller.getRecord();
		
		try{
			this.seoWebsite = [select Id, Name, Geolocation__c FROM seoWebsite__c WHERE id =: seoThemeKeyword.seoWebsites__c][0];
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No SEO website found'));
		}
	}
	
	public PageReference save(){
		try{
			String[] keywords_array = this.bulk_keywords.split('\n');
			List<seoThemeKeywords__c> keywords = new List<seoThemeKeywords__c>();
			for(String keyword_name : keywords_array){
				if(keyword_name.trim() != ''){
					seoThemeKeywords__c keyword = new seoThemeKeywords__c();
					keyword.seoWebsites__c      = this.seoThemeKeyword.seoWebsites__c;
					keyword.Name 				= keyword_name;

					if (this.seoThemeKeyword.Geolocation_Override__c != null && this.seoThemeKeyword.Geolocation_Override__c != this.seoWebsite.Geolocation__c){
						keyword.Geolocation_Override__c		= this.seoThemeKeyword.Geolocation_Override__c;
					}

					keywords.add(keyword);	
				}
			}
			insert keywords;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'why not working here? '+e));
			return null;
		}
		PageReference seoWebsitePage = new PageReference('/'+this.seoThemeKeyword.seoWebsites__c);
        seoWebsitePage.setRedirect(true);
        return seoWebsitePage;
	}
	
	public PageReference cancel(){
		PageReference seoWebsitePage = new PageReference('/'+this.seoThemeKeyword.seoWebsites__c);
        seoWebsitePage.setRedirect(true);
        return seoWebsitePage;
	}
	
	public static testMethod void bulkKeywordsInsertTest() {
		Test.StartTest();
		
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		seoWebsite__c seowebsite = new seoWebsite__c();
		seowebsite.Name = 'testwebsite';
		seowebsite.Account__c = acc.Id;
		insert seowebsite;	
		
		seoThemeKeywords__c keyword = new seoThemeKeywords__c();
		keyword.Name = 'test';
		keyword.seoWebsites__c = seowebsite.Id;
		
		ApexPages.standardController controller = new ApexPages.standardController(keyword);
		BulkKeywordsInsert con = new BulkKeywordsInsert(controller);
		
		con.bulk_keywords = 'test1';
		con.save();
		con.cancel();
			
		Test.stopTest();
	}
	
	public static testMethod void bulkKeywordsInsertTest1() {
		Test.StartTest();
		
		seoThemeKeywords__c keyword = new seoThemeKeywords__c();
		
		ApexPages.standardController controller = new ApexPages.standardController(keyword);
		BulkKeywordsInsert con = new BulkKeywordsInsert(controller);
		
		con.bulk_keywords = 'test1';
		con.save();
		con.cancel();
			
		Test.stopTest();
	}

}