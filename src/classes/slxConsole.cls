public class slxConsole {
    // Return contents of a page from the console
    public static String getBaseURL() {
    
        // Get the configuration from the 'SLXConsole' Login in Custom Settings.
        Login__c consoleLogin = Login__c.getInstance('SLXConsole');

        if (consoleLogin == null) {
            System.debug('Missing Login SLXConsole custom setting');
            return '';
        }

        return consoleLogin.URL__c;
    }

    // Return contents of a page from the console
    public static String getConsolePage(String path) {
    
        // Get the configuration from the 'SLXConsole' Login in Custom Settings.
        Login__c consoleLogin = Login__c.getInstance('SLXConsole');

        if (consoleLogin == null) {
            System.debug('Missing Login SLXConsole custom setting');
            return '';
        }

        String consoleEndpoint = consoleLogin.URL__c;
        String consoleUsername = consoleLogin.username__c;
        String consolePassword = consoleLogin.password__c;
        
//        System.debug('path: ' + path);
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(consoleEndpoint + path);
        req.setMethod('GET');
        req.setHeader('Cookie','username=' + consoleUsername + '; password=' + consolePassword);
        
        // Create a new http object to send the request object
        // A response object is generated as a result of the request  
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug('body: ' + res.getBody());
        
        return res.getBody();
    }

    // Call a page from the console asynchronously, (eg for use in triggers)
    @future(callout=true)
    public static void getConsolePageAsync(String path) {
    
        // Get the configuration from the 'SLXConsole' Login in Custom Settings.
        Login__c consoleLogin = Login__c.getInstance('SLXConsole');

        if (consoleLogin == null) {
            System.debug('Missing Login SLXConsole custom setting');
            return;
        }

        String consoleEndpoint = consoleLogin.URL__c;
        String consoleUsername = consoleLogin.username__c;
        String consolePassword = consoleLogin.password__c;
        
//        System.debug('path: ' + path);
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(consoleEndpoint + path);
        req.setMethod('GET');
        req.setHeader('Cookie','username=' + consoleUsername + '; password=' + consolePassword);
        
        // Create a new http object to send the request object
        // A response object is generated as a result of the request  
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('body: ' + res.getBody());
    }
}