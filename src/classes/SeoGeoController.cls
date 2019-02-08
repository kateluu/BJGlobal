public with sharing class SeoGeoController {

    public seoWebsite__c seoWebsite {get;set;}
    public boolean refreshRequired {get;set;}

    public string device {get;set;}

    public SelectOption[] selectedGeo { get; set; }
    public SelectOption[] allGeo { get; set; }


    public SeoGeoController(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) controller.addFields(new String[]{'Id', 'Name', 'Prospect_Keywords__c', 'RecordTypeId', 'website_url__c', 'Geolocation__c'});
        this.seoWebsite = (seoWebsite__c)controller.getRecord();

        this.refreshRequired = true;

        // Initialize default values
        this.device = 'desktop';

        // Generate geolocation Select Options
        selectedGeo = new List<SelectOption>();
        allGeo = new List<SelectOption>();
        
        Schema.DescribeFieldResult geoField = seoWebsite__c.Geolocation__c.getDescribe();
        List<Schema.PicklistEntry> ple = geoField.getPicklistValues();

        for( Schema.PicklistEntry f : ple){
            allGeo.add(new SelectOption(f.getValue(), f.getLabel()));
        }
    }

    // Get the options for devices
    public List<SelectOption> getDeviceOptions() {
        List<SelectOption> deviceOptions = new List<SelectOption>();
        deviceOptions.add(new SelectOption('desktop','Desktop'));
        deviceOptions.add(new SelectOption('mobile','Mobile'));

        return deviceOptions;
    }

    // Get the querystring of keyword ids for this SEO website
    private String getKeywordIdQueryString() {
        String keywordQueryString = '';

        List<seoThemeKeywords__c> seoKeywords;

        // Add the keywordids that we want the data for.
        if (ApexPages.currentPage().getParameters().get('keywordid') != null){
            // Optionally restrict to a single keyword
            seoKeywords = [SELECT Id FROM seoThemeKeywords__c WHERE seoWebsites__c = :ApexPages.currentPage().getParameters().get('id') AND Id = :ApexPages.currentPage().getParameters().get('keywordid') ORDER BY Google_Current__c];
        } else {
            // Otherwise use all keywords for this website
            seoKeywords = [SELECT Id FROM seoThemeKeywords__c WHERE seoWebsites__c = :ApexPages.currentPage().getParameters().get('id') ORDER BY Google_Current__c];
        }

        if ( seoKeywords.size() > 0 ) {
            for (seoThemeKeywords__c seoKeyword : seoKeywords){
                keywordQueryString += '&k[]=' + EncodingUtil.urlEncode(seoKeyword.Id, 'UTF-8');
            }
        }

        return keywordQueryString;
    }

    // Submit the selected geolocations
    public PageReference submit(){
        // We now allow zero geolocations, because you may want to just compare to mobile
//        if (selectedGeo.size() <= 0){
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one Geolocation to compare'));
//        }

        return null;
    }

    // Return to SEO Website page
    public PageReference cancel(){
        PageReference seoWebsitePage = new PageReference('/'+seoWebsite.Id);
        seoWebsitePage.setRedirect(true);
        return seoWebsitePage;
    }

    // Get geo comparison table
    public String getGeoTable() {
        String geoTable;

        // Build the URL for the console
        String consolePath = getGeoURL();
        
        if (consolePath != null) {
            geoTable = slxConsole.getConsolePage(consolePath);
        }

        // Check if there are any 'loading' cells in the page, so we can stop re-loading.
        if (geoTable == null || geoTable.contains('geoloading')){
            this.refreshRequired = true;
        } else {
            this.refreshRequired = false;
        }

        return geoTable;
    }

    // Get geo comparison url
    public String getGeoURL() {
        // Build the URL for the console
        String consolePath = '/seo/keywordGeoCompare?output=table&websiteid=' + EncodingUtil.urlEncode(seoWebsite.Id, 'UTF-8');

        for ( SelectOption so : selectedGeo ) {
            consolePath += '&g[]=' + EncodingUtil.urlEncode(so.getValue(), 'UTF-8');
        }

        if (seoWebsite.Geolocation__c != null){
            consolePath += '&geolocation=' + EncodingUtil.urlEncode(seoWebsite.Geolocation__c, 'UTF-8');
        }

        if (this.device == 'mobile'){
            consolePath += '&device=mobile';
        }

        String keywordQueryString = getKeywordIdQueryString();
        
        if (keywordQueryString != '') {
            consolePath += keywordQueryString;
        } else {
            return null;
        }

        return consolePath;
    }
}