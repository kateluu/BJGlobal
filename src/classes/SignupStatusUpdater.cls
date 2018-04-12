public class SignupStatusUpdater {

  //Future annotation to mark the method as async.
  @Future(callout=true)
  public static void updateStatus(Id accid) {

    Account a = [SELECT deviceid__c,BJB_Company__c FROM Account WHERE ID =: accid]; 
    //System.Debug('Test data' + a);

        //construct an HTTP request
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://ec2-54-206-77-183.ap-southeast-2.compute.amazonaws.com/webservice/TestNotifications.php');
    req.setMethod('POST');
    string arguments = 'devicetoken=' + a.deviceid__c + '&company=' + a.BJB_Company__c;
    req.setBody(arguments);
    //send the request
    Http http = new Http();
    HttpResponse res = http.send(req);

    //check the response
    if (res.getStatusCode() == 200) {

    } else {
      System.debug('Callout failed: ' + res);
    } 
    //}
    
  }
}