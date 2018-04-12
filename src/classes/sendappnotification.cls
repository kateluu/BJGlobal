public class sendappnotification {
    //Future annotation to mark the method as async.
  @Future(callout=true)
  public static void notification(Id accid,String message) {

    Account a = [SELECT deviceid__c,BJB_Company__c FROM Account WHERE ID =: accid]; 
    //System.Debug('Test data' + a);

        //construct an HTTP request
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://clientpanel.sponsoredlinx.com.au/webservice/appnotification.php');
    req.setMethod('POST');
    string arguments = 'devicetoken=' + a.deviceid__c + '&company=' + a.BJB_Company__c + '&message=' + message;
    req.setBody(arguments);
    //send the request
    Http http = new Http();
    if (!Test.isRunningTest()){
    	HttpResponse res = http.send(req);

	    //check the response
	    if (res.getStatusCode() == 200) {
	
	    } else {
	      System.debug('Callout failed: ' + res);
	    } 
    	
    }
    
    //}
    
  }
}