@isTest
private class SeoKeywordControllerTest {
	
	@isTest static void testGetSerpHistoryChart() {
		seoThemeKeywords__c seoKeyword = setupSeoKeyword();

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoKeyword.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoKeyword);
		SeoKeywordController controller = new SeoKeywordController(stdController);

		String chartData = controller.getSerpHistoryChart();

		System.assertNotEquals(null, chartData, 'The callout returned a null response.');

		Test.stopTest();
	}


	@isTest static void testGetRankHistoryChart() {
		seoThemeKeywords__c seoKeyword = setupSeoKeyword();

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoKeyword.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoKeyword);
		SeoKeywordController controller = new SeoKeywordController(stdController);

		String chartData = controller.getRankHistoryChart();

		System.assertNotEquals(null, chartData, 'The callout returned a null response.');

		Test.stopTest();
	}

	@isTest static void testGetLandingPagesHistoryChart() {
		seoThemeKeywords__c seoKeyword = setupSeoKeyword();

        Test.startTest();

		// Load the controller
		ApexPages.currentPage().getParameters().put('id',seoKeyword.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(seoKeyword);
		SeoKeywordController controller = new SeoKeywordController(stdController);

		String chartData = controller.getLandingPagesHistoryChart();

		System.assertNotEquals(null, chartData, 'The callout returned a null response.');

		Test.stopTest();
	}

	Private Static seoThemeKeywords__c setupSeoKeyword() {
		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new consoleHttpCalloutMock());

		// Create a test SEO website
		seoWebsite__c seoWebsite = new seoWebsite__c();
		seoWebsite.Name = 'My SEO Website';
		seoWebsite.website_url__c = 'http://www.example.com.au/';
		seoWebsite.geolocation__c = 'Sydney,New South Wales,Australia';
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

        return seoKeyword;
	}	
}