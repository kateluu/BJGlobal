public class TigerPistolConnector {
    public static String endpoint_prod {get;set;}
    public static String action {get;set;}
    public static String method {get;set;}
    public static String requestBody{get;set;}
    public static String token{get;set;}
    public static String token_NZ{get;set;}
    public static String packageName{get;set;}
    public static Customer myCustomer{get;set;}
    public static String locale{get;set;}

    public TigerPistolConnector(){
        endpoint_prod = 'https://api.tigerpistol.com/v1';       
        token = 'Token shJyh7D1gXJzMVZlNuL30GQOSzeERyxyNlBppQSD';
        token_NZ = 'Token LNu6KzrucPwCoQVQzIH7JjYZxvA6rdgyaJNJVnIw';
        requestBody ='';        
    }

    
    //public String addCustomer(String accountId){
    //    action ='customers';    
    //    method ='POST';
    
    //    // figure out package name base on product name
    //    //if(product.Name.containsIgnoreCase('Simple')){
    //    //  packageName = 'Standard';
    //    //}else if (product.Name.containsIgnoreCase('Super')){
    //    //  packageName = 'Super';
    //    //}else{
    //    //  packageName = 'Super-charged';
    //    //}

    //    packageName = 'super-charged';

    //    requestBody = initCustomerInfoFromAccount(accountId);
    //    String response = sendRequest();
    //    Map<String, Object> m = extractResponse(response);

        
    //    return ((m!=null)&&(m.get('id') != null))?m.get('id').toString():'';
        
    //}

  
    @future(callout=true)
    public static void addCustomerOnProductFuture(List<ID> products)
    {   
        List<Account_Product__c> updateProducts = new List<Account_Product__c>();
        action ='customers';    
        method ='POST';
        
        system.debug('call 1');
        String productId ='';
        if(products!=null && products.size()>0){
            for( Id item: products){
                productId = item;
                Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];
                system.debug('call 2');

                // figure out package name base on product name
                if(product.Name.containsIgnoreCase('Simple')){
                    packageName = 'Standard';
                }else if (product.Name.containsIgnoreCase('Super')){
                    packageName = 'Super';
                }else{
                    packageName = 'super-charged';
                }

                requestBody = initCustomerInfoFromAccount(product.Account__c);
                locale = product.CurrencyIsoCode;
                String response = sendRequest();
                system.debug('call 4');
                Map<String, Object> m = extractResponse(response);

                product.TP_Record_Id__c = ((m!=null)&&(m.get('id') != null))?m.get('id').toString():'';
                system.debug('addCustomerOnProductFuture product.TP_Record_Id__c = ' + product.TP_Record_Id__c);
                updateProducts.add(product);
            }
            update updateProducts;      
        }       

    }


    
    public static void addCustomerOnProductSynch(List<ID> products)
    {   
        system.debug('addCustomerOnProductSynch :: start');
        List<Account_Product__c> updateProducts = new List<Account_Product__c>();
        action ='customers';    
        method ='POST';
        
        
        String productId ='';
        if(products!=null && products.size()>0){
            for( Id item: products){
                productId = item;
                Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];
                system.debug('call 2');

                // figure out package name base on product name
                if(product.Name.containsIgnoreCase('Simple')){
                    packageName = 'Standard';
                }else if (product.Name.containsIgnoreCase('Super')){
                    packageName = 'Super';
                }else{
                    packageName = 'super-charged';
                }

                requestBody = initCustomerInfoFromAccount(product.Account__c);
                locale = product.CurrencyIsoCode;
                String response = sendRequest();
                system.debug('call 4');
                Map<String, Object> m = extractResponse(response);

                product.TP_Record_Id__c = ((m!=null)&&(m.get('id') != null))?m.get('id').toString():'';
                system.debug('addCustomerOnProductFuture product.TP_Record_Id__c = ' + product.TP_Record_Id__c);
                updateProducts.add(product);
            }
            update updateProducts;      
        }       

        system.debug('addCustomerOnProductSynch :: end');
    }    

    //@future(callout=true)
    //public static void deleteCustomers(List<Id> products){

    //    if(products!=null && products.size()>0){
    //        for( Id item: products){
                
    //            Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :item];                
    //            requestBody = initCustomerToDelete(product.TP_record_id__c);
    //            locale = product.CurrencyIsoCode;
    //            String response = sendRequestToDeleteCustomer(product.TP_record_id__c);                
    //            Map<String, Object> m = extractResponse(response);                
    //            system.debug('call 5 product.TP_Record_Id__c = ' + product.TP_Record_Id__c);                
    //        }            
    //    }       

    //}



    @future(callout=true)
    public static void deleteCustomer(String productId){

        Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];                
        requestBody = initCustomerToDelete(product.TP_record_id__c);
        locale = product.CurrencyIsoCode;
        String response = sendRequestToDeleteCustomer(product.TP_record_id__c);                
        Map<String, Object> m = extractResponse(response);                
        system.debug('deleteCustomer product.TP_Record_Id__c = ' + productId);                

    }

    public static void deleteCustomerSynch(String productId){   
        system.debug('deleteCustomerSynch :: start :: productId = ' + productId);
        Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];                
        requestBody = initCustomerToDelete(product.TP_record_id__c);
        locale = product.CurrencyIsoCode;
        String response = sendRequestToDeleteCustomer(product.TP_record_id__c);
        system.debug('deleteCustomerSynch :: response = ' + productId);
        Map<String, Object> m = extractResponse(response);
        system.debug('deleteCustomerSynch :: start :: product.TP_Record_Id__c = ' + productId);

    }



    @future(callout=true)
    public static void pauseCustomer(String productId){

        Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];                
        requestBody = initCustomerToDelete(product.TP_record_id__c);
        locale = product.CurrencyIsoCode;
        String response = sendRequestToPauseCustomer(product.TP_record_id__c);                
        Map<String, Object> m = extractResponse(response);                
        system.debug('pauseCustomer product.TP_Record_Id__c = ' + productId);                

    }

    public static void pauseCustomerSynch(String productId){
        system.debug('pauseCustomerSynch :: start :: product = ' + productId);                
        Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];                
        requestBody = initCustomerToDelete(product.TP_record_id__c);
        locale = product.CurrencyIsoCode;
        String response = sendRequestToPauseCustomer(product.TP_record_id__c);                
        Map<String, Object> m = extractResponse(response);                
        system.debug('pauseCustomerSynch product.TP_Record_Id__c = ' + productId);                

    }



    @future(callout=true)
    public static void reActivateCustomer(String productId){
        
        Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];                
        //requestBody = initCustomerToActivate(product.TP_record_id__c);
        locale = product.CurrencyIsoCode;
        String response = sendRequestToActivateCustomer(product.TP_record_id__c);                
        Map<String, Object> m = extractResponse(response);                
        system.debug('reActivateCustomer product.TP_Record_Id__c = ' + productId);                

    }


    public static void reActivateCustomerSynch(String productId){
        system.debug('reActivateCustomerSynch product.TP_Record_Id__c = ' + productId);                
        Account_Product__c product = [SELECT id , TP_record_id__c, Account__c, Name, CurrencyIsoCode  FROM Account_Product__c WHERE id = :productId];                
        //requestBody = initCustomerToActivate(product.TP_record_id__c);
        locale = product.CurrencyIsoCode;
        String response = sendRequestToActivateCustomer(product.TP_record_id__c);                
        Map<String, Object> m = extractResponse(response);                
        system.debug('reActivateCustomerSynch product.TP_Record_Id__c = ' + productId);                

    }



    public static String initCustomerInfoFromAccount(String accountId){
        system.debug('acc = ' + accountId);
        Account acc = [SELECT Id, Name, Email__c, Phone, BillingStreet, BillingCity, BillingCountry, BillingPostalCode, BillingState , (SELECT id, FirstName, LastName, Email FROM contacts WHERE Title = 'Marketing') FROM Account WHERE Id = :accountId];

        system.debug('acc = ' + acc);
        myCustomer = new Customer();
        myCustomer.externalID = acc.Id;
        myCustomer.name =acc.Name;
        myCustomer.packageId = packageName; //'Test'
        myCustomer.industryId = '382'; // other- retails
        myCustomer.objective = 'local_awareness';
        myCustomer.showPixelStep = false;
        myCustomer.subscriptionDate = ''+system.today();

        LitleContact myContact = new LitleContact();
        mycontact.email     = acc.contacts[0].Email;
        myContact.firstName = acc.contacts[0].FirstName;
        myContact.lastName  = acc.contacts[0].LastName;
        myContact.address   = acc.BillingStreet ;
        myContact.city      = acc.BillingCity;
        myContact.zip       = acc.BillingPostalCode;
        myContact.state     = acc.BillingState;
        myContact.country   = acc.BillingCountry;

        myCustomer.contact = myContact;
        return JSON.serialize(myCustomer);      
    }


    public static String initCustomerToDelete(String tpUserID){
        myCustomer = new Customer();
        myCustomer.id = tpUserId;
        return JSON.serialize(myCustomer);
        
    }


    public static Map<String, Object> extractResponse(String response){ 
        if(response.containsAny('"')){
            return  (Map<String, Object>) JSON.deserializeUntyped(response);
        }
        return null;
    }


    public static String  sendRequest(){
        // Make the request
        HttpRequest req = new HttpRequest();
        Http h = new Http();

        if(!Test.isRunningTest()){
            endpoint_prod = 'https://api.tigerpistol.com/v1';       
            token = 'Token shJyh7D1gXJzMVZlNuL30GQOSzeERyxyNlBppQSD';     
            token_NZ = 'Token LNu6KzrucPwCoQVQzIH7JjYZxvA6rdgyaJNJVnIw';      
            
            req.setEndpoint(endpoint_prod + '/' + action );
            req.setMethod(method);
            req.setBody(requestBody); 
            system.debug('requestBody = ' + requestBody);
            system.debug(req);
            req.setTimeout(60000);

            // header.
            String authorizationHeader = locale.containsIgnoreCase('NZ')?token_NZ:token;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');

            // send request
            HTTPResponse res = h.send(req);
            system.debug('Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
            return res.getBody();
        }
        return '{"id": "abc-kdhskldahskdlsadhsdlk-ieroe897"}';
        
    }


    public static String  sendRequestToActivateCustomer(String tpRecordId){
      // Make the request
         HttpRequest req = new HttpRequest();
         Http h = new Http();
        if(!Test.isRunningTest()){
            endpoint_prod = 'https://api.tigerpistol.com/v1';       
            token = 'Token shJyh7D1gXJzMVZlNuL30GQOSzeERyxyNlBppQSD';     
            token_NZ = 'Token LNu6KzrucPwCoQVQzIH7JjYZxvA6rdgyaJNJVnIw';  
            action ='customers';    
            method ='POST';   

            // header.
            String authorizationHeader = locale.containsIgnoreCase('NZ')?token_NZ:token;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '0');

            req.setEndpoint(endpoint_prod + '/' + action + '/' + tpRecordId + '/reactivate');
            req.setMethod(method);                    
            req.setTimeout(60000);
            system.debug(req);

            // send request
            HTTPResponse res = h.send(req);

            // Load the response
            system.debug('Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
            return res.getBody();
        }
        return 'OK'; 
    }



    public static String  sendRequestToPauseCustomer(String tpRecordId){
      // Make the request
         HttpRequest req = new HttpRequest();
           Http h = new Http();
      if(!Test.isRunningTest()){
            endpoint_prod = 'https://api.tigerpistol.com/v1';       
            token = 'Token shJyh7D1gXJzMVZlNuL30GQOSzeERyxyNlBppQSD';     
            token_NZ = 'Token LNu6KzrucPwCoQVQzIH7JjYZxvA6rdgyaJNJVnIw';  
            action ='customers';    
            method ='POST';   

            // header.
            String authorizationHeader = locale.containsIgnoreCase('NZ')?token_NZ:token;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '0');

            req.setEndpoint(endpoint_prod + '/' + action + '/' + tpRecordId + '/pause');
            req.setMethod(method);                    
            req.setTimeout(60000);
            system.debug(req);

            // send request
            HTTPResponse res = h.send(req);

            // Load the response
            system.debug('Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
            return res.getBody();
        }
        return 'OK'; 
    }

    public static String sendRequestToDeleteCustomer(String tpRecordId){
      // Make the request
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        if(!Test.isRunningTest()){
            endpoint_prod = 'https://api.tigerpistol.com/v1';       
            token = 'Token shJyh7D1gXJzMVZlNuL30GQOSzeERyxyNlBppQSD';     
            token_NZ = 'Token LNu6KzrucPwCoQVQzIH7JjYZxvA6rdgyaJNJVnIw';  
            action ='customers';    
            method ='DELETE';   

            // header.
            String authorizationHeader = locale.containsIgnoreCase('NZ')?token_NZ:token;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '0');        
            req.setEndpoint(endpoint_prod + '/' + action + '/' + tpRecordId );
            req.setMethod(method);                    
            req.setTimeout(60000);

            system.debug(req);

            // send request
            HTTPResponse res = h.send(req);

            // Load the response
            system.debug('Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
            return res.getBody();
        }
        return 'OK'; 
    }




    public class Customer{
        String id{get;set;}
        String externalId {get;set;}
        String name {get;set;}
        String packageId {get;set;}
        String industryId {get;set;}
        String objective {get;set;}
        Boolean showPixelStep{get;set;}
        String subscriptionDate {get;set;}
        LitleContact contact{get;set;}
    }

    public class LitleContact{
        String email {get;set;}
        String firstName {get;set;}
        String lastName {get;set;}
        String address {get;set;}
        String city {get;set;}
        String state {get;set;}
        String zip {get;set;}
        String country {get;set;}
    }

}