trigger seoKeyword_crawl on seoThemeKeywords__c (after insert, after update) {

	// If there is no last crawl date, we need to queue it for recrawling
	String keywordQueryString = '';
    for (seoThemeKeywords__c keyword : Trigger.new) {
    	if (keyword.Last_Crawl_Date__c == null) {
	    	keywordQueryString += '&k[]=' + EncodingUtil.urlEncode(keyword.Id, 'UTF-8');
	    }
    }

    if (keywordQueryString != ''){
		try {
			// We have to do an asynchronous request because triggers don't allow live callouts
	        slxConsole.getConsolePageAsync('/?c=seo&action=crawlKeywordIds' + keywordQueryString);
		} catch(exception e) {
			system.debug('Error requesting crawl: ' + e.getMessage());
		}
	}
}