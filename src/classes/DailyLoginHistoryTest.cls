@isTest(SeeAllData=true)
private class DailyLoginHistoryTest
{
	@isTest
	static void testNoLoginUser(){
		DailyLoginHistory myObj = new DailyLoginHistory();
		List<ss_NonLogin__c> items = [SELECT id FROM ss_NonLogin__c WHERE CreatedDate = TODAY ];
		SYstem.assertNotEquals(items.size(), 0,'there are is not new records');
	}
}