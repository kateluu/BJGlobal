public with sharing class SeoCompetitorController {

	public seoWebsite__c seoWebsite {get;set;}
    public List<Competitor_Website__c> competitorList {get;set;}
    public Competitor_Website__c newCompetitor {get;set;}
    public List<seoThemeKeywords__c> seoKeywords {get;set;}

    private Map<String, Object> responseObj;

    public SeoCompetitorController(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) controller.addFields(new String[]{'Id', 'Name', 'Prospect_Keywords__c', 'RecordType.Name', 'website_url__c', 'Geolocation__c', 'Searching_From__c', 'Last_Crawl_Completed_Date__c'});
        this.seoWebsite = (seoWebsite__c)controller.getRecord();

        this.competitorList = [SELECT Name FROM Competitor_Website__c WHERE SEO_Website__c = :seoWebsite.Id];

        // Add the keywordids that we want the data for
        this.seoKeywords = [
            SELECT Id, Name, Google_Current__c, Google_Volume__c, Google_Title__c, Google_Snippet__c, Google_Pos_1_URL__c, Google_Pos_1_Title__c, Google_Pos_1_Snippet__c, Geolocation_Effective__c
            FROM seoThemeKeywords__c 
            WHERE seoWebsites__c = :seoWebsite.Id
            ORDER BY Google_Current__c ASC];

        newCompetitor = new Competitor_Website__c();

		// Load the data from the console
        this.loadExternalData();
	}
    
    // Add a competitor
    public PageReference addRow(){

    	this.competitorList.add(newCompetitor);

		// Reload the data from the console
        this.loadExternalData();

        // Insert the record (must come after the callout)
    	newCompetitor.SEO_Website__c = seoWebsite.Id;
        insert newCompetitor;

		// Reset so another new record can be added
        newCompetitor = new Competitor_Website__c();

        return null;
    }
    
    // Delete a competitor for this website
    public PageReference delRow(){
        String competitorId = apexpages.currentpage().getparameters().get('competitorId');

        if (competitorId != null){
			for(Integer i = competitorList.size() - 1; i >= 0; i--) {
	        	if (competitorList[i].Id == competitorId){
	        		this.competitorList.remove(i);
	        	}
	        }

			// Reload the data from the console
	        this.loadExternalData();

			// Delete the record (must come after the callout)
			delete [SELECT Id, Name FROM Competitor_Website__c WHERE Id = :competitorId AND SEO_Website__c = :seoWebsite.Id];
		}

		return null;
    }

    // Load the data from the console
    private void loadExternalData(){
        // Build the URL for the console
        String consolePath = getDataURL();
        
        system.debug('consolePath: ' + consolePath);

        if (consolePath != null) {
            String responseJson = slxConsole.getConsolePage(consolePath);

            system.debug('responseJson: ' + responseJson);

	        this.responseObj = (Map<String, Object>) JSON.deserializeUntyped(responseJson);

	        system.debug('responseObj: ' + responseObj);
	    }
	}

    public String getDataURL() {
        String geolocation = '';

        if (seoWebsite.geolocation__c != null) {
            geolocation = seoWebsite.geolocation__c;
        }

        String consolePath = '/seo/keywordCompetitors' 
        + '?searchFilter='+EncodingUtil.urlEncode(seoWebsite.Searching_From__c, 'UTF-8')
        + '&geolocation='+EncodingUtil.urlEncode(geolocation, 'UTF-8')
        + '&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8')
        + '&domain=' + EncodingUtil.urlEncode(seoWebsite.website_url__c, 'UTF-8');

        if (seoWebsite.Last_Crawl_Completed_Date__c != null){
            consolePath += '&date=' + Utility.dateFormat(seoWebsite.Last_Crawl_Completed_Date__c, 'YYYY-MM-dd');
        }

        // Add the keywordids that we want the data for
        for (Competitor_Website__c competitor : this.competitorList){
        	if (competitor.Name != null){
	            consolePath += '&cd[]=' + EncodingUtil.urlEncode(competitor.Name, 'UTF-8');
	        }
        }

        String keywordQueryString = getKeywordIdQueryString();
        
        if (keywordQueryString != '') {
            consolePath += keywordQueryString;
        } else {
            return null;
        }

        return consolePath;
    }

    // Get SEO Website competitor comparison table
    public String getDomainChart() {
        String chartData = '';
        
        if (this.responseObj != null){
	        chartData = (String) this.responseObj.get('domainChart');
	    }
        
        return chartData;
    }

    // Get SEO Website competitor comparison table
    public Map<String, Map<String, Integer>> getCompetitorKeywords() {
        Map<String, Map<String, Integer>> keywordList = new Map<String, Map<String, Integer>>();
        
        if (this.responseObj != null){
	        Map<String, Object> keywordsResponse = (Map<String, Object>) this.responseObj.get('keywords');

	        if (keywordsResponse != null){
		        for (seoThemeKeywords__c seoKeyword : this.seoKeywords){
			        Map<String, Object> keywordResponse = (Map<String, Object>) keywordsResponse.get(seoKeyword.Name.toLowerCase());

			        Map<String, Integer> keywordDomains = new Map<String, Integer>();
			        for (Competitor_Website__c competitor : this.competitorList){
			        	Integer domainRank;

				        if (keywordResponse == null){
				        	domainRank = 0;
				        } else {
				        	domainRank = (Integer) keywordResponse.get(competitor.Name.toLowerCase());

				        	if (domainRank == null){
				        		domainRank = 100;
				        	}
				        }

			            keywordDomains.put(competitor.Name, domainRank);
			        }

			        keywordList.put(seoKeyword.Name, keywordDomains);
			    }
			}
	    }
        
        return keywordList;
    }

    // Return to SEO Website page
    public PageReference cancel(){
        PageReference seoWebsitePage = new PageReference('/'+seoWebsite.Id);
        seoWebsitePage.setRedirect(true);
        return seoWebsitePage;
    }

    // Get the querystring of keyword ids for this SEO website
    private String getKeywordIdQueryString() {
        String keywordQueryString = '';

        for (seoThemeKeywords__c seoKeyword : this.seoKeywords){
            keywordQueryString += '&k[]=' + EncodingUtil.urlEncode(seoKeyword.Id, 'UTF-8');
        }
        
        return keywordQueryString;
    }
}