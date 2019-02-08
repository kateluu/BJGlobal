global class SeoWebsiteService {

    webService static Boolean sendSeoReport(String websiteid){

        // Build the URL for the console
        String consolePath = '/seo/sendSeoReport?websiteid=' + websiteid;
        
        if (consolePath == null) {
        	return false;
        }

        String resultData = slxConsole.getConsolePage(consolePath);

        return true;
    }

}