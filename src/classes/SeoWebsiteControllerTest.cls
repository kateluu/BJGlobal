@isTest
private class SeoWebsiteControllerTest {
	
	@isTest
	Private Static void testGetRankHistoryChart() {
		seoWebsite__c seoWebsite = setupSeoWebsite();

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoWebsite.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoWebsite);
		SeoWebsiteController seoWebsiteController = new SeoWebsiteController(stdController);

		String chartData = seoWebsiteController.getRankHistoryChart();

		System.assertNotEquals(null, chartData, 'The callout returned a null response.');

		Test.stopTest();
	}


	@isTest
	Private Static void testGetKeywordsRankHistoryChart() {
		seoWebsite__c seoWebsite = setupSeoWebsite();

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoWebsite.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoWebsite);
		SeoWebsiteController seoWebsiteController = new SeoWebsiteController(stdController);

		String chartData = seoWebsiteController.getKeywordsRankHistoryChart();
		System.assertNotEquals(null, chartData, 'The callout returned a null response.');

		Test.stopTest();
	}


	@isTest
	Private Static void testGetKeywordsRankHistoryChartProspect() {
		seoWebsite__c seoWebsite = setupSeoWebsite();
		seoWebsite.Prospect_Keywords__c = '[{"keyword":"test keyword","google_organic_position":12,"google_organic_url":"http://www.example.com.au/about/","geolocation":"Sydney,New South Wales,Australia","search_filter":"","last_crawl_time":"2016-12-13 23:22:05"}]';
		update seoWebsite;

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoWebsite.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoWebsite);
		SeoWebsiteController seoWebsiteController = new SeoWebsiteController(stdController);

		String chartData = seoWebsiteController.getKeywordsRankHistoryChart();
		System.assertNotEquals(null, chartData, 'The callout returned a null response.');

		Test.stopTest();
	}


	@isTest
	Private Static void testGetProspectKeywordQueryString() {
		seoWebsite__c seoWebsite = setupSeoWebsite();

		seoWebsite.Prospect_Keywords__c = '[{"keyword":"test keyword","google_organic_position":12,"google_organic_url":"http://www.example.com.au/about/","geolocation":"Sydney,New South Wales,Australia","search_filter":"","last_crawl_time":"2016-12-13 23:22:05"}]';
		update seoWebsite;

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoWebsite.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoWebsite);
		SeoWebsiteController seoWebsiteController = new SeoWebsiteController(stdController);

		List<Map<String,String>> keywordsMap = seoWebsiteController.getProspectKeywordsMap();

		System.assertNotEquals(null, keywordsMap, 'The callout returned a null response.');

		Test.stopTest();
	}


	@isTest
	Private Static void testGetSparklineMap() {
		seoWebsite__c seoWebsite = setupSeoWebsite();

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoWebsite.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoWebsite);
		SeoWebsiteController seoWebsiteController = new SeoWebsiteController(stdController);

		Map<String, String> mySparklines = seoWebsiteController.getSparklineMap();

		System.assertNotEquals(null, mySparklines, 'The callout returned a null response.');

		Test.stopTest();
	}

	Private Static seoWebsite__c setupSeoWebsite() {
		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new consoleHttpCalloutMock());

		// Create a test SEO website
		seoWebsite__c seoWebsite = new seoWebsite__c();
		seoWebsite.Name = 'My SEO Website';
		seoWebsite.website_url__c = 'http://www.example.com.au/';
		seoWebsite.geolocation__c = 'Sydney,New South Wales,Australia';
		seoWebsite.Searching_From__c = '';
		insert seoWebsite;

		// Create a test SEO keyword
		seoThemeKeywords__c seoKeyword = new seoThemeKeywords__c();
		seoKeyword.Name = 'My keyword';
		seoKeyword.seoWebsites__c = seoWebsite.Id;
		insert seoKeyword;

		// Create a login custom setting
        Login__c consoleLogin = new Login__c();
        consoleLogin.Name = 'SLXConsole';
        consoleLogin.URL__c = 'http://ec2-52-65-47-83.ap-southeast-2.compute.amazonaws.com/';
        consoleLogin.username__c = 'salesforce';
        consoleLogin.password__c = 'mypass';
        insert consoleLogin;

        return seoWebsite;
	}
}