public class ActivitySEOReport {

	//Calculate SEO activity , communication infor from project level and save on Project	
	private boolean isTestMode {set;get;}
  private boolean isEmailSend {set;get;}

	public ActivitySEOReport(Boolean isTest, Boolean isSend) {
		this.isTestMode = isTest;
    this.isEmailSend = isSend;
    calculate();
	}

	private void calculate(){

		Map<String, String> emailMap = new Map<String, String>();
        String htmlBody= '';

        // build user list
        // SEO team A
        List<User> teamA = [select name, email from user where isActive = true and UserRole.name like '%SEO Team A%' and isActive = true ];        
    		for(User u : teamA){
    		  emailMap.put(u.name, u.email);
    		}

        // SEO team B
        List<User> teamB = [select name, email from user where isActive = true and UserRole.name like '%SEO Team B%' and isActive = true];        
    		for(User u : teamB){
    			emailMap.put(u.name, u.email);
    		}

		    // setup report URL
        Map<String, SEO_Report> result = new Map<string, SEO_Report>();
        system.debug(emailMap.keyset());
        for (String s : emailMap.keyset()) {
          system.debug('###########'+s);
          result.put(s, new SEO_Report(s));
        }        
        string domain = URL.getSalesforceBaseUrl().toExternalForm();
        String no_completed_activity_report_url = domain + '/00O6F00000FR0xQ';        
        String no_open_activity_report_url = domain + '/00O6F00000FR0xL';
        String overdue_report_url = domain + '/00O6F00000FR0yO';
        String resume_report_url = domain + '/00O6F00000FR1v8';
        String pending_signups_report_url = domain + '/00O6F00000FR1vD';  
        String new_cases_report_url = domain + '/00O6F00000FR1vX';        
        String no_calls_14days_report_url = domain + '/00O6F00000Bd5sl';

        //get the email template
        EmailTemplate template = [Select id, HtmlValue from EmailTemplate where name = 'CM Activity Report'];

        //No Completed Activity (w-in project) last 28days
        AggregateResult[] noCompletedProds = [SELECT owner.name OwnerName , count(id)
                                              FROM
                                                  Account_Product__c
                                              WHERE
                                                    Product_Status__c = 'Active'
                                                    AND 
                                                     ( Name LIKE 'SEO%') 
                                                    AND 
                                                      No_Complete_Task_Within_4_Weeks__c = true 
                                                    AND 
                                                      owner.name in :emailMap.keyset()
                                              GROUP BY Owner.Name
                                              ];

        for( AggregateResult  ar : noCompletedProds){
          String ownerName = ar.get('OwnerName').toString();

          if ((ownerName!= null) && ( result.get(ownerName)!= null) ) {
              result.get(ownerName).no_avtivity_accounts = Integer.valueof(ar.get('expr0'));
          }
        }


        //No Open Activities last 28days - include STP
        AggregateResult[] noOpenActivityProds = [SELECT owner.name OwnerName , count(id)
                                              FROM
                                                  Account_Product__c
                                              WHERE
                                                    Name LIKE 'SEO%'
                                                    AND
                                                      ( Product_Status__c = 'Active' OR  Product_Status__c = 'Paused' ) 
                                                    AND 
                                                      No_Open_Activity__c = true 
                                                    AND 
                                                      owner.name in :emailMap.keyset()
                                              GROUP BY Owner.Name
                                              ];

        for( AggregateResult  ar : noOpenActivityProds){
          String ownerName =  ar.get('OwnerName')!= null?ar.get('OwnerName').toString():'';

          if ((ownerName!= null) && ( result.get(ownerName)!= null) ) {
              result.get(ownerName).no_open_avtivity_accounts = Integer.valueof(ar.get('expr0'));
          }
        }


        // overdue tasks in last 120days, need to cal in batch because of data volumn
        Task[] tks = [  SELECT  owner.name
                        FROM
                          Task
                        WHERE
                          ActivityDate = LAST_N_DAYS:120
                          AND status = 'Not Started'
                          AND IsRecurrence  = false
                          AND IsClosed  = false
                          AND owner.name in: emailMap.keyset()
                      ];
        for (Task tk : tks) {
          if(result.containsKey(tk.owner.name)) {
            result.get(tk.owner.name).overdue_tasks++;
          }
        }


        //SEO product resume today
        //get resuming account_products
        Account_product__c[] aps = [SELECT
                                        owner.name
                                    FROM
                                        account_product__c
                                    WHERE 
                                        activeat__c = today
                                        AND 
                                          (name like 'SEO%')
                                        and
                                          Recurring_Period__c != null
                                        and
                                          Recurring_Period__c != 'N/A'
                                        and
                                          owner.name in: emailMap.keyset()
                                    ]; 
        
        for (account_product__c ap : aps) {
          if(result.containsKey(ap.owner.name)) {
            result.get(ap.owner.name).resume_accounts++;
          }
        }

        //New SEO product which had new cases raised 
        Cases__c[] cas = [SELECT
                              owner.name
                          FROM
                              Cases__c
                          WHERE
                              status__c = 'New'
                              AND 
                              Account_Product__r.Name LIKE 'SEO%'
                              AND
                              owner.name in: emailMap.keyset()
                          ];
        for (Cases__c ca : cas) {
          if(result.containsKey(ca.owner.name)) {
            result.get(ca.owner.name).new_cases++;
          }
        }

        // pending sign up, created in this month
        List<AggregateResult> pending_signups = [SELECT count(id),  Assign_To_User__r.Name Name
                                                  FROM Sign_Up__c 
                                                  WHERE CreatedDate = THIS_MONTH 
                                                    AND status__c = 'Pending CM Call' 
                                                    AND product_type__c = 'SEO' 
                                                    GROUP BY Assign_To_User__r.Name];
        for (AggregateResult ar : pending_signups)  {
          if (ar.get('Name')!= null){
            result.get(''+ar.get('Name')).pending_signups = Integer.valueOf(ar.get('expr0'));
          }
        }




        // No call made from last 14days
        List<AggregateResult> noCall14_prods = [SELECT COUNT(ID), Owner.Name Name
                                                FROM
                                                       Account_Product__c
                                                WHERE
                                                      Product_Status__c = 'Active'                                                          
                                                      AND Recurring__c = true
                                                      AND 
                                                       ( Name LIKE 'SEO%' )
                                                      AND 
                                                        owner.name in :emailMap.keyset()                                                                            
                                                      AND 
                                                        Last_7_days_num_of_calls__c = 0
                                                      GROUP BY Owner.Name
                                                ];
        for (AggregateResult ar : noCall14_prods)  {
          if (ar.get('Name')!= null){
            result.get(''+ar.get('Name')).no_calls_last14days = Integer.valueOf(ar.get('expr0'));
          }
        }
        //AggregateResult[] noCallLast14DayProds 
        //List<Account_product__c> updatedProducts = new List<Account_Product__c>();
        //Set<Account_product__c> changedProducts = new Set<Account_Product__c>();
        //List<SFDC_Projects__c>  projects = [ SELECT id, Account_Product__c, OwnerId
        //                                    FROM SFDC_Projects__c
        //                                    WHERE Account_Product__c  IN : prods.keyset()
        //                                      AND Project_Type__c LIKE '%SEO%'
        //                                    ORDER BY CreatedDate ASC
        //                                    ];

        //Set<String> projectIDs = new Set<String>();
        //for(SFDC_Projects__c itemProject:projects){
        //  projectIDs.add(itemProject.id);          
        //}

        //Set<String> ownerIDs = new Set<String>();
        //for(SFDC_Projects__c itemProject:projects){
        //  ownerIDs.add(itemProject.OwnerId);          
        //}

        //Map<String , String> projectToProductMap = new Map<String , String>();
        //for(SFDC_Projects__c itemProject:projects){
        //    projectToProductMap.put(itemProject.Id + ':' + itemProject.OwnerId, itemProject.Account_Product__c);
        //}

        //// option 1: error: System.LimitException: Too many SOQL queries: 101 
        //// for(SFDC_Projects__c itemProject:projects){
        ////    List<Task> callTasks = [  SELECT id, AccountId, OwnerId , Subject , LastModifiedDate , TaskSubtype , WhatId, OwnerId
        ////                                    FROM Task
        ////                                    WHERE IsClosed = true
        ////                                        AND IsRecurrence  = false
        ////                                        AND ((calltype = 'Outbound') OR (Subject LIKE 'CALL -%'))
        ////                                        AND LastModifiedDate = LAST_N_DAYS:14                                        
        ////                                        AND WhatId = :itemProject.id        //change to list id then loop to calculate
        ////                                        AND OwnerId = :itemProject.OwnerId  //change to list id then loop to calculate
        ////                                 ];
            
        ////      /*asumption : on account product just contain only one project,  
        ////                  otherwise the lated created project data will be shown on account product level 
        ////                  and the activity information based on project owner, so need to make sure the account product owner and project owner must be the same person */
                        
        ////    prods.get(itemProject.Account_Product__c).Last_14_days_num_of_calls__c = (callTasks== null)?0:callTasks.size();
        ////    udpatedProducts.add(prods.get(itemProject.Account_Product__c));
        //// }

        //// update product communication calculation result,
        //// if(udpatedProducts.size()>0){
        ////    update udpatedProducts;
        //// }

        //// Option 2: 
        //// prods : product map
        //// prosMap : calcualtion map
        //// projectToProductMap: map to look up product from projectID
        //List<Task> callTasks = [  SELECT id, AccountId, OwnerId , Subject , LastModifiedDate , TaskSubtype , WhatId
        //                                FROM Task
        //                                WHERE IsClosed = true
        //                                    AND IsRecurrence  = false
        //                                    AND ((calltype = 'Outbound') OR (Subject LIKE 'CALL -%'))
        //                                    AND LastModifiedDate = LAST_N_DAYS:14 
        //                                    AND WhatId IN :projectIDs
        //                                    AND OwnerId IN :ownerIDs
        //                       ];
            
        ///*asumption : on account product just contain only one project,  
        //            otherwise the lated created project data will be shown on account product level 
        //            and the activity information based on project owner, so need to make sure the account product owner and project owner must be the same person */
        //Map<String , Integer> prosMap = new Map<String , Integer>();
        //for(Task itemTask : callTasks){
        //    if(prosMap.get(itemTask.WhatId + ':' + itemTask.OwnerId) == null){
        //      prosMap.put(itemTask.WhatId + ':' + itemTask.OwnerId, 1 );
        //    }else{
        //      Integer val = prosMap.get(itemTask.WhatId + ':' + itemTask.OwnerId);
        //      prosMap.put(itemTask.WhatId + ':' + itemTask.OwnerId, val++);
        //    }
        //}

        ////Account_Product__c prod:prods.values()
        //for(SFDC_Projects__c itemProject:projects){
        //    prods.get(projectToProductMap.get(itemProject.Id + ':' + itemProject.OwnerId)).Last_14_days_num_of_calls__c 
        //        = (prosMap.get(itemProject.Id + ':' + itemProject.OwnerId)== null)?0:prosMap.get(itemProject.Id + ':' + itemProject.OwnerId);
        //    changedProducts.add(prods.get(projectToProductMap.get(itemProject.Id + ':' + itemProject.OwnerId)));
        //}
        
        // ////update product communication calculation result,
        // if(changedProducts.size()>0){
        //    updatedProducts = new List<Account_Product__c>(changedProducts);
        //    update updatedProducts;
        // }

        ////// the emails will show how many project without any outbound calls during last 2 weeks
        // prods = new Map<Id, Account_Product__c>([SELECT ID, Owner.Name, Last_14_days_num_of_calls__c
        //                                                                    FROM
        //                                                                          Account_Product__c
        //                                                                    WHERE
        //                                                                          Product_Status__c = 'Active'                                                          
        //                                                                          AND Recurring__c = true
        //                                                                          AND 
        //                                                                           ( Name LIKE 'SEO%' )
        //                                                                          AND 
        //                                                                            owner.name in :emailMap.keyset()                                                                            
        //                                                                    ]);
        //for(Account_Product__c item: prods.values()){
        //    String ownerName = item.Owner.Name;
        //    if ((ownerName!= null) && ( result.get(ownerName)!= null) && (item.Last_14_days_num_of_calls__c == 0)) {
        //        result.get(ownerName).no_calls_last14days ++;
        //    }
        //}

        //for( AggregateResult  ar : noCallLast14DayProds){
        //  String ownerName = ar.get('OwnerName')!= null?ar.get('OwnerName').toString():'';
        //  if ((ownerName!= null) && ( result.get(ownerName)!= null) ) {
        //      result.get(ownerName).no_calls_last14days = Integer.valueof(ar.get('expr0'));
        //  }
        //}

 
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        String emailBody;
        Messaging.SingleEmailMessage mail;
        String[] toAddresses;
        
        //Send report to the CM
        for(String name : result.keyset()) {
          emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2"  rules="all" cellpadding="10" style="text-align:left;">';
          emailBody += '<thead>';
          emailBody += '<tr>';
          emailBody += '<th>SEO Client Manager</th>';
          emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
          emailBody += '<th>No Open Activity Account</th>';          
          emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
          emailBody += '<th>Resume Today</th>';
          emailBody += '<th>New Cases</th>';
          emailBody += '<th>Pending Signups</th>';
          emailBody += '<th>Last 14days No Call</th>';
          emailBody += '</tr>';
          emailBody += '</thead>';
          emailBody += '<tbody>';
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_completed_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '</tr>';
          emailBody += '</tbody>';
          emailBody += '</table>';
          
          mail = new Messaging.SingleEmailMessage();
          try {
            if(isTestMode) {
              toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
              } else {
                toAddresses = new String[] {emailMap.get(name)};
              }

            // get template
            mail.setTemplateID(template.Id); 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('SEO Daily Report');
            mail.setSubject('SEO Client Manager Daily Report');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('[email_content]', emailBody);
            mail.setHtmlBody(htmlBody);        
            mails.add(mail);
            } catch (Exception e) {
              emailBody = 'Cannot get email address from SEO CM ' + name + '. ' + e.getMessage();
              toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
              mail.setToAddresses(toAddresses);
              mail.setSenderDisplayName('SEO CM Activity Report Error');
              mail.setSubject('Getting SEO CM Email Failed');
              mail.setBccSender(false);
              mail.setUseSignature(false);
              mail.setHtmlBody(emailBody);
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
              
              return;
            }
            
        }        

        //Send to teamA leader
        Map<string, SEO_Report> resultA = new Map<string, SEO_Report>();
        for (User u : teamA) {
          resultA.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">SEO Team A</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>SEO Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultA.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_completed_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';

        // SEO Team A Managers
        mail = new Messaging.SingleEmailMessage();        
        User[] TLA  = [select name, email from user where isActive = true and UserRole.name like '%SEO Team A Manager' and isActive = true];
        if(isTestMode) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
          } else {
            toAddresses = new List<String>();
            for(User u : TLA) {
              toAddresses.add(u.email);
            }
          }

        // get template    
        mail.setTemplateID(template.Id); 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('SEO Daily Report');
        mail.setSubject('SEO Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        String allSEO_CMEmailBody = emailBody; 

        //Send to teamB leader
        Map<string, SEO_Report> resultB = new Map<string, SEO_Report>();
        for (User u : teamB) {
          resultB.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">SEO Team B</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>SEO Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultB.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_completed_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';

        // SEO Team B Managers
        mail = new Messaging.SingleEmailMessage();        
        User[] TLB  = [select name, email from user where isActive = true and UserRole.name like '%SEO Team B Manager' and isActive = true];
        if(isTestMode) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
          } else {
            toAddresses = new List<String>();
            for(User u : TLB) {
              toAddresses.add(u.email);
            }
          }

        // get template    
        mail.setTemplateID(template.Id);
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('SEO Daily Report');
        mail.setSubject('SEO Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        allSEO_CMEmailBody += '<br><br><br>' +emailBody; 

        // send to CEO + CFO and top managers        
        mail = new Messaging.SingleEmailMessage();
        User[] COM = [select name, email from user where isActive = true and UserRole.name like '%Client Operations Manager%' and isActive = true];
        if(isTestMode) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
        } else {
            toAddresses = new List<String>();
            toAddresses.add('shannah.bradshaw@sponsoredlinx.com');
            toAddresses.add('benbjb@sponsoredlinx.com');          
            toAddresses.add('amber.porter@sponsoredlinx.com');      
            toAddresses.add('david.powell@sponsoredlinx.com');
            for(User u : COM) {
              toAddresses.add(u.email);
            }
        }

        // get template
        mail.setTemplateID(template.Id);         
        mail.setToAddresses(toAddresses);
        system.debug('email address : toAddresses = '  + toAddresses);
        String[] bccAddresses = new String[] { 'salesforce@sponsoredlinx.com'};
        mail.setBccAddresses(bccAddresses);
        mail.setSenderDisplayName('SEO Daily Report');
        mail.setSubject('SEO Client Managers Daily Report');
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;        
        htmlBody = htmlBody.replace('[email_content]', allSEO_CMEmailBody);
        mail.setHtmlBody(htmlBody);   

        mails.add(mail);

        if (isEmailSend){
            try{
                Messaging.sendEmail(mails);
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
	}

	 public class SEO_Report {
          String name {get; set;} //cm name
          integer no_avtivity_accounts {get; set;}
          integer no_open_avtivity_accounts {get; set;}
          integer overdue_tasks {get; set;}      
          integer resume_accounts {get; set;}
          integer pending_signups {get; set;}
          integer new_cases {get; set;}     
          integer no_calls_last14days {get; set;}
          
          public SEO_Report(String s) {
            this.name = s;
            this.no_avtivity_accounts = 0;
            this.no_open_avtivity_accounts = 0;
            this.overdue_tasks = 0;
            this.resume_accounts = 0;            
            this.pending_signups =0;
            this.new_cases = 0;
            this.no_calls_last14days = 0;            
          }
        }
}