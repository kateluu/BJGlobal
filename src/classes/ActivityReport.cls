public with sharing class ActivityReport{
        public ActivityReport(Boolean isTest) {      
          Map<String, String> emailMap = new Map<String, String>();
          String htmlBody= '';
          
          List<User> teamA = [select name, email from user where isActive = true and (UserRole.name like 'Client Manager Team A%' or UserRole.name = ' Client Resolution Manager Team A')];        
          for(User u : teamA){
            emailMap.put(u.name, u.email);
          }
          List<User> teamB = [select name, email from user where isActive = true and (UserRole.name like 'Client Manager Team B%' or UserRole.name = ' Client Resolution Manager Team B')];                
          for(User u : teamB){
            emailMap.put(u.name, u.email);
          }
          List<User> teamC = [select name, email from user where isActive = true and (UserRole.name like 'Client Manager Team C%' or UserRole.name = ' Client Resolution Manager Team C')];        
          for(User u : teamC){
            emailMap.put(u.name, u.email);
          }
          List<User> teamGMTA = [select name, email from user where isActive = true and UserRole.name like 'Client Manager GMT Team A%'];
          for(User u : teamGMTA){
            emailMap.put(u.name, u.email);
          }
          List<User> teamGMTB = [select name, email from user where isActive = true and UserRole.name like 'Client Manager GMT Team B%'];
          for(User u : teamGMTB){
            emailMap.put(u.name, u.email);
          }
        //List<User> teamResolution = [select name, email from user where isActive = true and UserRole.name like '%Client Resolution Manager%'];
        //for(User u : teamResolution){
        //  emailMap.put(u.name, u.email);
        //}
        List<User> teamAdwordsAndSEO = [select name, email from user where isActive = true and UserRole.name like '%Adwords & SEO Client Manger%'];
        for(User u : teamAdwordsAndSEO){
          emailMap.put(u.name, u.email);
        }


        
        Map<string, report> result = new Map<string, report>();
        system.debug(emailMap.keyset());
        for (string s : emailMap.keyset()) {
          system.debug('###########'+s);
          result.put(s, new report(s));
        }
        
        string domain = URL.getSalesforceBaseUrl().toExternalForm();
        String no_activity_report_url = domain + '/00O6F00000EzYoj';
        String no_open_activity_report_url = domain + '/00O6F00000EzYi5';
        String overdue_report_url = domain + '/00O90000003rCBZ';
        String resume_report_url = domain + '/00O90000003c393';
        String new_cases_report_url = domain + '/00O90000003Gcg3';
        String days14_report_url = domain + '/00O6F00000BigEu';
        String no_calls_14days_report_url = domain + '/00O6F00000FQlEL';
        String pending_signups_report_url = domain + '/00O6F00000BOTMX';
        String adwords_without_id_report_url = domain + '/00O6F00000BXEw4';
        String adwords_alert_report_url = domain + '/00O6F00000EdDiB';
        

        //get the email template
        EmailTemplate template = [Select id, HtmlValue from EmailTemplate where name = 'CM Activity Report'];


        // pending sign up, created in this month
        List<AggregateResult> pending_signups = [SELECT count(id),  Assign_To_User__r.Name Name
        FROM Sign_Up__c 
        WHERE CreatedDate = THIS_MONTH AND status__c = 'Pending CM Call' GROUP BY Assign_To_User__r.Name];
        for (AggregateResult ar : pending_signups)  {
          if (ar.get('Name')!= null){
            result.get(''+ar.get('Name')).pending_signups = Integer.valueOf(ar.get('expr0'));
          }
        }

        //adwords_without_id from account products
        List<AggregateResult> withoutAdwordsId = [ SELECT count(Id), Owner.Name Name
        FROM   Account_Product__c 
        WHERE  Product_Status__c = 'Active' 
        AND (Adwords_ID__c = '' OR Adwords_ID__c='000-000-0000')
        AND Recurring__c = true
        AND Product_Type__c = 'AdWords Management'
        GROUP BY Owner.Name];
        for (AggregateResult ar : withoutAdwordsId)  {
          if ((ar.get('Name')!= null) && (ar.get('expr0')!= null)){
            if ( result.get(''+ar.get('Name')) != null){
              result.get(''+ar.get('Name')).adwords_without_id = Integer.valueOf(ar.get('expr0'));
            }
          }
        }

        // last 14 no activity client number group by CM
        List<Account_Product__c> last14_no_activity = [ SELECT Id, Owner.Name,No_Adwords_Change_14__c,Recurring_Period__c, Product_Status__c, Adwords_ID__c, Active_Days__c, Name, 
        (   SELECT Id , Status__c
            FROM CustomCases__r        
        )
        FROM ACcount_Product__c 
        WHERE  Active_Days__c >= 3 AND Adwords_ID__c <> '' 
        AND No_Adwords_Change_14__c=true 
        AND Product_Status__c = 'Active' 
        AND Name like '%adwords%' 
        AND Recurring_Period__c IN ('Weekly','Fortnightly','Monthly','Quarterly', 'Half Yearly', 'Yearly','2 Yearly')
        ];

        boolean isCount = true;
        for (Account_Product__c item : last14_no_activity)  {
          if ((item.Owner.Name!= null) && ( result.get(item.Owner.Name)!= null)){
            if(item.CustomCases__r.size()>0){
              for(cases__c caseItem : item.CustomCases__r){
                if (caseitem.status__c.equalsignorecase('Escalated') || caseitem.status__c.equalsignorecase('Unresolved')){
                  isCount = false;
                  break;
                }
              }
            }
            if(isCount){
              result.get(item.Owner.Name).days14++;
            }
          }
          isCount = true;
        }

        //get accounts without activity for last 28 days  
        //new logic applied in pardotaccount class to calcualte all the No_Completed_Activity__c of each product
        //need to make sure the pardotaccount script run before this script to ensure the latest value
        //applied on 12 Nov, 2018        
        AggregateResult[] noCompletedProds = [SELECT owner.name OwnerName , count(id)
                                                      FROM
                                                             Account_Product__c
                                                      WHERE
                                                             Product_Status__c = 'Active'
                                                            AND 
                                                              ( NOT Name LIKE 'SEO%')
                                                             AND 
                                                              ( NOT Name LIKE 'Conver%')
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



        // Account with at least one Adwords Alert which is collected by script every night for both GMT and SLX base on Google Adwords system dianostic result
        // just added on 26 OCt 2018
        List<Account_Product__c> adwordAlertAccounts = [ SELECT Id,Name, Adwords_Alert__c, owner.name ,Account__r.Any_Cancellation_Case__c
                                                            
                                                        FROM ACcount_Product__c 
                                                        WHERE  
                                                              Product_Status__c = 'Active' 
                                                              AND (( Name LIKE '%facebook%') OR  (Name LIKE '%yahoo%') OR  (Name LIKE '%adwords%') OR  (Name LIKE '%admob%') OR (Name LIKE '%social%'))
                                                              AND Recurring_Period__c IN ('Weekly','Fortnightly','Monthly','Quarterly', 'Half Yearly', 'Yearly','2 Yearly')
                                                              AND Adwords_Alert__c <> null 
                                                              AND Account__r.Any_Cancellation_Case__c = false
                                                              AND owner.name in: emailMap.keyset()
                                                      ];


        for( Account_Product__c item: adwordAlertAccounts){

          if ((item.Owner.Name!= null) && ( result.get(item.Owner.Name)!= null)){
              if (item.Adwords_Alert__c <> ''){
                  result.get(item.Owner.Name).adword_alert++;
              }
          }
        }




        // account no open activity 
        // new logic applied in pardotaccount class to calcualte all the No_Open_Activity__c of each product
        // need to make sure the pardotaccount script need to run before this script to ensure the latest value
        // applied on 12 Nov, 2018
        AggregateResult[] noActivityProds = [SELECT owner.name OwnerName, count(id) 
                                                    FROM
                                                           Account_Product__c
                                                    WHERE
                                                           Product_Status__c = 'Active'
                                                          AND 
                                                           ( NOT Name LIKE 'SEO%' )
                                                          AND 
                                                           ( NOT Name LIKE 'Conver%')
                                                          AND 
                                                          No_Open_Activity__c = true 
                                                          AND 
                                                            owner.name in :emailMap.keyset()
                                                    GROUP BY Owner.Name
                                                    ];
        for( AggregateResult  ar : noActivityProds){
          String ownerName = ar.get('OwnerName')!= null?ar.get('OwnerName').toString():'';
          if ((ownerName!= null) && ( result.get(ownerName)!= null) ) {
              result.get(ownerName).no_open_avtivity_accounts = Integer.valueof(ar.get('expr0'));
          }
        }




        // No call made from last 14days
        // correspondent report :  https://sponsoredlinx.my.salesforce.com/00O6F00000FQlEL        
        // applied on 10 Jan, 2019        
        AggregateResult[] noCallLast14DayProds = [SELECT owner.name OwnerName, count(id) 
                                                    FROM
                                                           Account_Product__c
                                                    WHERE
                                                          Product_Status__c = 'Active'
                                                          AND Last_14_days_num_of_calls__c = 0
                                                          AND Recurring__c = true
                                                          AND 
                                                           ( NOT Name LIKE 'SEO%' )
                                                          AND 
                                                           ( NOT Name LIKE 'Conver%')                                                          
                                                          AND 
                                                            owner.name in :emailMap.keyset()
                                                    GROUP BY Owner.Name
                                                    ];
        for( AggregateResult  ar : noCallLast14DayProds){
          String ownerName = ar.get('OwnerName')!= null?ar.get('OwnerName').toString():'';
          if ((ownerName!= null) && ( result.get(ownerName)!= null) ) {
              result.get(ownerName).no_calls_last14days = Integer.valueof(ar.get('expr0'));
          }
        }


        //get overdue tasks
        Task[] tks = [select
        owner.name
        from
        Task
        where
        ActivityDate = LAST_N_DAYS:120
        and
        status = 'Not Started'
        and
        owner.name in: emailMap.keyset()
        ];
        for (Task tk : tks) {
          if(result.containsKey(tk.owner.name)) {
            result.get(tk.owner.name).overdue_tasks++;
          }
        }
        
        //get resuming account_products
        Account_product__c[] aps = [select
        owner.name
        from
        account_product__c
        where
        activeat__c = today
        and
        (name like '%adwords%' or name like '%facebook%' or name like '%yahoo%' or name like '%admob%')
        and
        Recurring_Period__c != null
        and
        Recurring_Period__c != 'N/A'
        and
        account__r.owner.name in: emailMap.keyset()
        ]; 
        
        for (account_product__c ap : aps) {
          if(result.containsKey(ap.owner.name)) {
            result.get(ap.owner.name).resume_accounts++;
          }
        }
        
        //get new cases
        Cases__c[] cas = [select
        owner.name
        from
        Cases__c
        where
        status__c = 'New'
        and
        owner.name in: emailMap.keyset()              
        ];
        for (Cases__c ca : cas) {
          if(result.containsKey(ca.owner.name)) {
            result.get(ca.owner.name).new_cases++;
          }
        }
        
        
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        String emailBody;
        Messaging.SingleEmailMessage mail;
        String[] toAddresses;
        
        //Send report to the CM
        for(String name : result.keyset()) {
          emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2"  rules="all" cellpadding="10" style="text-align:left;">';
          emailBody += '<thead>';
          emailBody += '<tr>';
          emailBody += '<th>Client Manager</th>';
          emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
          emailBody += '<th>No Open Activity Account</th>';          
          emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
          emailBody += '<th>Resume Today</th>';
          emailBody += '<th>New Cases</th>';
          emailBody += '<th>AdWords Without ID</th>';
          emailBody += '<th>Pending Signups</th>';
          emailBody += '<th>Adwords Alert</th>';
          emailBody += '<th>Last 14days No Call</th>';
          emailBody += '<th>Last 14days No Activity</th>';
          emailBody += '</tr>';
          emailBody += '</thead>';
          emailBody += '<tbody>';
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ;   
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;
          emailBody += '</tr>';
          emailBody += '</tbody>';
          emailBody += '</table>';
          
          mail = new Messaging.SingleEmailMessage();
          try {
            if(isTest) {
              toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
              } else {
                toAddresses = new String[] {emailMap.get(name)};
              }

            // get template
            mail.setTemplateID(template.Id); 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Daily Report');
            mail.setSubject('Client Manager Daily Report');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('[email_content]', emailBody);
            mail.setHtmlBody(htmlBody);        
            mails.add(mail);
            } catch (Exception e) {
              emailBody = 'Cannot get email address from CM ' + name + '. ' + e.getMessage();
              toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
              mail.setToAddresses(toAddresses);
              mail.setSenderDisplayName('CM Activity Report Error');
              mail.setSubject('Getting CM Email Failed');
              mail.setBccSender(false);
              mail.setUseSignature(false);
              mail.setHtmlBody(emailBody);
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
              
              return;
            }
            
          }
          
        //Send to teamA leader
        Map<string, report> resultA = new Map<string, report>();
        for (User u : teamA) {
          resultA.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">Team A</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>AdWords Without ID</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Adwords Alert</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '<th>Last 14days No Activity</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultA.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ;          
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;
          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';
        
        mail = new Messaging.SingleEmailMessage();
        User[] TLA = [select name, email from user where isActive = true and UserRole.name like '%Client Manager Team A Leader%'];
        if(isTest) {
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
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        String allCMEmailBody = emailBody; 
        
        //Send to teamB leader
        Map<string, report> resultB = new Map<string, report>();
        for (User u : teamB) {
          resultB.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">Team B</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>AdWords Without ID</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Adwords Alert</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '<th>Last 14days No Activity</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultB.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ;       
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;   
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;
          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';
        
        mail = new Messaging.SingleEmailMessage();
        User[] TLB = [select name, email from user where isActive = true and UserRole.name like '%Client Manager Team B Leader%'];
        if(isTest) {
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
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        allCMEmailBody += '<br><br><br>' + emailBody;
        
        
        //Send to teamC leader
        Map<string, report> resultC = new Map<string, report>();
        for (User u : teamC) {
          resultC.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">Team C</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>AdWords Without ID</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Adwords Alert</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '<th>Last 14days No Activity</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultC.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ; 
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;         
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;

          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';
        
        mail = new Messaging.SingleEmailMessage();
        User[] TLC = [select name, email from user where isActive = true and (UserRole.name like '%Client Manager Team C Leader%' Or UserRole.name like '%PPC Manager%' or UserRole.Name = 'Client Resolution Manager Team C')];
        if(isTest) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
          } else {
            toAddresses = new List<String>();
            for(User u : TLC) {
              toAddresses.add(u.email);
            }
          }

        // get template   
        mail.setTemplateID(template.Id); 

        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(htmlBody);        
        mails.add(mail);
        allCMEmailBody += '<br><br><br>' + emailBody;
        
        //Send to teamGMT Team A leader
        Map<string, report> resultGMTA = new Map<string, report>();
        for (User u : teamGMTA) {
          resultGMTA.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">GMT Team A</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>AdWords Without ID</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Adwords Alert</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '<th>Last 14days No Activity</th>';

        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultGMTA.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ;          
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;

          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';
        
        mail = new Messaging.SingleEmailMessage();
        User[] TLGMTA = [select name, email from user where isActive = true and UserRole.name = 'Client Manager GMT Team A Leader'];
        if(isTest) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
          } else {
            toAddresses = new List<String>();
            for(User u : TLGMTA) {
              toAddresses.add(u.email);
            }
            toAddresses.add('kerry.anderson@sponsoredlinx.com');
          }

        // get template    
        mail.setTemplateID(template.Id); 

        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(emailBody);
        
        mails.add(mail);
        allCMEmailBody += '<br><br><br>' + emailBody;
        
        //Send to teamGMT Team B leader
        Map<string, report> resultGMTB = new Map<string, report>();
        for (User u : teamGMTB) {
          resultGMTB.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">GMT Team B</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>AdWords Without ID</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Adwords Alert</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '<th>Last 14days No Activity</th>';

        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        for(String name : resultGMTB.keySet()) {
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ;   
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;       
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;

          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';
        
        mail = new Messaging.SingleEmailMessage();
        User[] TLGMTB = [select name, email from user where isActive = true and UserRole.name = 'Client Manager GMT Team B Leader'];
        if(isTest) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
          } else {
            toAddresses = new List<String>();
            for(User u : TLGMTB) {
              toAddresses.add(u.email);
            }
            toAddresses.add('kerry.anderson@sponsoredlinx.com');
          }

        // get template    
        mail.setTemplateID(template.Id);
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Team Leader Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('[email_content]', emailBody);
        mail.setHtmlBody(htmlBody);        

        mails.add(mail);
        allCMEmailBody += '<br><br><br>' + emailBody;
        
        //Send to Ben & COM
        //add resolution managers block in email body
        //Map<string, report> resultResolution = new Map<string, report>();
        //for (User u : teamResolution) {
        //  resultResolution.put(u.name, result.get(u.name));
        //}
        //emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        //emailBody += '<caption style="font-size:25px;font-weight:bold;">Resolution Managers</caption>';
        //emailBody += '<thead>';
        //emailBody += '<tr>';
          //emailBody += '<th>Name</th>';
          //emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
          //emailBody += '<th>No Open Activity Account</th>';
          //emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
           //emailBody += '<th>Resume Today</th>';
          //emailBody += '<th>New Cases</th>';
          //emailBody += '</tr>';
          //emailBody += '</thead>';
          //emailBody += '<tbody>';
        //for(String name : resultResolution.keySet()) {
        //    emailBody += '<tr>';
        //    emailBody += '<td>'+ name + '</td>';
        //    emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
        //    emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
        //    emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
        //    emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
        //    emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
        //    emailBody += '</tr>';
        //}
        //emailBody += '</tbody>';
        //emailBody += '</table>';
        //allCMEmailBody += '<br><br><br>' + emailBody;
        
        //add Nathan in email body
        Map<string, report> resultAdwordsAndSEO = new Map<string, report>();
        for (User u : teamAdwordsAndSEO) {
          resultAdwordsAndSEO.put(u.name, result.get(u.name));
        }
        emailBody = '<table style="border-color: #69717a; background-color: #ffffff;" border="2" rules="all" cellpadding="10" style="text-align:left;">';
        emailBody += '<caption style="font-size:25px;font-weight:bold;">Adwords And SEO Manager</caption>';
        emailBody += '<thead>';
        emailBody += '<tr>';
        emailBody += '<th>Name</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
        emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
        emailBody += '<th>AdWords Without ID</th>';
        emailBody += '<th>Pending Signups</th>';
        emailBody += '<th>Adwords Alert</th>';
        emailBody += '<th>Last 14days No Call</th>';
        emailBody += '<th>Last 14days No Activity</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';

        for(String name : resultAdwordsAndSEO.keySet()) {
          emailBody += '<tr>';
          emailBody += '<tr>';
          emailBody += '<td>'+ name + '</td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_activity_report_url+'">'+result.get(name).no_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+no_open_activity_report_url+'">'+result.get(name).no_open_avtivity_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+overdue_report_url+'">'+result.get(name).overdue_tasks+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+resume_report_url+'">'+result.get(name).resume_accounts+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+new_cases_report_url+'">'+result.get(name).new_cases+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+adwords_without_id_report_url+'">'+result.get(name).adwords_without_id+'</a></td>';
          emailBody += '<td style="text-align:center;"><a href="'+pending_signups_report_url+'">'+result.get(name).pending_signups+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+adwords_alert_report_url+'">'+result.get(name).adword_alert+'</a></td>' ;          
          emailBody += '<td style="text-align:center;"><a href="'+no_calls_14days_report_url +'">'+result.get(name).no_calls_last14days+'</a></td>' ;
          emailBody += '<td style="text-align:center;"><a href="'+days14_report_url+'">'+result.get(name).days14+'</a></td>' ;

          emailBody += '</tr>';
        }
        emailBody += '</tbody>';
        emailBody += '</table>';
        allCMEmailBody += '<br><br><br>' + emailBody;

        mail = new Messaging.SingleEmailMessage();
        User[] COM = [select name, email from user where isActive = true and UserRole.name like '%Client Operations Manager%'];
        if(isTest) {
          toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
          } else {
            toAddresses = new List<String>();
            toAddresses.add('benbjb@sponsoredlinx.com');
            
            // Add more Amber by request on 22 June 2018, to get whole CM floor reports
            toAddresses.add('amber.porter@sponsoredlinx.com');      


            // Add David by request on 24 Sep 2018, to get whole CM floor reports
            toAddresses.add('david.powell@sponsoredlinx.com');


            // Add more Shannah by request on 22 Oct 2018, to get whole CM floor reports
            toAddresses.add('shannah.bradshaw@sponsoredlinx.com');


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
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Client Managers Daily Report');
        mail.setUseSignature(false);
        htmlBody = template.HtmlValue;        
        htmlBody = htmlBody.replace('[email_content]', allCMEmailBody);

        mail.setHtmlBody(htmlBody);        

        mails.add(mail);
        try{
            Messaging.sendEmail(mails);
          }catch(Exception e){
            System.debug(e.getMessage());
          }
        }
        
        public class report {
          String name {get; set;} //cm name
          integer no_avtivity_accounts {get; set;}
          integer no_open_avtivity_accounts {get; set;}
          integer overdue_tasks {get; set;}      
          integer days14 {get; set;}
          integer pending_signups {get; set;}
          integer adwords_without_id {get; set;}
          integer resume_accounts {get; set;}
          integer new_cases {get; set;}     
          integer no_calls_last14days {get; set;}
          integer adword_alert {get; set;}     
          
          public report(String s) {
            this.name = s;
            this.no_avtivity_accounts = 0;
            this.no_open_avtivity_accounts = 0;
            this.overdue_tasks = 0;
            this.days14 =0;
            this.pending_signups =0;
            this.adwords_without_id =0;
            this.resume_accounts = 0;
            this.new_cases = 0;
            this.no_calls_last14days = 0;
            this.adword_alert = 0;
          }
        }

        public static testmethod void ActivityReportTest() {
          Test.StartTest();

          ActivityReport ar = new ActivityReport(true);
          
          Test.stopTest();
        }
      }