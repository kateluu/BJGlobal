@isTest
private class SeoWebsiteServiceTest {
	
	@isTest
	Private Static void sendSeoReportTest() {
		seoWebsite__c seoWebsite = setupSeoWebsite();

        Test.startTest();

		SeoWebsiteService.sendSeoReport(seoWebsite.id);

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