public with sharing class Utility {

    // Get the current user's IP address
    public static String getUserIPAddress() {
        string ReturnValue = '';

        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        
        if (ReturnValue == '' || ReturnValue == null) {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)

        if (ReturnValue == '' || ReturnValue == null) {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
            
        return ReturnValue;
    }

    // Generate a random string, eg for passwords
    public static String generateRandomString(Integer len) {
        // list all possible characters, similar looking characters and vowels have been removed
        final String chars = '23456789bcdfghjkmnpqrstvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    // Convert number to zero if it is null
    public static Integer zerofy(Integer myNumber){
        return (myNumber == null) ? 0 : myNumber;
    }
    public static Decimal zerofy(Decimal myNumber){
        return (myNumber == null) ? 0 : myNumber;
    }
    public static Long zerofy(Long myNumber){
        return (myNumber == null) ? 0 : myNumber;
    }

    // replace arg1 with arg2, if arg1 is null
    public static string ifnull(string s1,string s2) {
        string result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }

    // Format a Date using the formats that are available to DateTime
    public static string dateFormat(Date myDate, string format){
        if (myDate == null){
            return '';
        } else {
            return DateTime.newInstance(myDate, Time.newInstance(0,0,0,0)).format(format);
        }
    }

    // Check if we're running the sandbox
    public static Boolean runningInASandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    // Get a map from an sObject list, indexed by a field
    public static Map<String, sObject> getSObjectMap(String indexField, List<sObject> objList){
        Map<String, sObject> objMap = new Map<String, sObject>();
        for ( sObject obj : objList ){
            objMap.put((String)obj.get(indexField), obj);
        }
        return objMap;
    }

    // Send an email to sysadmin (eg to notify of an error)
    public static boolean notifySysadmin(String subject, String body){
        String[] recipients = New String[] {'devteam@sponsoredlinx.com'};
        
        return Utility.sendEmail(recipients, subject, body);
    }


    // Send a simple plaintext email
    public static boolean sendEmail(String[] recipients, String subject, String body){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // In the sandbox, send all messages to the dev team
        if ( utility.runningInASandbox() ){
            recipients = New String[] {'brendan.west@sponsoredlinx.com'};
        }

        mail.setToAddresses(recipients);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return true;
    }

    // Check if a list contains a value
    public static boolean ListFind(List<String> a, String b){
        Set<String> tempSet = new Set<String>();
        tempSet.addAll(a);
        return tempSet.contains(b);
    }

    // Convert a querystring into a map of name/value pairs
    public static Map<String, String> createMapFromQueryString(String queryString) {
        Map<String,String> params = new Map<String,String>();

        System.PageReference pageReference = new System.PageReference('/?' + queryString);
        params = pageReference.getParameters();

        return params;
    }

    // Convert a querystring into a map of name/value pairs
    public static String createQueryStringFromMap(Map<String, String> params) {

        String queryString  = '';
        for (String key :params.keySet()) {
            if (queryString.length() > 0){
                queryString += '&';
            }

            String value = params.get(key);
            if (value == null){
                system.debug('Warning: value for ' + key + ' is null');
                value = '';
            }

            queryString += key + '=' + EncodingUtil.urlEncode(value, 'UTF-8');
        }

        return queryString;
    }
}