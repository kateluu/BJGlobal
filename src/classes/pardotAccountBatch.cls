global class pardotAccountBatch implements Database.batchable<Account>,Database.Stateful , Database.AllowsCallouts{
    global Iterable<Account> start(Database.batchableContext info) {    
        return new pardotAccountIterator();  
    }
    

    global void calActivityAndStatusForProduct(List<Account> scope){
            String productname = '';
            List<Account_Product__c> updatedProducts = new List<Account_Product__c>();

            for(Account account : scope){
                try{
                        List<Account_Product__c> products = [SELECT Id, 
                                                                 Name,
                                                                 Product_Status__c, 
                                                                 Monthly_Price__c, 
                                                                 No_Open_Activity__c,
                                                                 No_Complete_Task_Within_4_Weeks__c,
                                                                 Owner.Name,
                                                                 From_Last_Paid_Date__c,
                                                                 Last_Paid_Date__c,
                                                                 suspendedat__c,
                                                                 Account__c,
                                                                 cancelat__c 
                                                            FROM Account_Product__c 
                                                            WHERE 
                                                                Account__c=:account.Id 
                                                                AND (Recurring_Period__c !='N/A' AND Recurring_Period__c != '')
                                                                AND (Name like '%Facebook%' or Name like '%Adwords%' or Name like '%SEO%' or Name Like 'Social%' or Name Like '%Converto%' )
                                                                AND Product_Status__c = 'Active'];

                        for(Account_Product__c ap : products) {
                                if (!ap.Name.containsIgnoreCase('SEO')){
                                    // no open activity
                                    List<Task> openTask = [SELECT id, status FROM Task WHERE IsRecurrence  = false  AND status='Not Started' AND AccountID = :ap.Account__c and Owner.Name = :ap.Owner.Name ];
                                    if (openTask == null || openTask.size()==0 ){
                                        ap.No_Open_Activity__c = true;
                                    }else{
                                        ap.No_Open_Activity__c = false;
                                    }

                                    // no completed activity within 4 weeks
                                    List<Task> completedTask = [SELECT id, status FROM Task WHERE IsRecurrence  = false AND status='Completed' AND AccountID = :ap.Account__c and Owner.Name = :ap.Owner.Name  AND LastModifiedDate = LAST_N_DAYS:28];
                                    if (completedTask == null || completedTask.size()==0 ){
                                        ap.No_Complete_Task_Within_4_Weeks__c = true;
                                    }else{
                                        ap.No_Complete_Task_Within_4_Weeks__c = false;
                                    }

                                 }
                                 else{
                                    List<SFDC_Projects__c>  projects = [SELECT id
                                                                        FROM SFDC_Projects__c
                                                                        WHERE Account_Product__c = :ap.Id
                                                                                ORDER BY CreatedDate DESC
                                                                                LIMIT 1];
                                    // open activity
                                    List<Task> openTasks = [SELECT id, status 
                                                                FROM Task 
                                                                WHERE status='Not Started' 
                                                                    AND IsRecurrence  = false
                                                                    AND WhatId  =:projects.get(0).id 
                                                                    AND  Owner.Name = :ap.Owner.Name];


                                    // no completed activity within 4 weeks
                                    List<Task> completedTasks = [SELECT id, status 
                                                                FROM Task 
                                                                WHERE status='Completed'    
                                                                    AND IsRecurrence  = false                                                               
                                                                    AND WhatId  =:projects.get(0).id 
                                                                    AND  Owner.Name = :ap.Owner.Name  
                                                                    AND LastModifiedDate = LAST_N_DAYS:28];


                                    // no open activity
                                    if(openTasks ==null || openTasks.size() ==0){
                                        ap.No_Open_Activity__c = true;                                      
                                    }else{
                                        ap.No_Open_Activity__c = false;
                                    }

                                    // no completed activity
                                    if (completedTasks == null || completedTasks.size()==0 ){
                                        ap.No_Complete_Task_Within_4_Weeks__c = true;
                                    }else{
                                        ap.No_Complete_Task_Within_4_Weeks__c = false;
                                    }

                                 }
                                 
                                //evaluate social engage product's status base on last_paid_date__c
                                if(ap.name.containsIgnoreCase('Social Engage')){
                                    if(ap.From_Last_Paid_Date__c >= 6 &&  ap.product_status__c.equalsIgnoreCase('Active')){
                                        ap.product_status__c = 'Suspended';
                                        ap.suspendedat__c = System.Date.Today();
                                        ap.Last_Paid_Date__c = null;
                                        
                                        // make a synchronous call to TigerPistol
                                        system.debug('TigerPistol suspended product.id = ' + ap.id);
                                        TigerPistolConnector.pauseCustomerSynch(ap.id);
                                    }
                                }
                                updatedProducts.add(ap);
                        }   
                }catch(Exception ex){
                    system.debug(ex.getMessage());  
                }
            }

            try{
                update updatedProducts;
            }catch (Exception e){
                system.debug(e.getMessage());
            }

    }

    global void execute(Database.batchableContext info, List<Account> scope){

        calActivityAndStatusForProduct(scope);

        for(Account account : scope){
            try {
                String productname = '';
                
                Decimal account_active_days  = 0;
                Decimal adwords_active_days  = 0;
                Decimal facebook_active_days = 0;
                Decimal seo_active_days      = 0;
                Decimal converto_active_days = 0;
                
                Boolean adsActive    = false;
                Boolean adsPaused    = false;
                Boolean adsCancelled = false;   
                                
                Boolean seoActive    = false;
                Boolean seoPaused    = false;
                Boolean seoCancelled = false;
                    
                Boolean facebookActive    = false;
                Boolean facebookPaused    = false;
                Boolean facebookCancelled = false;
                    
                Boolean convertoActive    = false;
                Boolean convertoPaused    = false;
                Boolean convertoCancelled = false;
                
                Date cancelledDate        = null;
                    
                    
                List<Date> cancelledDates = new List<Date>(); 
                    
                String package_name = '';
                
                Boolean first_record = true;
                    
                for(Account_Product__c product : [SELECT Id, 
                                                         Name,
                                                         Product_Status__c, 
                                                         Monthly_Price__c, 
                                                         No_Open_Activity__c,
                                                         No_Complete_Task_Within_4_Weeks__c,
                                                         cancelat__c 
                                                    FROM Account_Product__c 
                                                    WHERE Account__c=:account.Id 
                                                    AND (Recurring_Period__c !='N/A' AND Recurring_Period__c != '')
                                                    AND (Name like '%Facebook%' or Name like '%Adwords%' or Name like '%SEO%' or Name Like '%Social%' or Name Like '%Converto%' OR Name Like 'Social Engage%' )
                                                    ORDER BY
                                                    cancelat__c Desc]) {
                    System.debug('Product Record: '+product);
                    productname = '';
                    productname = product.Name.toLowerCase();
                    if( first_record && product.cancelat__c != null){
                        cancelledDate = product.cancelat__c;
                        first_record = false;
                    }
                    
                    Decimal product_active_days = 0;
                    
                    Client_History__c[] chs = [select 
                                                    Lasting_Days__c 
                                                from 
                                                    Client_History__c 
                                                where 
                                                    Type__c = 'Active'
                                                and 
                                                    Account_Product__c =: product.Id];
                    if(chs.size() > 0 ){
                        for(Client_History__c ch : chs){
                            product_active_days += ch.Lasting_Days__c;
                        }
                    }
                    system.debug(productname);  
                    if(productname.contains('adwords')) {
                        if(product.Product_Status__c == 'Active'){
                            adsActive = true;
                            if(product.Monthly_Price__c <= 343 ){
                                package_name = 'Standard';
                            }else if(product.Monthly_Price__c <= 386){
                                package_name = 'Optimised';
                            }else if(product.Monthly_Price__c <= 429){
                                package_name = 'Premium';
                            }
                        }else if(product.Product_Status__c == 'Paused'){
                            adsPaused = true;
                        }else if(product.Product_Status__c == 'Cancelled'){
                            adsCancelled = true;
                            cancelledDates.add(product.cancelat__c);
                        }
                        adwords_active_days += product_active_days;
                        
                    } else if(productname.contains('seo')) {
                                if(product.Product_Status__c == 'Active'){
                                    seoActive = true;
                                }else if(product.Product_Status__c == 'Paused'){
                                    seoPaused = true;
                                }else if(product.Product_Status__c == 'Cancelled'){
                                    seoCancelled = true;
                                }
                                seo_active_days += product_active_days;
                                    
                    } else if(productname.contains('facebook') || productname.contains('social media')) {
                                system.debug(product.Product_Status__c);
                                if(product.Product_Status__c == 'Active' || product.Product_Status__c == 'Pending Linking'){
                                    facebookActive = true;
                                }else if(product.Product_Status__c == 'Paused'){
                                    facebookPaused = true;
                                }else if(product.Product_Status__c == 'Cancelled'){
                                    facebookCancelled = true;
                                }
                            facebook_active_days += product_active_days;
                    }else if(productname.contains('convertopages')) {
                        System.debug('Product Name Contains ConvertoPages');
                                if(product.Product_Status__c == 'Active'){
                                    convertoActive = true;
                                }else if(product.Product_Status__c == 'Paused'){
                                    convertoPaused = true;
                                }else if(product.Product_Status__c == 'Cancelled'){
                                    convertoCancelled = true;
                                }
                                converto_active_days += product_active_days;
                    }
                    
                    product.Active_Days__c = product_active_days;


                    try{
                        update product;
                    }catch(Exception e){
                        system.debug(e.getMessage());
                    }
                }
                system.debug('finished looping products');
                if(adsActive){
                    account.Adwords_Product__c = 'Active';
                }else if(adsPaused){
                    account.Adwords_Product__c = 'Paused';
                }else if(adsCancelled){
                    account.Adwords_Product__c = 'Cancelled';
                }
                    
                account.Package_Name__c = package_name;
                if(seoActive){
                    account.SEO_Product__c = 'Active';
                }else if(seoPaused){
                    account.SEO_Product__c = 'Paused';
                }else if(seoCancelled){
                    account.SEO_Product__c = 'Cancelled';
                }
                
                if(facebookActive){
                    account.Facebook_Product__c = 'Active';
                }else if(facebookPaused){
                    account.Facebook_Product__c = 'Paused';
                }else if(facebookCancelled){
                    account.Facebook_Product__c = 'Cancelled';
                }
                    
                if(convertoActive){
                    account.Converto_Product__c = 'Active';
                }else if(convertoPaused){
                    account.Converto_Product__c = 'Paused';
                }else if(convertoCancelled){
                    account.Converto_Product__c = 'Cancelled';
                }
                    
                if(adsActive || seoActive || facebookActive || convertoActive){
                    account.Active__c = true;
                }else{
                    account.Active__c = false;
                }
                system.debug('converto'+ account.Converto_Product__c );
                system.debug('adwords'+ account.Adwords_Product__c );
                system.debug('seo'+ account.SEO_Product__c );
                system.debug('facebook'+ account.Facebook_Product__c );
                
                if((account.Converto_Product__c == null || account.Converto_Product__c == 'Cancelled')
                    &&(account.Adwords_Product__c == null || account.Adwords_Product__c == 'Cancelled')
                    &&(account.SEO_Product__c == null || account.SEO_Product__c == 'Cancelled')
                    &&(account.Facebook_Product__c == null || account.Facebook_Product__c == 'Cancelled')
                ){
                    account.cancelled_date__c = cancelledDate;
                }
                
                
                account.Adwords_Active_Days__c  = adwords_active_days;
                account.SEO_Active_Days__c      = seo_active_days;
                account.Facebook_Active_Days__c = facebook_active_days;
                account.Converto_Active_Days__c = converto_active_days;
                
                account.Active_Days__c          = adwords_active_days + facebook_active_days + seo_active_days;

                update account;
              
          } catch(Exception e) {
               System.debug('Error fetching contact record');
               System.debug('EXCEPTION: '+e.getMessage());
          }
    }
        
    }
    global void finish(Database.batchableContext info){
        
        }
}