public with sharing class SeoWebsiteController {

    public seoWebsite__c seoWebsite {get;set;}

    public SeoWebsiteController(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) controller.addFields(new String[]{'Id', 'Name', 'Prospect_Keywords__c', 'RecordTypeId', 'website_url__c', 'Geolocation__c', 'Searching_From__c'});
        this.seoWebsite = (seoWebsite__c)controller.getRecord();
    }
    
    // Get rank history for all keywords on this SEO Website
    public String getKeywordsRankHistoryChart() {
        String chartData = '';
        
        // Build the URL for the console
        String consolePath = getKeywordsRankHistoryURL();
        
        if (consolePath != null) {
            chartData = slxConsole.getConsolePage(consolePath);
        }
        
        return chartData;
    }

    public String getKeywordsRankHistoryURL() {
        String consolePath;

        if (seoWebsite.Prospect_Keywords__c != null){
            consolePath = '/?c=seo&action=prospectKeywordRankHistoryChart' 
            + '&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8') 
            + '&domain=' + EncodingUtil.urlEncode(seoWebsite.website_url__c, 'UTF-8');
        } else {
            String keywordQueryString = getKeywordIdQueryString();

            if (keywordQueryString != '') {
                consolePath = '/?c=seo&action=keywordRankHistoryChart' 
                + '&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8') 
                + keywordQueryString;
            }
        }

        system.debug('consolePath: ' + consolePath);

        return consolePath;
    }

    // Get SEO Website average rank history chart 
    public String getRankHistoryChart() {
        String chartData = '';
        
        // Build the URL for the console
        String consolePath = getRankHistoryURL();
        
        if (consolePath != null) {
            chartData = slxConsole.getConsolePage(consolePath);
        }
        
        return chartData;
    }

    public String getRankHistoryURL() {
        String consolePath = '/?c=seo&action=websiteRankHistoryChart' 
        + '&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8');

        String keywordQueryString = getKeywordIdQueryString();
        
        if (keywordQueryString != '') {
            consolePath += keywordQueryString;
        } else {
            return null;
        }

        return consolePath;
    }

    // Get Map of sparkline data for keywords in this SEO Website
    public Map<String, String> getSparklineMap() {
        Map<String, String> mySparklines = new Map<String, String>();
        
        // Build the URL for the console
        String consolePath = '/?c=seo&action=keywordSparklineChart' 
        + '&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8');
        
        String keywordQueryString = getKeywordIdQueryString();
        
        if (keywordQueryString != '') {
            consolePath += keywordQueryString;
        
            String chartData = slxConsole.getConsolePage(consolePath);
        
            JSONParser parser = JSON.createParser(chartData);

            while (parser.nextToken() == JSONToken.START_OBJECT) {
                System.debug('getCurrentToken: ' + parser.getCurrentToken());
            
                while (parser.nextToken() != null ) {
                    if (parser.getCurrentToken() != JSONToken.END_OBJECT) {
                
                        // Entering a keyword
                        String keywordid = parser.getText();
                        String sparkline = '';
                
                        while (parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_OBJECT) {
                
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                String sparkDate = parser.getText();
                                parser.nextToken();
                                String sparkValue = parser.getText();
                                if (sparkValue == 'null') {
                                    sparkValue = ' ';
                                }
                            
                                // Add a comma between values
                                if ( sparkline != '' ) {
                                    sparkline += ', ';
                                }
                            
                                sparkline += sparkValue;
                            }
                        }
                    
                        System.debug('keywordid: ' + keywordid + ' sparkline: ' + sparkline);
                    
                        mySparklines.put(keywordid, sparkline);
                    }
                }
            }
        }
        
        return mySparklines;
    }
    
    
    // Get the querystring of keyword ids for this SEO website
    private String getKeywordIdQueryString() {
        String keywordQueryString = '';

        // Add the keywordids that we want the data for
        List<seoThemeKeywords__c> seoKeywords = [SELECT Id FROM seoThemeKeywords__c WHERE seoWebsites__c = :ApexPages.currentPage().getParameters().get('id')];

        if ( seoKeywords.size() > 0 ) {
            for (seoThemeKeywords__c seoKeyword : seoKeywords){
                keywordQueryString += '&k[]=' + EncodingUtil.urlEncode(seoKeyword.Id, 'UTF-8');
            }
        }
        
        return keywordQueryString;
    }


    // Get the map of prospect keywords
    public List<Map<String,String>> getProspectKeywordsMap() {
        List<Map<String,String>> keywords = (List<Map<String,String>>) JSON.deserialize(seoWebsite.Prospect_Keywords__c, List<Map<String,String>>.class);
        
        // Do some field modifications for the visualforce page
        for (Map<String,String> keyword : keywords){
            keyword.put('last_crawl_date', keyword.get('last_crawl_time').left(10));

            Url googleUrl = new Url(keyword.get('google_organic_url'));
            keyword.put('google_organic_url_relative', googleUrl.getPath());
        }

        return keywords;
    }

}