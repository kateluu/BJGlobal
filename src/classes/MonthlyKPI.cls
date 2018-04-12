global class MonthlyKPI {
  // Get Team A and Team B members
  public Map<String, Map<String, String>> teamA      = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> teamB      = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> teamC      = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> gmtTeamA   = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> gmtTeamB   = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> seoTeamA   = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> seoTeamB   = new Map<String, Map<String, String>>{};
  public Map<String, Map<String, String>> teamOther  = new Map<String, Map<String, String>>{};
  
  global MonthlyKPI(){
    
    User[] users = [select Name, UserRole.Name from User where (UserRole.Name like '%Client%' or UserRole.Name like '%SEO%' or UserRole.Name like 'Resolution%')];
    // Initialise users map
    for(User user : users){
        system.debug(user.Name);
        system.debug(user.UserRole.Name);
      Map<String, String> m = new Map<String, String>();
      m.put('Active','0');
      m.put('Paused','0');
      m.put('Total_Pause','0');
      m.put('Setups','0');
      m.put('Cancelled','0');
      m.put('Revenue','0');
      m.put('Unpaid_Revenue','0');
      m.put('Waivers','0');
      m.put('Pause_Revenue', '0');
      m.put('Cancel_Revenue', '0');
      m.put('Credits','0');
      m.put('Refunds', '0');
      //m.put('Unpaid_Active', '0');
      //m.put('Void_Revenue', '0');
      m.put('NPS', '0');
      
        if(user.UserRole.Name.contains('Client Manager Team A') || user.UserRole.Name == 'Client Resolution Manager Team A'){
            teamA.put(user.Name, m);
        }
        else if(user.UserRole.Name.contains('Client Manager Team B') || user.UserRole.Name == 'Client Resolution Manager Team B'){
            teamB.put(user.Name, m);
        }
        else if(user.UserRole.Name.contains('Client Manager Team C') || user.UserRole.Name == 'Client Resolution Manager Team C'){
            teamC.put(user.Name, m);
        }else if(user.UserRole.Name.contains('Client Manager GMT Team A')){
            gmtTeamA.put(user.Name, m);
        }else if(user.UserRole.Name.contains('Client Manager GMT Team B')){
            gmtTeamB.put(user.Name, m);
        }else if(user.UserRole.Name.contains('SLX (Aus) SEO Team A')){
          seoTeamA.put(user.Name, m);
        }else if(user.UserRole.Name.contains('SLX (Aus) SEO Team B')){
          seoTeamB.put(user.Name, m);
        }else{
          teamOther.put(user.Name, m);
        }
    }
    system.debug(teamA);
    system.debug(teamB);
    system.debug(teamC);
    system.debug(gmtTeamA);
    system.debug(gmtTeamB);
    system.debug(seoTeamA);
    system.debug(seoTeamB);
    system.debug(teamOther);
    
    //CM_Stats__c[] cmstats = [select id from CM_Stats__c where report_date__c = today];
    //if(cmstats.size() == 0) {
    //  //initialize('Team A', teamA);
    //  //initialize('Team B', teamB);
    //  //initialize('Team C', teamC);
    //  //initialize('GMT Team A', gmtTeamA);
    //  //initialize('GMT Team B', gmtTeamB);
    //  //initialize('SEO Team A', seoTeamA);
    //  //initialize('SEO Team B', seoTeamB);
    //  //initialize('Team Other', teamOther);
    //}
    
    AggregateResult[] groupedResults = new List<AggregateResult>();    
    
    try{
        // Active Number of Clients Per CM
        groupedResults = [SELECT Owner.Name, count(Id)
                                            FROM Account_Product__c
                                            Where Product_Status__c = 'Active'
                                            and (Name like '%Adwords%' or Name like '%Facebook%' or Name like '%Admob%' or Name like '%Yahoo%' or Name like '%google+%' or Name like '%SEO%' or Name like '%Social Media%')
                                            and Recurring_period__c != '' and Recurring_Period__c != 'N/A'
//                                            and Owner.IsActive = true
                                            GROUP BY Owner.Name];
        system.debug(groupedResults);
        for (AggregateResult ar : groupedResults){
            System.debug('Owner' + ar.get('Name'));
            System.debug('Active Proudct Numbers: ' + ar.get('expr0'));
            String name = string.valueOf(ar.get('Name'));
            system.debug(name);
            saveCMStats(name,string.valueOf(ar.get('expr0')),  'Active');
        }
        
        // Unpaid Active Clients Per CM
        //groupedResults = [SELECT Owner.Name, count(Id)
        //                                    FROM Account_Product__c
        //                                    Where Product_Status__c = 'Active'
        //                                    and (Name like '%Adwords%' or Name like '%Facebook%' or Name like '%Admob%' or Name like '%Yahoo%' or Name like '%google+%' or Name like '%SEO%' or Name like '%Social Media%')
        //                                    and (Recurring_period__c = 'Weekly' or Recurring_Period__c = 'Fortnightly' or Recurring_Period__c = 'Monthly')
        //                                    and Owner.IsActive = true
        //                                    AND No_Charge__c = false
        //                                    AND CreatedDate < THIS_MONTH
        //                                    AND Payment_Made_This_Month__c <= 0
        //                                    GROUP BY Owner.Name];
                                          
        //system.debug(groupedResults);
        //for (AggregateResult ar : groupedResults){
        //    System.debug('Owner' + ar.get('Name'));
        //    System.debug('Unpaid Active Number : ' + ar.get('expr0'));
        //    String name = string.valueOf(ar.get('Name'));
        //    system.debug(name);
        //    saveCMStats(name,string.valueOf(ar.get('expr0')),  'Unpaid_Active');
        //}
        
        // Current Paused Clients per CM
       // groupedResults = [SELECT Owner.Name, count(Id)
       //                   FROM Account_Product__c
       //                   Where (Name like '%Adwords%' or Name like '%Facebook%' or Name like '%Admob%' or Name like '%Yahoo%' or Name like '%google+%' or Name like '%SEO%')
       //                   and pauseat__c = THIS_MONTH
       //                   and Recurring_period__c != '' and Recurring_Period__c != 'N/A'
       //                   and Owner.IsActive = true
       //                   GROUP BY Owner.Name];
       // system.debug(groupedResults);
       // for (AggregateResult ar : groupedResults)  {
       //     System.debug('Owner' + ar.get('Name'));
       //     System.debug('Paused Proudct Numbers: ' + ar.get('expr0'));
       //     String name = string.valueOf(ar.get('Name'));
       //     system.debug(name);
       //     saveCMStats(name, string.valueOf(ar.get('expr0')), 'Paused');
       // }
        
        // Current Paused Clients per CM, exclude STP
        groupedResults = [SELECT Owner.Name, count(Id)
                          FROM Account_Product__c
                          Where Product_Status__c = 'Paused' and (Name like '%Adwords%' or Name like '%Facebook%' or Name like '%Admob%' or Name like '%Yahoo%' or Name like '%google+%' or Name like '%SEO%' or Name like '%Social Media%')
                          and Recurring_period__c != '' and Recurring_Period__c != 'N/A'
  //                        and Owner.IsActive = true
                          and Sold_to_Pause__c = false
                          GROUP BY Owner.Name];
        for (AggregateResult ar : groupedResults)  {
            System.debug('Owner' + ar.get('Name'));
            System.debug('Current Proudct Numbers: ' + ar.get('expr0'));
            String name = string.valueOf(ar.get('Name'));
            saveCMStats(name, string.valueOf(ar.get('expr0')), 'Total_Pause');
            system.debug(name);
            
        }
        
        // Cancellations per CM
        groupedResults = [SELECT Owner.Name, count(Id),
        						SUM(Cancelled_Revenue__c)
                          FROM Cases__c
                          Where Cancellation_Date__c = THIS_MONTH
     //                     and Owner.IsActive = true
                          GROUP BY Owner.Name];
        system.debug(groupedResults);
        for (AggregateResult ar : groupedResults)  {
            System.debug('Owner' + ar.get('Name'));
            System.debug('Cacellations: ' + ar.get('expr0'));
            String name = string.valueOf(ar.get('Name'));
            system.debug(name);
            saveCMStats(name, string.valueOf(ar.get('expr0')), 'Cancelled');
            saveCMStats(name, string.valueOf(ar.get('expr1')), 'Cancel_Revenue');
        }
        
        // Completed Setups
      groupedResults = [SELECT Owner.Name, count(Id)
                FROM Sign_Up__c
                Where Completed_Date__C = THIS_MONTH
       //         and Account__r.Owner.IsActive = true
                GROUP BY Owner.Name];
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('Completed Setups: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Setups');
      }
      
      //Revenue Per CM
      groupedResults = [SELECT Payment_owner__r.Name, sum(Payment_Amount__c)
                FROM Payment__c
                Where (Invoice__r.Account_Product__r.Name like '%Adwords%' or Invoice__r.Account_Product__r.Name like '%Facebook%' or Invoice__r.Account_Product__r.Name like '%Admob%' or Invoice__r.Account_Product__r.Name like '%Yahoo%' or Invoice__r.Account_Product__r.Name like '%google+%' or Invoice__r.Account_Product__r.Name like '%SEO%' or Invoice__r.Account_Product__r.Name like '%Social Media%')
                AND Payment_Date__c = THIS_MONTH
                AND Payment_Type__c != 'Credit'
    //            AND Invoice__r.Account_Product__r.Owner.IsActive = true
    //            GROUP BY Invoice__r.Account_Product__r.Owner.Name];
                 GROUP BY Payment_owner__r.Name];
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('Total Revenue: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Revenue');
      }

      //Credit Per CM
      groupedResults = [SELECT Owner.Name, SUM(Credit_Amount__c)
                          FROM Cases__c
                          Where unresolved_date__c = THIS_MONTH
      //                    and Owner.IsActive = true
                          and Credit_Amount__c != null
                          GROUP BY Owner.Name];
      system.debug(groupedResults);
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('Credit Amount: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Credits');
      }

      //Refunds Per CM
      groupedResults = [SELECT Owner.Name, SUM(Refund_Amount__c)
                          FROM Cases__c
                          Where unresolved_date__c = THIS_MONTH
      //                    and Owner.IsActive = true
                          and Refund_Amount__c != null
                          GROUP BY Owner.Name];
      system.debug(groupedResults);
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('Refund Amount: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Refunds');
      }

      //Waivers Per CM
      groupedResults = [SELECT Owner.Name, SUM(Waiver_Request_Amount__c)
                          FROM Cases__c
                          Where unresolved_date__c = THIS_MONTH
      //                    and Owner.IsActive = true
                          and Waiver_Request_Amount__c != null
                          GROUP BY Owner.Name];
      system.debug(groupedResults);
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('Waivers Amount: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Waivers');
      }
      
      //Credits Per CM
      //groupedResults = [SELECT Invoice__r.Account_Product__r.Owner.Name, sum(Payment_Amount__c)
      //          FROM Payment__c
      //          Where (Invoice__r.Account_Product__r.Name like '%Adwords%' or Invoice__r.Account_Product__r.Name like '%Facebook%' or Invoice__r.Account_Product__r.Name like '%Admob%' or Invoice__r.Account_Product__r.Name like '%Yahoo%' or Invoice__r.Account_Product__r.Name like '%google+%' or Invoice__r.Account_Product__r.Name like '%SEO%' or Invoice__r.Account_Product__r.Name like '%Social Media%')
      //          AND Payment_Date__c = THIS_MONTH
      //          AND Payment_Type__c = 'Credit'
      //          AND Invoice__r.Account_Product__r.Owner.IsActive = true
      //          GROUP BY Invoice__r.Account_Product__r.Owner.Name];
      //for (AggregateResult ar : groupedResults)  {
      //  String name = string.valueOf(ar.get('Name'));
      //  System.debug('Credits: ' + ar.get('expr0'));
      //  saveCMStats(name, string.valueOf(ar.get('expr0')), 'Credits');
      //}
      
      //Refunds Per CM
      //groupedResults = [SELECT Invoice__r.Account_Product__r.Owner.Name, sum(Payment_Amount__c)
      //          FROM Payment__c
      //          Where (Invoice__r.Account_Product__r.Name like '%Adwords%' or Invoice__r.Account_Product__r.Name like '%Facebook%' or Invoice__r.Account_Product__r.Name like '%Admob%' or Invoice__r.Account_Product__r.Name like '%Yahoo%' or Invoice__r.Account_Product__r.Name like '%google+%' or Invoice__r.Account_Product__r.Name like '%SEO%' or Invoice__r.Account_Product__r.Name like '%Social Media%')
      //          AND Payment_Date__c = THIS_MONTH
      //          AND Payment_Type__c = 'Refund'
      //          AND Invoice__r.Account_Product__r.Owner.IsActive = true
      //          AND (NOT Invoice__r.Invoice_Number__c like 'INV%')
      //          GROUP BY Invoice__r.Account_Product__r.Owner.Name];
      //for (AggregateResult ar : groupedResults)  {
      //  String name = string.valueOf(ar.get('Name'));
      //  System.debug('Refunds: ' + ar.get('expr0'));
      //  saveCMStats(name, string.valueOf(ar.get('expr0')), 'Refunds');
      //}
      
     // Unpaid Revenue Per CM
      groupedResults = [SELECT Account_Product__r.Owner.Name, sum(Amount_Due__c)
                FROM Invoice__c
                Where (Account_Product__r.name like '%Adwords%' or Account_Product__r.Name like '%Facebook%' or Account_Product__r.Name like '%Admob%' or Account_Product__r.Name like '%Yahoo%' or Account_Product__r.Name like '%google+%' or Account_Product__r.Name like '%SEO%' or Account_Product__r.Name like '%Social Media%')
                AND Amount_Due__c > 0
                AND Issue_Date__c = THIS_MONTH
                AND (Status__c = 'AUTHORISED' or Status__c = 'PARTIALLY PAID' or  Status__c = 'PARTIALLY CREDITED')
      //          AND Account__r.Owner.IsActive = true
                GROUP BY Account_Product__r.Owner.Name];
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('Unpaid Revenue: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Unpaid_Revenue');
      }
      
      //Void Revenue Per CM
      //groupedResults = [SELECT Account_Product__r.Owner.Name, sum(Amount_Due__c)
      //          FROM Invoice__c
      //          Where (Account_Product__r.name like '%Adwords%' or Account_Product__r.Name like '%Facebook%' or Account_Product__r.Name like '%Admob%' or Account_Product__r.Name like '%Yahoo%' or Account_Product__r.Name like '%google+%' or Account_Product__r.Name like '%SEO%' or Account_Product__r.Name like '%Social Media%')
      //          AND Amount_Due__c > 0
      //          AND Issue_Date__c = THIS_MONTH
      //          AND Status__c = 'VOID'
      //          AND Account_Product__r.Owner.IsActive = true
      //          GROUP BY Account_Product__r.Owner.Name];
      //for (AggregateResult ar : groupedResults)  {
      //  String name = string.valueOf(ar.get('Name'));
      //  System.debug('Void Revenue: ' + ar.get('expr0'));
      //  saveCMStats(name, string.valueOf(ar.get('expr0')), 'Void_Revenue');
      //}
      
      //NPS received this month per CM
      groupedResults = [SELECT simplesurvey__Record_Owner__r.Name, avg(simplesurvey__Survey_Score__c)
                FROM simplesurvey__Survey__c
                Where CreatedDate = THIS_MONTH
                GROUP BY simplesurvey__Record_Owner__r.Name];
      for (AggregateResult ar : groupedResults)  {
        String name = string.valueOf(ar.get('Name'));
        System.debug('NPS: ' + ar.get('expr0'));
        saveCMStats(name, string.valueOf(ar.get('expr0')), 'NPS');
      }
      
      //Waivers Approved Per CM
      //groupedResults = [SELECT Owner.Name, count(Id)
        //                  FROM Cases__c
        //                  Where Cancellation_Date__c = THIS_MONTH
        //                  and Owner.IsActive = true
        //                  and X2012_Cancellation_Waiver_approved__c = true
        //                  GROUP BY Owner.Name];
        //system.debug(groupedResults);
      //for (AggregateResult ar : groupedResults)  {
      //  String name = string.valueOf(ar.get('Name'));
      //  System.debug('Waiver Approved: ' + ar.get('expr0'));
      //  saveCMStats(name, string.valueOf(ar.get('expr0')), 'Waiver');
      //}
      
      
      //Paused Revenue Per CM
      // Account_product__c[] aps = [select
        //             	product_price__c, 
        //             	pauseat__c,
        //             	activeat__c, 
        //             	Recurring_Period__c,
       //              	owner.name,
       //              	Owner.UserRole.Name
       //              from
       //                	Account_Product__c
       //              Where
       //                  Recurring_Period__c != null
       //              And
      	//                 Recurring_Period__c != 'N/A'
       //              And
      // 	                (Name like '%Adwords%' or Name like '%Facebook%' or Name like '%Admob%' or Name like '%Yahoo%' or Name like '%google+%' or Name like '%SEO%' or Name like 'Socail Media%')
       //              And
      // 	                (pauseat__c = THIS_MONTH or (pauseat__c < THIS_MONTH and (activeat__c = THIS_MONTH or activeat__c > THIS_MONTH)))
      // 	            And
      // 	                activeat__c != null
      //               And
      //                   (Owner.UserRole.Name like '%Client%' or Owner.UserRole.Name like '%SEO%')
      //               AND
      // 	                Owner.IsActive = true];
                        
      // if (aps.size() > 0) {
      //   for(Account_product__c ap : aps) {
      //      String singleProductLost = caculatePauseRevenue(ap.Recurring_Period__c, ap.Product_Price__c, ap.pauseat__c, ap.activeat__c);
      //      saveCMStats(ap.owner.Name, singleProductLost, 'Pause_Revenue');
      //   }
      // }
      
      //Paused Revenue Per CM
	 groupedResults = [select
 						Account_Product__r.Owner.Name,
                        SUM(Paused_Revenue_This_Month__c)
                    from
                        Client_History__c
                    Where
                        Account_Product__r.Recurring_Period__c != null
                    And
                        Account_Product__r.Recurring_Period__c != 'N/A'
                    And
                        (Account_Product__r.Name like '%Adwords%' or Account_Product__r.Name like '%Facebook%' or Account_Product__r.Name like '%Admob%' or Account_Product__r.Name like '%Yahoo%' or Account_Product__r.Name like '%google+%' or Account_Product__r.Name like '%SEO%' or Account_Product__r.Name like 'Socail Media%')
                    And
                        (Start_Date__c = This_Month OR (Start_Date__c < This_Month and End_Date__c = null) OR (Start_date__c < This_Month and End_Date__c >= This_Month))
                    And
                        (Account_Product__r.Owner.UserRole.Name like '%Client%' or Account_Product__r.Owner.UserRole.Name like '%SEO%')
      //              AND
     //                   Account_Product__r.Owner.IsActive = true
                    AND
                        Type__c = 'Paused'
                    And
                        Sold_to_Pause__c = false
                    group by
                        Account_Product__r.Owner.Name
                    ];
		system.debug(groupedResults);
		
		for (AggregateResult ar : groupedResults)  {
	        String name = string.valueOf(ar.get('Name'));
	        System.debug('Paused_Revenue: ' + ar.get('expr0'));
	        saveCMStats(name, string.valueOf(ar.get('expr0')), 'Pause_Revenue');
	      }
		
        
      //Cancelled revenue Per CM
      //Get the cancelled account list from cancellation cases. Avoid counting in the downgrade/upgrade cancellation product
      //Set<Id> cancelAccs = new Set<Id>();
      //Cases__c[] cas = [select
      //          account__c
      //          from
      //          cases__c
      //          where
      //          CaseType__c = 'Cancellation'
      //          and
      //          cancellation_date__c = THIS_MONTH
      //          ];
      //for(Cases__c ca : cas) {
      //  cancelAccs.add(ca.account__c);
      //}
      
      //Account_product__c[] aps1 = [select
      //                product_price__c, 
      //                last_invoice_date__c, 
      //                cancelat__c, 
      //                Recurring_Period__c,
      //                owner.name,
      //                Owner.UserRole.Name
      //               from
      //                Account_Product__c
      //                 Where
      //                Product_Status__c = 'Cancelled'
      //               And
      //                Recurring_Period__c != null
      //               And
      //                Recurring_Period__c != 'N/A'
      //               And
      //                (Name like '%Adwords%' or Name like '%Facebook%' or Name like '%Admob%' or Name like '%Yahoo%' or Name like '%google+%' or Name like '%SEO%')
      //               And
      //                cancelat__c = THIS_MONTH
      //               And
      //                (Owner.UserRole.Name like '%Client%' or Owner.UserRole.Name like '%SEO%')
      //               And
      //                account__c in :cancelAccs
      //               AND
      //                Owner.IsActive = true
      //              ];
    
      //if (aps1.size() > 0) {
      //  for(Account_product__c ap : aps1) {
      //    String singleProductLost = caculateCancelRevenue(ap.Recurring_Period__c, ap.Product_Price__c, ap.cancelat__c, ap.Last_Invoice_Date__c);
      //    saveCMStats(ap.owner.Name, singleProductLost, 'Cancel_Revenue');
      //  }
      //}
      
                   
    }catch(Exception e){
      system.debug(e.getMessage());
    }
    
    system.debug('Team A: '+teamA);
    system.debug('Team B: '+teamB);
    system.debug('Team C: '+teamC);
    system.debug('GMT TeamA: '+gmtTeamA);
    system.debug('GMT TeamB: '+gmtTeamB);
    system.debug('SEO TeamA: '+seoTeamA);
    system.debug('SEO TeamB: '+seoTeamB);
    system.debug('TeamSEO: '+teamOther);
    
    // Now we generate the monthly kpi stats
    generateKPIStats('Team A', teamA);
    generateKPIStats('Team B', teamB);
    generateKPIStats('Team C', teamC);
    generateKPIStats('GMT Team A', gmtTeamA);
    generateKPIStats('GMT Team B', gmtTeamB);
    generateKPIStats('SEO Team A', seoTeamA);
    generateKPIStats('SEO Team B', seoTeamB);
    generateKPIStats('Team Other', teamOther);
       
  }
  
  //private void initialize(String team, Map<String, Map<String, String>> teamMap){
  //  try{
  //    CM_Stats__c[] cms =  new List<CM_Stats__c>();
  //    for(String cm_name : teamMap.keyset()){
  //          system.debug(cm_name);
  //          CM_Stats__c cm = new CM_Stats__c();
  //          cm.Name        = cm_name;
  //          cm.Report_Date__c   = Date.today();
  //          cm.Team__c   = team;
  //          cms.add(cm);
  //    }
  //    insert cms;
  //  }catch(Exception e){
  //          system.debug(e.getMessage());
  //  }
  //} 
  
  private void generateKPIStats(String team, Map<String, Map<String, String>> teamMap){
      try{
        List<CM_Stats__c> cmList = new List<CM_Stats__c>();

        for(String cm_name : teamMap.keyset()){
            system.debug(cm_name);
            //CM_Stats__c cm = [select 
            //                        Active__c, 
            //                        Setups__c, 
            //                        Paused__c, 
            //                        Total_Pause__c, 
            //                        Cancelled__c, 
            //                        Waivers_Approved__c, 
            //                        Revenue__c, 
            //                        Unpaid_Revenue__c, 
            //                        Paused_Revenue__c,
            //                        Cancelled_Revenue__c,
            //                        Unpaid_Active__c,
            //                        Credits__c,
            //                        Refunds__c,
            //                        NPS__c, 
            //                        Void_Revenue__c,
            //                        Waivers__c
            //                    from CM_Stats__c 
            //                    where 
            //                      name =: cm_name
            //                    And
            //                      report_date__c = today
            //                    limit 1];

  //          if(cm.Active__c == 0)
              CM_Stats__c cm = new CM_Stats__c();
              cm.Name        = cm_name;
            	cm.Active__c   = Integer.valueOf(teamMap.get(cm_name).get('Active'));
  //          if(cm.Setups__c == 0)
              	cm.Setups__c   = Integer.valueOf(teamMap.get(cm_name).get('Setups'));
  //          if(cm.Paused__c == 0)
              	cm.Paused__c   = Integer.valueOf(teamMap.get(cm_name).get('Paused'));
  //          if(cm.Total_Pause__c == 0)
              	cm.Total_Pause__c   = Integer.valueOf(teamMap.get(cm_name).get('Total_Pause'));
   //         if(cm.Cancelled__c == 0)
              	cm.Cancelled__c   = Integer.valueOf(teamMap.get(cm_name).get('Cancelled'));
            //if(cm.Unpaid_Active__c == 0)
    	      	//cm.Unpaid_Active__c = Integer.valueOf(teamMap.get(cm_name).get('Unpaid_Active'));
   //         if(cm.Revenue__c == 0)
      	      	cm.Revenue__c = Decimal.valueOf(teamMap.get(cm_name).get('Revenue'));
   //         if(cm.Unpaid_Revenue__c == 0)
        	  	cm.Unpaid_Revenue__c = Decimal.valueOf(teamMap.get(cm_name).get('Unpaid_Revenue'));
   //     	  if(cm.Credits__c == 0)  
          	  	cm.Credits__c = Decimal.valueOf(teamMap.get(cm_name).get('Credits'));
    //    	  if(cm.Refunds__c == 0)
          	  	cm.Refunds__c = Decimal.valueOf(teamMap.get(cm_name).get('Refunds'));
   //       	if(cm.NPS__c == 0)
          	  	cm.NPS__c = Decimal.valueOf(teamMap.get(cm_name).get('NPS'));
          	//if(cm.Void_Revenue__c == 0)
          	//  	cm.Void_Revenue__c = Decimal.valueOf(teamMap.get(cm_name).get('Void_Revenue'));
           // //  if(cm.Waivers_Approved__c == 0)
           //   cm.Waivers_Approved__c = Integer.valueOf(teamMap.get(cm_name).get('Waiver'));
            
     //       if(cm.Paused_Revenue__c == 0)
              cm.Paused_Revenue__c = Decimal.valueOf(teamMap.get(cm_name).get('Pause_Revenue')); 
    //        if(cm.Cancelled_Revenue__c == 0)
              cm.Cancelled_Revenue__c = Decimal.valueOf(teamMap.get(cm_name).get('Cancel_Revenue'));
    //        if(cm.Waivers__c == 0)
              cm.Waivers__c = Decimal.valueOf(teamMap.get(cm_name).get('Waivers'));
              cm.Team__c   = team;
              cm.Report_Date__c   = Date.today();
              if(cm.Cancelled_Revenue__c != 0 || cm.Paused_Revenue__c != 0 || cm.Credits__c != 0 
                  ||  cm.Cancelled__c != 0 || cm.Total_Pause__c != 0 || cm.Waivers__c!=0 || cm.Refunds__c != 0
                  || cm.Active__c != 0 || cm.Revenue__c!=0){
                cmList.add(cm);
              }
            
        }

      insert cmList;
      }catch(Exception e){
          system.debug(e.getMessage());
      }
  } 
  
  private void saveCMStats(String name, String value, String field){
      if(this.teamA.containsKey(name)){
            Map<String, String> cm_stats = this.teamA.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.teamB.containsKey(name)){
            Map<String, String> cm_stats = this.teamB.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.teamC.containsKey(name)){
            Map<String, String> cm_stats = this.teamC.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.gmtTeamA.containsKey(name)){
            Map<String, String> cm_stats = this.gmtTeamA.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.gmtTeamB.containsKey(name)){
            Map<String, String> cm_stats = this.gmtTeamB.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.seoTeamA.containsKey(name)){
            Map<String, String> cm_stats = this.seoTeamA.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.seoTeamB.containsKey(name)){
            Map<String, String> cm_stats = this.seoTeamB.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
        else if(this.teamOther.containsKey(name)){
            Map<String, String> cm_stats = this.teamOther.get(name);
            if(field == 'Pause_Revenue' || field == 'Cancel_Revenue') {
              cm_stats.put(field, String.valueOf(Decimal.valueOf(cm_stats.get(field)) + Decimal.valueOf(value)));
            } else {
        cm_stats.put(field, value);              
            }
        }
    } 
    
    private  String caculatePauseRevenue(String recurPeriod, Decimal price, Date pauseDate, Date activeDate ) {
	    Decimal sum = 0;
	    
	    Date ld = Date.today();
	    Date fd = ld.toStartOfMonth();
	    
	    integer days = 0;
	    
	    if (pauseDate >= fd && activeDate <= ld) {
	      days = pauseDate.daysBetween(activeDate);
	    } else if (pauseDate >= fd && activeDate >= ld) {
	      days = pauseDate.daysBetween(ld); 
	    } else if (pauseDate <= fd && activeDate <= ld) {
	      days = fd.daysBetween(activeDate);
	    } else if (pauseDate <= fd && activeDate >= ld) {
	      days = fd.daysBetween(ld);
	    }
	    
	    double cycle = 0;
	    if (recurPeriod == 'Weekly') {
	      cycle = days/7;
	    } else if (recurPeriod == 'Monthly') {
	      cycle = days/fd.daysBetween(ld);
	    }
	    sum = cycle * price;
	    sum = sum.setScale(2, RoundingMode.HALF_UP);
	    
	    return sum+'';
	  } 
  
  
  private String caculateCancelRevenue(String recurPeriod, Decimal price, Date cancelDate, Date lastInvoiceDate ) {
    Decimal sum = 0;
    
    Date firstDayOfMonth = cancelDate.toStartOfMonth();
    Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1); 
    
    integer days = lastInvoiceDate.daysBetween(lastDayOfMonth);
    
    integer cycle = 0;
    if (recurPeriod == 'Weekly') {
      cycle = days/7;
    } else if (recurPeriod == 'Monthly') {
      if (lastInvoiceDate.month() != cancelDate.month()) {
        cycle = 1;
      }
    }
    sum = cycle * price;
    sum = sum.setScale(2, RoundingMode.HALF_UP);
    
    return sum+'';
  }
}