public with sharing class ActivityReport{
  public ActivityReport(Boolean isTest) {      
    Map<String, String> emailMap = new Map<String, String>();
  
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
    String no_activity_report_url = domain + '/00O90000005PBgY';
    String no_open_activity_report_url = domain + '/00O90000004WeCW';
    String overdue_report_url = domain + '/00O90000003rCBZ';
    String resume_report_url = domain + '/00O90000003c393';
    String new_cases_report_url = domain + '/00O90000003Gcg3';
        
    //get accounts without activity for last 28 days  
    account[] accs = [select
              owner.name,
              (select
                          id
                        from
                          Account_Products__r
                        where
                          (name like '%adwords%' or name like '%facebook%' or name like '%yahoo%' or name like '%admob%')
                         and
                Recurring_Period__c != null
               and
                Recurring_Period__c != 'N/A'
                         and
                           Product_status__c = 'Active'
                        )
            from
              Account
            where
              LastActivityDate < LAST_N_DAYS:28
            and
              Active__c = true
            and
              owner.name in: emailMap.keyset()
    ];
            
    for (account acc : accs) {
      if(acc.Account_Products__r.size() > 0 && result.containsKey(acc.owner.name)) {
        result.get(acc.owner.name).no_avtivity_accounts++;
      }
    }
    
    //get accounts without open activitiy
      Date current = System.today();
    accs = [select
          owner.name,
          (select
            id
          from
            OpenActivities
          where
                  Status =	'Not Started'
           limit 1
          ),
          (select
                      id
                    from
                      Account_Products__r
                    where
                      (name like '%adwords%' or name like '%facebook%' or name like '%yahoo%' or name like '%admob%')
                     and
                     Recurring_Period__c != ''
                      and
                    Recurring_Period__c != 'N/A'
                     and
                       Product_status__c = 'Active'
                    )
        from
          Account
        where
          Active__c = true
        and
          owner.name in: emailMap.keyset()
    ];
     
    for (account acc : accs) {
      if(acc.OpenActivities.size() == 0 && acc.Account_Products__r.size() > 0 && result.containsKey(acc.owner.name)) {
        System.debug('Ownername = ' + acc.owner.name + 'Account ID = ' + acc.Id);
        result.get(acc.owner.name).no_open_avtivity_accounts++;
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
      emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
      emailBody += '<thead>';
      emailBody += '<tr>';
        emailBody += '<th>Client Manager</th>';
        emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
        emailBody += '<th>No Open Activity Account</th>';
        emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
         emailBody += '<th>Resume Today</th>';
        emailBody += '<th>New Cases</th>';
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
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Daily Report');
        mail.setSubject('Client Manager Daily Report');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody(emailBody);
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
    emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
    emailBody += '<caption style="font-size:25px;font-weight:bold;">Team A</caption>';
    emailBody += '<thead>';
    emailBody += '<tr>';
      emailBody += '<th>Client Manager</th>';
      emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
      emailBody += '<th>No Open Activity Account</th>';
      emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
       emailBody += '<th>Resume Today</th>';
      emailBody += '<th>New Cases</th>';
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
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Daily Report');
    mail.setSubject('Team Leader Daily Report');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setHtmlBody(emailBody);
    mails.add(mail);
    String allCMEmailBody = emailBody; 
    
    //Send to teamB leader
    Map<string, report> resultB = new Map<string, report>();
    for (User u : teamB) {
      resultB.put(u.name, result.get(u.name));
    }
    emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
    emailBody += '<caption style="font-size:25px;font-weight:bold;">Team B</caption>';
    emailBody += '<thead>';
    emailBody += '<tr>';
      emailBody += '<th>Client Manager</th>';
      emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
      emailBody += '<th>No Open Activity Account</th>';
      emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
       emailBody += '<th>Resume Today</th>';
      emailBody += '<th>New Cases</th>';
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
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Daily Report');
    mail.setSubject('Team Leader Daily Report');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setHtmlBody(emailBody);
    mails.add(mail);
    allCMEmailBody += '<br><br><br>' + emailBody;
    
    
    //Send to teamC leader
    Map<string, report> resultC = new Map<string, report>();
    for (User u : teamC) {
      resultC.put(u.name, result.get(u.name));
    }
    emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
    emailBody += '<caption style="font-size:25px;font-weight:bold;">Team C</caption>';
    emailBody += '<thead>';
    emailBody += '<tr>';
      emailBody += '<th>Client Manager</th>';
      emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
      emailBody += '<th>No Open Activity Account</th>';
      emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
       emailBody += '<th>Resume Today</th>';
      emailBody += '<th>New Cases</th>';
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
        emailBody += '</tr>';
    }
    emailBody += '</tbody>';
    emailBody += '</table>';
    
    mail = new Messaging.SingleEmailMessage();
    User[] TLC = [select name, email from user where isActive = true and (UserRole.name like '%Client Manager Team C Leader%' or UserRole.Name = 'Client Resolution Manager Team C')];
    if(isTest) {
      toAddresses = new String[] {'hanh.luu@sponsoredlinx.com'};
    } else {
      toAddresses = new List<String>();
      for(User u : TLC) {
        toAddresses.add(u.email);
      }
    }
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Daily Report');
    mail.setSubject('Team Leader Daily Report');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setHtmlBody(emailBody);
    mails.add(mail);
    allCMEmailBody += '<br><br><br>' + emailBody;
    
    //Send to teamGMT Team A leader
    Map<string, report> resultGMTA = new Map<string, report>();
    for (User u : teamGMTA) {
      resultGMTA.put(u.name, result.get(u.name));
    }
    emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
    emailBody += '<caption style="font-size:25px;font-weight:bold;">GMT Team A</caption>';
    emailBody += '<thead>';
    emailBody += '<tr>';
      emailBody += '<th>Client Manager</th>';
      emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
      emailBody += '<th>No Open Activity Account</th>';
      emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
       emailBody += '<th>Resume Today</th>';
      emailBody += '<th>New Cases</th>';
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
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Daily Report');
    mail.setSubject('Team Leader Daily Report');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setHtmlBody(emailBody);
    mails.add(mail);
    allCMEmailBody += '<br><br><br>' + emailBody;
    
    //Send to teamGMT Team B leader
    Map<string, report> resultGMTB = new Map<string, report>();
    for (User u : teamGMTB) {
      resultGMTB.put(u.name, result.get(u.name));
    }
    emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
    emailBody += '<caption style="font-size:25px;font-weight:bold;">GMT Team B</caption>';
    emailBody += '<thead>';
    emailBody += '<tr>';
      emailBody += '<th>Client Manager</th>';
      emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
      emailBody += '<th>No Open Activity Account</th>';
      emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
       emailBody += '<th>Resume Today</th>';
      emailBody += '<th>New Cases</th>';
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
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Daily Report');
    mail.setSubject('Team Leader Daily Report');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setHtmlBody(emailBody);
    mails.add(mail);
    allCMEmailBody += '<br><br><br>' + emailBody;
    
    //Send to Ben & COM
    //add resolution managers block in email body
    //Map<string, report> resultResolution = new Map<string, report>();
    //for (User u : teamResolution) {
    //  resultResolution.put(u.name, result.get(u.name));
    //}
    //emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
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
    emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
    emailBody += '<caption style="font-size:25px;font-weight:bold;">Adwords And SEO Manager</caption>';
    emailBody += '<thead>';
    emailBody += '<tr>';
      emailBody += '<th>Name</th>';
      emailBody += '<th>No Completed Activity Account (Last 4 Weeks)</th>';
      emailBody += '<th>No Open Activity Account</th>';
      emailBody += '<th>Overdue Tasks (Last 120 Days)</th>';
       emailBody += '<th>Resume Today</th>';
      emailBody += '<th>New Cases</th>';
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
      for(User u : COM) {
        toAddresses.add(u.email);
      }
    }
    mail.setToAddresses(toAddresses);
      system.debug('email address : toAddresses = '  + toAddresses);
    String[] bccAddresses = new String[] { 'salesforce@sponsoredlinx.com' };
    mail.setBccAddresses(bccAddresses);
    mail.setSenderDisplayName('Daily Report');
    mail.setSubject('Client Managers Daily Report');
    mail.setUseSignature(false);
    mail.setHtmlBody(allCMEmailBody);
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
      integer new_cases {get; set;}
      integer resume_accounts {get; set;}
      
      public report(String s) {
            this.name = s;
            this.no_avtivity_accounts = 0;
            this.no_open_avtivity_accounts = 0;
            this.overdue_tasks = 0;
            this.new_cases = 0;
            this.resume_accounts = 0;
        }
    }

    public static testmethod void ActivityReportTest() {
    Test.StartTest();

    ActivityReport ar = new ActivityReport(true);
    
    Test.stopTest();
  }
}