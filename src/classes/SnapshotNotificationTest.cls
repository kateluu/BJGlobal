@isTest
private class SnapshotNotificationTest
{

	@testSetup static void setup(){

	}

	@isTest
	static void testSuccessCase()
	{

			// create email template
			EmailTemplate e = new EmailTemplate (developerName = 'SEO Keyword Unrank Notification', HtmlValue = '', TemplateType= 'Custom', Name = 'SEO Keyword Unrank Notification');
			e.HtmlValue += '{!Snapshot_Keyword_Unrank__c.Google_Unranked_Increase_2_days__c} ';
			e.HtmlValue += '{!Snapshot_Keyword_Unrank__c.Google_Unranked_Count__c} ';
			e.HtmlValue += '{!Snapshot_Keyword_Unrank__c.Google_Unranked_Count_DaysAgo2__c} ';
			e.HtmlValue += ' {!Snapshot_Keyword_Unrank__c.Keyword_Count__c} ';
			e.HtmlValue += '{!Snapshot_Keyword_Unrank__c.Project_Owner_Name__c} ';
			e.HtmlValue += '{!Snapshot_Keyword_Unrank__c.URL__c} ';
			e.HtmlValue += '{!Snapshot_Keyword_Unrank__c.SEO_Website__c} ';

			// create Snapshot_Keyword_Unrank__c
			List<Snapshot_Keyword_Unrank__c> words = new List<Snapshot_Keyword_Unrank__c>();
			for (integer i =0; i< 5;i++){
				Snapshot_Keyword_Unrank__c word = new Snapshot_Keyword_Unrank__c();
				word.Project_Owner_Email__c = 'test' + i +'@gmail.com';
				word.Google_Unranked_Count__c = 9;
				word.Google_Unranked_Count_DaysAgo2__c = 1;
				word.Google_Unranked_Increase_2_days__c = 26.35;
				word.Project_Owner_Name__c = 'Test';
				word.Keyword_Count__c = 28;
				word.SEO_Website__c= 'http://www.abc.com.au';
				word.URL__c = 'http://www.abc.com.au';

				words.add(word);
			}
			insert words;

			SnapshotNotification myTest = new SnapshotNotification();
			System.assertNotEquals(myTest.mails.size(),0);
	}


	@isTest
	static void testFailCase()
	{
		
			// create Snapshot_Keyword_Unrank__c
			DmlException d = new DmlException();
			Test.startTest();
			SnapshotNotification myTest = new SnapshotNotification();	
			Test.stopTest();
			
			
	}

}