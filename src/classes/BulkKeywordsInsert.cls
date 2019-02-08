public with sharing class BulkKeywordsInsert {
	public String bulk_keywords {set; get;}
	public String keyword_suffix {set; get;}
	public String geolocation {get;set;}
	public seoThemeKeywords__c seoThemeKeyword {get;set;}
	public seoWebsite__c seoWebsite {get;set;}
	public List<seoThemeKeywords__c> seoKeywords {get;set;}
	public List<seoThemeKeywords__c> keywordSuggestions {get;set;}

	public BulkKeywordsInsert(ApexPages.StandardController controller){
		seoThemeKeyword 	= (seoThemeKeywords__c)controller.getRecord();
		
		try{
			this.seoWebsite = [select Id, Name, website_url__c, Geolocation__c FROM seoWebsite__c WHERE id =: seoThemeKeyword.seoWebsites__c][0];
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No SEO website found'));
		}

        // Add the keywordids that we want the data for
        this.seoKeywords = [
            SELECT Id, Name, Google_Current__c, Google_Volume__c
            FROM seoThemeKeywords__c 
            WHERE seoWebsites__c = :seoWebsite.Id
            ORDER BY Name ASC];

		// Load the data from the console
        this.loadExternalData();
	}
	
    // Load the data from the console
    private void loadExternalData(){
        
        String geolocation = '';

        if (seoWebsite.geolocation__c != null) {
            geolocation = seoWebsite.geolocation__c;
        }

        String consolePath = '/?c=seo&action=keywordSuggestions' 
        + '&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8')
        + '&domain=' + EncodingUtil.urlEncode(seoWebsite.website_url__c, 'UTF-8');

        system.debug('consolePath: ' + consolePath);

        String responseJson = slxConsole.getConsolePage(consolePath);

        if (responseJson == null || responseJson == '' || responseJson == '[]'){
        	return;
        }

        system.debug('responseJson: ' + responseJson);

        Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(responseJson);

		// Build a list of existing keyword names so we can check if any of the suggestions are already in it.
		// We'll rearrange each keyword so that its words are in alphabetical, so that the sequence of the words is ignored.
		// Eg "firewood sydney" and "sydney firewood" should be considered the same keyword.
        String[] keywordNames = new String[]{};
        for(seoThemeKeywords__c kw : this.seoKeywords){
        	String[] keywordWords = kw.Name.trim().toLowerCase().replace('  ', ' ').split(' ');
        	keywordWords.sort();
        	keywordNames.add(String.join(keywordWords, ' '));
        }
        system.debug('keywordNames: ' + keywordNames);

        this.keywordSuggestions = new List<seoThemeKeywords__c>();
        for(Object kw : responseObj.values()){
        	try{
	        	Map<String,Object> kwMap = (Map<String,Object>) kw;

	        	String[] keywordWords = String.valueOf(kwMap.get('keyword')).trim().toLowerCase().replace('  ', ' ').split(' ');
	        	keywordWords.sort();

	        	if (!keywordNames.contains(String.join(keywordWords, ' '))){
					seoThemeKeywords__c keyword = new seoThemeKeywords__c();
					keyword.seoWebsites__c      = this.seoThemeKeyword.seoWebsites__c;
					keyword.Name 				= String.valueOf(kwMap.get('keyword'));
					keyword.Google_Current__c   = Integer.valueOf(kwMap.get('position'));
					keyword.Google_Volume__c 	= Integer.valueOf(kwMap.get('volume'));
					this.keywordSuggestions.add(keyword);
				}
			}catch(Exception e){
				system.debug('Could not add result');
			}
		}
	}


	public PageReference save(){
		try{
			List<seoThemeKeywords__c> keywords = new List<seoThemeKeywords__c>();
			// Combine each keyword with each suffix
			for(String keyword_name : this.bulk_keywords.split('\n')){
				for(String suffix : this.keyword_suffix.split('\n')){
					String combined = keyword_name + ' ' + suffix;
					combined = combined.toLowerCase().trim();
					if(combined != ''){
						seoThemeKeywords__c keyword = new seoThemeKeywords__c();
						keyword.seoWebsites__c      = this.seoThemeKeyword.seoWebsites__c;
						keyword.Name 				= combined;

						if (this.seoThemeKeyword.Geolocation_Override__c != null && this.seoThemeKeyword.Geolocation_Override__c != this.seoWebsite.Geolocation__c){
							keyword.Geolocation_Override__c		= this.seoThemeKeyword.Geolocation_Override__c;
						}

						keywords.add(keyword);	
					}
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
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		seoWebsite__c seowebsite = new seoWebsite__c();
		seowebsite.Name = 'testwebsite';
		seowebsite.Account__c = acc.Id;
		seowebsite.Geolocation__c = 'Brisbane,Queensland,Australia';
		seowebsite.website_url__c = 'example.com';
		insert seowebsite;
		
		seoThemeKeywords__c keyword = new seoThemeKeywords__c();
		keyword.Name = 'test';
		keyword.seoWebsites__c = seowebsite.Id;

		Test.StartTest();
		
		ApexPages.standardController controller = new ApexPages.standardController(keyword);
		BulkKeywordsInsert con = new BulkKeywordsInsert(controller);
		
		con.bulk_keywords = 'test1';
		con.save();
		con.cancel();
			
		Test.stopTest();
	}
	
	public static testMethod void bulkKeywordsInsertTest1() {
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		seoWebsite__c seowebsite = new seoWebsite__c();
		seowebsite.Name = 'testwebsite';
		seowebsite.Account__c = acc.Id;
		seowebsite.Geolocation__c = 'Brisbane,Queensland,Australia';
		seowebsite.website_url__c = 'example.com';
		insert seowebsite;
		
		seoThemeKeywords__c keyword = new seoThemeKeywords__c();
		keyword.Name = 'test';
		keyword.seoWebsites__c = seowebsite.Id;

		Test.StartTest();
		
		ApexPages.standardController controller = new ApexPages.standardController(keyword);
		BulkKeywordsInsert con = new BulkKeywordsInsert(controller);
		
		con.bulk_keywords = 'test1';
		con.save();
		con.cancel();
			
		Test.stopTest();
	}

}