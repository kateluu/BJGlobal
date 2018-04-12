global class GMTGOWebservice {

    webService static Id makeContact(String lastName, String firstName) {

            Contact c = new Contact(lastName = lastName, FirstName = firstName);

            insert c;

            return c.id;

        }
        
        
    // *********************************
    // ** Webservices for GMT GO App  **
    // *********************************
    // ** Written by Nirali / Mathew  **
    // *********************************
    // ** Date:     January 2017      **
    // *********************************
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static String clientPanelWebserviceURL() {
        String sandboxURL     = 'http://ec2-54-206-77-183.ap-southeast-2.compute.amazonaws.com';
        String productionURL  = 'https://clientpanel.sponsoredlinx.com.au';
        if (runningInASandbox()) {
            return sandboxURL;
        } 
        return productionURL;
    }
    
    public static String invoiceURL() {
        String sandboxURL     = 'http://staging-bjbglobal.cs5.force.com/gmtgo';
        String productionURL  = 'http://bjbglobal.force.com/gmtgo';
        if (runningInASandbox()) {
            return sandboxURL;
        } 
        return productionURL;
    }
    
    global class GoogleAdwordsid{
        WebService List<String> id;
    }
    global class GoogleAdwords {
        WebService List<GoogleAdwordsid> adword;
    }
    global class WebServiceAuthenticate {
        WebService Boolean  status;
        WebService String   message;
        WebService String   accountid;
        WebService GoogleAdwords adwordslist;
        WebService String   ownerid;
        WebService String   signupstatus;
        WebService Integer setuphours;
        WebService Datetime signupdatetime;
        WebService Account  user_account;
        WebService Account  clientmanager_account;
        
    }
    
        
    webService static WebServiceAuthenticate user_authenticate(String username, String password , String deviceid , String company) {

        Account[] A = new List<Account>();
        // return WebServiceAuthenticate Object
        if(company == 'Get More Traffic')
        {
             A = [SELECT Account_No__c,password__c,Owner.Id FROM Account WHERE username__c =: username and BJB_Company__r.Name =: company limit 1];
        }
        else
        {
             A = [SELECT Account_No__c,password__c,Owner.Id FROM Account WHERE username__c =: username  and BJB_Company__r.Name IN ('SponsoredLinX New Zealand','SponsoredLinX') limit 1];
        }
        WebServiceAuthenticate auth_obj = new WebServiceAuthenticate();
        
        try{
            if(A.size() > 0){
            if(A[0].password__c == password)
            {
                List<Account_Product__c> AP = [SELECT Adwords_ID__c FROM Account_Product__c WHERE Account__c =: A[0].Id and Adwords_ID__c != ''];
                auth_obj.user_account = new Account();
                auth_obj.clientmanager_account = new Account();
                A[0].deviceid__c = deviceid;
                update A;
                
                //Sign_Up__c signup = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Account__c =: A[0].Id limit 1];
                Sign_Up__c signup = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Account__c =: A[0].Id and (Product_Type__c = 'AdWords Management' or Product_Type__c= 'Social Marketing') and (status__c = 'Completed' or status__c = 'New' or status__c = 'Pending CM Call') order by CreatedDate DESC limit 1];
                auth_obj.signupstatus = signup.Status__c;
                auth_obj.signupdatetime = signup.CreatedDate;
                auth_obj.setuphours = hoursdiff(signup.CreatedDate,datetime.now());
                //auth_obj.setuphours = 49;
                
                GoogleAdwords ad_obj = new GoogleAdwords();
                
                ad_obj.adword = new List<GoogleAdwordsid>();
                For(Account_Product__c obj : AP){
                       GoogleAdwordsid adid_obj = new GoogleAdwordsid();
                       adid_obj.id = new List<String>();
                       adid_obj.id.add(obj.Adwords_ID__c);
                       ad_obj.adword.add(adid_obj);
                 }
                auth_obj.accountid = A[0].Id;
                auth_obj.adwordslist = ad_obj; 
                auth_obj.ownerid = A[0].Owner.Id;
                auth_obj.status = true;
                auth_obj.message = 'Successfully Logged In';
            }
            else
            {
                auth_obj.status = false;
                auth_obj.message = 'There was an error authenticating your account. Please try again';
            }
        }
        else
        {
            auth_obj.status = false;
            auth_obj.message = 'There was an error authenticating your account. Please try again';
        }
    }catch(exception e) {
        //else{
            auth_obj.status = false;
            auth_obj.message = e.getLineNumber()+' '+e.getMessage();
            //}
        }       
    
        System.debug(auth_obj);
        return auth_obj;
    }
    
    webService static updatepasswordreturn forget_password(String username) {
        // send reset email (how/where do we handle the update password)  
        
        Account[] a = [SELECT ID,BJB_Company__c FROM Account WHERE username__c =: username];
        updatepasswordreturn returnobj = new updatepasswordreturn();
        if(a.size() > 0){
            Integer len = 10;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            String newpassword = key.substring(0,len);
            a[0].password__c = newpassword;
            update a;
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{username};
            semail.setToAddresses(sendingTo);
            //if(a[0].BJB_Company__c == 'Get More Traffic')
            //{
            //    semail.setSubject('GMTGo : New Password');
            //}
            //else
            //{
            //    semail.setSubject('LinX: New Password');
           // }
            semail.setSubject('LinX: New Password');
            semail.setPlainTextBody('Your New Password is : ' + newpassword);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            returnobj.message = 'Your new password has been sent to your registred email';
            returnobj.status = 1;
        }
        else
        {
            returnobj.message = 'User not exist';
            returnobj.status = 0;
        }
        
        return returnobj;
    }
    
    global class updatepasswordreturn {
        WebService String   message;
        WebService Integer  status;
    }
    
    webService static updatepasswordreturn update_password(String username, String newpassword) {
        // update user password
        //load the contact object from the parameter contactid
            Account a = [SELECT ID FROM Account WHERE username__c =: username];
            
            //do some processing if ya want
            a.password__c = newpassword;
            //update the contact object
            
            updatepasswordreturn returnobj = new updatepasswordreturn();
            
            try {
                update a;
                returnobj.message = 'Password updated successfully';
                returnobj.status = 1;
            } catch(DmlException e) {
                returnobj.message = 'Password failed to update';
                returnobj.status = 0;
            }

            return returnobj;
    }
    
    global class dashboardreturn {
        WebService String stats;
    }
    
    webService static String dashboard(String accountid,String adwordsid,String start_date,String end_date) {
        
        String newadwordsid = adwordsid.substring(0,3)+'-'+adwordsid.substring(3,6)+'-'+adwordsid.substring(6,10);
        //return newadwordsid;
        System.debug(newadwordsid);
        Sign_Up__c signup = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Account__c =: accountid and (Product_Type__c = 'AdWords Management' or Product_Type__c = 'Social Marketing' ) and (status__c = 'Completed' or status__c = 'New' or status__c = 'Pending CM Call') order by CreatedDate DESC limit 1];
        //Sign_Up__c signup = [SELECT Status__c,CreatedDate FROM Sign_Up__c WHERE Adwords_ID__c =: adwordsid and Product_Type__c = 'AdWords Management' order by CreatedDate DESC limit 1];
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(30000); // timeout in milliseconds
        req.setEndpoint(clientPanelWebserviceURL()+'/webservice/dashboard.php');
        req.setMethod('POST');
        System.debug('status' + signup.Status__c);

        string arguments = 'adwordsid=' + adwordsid + '&status=' + signup.Status__c + '&signupdate=' + signup.CreatedDate + '&start_date=' + start_date + '&end_date=' + end_date;
        req.setBody(arguments);
        Http h = new Http();
        HTTPResponse res = h.send(req);
        string Response = EncodingUtil.urlDecode(res.getBody(),'UTF-8');
        return Response;
        //return '{"status":"Completed",<currentdatetime>:&quot;2017-03-25 12:24:46&quot;,&quot;signupdatetime&quot;:&quot;2017-02-18 06:18:52&quot;,&quot;Stats&quot;:{&quot;clicks&quot;:&quot;118&quot;,&quot;impressions&quot;:&quot;2422&quot;,&quot;ctr&quot;:&quot;4.8720&quot;,&quot;cpc&quot;:3.21,&quot;cost&quot;:&quot;378.52000000000004&quot;,&quot;conv&quot;:&quot;1&quot;,&quot;avg_position&quot;:&quot;1.6298926507018991&quot;},&quot;Segments&quot;:{&quot;networksegment&quot;:';
    }
    
    global class clientmanager{
        WebService String name;
        WebService String role;
        WebService String aboutme;
        WebService String phone;
        WebService String email;
        WebService String photo;
    }
    
    webService static clientmanager client_manager(ID ownerid) {
        
         User user = [SELECT Name,UserRole.Name,AboutMe,Phone,Email,FullPhotoUrl FROM User WHERE ID =: ownerid];
         
         clientmanager returnobj = new clientmanager();
         returnobj.name = user.Name;
         returnobj.role = 'Client Manager';
         //user.UserRole.Name;
         returnobj.aboutme= user.AboutMe;
         returnobj.phone = user.Phone;
         returnobj.email = user.Email;
         String uname = user.Name;
         uname = uname.replaceAll( '\\s+', '');
         uname = uname.tolowercase();
         //if(user.UserRole.Name.contains('GMT')){
         //	returnobj.photo = 'https://getmoretraffic.com.au/clientmanagers/' + uname + '.jpg';	
         //}else{
         	returnobj.photo = 'https://sponsoredlinx.com.au/clientmanagers/' + uname + '.jpg';	
         //}
         
         return returnobj;
    }
    
    global class reportsreturn {
        WebService String report;
    }
    
    webService static String reports(String adwordsid) {
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(30000); // timeout in milliseconds
        req.setEndpoint(clientPanelWebserviceURL()+'/webservice/reports.php');
        //req.setEndpoint('http://ec2-54-206-77-183.ap-southeast-2.compute.amazonaws.com/WebserviceEmailView/Send/'+adwordsid+'/20161226/20170101');
        req.setMethod('POST');
       
        string arguments = 'adwordsid=' + adwordsid;
        req.setBody(arguments);
        Http h = new Http();
        HTTPResponse res = h.send(req);
        string Response = EncodingUtil.urlDecode(res.getBody(),'UTF-8');
        //string Response = res.getBody();
        //string Response = EncodingUtil.base64Encode(res.getBodyAsBlob());
        return Response;
    }
    
    webService static String sendreports(String adwordsid,Decimal startdate, Decimal enddate) {
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(30000); // timeout in milliseconds
        //req.setEndpoint('http://ec2-54-206-77-183.ap-southeast-2.compute.amazonaws.com/webservice/reports.php');
        req.setEndpoint(clientPanelWebserviceURL()+'/WebserviceEmailView/Send/'+adwordsid+'/'+startdate+'/'+enddate+'');
        req.setMethod('POST');
       
        string arguments = 'adwordsid=' + adwordsid;
        req.setBody(arguments);
        Http h = new Http();
        HTTPResponse res = h.send(req);
        //string Response = EncodingUtil.urlDecode(res.getBody(),'UTF-8');
        //string Response = res.getBody();
        string Response = EncodingUtil.base64Encode(res.getBodyAsBlob());
        return Response;
    }
    
    global class listinvoice{
        WebService List<accountinvoice> allinvoice;
    }
    
    global class accountinvoice{
        WebService String status;
        WebService String invoicenumber;
        WebService Date issuedate;
        WebService Decimal amount;
        WebService ID invoiceid;
        WebService String invoiceurl;
    }
    
    webService static listinvoice invoices(String accountid) {
        
        List<Invoice__c> inv = [SELECT Invoice_Total__c,Issue_Date__c,Invoice_Number__c,Status__c,Id FROM Invoice__c WHERE Account__c =: accountid order by CreatedDate DESC limit 10];
        
        listinvoice listobj = new listinvoice();
        listobj.allinvoice = new List<accountinvoice>();
        For(Invoice__c obj : inv){
        accountinvoice returnobj = new accountinvoice();
        returnobj.status = obj.Status__c;
        returnobj.invoicenumber = obj.Invoice_Number__c;
        returnobj.issuedate = obj.Issue_Date__c;
        returnobj.amount = obj.Invoice_Total__c;
        //returnobj.invoiceid = obj.Id;
        returnobj.invoiceurl = invoiceURL()+'/printInvoice?id='+obj.Id;
        listobj.allinvoice.add(returnobj);
        }
        return listobj; 
    }

     webService static String requestcall(String accountid,String ownerid) {
        Task tk = new Task(OwnerId = ownerid,WhatId = accountid,  Subject = 'Callback Request',CurrencyIsoCode = 'AUD',Status = 'Not Started',Priority='High');

        insert tk;
        
        return 'A Call Request has been successfully sent to your client manager and will call you shortly';
    }
    
    global class notitifcationlist{
        WebService List<result> notificationslist;
    }
    
    global class result{
        WebService String notification;
        WebService Datetime createddate;
    }
    
    webService static notitifcationlist appnotificationlist(String accountid)
    {
        List<App_Notification__c> pushlistobj = [SELECT Push_Notifications__c,CreatedDate FROM App_Notification__c WHERE Account__c =: accountid order by CreatedDate desc];
        //System.debug('testdata' + pushlistobj);
        notitifcationlist notilistobj = new notitifcationlist();
        notilistobj.notificationslist = new List<result>(); 
        //TimeZone tz = UserInfo.getTimeZone();
        
        For(App_Notification__c obj : pushlistobj){
            result returnobj = new result();
            returnobj.notification = obj.Push_Notifications__c;
            
            TimeZone tz = TimeZone.getTimeZone('Australia/Brisbane');
            DateTime localTime = obj.CreatedDate.AddSeconds(tz.getOffset(obj.CreatedDate)/1000);
        
            returnobj.createddate = localTime;
            notilistobj.notificationslist.add(returnobj);
        }
        return notilistobj;
    }
    
    private static Integer hoursdiff(Datetime startdate,Datetime enddate)
    {
                    // Get the default business hours
            BusinessHours bh = [select id from businesshours where IsDefault=true];
            // Create Datetime on May 28, 2008 at 1:06:08 AM in local timezone.
            
            //Datetime startTime = Datetime.newInstance(2017, 3, 17, 9, 6, 8);
            
            // Create Datetime on May 28, 2008 at 4:06:08 PM in local timezone.
            
            //Datetime endTime = Datetime.newInstance(2017, 3, 21, 16, 6, 8);
            
            // Find the number of business hours milliseconds between startTime and endTime as
            // defined by the default business hours.  Will return a negative value if endTime is
            // before startTime, 0 if equal, positive value otherwise.
            Long diff = BusinessHours.diff(bh.id, startdate, enddate);
            
            Double temp = diff/3600000;
            Integer hours = temp.intValue();
            
            return hours;
    }

    global class fbleads{
        WebService Integer hasfacebookproduct;
        WebService String allleads;
    }    

    webService static fbleads getFacebookLeads(String accountid,String facebookdate) {
        
        //List<Account_Product__c> FP = [SELECT Facebook_Ad_ID__c FROM Account_Product__c WHERE Account__c =: accountid and Name = 'Facebook Basic Monthly Management'];
         List<Account_Product__c> FP = [SELECT Facebook_Ad_ID__c FROM Account_Product__c WHERE Account__c =: accountid and Name like '%Facebook%' and (Recurring_Period__c != '' and Recurring_Period__c !=null)];
         String commaSepratedList='';
         fbleads fbleadsobj = new fbleads();
         if(FP.size() > 0){
            //String[] tmp1 = New String[]{};
            For(Account_Product__c obj : FP){
                commaSepratedList += obj.Facebook_Ad_ID__c + ',' ; 
                
             }

            System.Debug('commaid' + FP[0].Facebook_Ad_ID__c);
            HttpRequest req = new HttpRequest();
            req.setTimeout(30000); // timeout in milliseconds
            req.setEndpoint(clientPanelWebserviceURL()+'/webservice/getfacebookleads.php');
            req.setMethod('POST');
           
            string arguments = 'fbids=' + commaSepratedList + '&facebookdate=' + facebookdate;
            req.setBody(arguments);
            Http h = new Http();
            HTTPResponse res = h.send(req);
           
            fbleadsobj.hasfacebookproduct = 1;
            fbleadsobj.allleads = EncodingUtil.urlDecode(res.getBody(),'UTF-8');
            
        }
        else
        {    
            fbleadsobj.hasfacebookproduct = 0;
            Account[] a = [SELECT Unique_Id__c,ID FROM Account WHERE ID  =: accountid];
            fbleadsobj.allleads = 'https://bjbglobal.secure.force.com/checkoutslx/?locale=AUD&do=addPackage&package=a1B90000000QXby,a1B90000000QXc3&accountid='+ a[0].ID +'&uid='+ a[0].Unique_Id__c +'&promocode=$special200';
        }
        return fbleadsobj;

    }
    
    global class cnvleads{
        WebService Integer hasconvertoproduct;
        WebService String allleads;
    }
    
    webService static cnvleads getConvertoLeads(String accountid) {
        //List<Account_Product__c> AP = [SELECT ID FROM Account_Product__c WHERE Account__c =: accountid];
        List<Account_Product__c> AP = [select id from account_product__c where (name like '%Convertopages%' or name like 'GO! Pages%') and (Recurring_Period__c != '' and Recurring_Period__c !=null) and account__c =:accountid];
        String commaSepratedList='';
         cnvleads cnvleadsobj = new cnvleads();
         if(AP.size() > 0){
            //String[] tmp1 = New String[]{};
            For(Account_Product__c obj : AP){
                commaSepratedList += obj.id + ',' ; 
                
             }

            //System.Debug('commaid' + FP[0].Facebook_Ad_ID__c);
            HttpRequest req = new HttpRequest();
            req.setTimeout(30000); // timeout in milliseconds
            req.setEndpoint('https://www.convertopages.com/webservices/converto_leads.php?accountproduct_id='+commaSepratedList);
            req.setMethod('GET');
           
            //string arguments = 'accountproduct_id=' + commaSepratedList;
            //req.setBody(arguments);
            Http h = new Http();
            HTTPResponse res = h.send(req);
           
            cnvleadsobj.hasconvertoproduct = 1;
            cnvleadsobj.allleads = EncodingUtil.urlDecode(res.getBody(),'UTF-8');
            
        }
        else
        {    
            cnvleadsobj.hasconvertoproduct= 0;
            Account[] a = [SELECT Unique_Id__c,ID, Name FROM Account WHERE ID  =: accountid];
            if(a[0].Name.contains('GetMoreTraffic')){
            	cnvleadsobj.allleads = 'https://bjbglobal.secure.force.com/checkoutgmt/?locale=AUD&do=addPackage&package=a1B6F000004I2q8,a1B6F000004I2po&accountid='+ a[0].ID +'&uid='+ a[0].Unique_Id__c +'&promocode=majordeal300';
            }else{
            	cnvleadsobj.allleads = 'https://bjbglobal.secure.force.com/checkoutslx/?locale=AUD&do=addPackage&package=a1B90000000Ry2o,a1B90000000Ry2t&accountid='+ a[0].ID +'&uid='+ a[0].Unique_Id__c +'&promocode=majordeal300';
            }
        }
        return cnvleadsobj;
    }
}