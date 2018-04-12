public with sharing class SeoKeywordController {

    private String keyword_id;
    private seoThemeKeywords__c seoThemeKeyword;
    private seoWebsite__c seoWebsite;

    public SeoKeywordController(ApexPages.StandardController controller){
        // Load the keyword and website objects
        if (!Test.isRunningTest()) controller.addFields(new String[]{'Id', 'Name', 'seoWebsites__c', 'geolocation__c', 'Sniper_Date__c'});
        seoThemeKeyword = (seoThemeKeywords__c)controller.getRecord();
        
        this.seoWebsite = [SELECT Id, Name, geolocation__c, website_url__c, Searching_From__c, device__c FROM seoWebsite__c where id =: seoThemeKeyword.seoWebsites__c][0];
    }


    public String getSerpHistoryChart() {
        String chartURL = getSerpHistoryURL();
        String chartData = slxConsole.getConsolePage(chartURL);        
        return chartData;
    }
    
    public String getSerpHistoryURL() {
        String geolocation = '';

        if (seoWebsite.geolocation__c != null) {
            geolocation = seoWebsite.geolocation__c;
        }

        if (seoThemeKeyword.geolocation__c != null) {
            geolocation = seoThemeKeyword.geolocation__c;
        }
        
        return '/?c=seo&action=serpHistoryChart&keyword=' + EncodingUtil.urlEncode(seoThemeKeyword.Name, 'UTF-8') 
        + '&searchFilter='+EncodingUtil.urlEncode(seoWebsite.Searching_From__c, 'UTF-8')
        + '&geolocation='+EncodingUtil.urlEncode(geolocation, 'UTF-8')
        + '&device='+EncodingUtil.urlEncode(Utility.ifnull(seoWebsite.device__c,''), 'UTF-8')
        + '&targetDomain=' + seoWebsite.website_url__c 
        + '&keywordid=' + this.seoThemeKeyword.Id 
        + '&sniperDate=' + Utility.dateFormat(this.seoThemeKeyword.Sniper_Date__c, 'YYYY-MM-dd')
        + '&websiteid=' + EncodingUtil.urlEncode(seoThemeKeyword.seoWebsites__c, 'UTF-8');
    }
    
    public String getRankHistoryChart() {
        String chartURL = getRankHistoryURL();
        String chartData = slxConsole.getConsolePage(chartURL);
        return chartData;
    }

    public String getRankHistoryURL() {
        String geolocation = '';

        if (seoWebsite.geolocation__c != null) {
            geolocation = seoWebsite.geolocation__c;
        }

        if (seoThemeKeyword.geolocation__c != null) {
            geolocation = seoThemeKeyword.geolocation__c;
        }
        
        return '/?c=seo&action=keywordRankHistoryChart&keyword=' + EncodingUtil.urlEncode(seoThemeKeyword.Name, 'UTF-8') 
        + '&searchFilter='+EncodingUtil.urlEncode(seoWebsite.Searching_From__c, 'UTF-8')
        + '&geolocation='+EncodingUtil.urlEncode(geolocation, 'UTF-8')
        + '&device='+EncodingUtil.urlEncode(Utility.ifnull(seoWebsite.device__c,''), 'UTF-8')
        + '&targetDomain=' + seoWebsite.website_url__c 
        + '&keywordid=' + this.seoThemeKeyword.Id 
        + '&sniperDate=' + Utility.dateFormat(this.seoThemeKeyword.Sniper_Date__c, 'YYYY-MM-dd')
        + '&websiteid=' + EncodingUtil.urlEncode(seoThemeKeyword.seoWebsites__c, 'UTF-8');
    }

    public String getLandingPagesHistoryChart() {
        String chartURL = getLandingPagesHistoryChartURL();
        String chartData = slxConsole.getConsolePage(chartURL);        
        return chartData;
    }
    
    public String getLandingPagesHistoryChartURL() {
        String geolocation = '';

        if (seoWebsite.geolocation__c != null) {
            geolocation = seoWebsite.geolocation__c;
        }

        if (seoThemeKeyword.geolocation__c != null) {
            geolocation = seoThemeKeyword.geolocation__c;
        }
        
        return '/?c=seo&action=serpHistoryChart&keyword=' 
        + EncodingUtil.urlEncode(seoThemeKeyword.Name, 'UTF-8') 
        + '&sitesearch=1&searchFilter='+EncodingUtil.urlEncode(seoWebsite.Searching_From__c, 'UTF-8')
        + '&geolocation='+EncodingUtil.urlEncode(geolocation, 'UTF-8')
        + '&device='+EncodingUtil.urlEncode(Utility.ifnull(seoWebsite.device__c,''), 'UTF-8')
        + '&targetDomain=' + seoWebsite.website_url__c 
        + '&keywordid=' + this.seoThemeKeyword.Id 
        + '&sniperDate=' + Utility.dateFormat(this.seoThemeKeyword.Sniper_Date__c, 'YYYY-MM-dd')
        + '&websiteid=' + EncodingUtil.urlEncode(seoThemeKeyword.seoWebsites__c, 'UTF-8') 
        + '&maxpositions=10';
    }
}