public with sharing class ForecastRevenue {
  public decimal cancelPrice {get; set;}
  public decimal cancelRevenueMonthly {get; set;}
  public decimal cancelRevenueYearly {get; set;}
  
  public decimal pausePrice {get; set;}
  public decimal pauseWeek {get; set;}
  public decimal pauseRevenueMonthly {get; set;}
  public decimal pauseRevenueYearly {get; set;}
  
  public decimal waive {get; set;}
  public decimal refund {get; set;}
  
  public decimal revenue {get; set;}
  public decimal averageRevenue {get; set;} //average revenue for the latest three months including forecast for this month
  public decimal lastMonthRevenue {get; set;}
  public decimal averageRetentionRate {get; set;}
  public decimal averageActiveRate  {get; set;}
  public decimal minusCancelRevenue {get; set;}
  public decimal minusPauseRevenue {get; set;}
  public decimal minusWaiveRevenue {get; set;}
  public decimal minusRefundRevenue {get; set;}
  
  public decimal cancelRate {get; set;}
  public integer actualCancels {get; set;}
  public integer kpiCancels {get; set;}
  public integer kpiNewClients {get; set;}
  public decimal newCancelRate {get; set;}
  
  public decimal pauseRate {get; set;}
  public integer actualPauses {get; set;}
  public integer kpiPauses {get; set;}
  public decimal newPauseRate {get; set;}
  
  public decimal newActiveRate {get; set;}
  public decimal newRetentionRate {get; set;}
  
  public decimal activeRate {get; set;}
  public decimal retentionRate {get; set;}
  
  private integer allProductsThisMonth {get; set;}
  
  private integer daysInMonth {get; set;} //how many days this month has
  private Date lastDayOfMonth {get; set;} //last date of this month
  private Date lastDayOfYear {get; set;}  //last date of this year
  public decimal weeksTillEndOfMonth {get; set;} //how many weeks left for this month
  public decimal weeksTillEndOfYear {get; set;} //how many weeks left for this year
  public decimal daysTillEndOfMonth {get; set;} //how many days left for this month
  public decimal daysTillEndOfYear {get; set;} //how many days left for this year
  
  public List<SelectOption> CMList {get; set;}
  public string selectedCM {get; set;} //selected CM ID
  public boolean isCM {get; set;} //is CM or higher role
  public Set<Id> cms {get; set;} //list of cm ids for calculattion, leader and COM need the stats for whole team
  
  
  
  public ForecastRevenue() {
    daysInMonth = Date.daysInMonth(Date.today().year(), Date.today().month()); 
    lastDayOfMonth = Date.newInstance(Date.today().year(), Date.today().month(), daysInMonth);
    lastDayOfYear = Date.newInstance(Date.today().year(), 12, daysInMonth);
    weeksTillEndOfMonth = (decimal)Date.today().daysBetween(lastDayOfMonth) / 7;
    weeksTillEndOfYear = (decimal)Date.today().daysBetween(lastDayOfYear) / 7;
    
    DateTime lDayIfMonth = (DateTime) lastDayOfMonth;
    DateTime lDayOfYear  = (DateTime) lastDayOfYear;
    
    daysTillEndOfMonth = getBusinessDays(DateTime.now(), lDayIfMonth);
    daysTillEndOfYear  = getBusinessDays(DateTime.now(), lDayOfYear);
    system.debug(daysTillEndOfMonth);
    
    CMList = new List<SelectOption>();
    
    Id uid = UserInfo.getUserId(); 
    Id roleid = UserInfo.getUserRoleId();
    
    UserRole ur = [select DeveloperName, name from UserRole where id =: roleid];
    if(ur.name.contains('Leader') || ur.name.contains('Resolution Manager')) {
      isCM = false;
      generateCMList(roleid, ur.name);
    } else if (ur.name.contains('CEO') || ur.name.contains('Client Operations Manager')) {
      isCM = false;
      generateCMList(roleid, ur.name);
    } else {
      isCM = true;
      cms = new Set<Id>{uid};
      getOriginalStats();
    }
  }
  
  private void generateCMList(Id roleId, String roleName) {
    CMList = new List<SelectOption>();
        CMList.add(new SelectOption('My Team','My Team'));
        set<Id> subRoles;
        User[] urs;
        if(roleName.contains('CEO') || roleName.contains('Client Operations Manager')) {
          CMList.add(new SelectOption('','',true)); //blank separate line
          CMList.add(new SelectOption('Team A','Team A'));
          urs = [select id, name from user where (userRole.name like '%Client Manager Team A%' or userRole.name = 'Client Resolution Manager Team A') and IsActive = true order by name asc];
      for(User u : urs){
              CMList.add(new SelectOption(u.id, u.name));
          }
          
          CMList.add(new SelectOption('','',true)); //blank separate line
          CMList.add(new SelectOption('Team B','Team B'));
          urs = [select id, name from user where (userRole.name like '%Client Manager Team B%' or userRole.name = 'Client Resolution Manager Team B') and IsActive = true order by name asc];
      for(User u : urs){
              CMList.add(new SelectOption(u.id, u.name));
          }
          
          CMList.add(new SelectOption('','',true)); //blank separate line
          CMList.add(new SelectOption('Team C','Team C'));
          urs = [select id, name from user where (userRole.name like '%Client Manager Team C%' or userRole.name = 'Client Resolution Manager Team C')  and IsActive = true order by name asc];
      for(User u : urs){
              CMList.add(new SelectOption(u.id, u.name));
          }
          
          CMList.add(new SelectOption('','',true)); //blank separate line
          CMList.add(new SelectOption('Team GMT','Team GMT'));
          urs = [select id, name from user where (userRole.name like '%Client Manager Team GMT%' or userRole.name = 'Client Resolution Manager Team GMT') and IsActive = true order by name asc];
      for(User u : urs){
              CMList.add(new SelectOption(u.id, u.name));
          }
        } else {
          CMList.add(new SelectOption('','',true)); //blank separate line
          subRoles = getSubordinateRoles(roleId);
          subRoles.add(roleId);
      urs = [select id, name from user where userRoleId in :subRoles and IsActive = true order by name asc];
          for(User u : urs){
              CMList.add(new SelectOption(u.id, u.name));
          }
        }
  }
  
  public void loadCMs() {
    cms = new Set<Id>();
    user[] urs;
    if(selectedCM == 'My Team') {
      Id roleId = UserInfo.getUserRoleId();
      set<id> subRoles = getSubordinateRoles(roleId);
          subRoles.add(roleId);
      urs = [select id, name from user where userRoleId in :subRoles and IsActive = true order by name asc];
          for(User u : urs){
              cms.add(u.id);
          }
    } else if(selectedCM == 'Team A') {
      urs = [select id, name from user where userRole.name like '%Client Manager Team A%' and IsActive = true order by name asc];
          for(User u : urs){
              cms.add(u.id);
          }
    } else if(selectedCM == 'Team B') {
      urs = [select id, name from user where userRole.name like '%Client Manager Team B%' and IsActive = true order by name asc];
          for(User u : urs){
              cms.add(u.id);
          }
    } else if(selectedCM == 'Team C') {
      urs = [select id, name from user where userRole.name like '%Client Manager Team C%' and IsActive = true order by name asc];
          for(User u : urs){
              cms.add(u.id);
          }
    } else if(selectedCM == 'Team GMT') {
      urs = [select id, name from user where userRole.name like '%Client Manager Team GMT%' and IsActive = true order by name asc];
          for(User u : urs){
              cms.add(u.id);
          }
    } else {
      cms.add(selectedCM);
    }
    getOriginalStats();
    calculate();
  }
  
  private decimal calculateForecast(Account_Product__c ap) {
    integer forcastInvoices = 0; //how many invoices will be generated if client stay with us for this month
    integer invoiceInterval = 0; //recurring period
    if(ap.recurring_period__c == 'Monthly') {
      invoiceInterval = daysInMonth;
    } else if (ap.recurring_period__c == 'Fortnightly') {
      invoiceInterval = 14;
    } else if (ap.recurring_period__c == 'Quarterly') {
      invoiceInterval = 91;
    }else if (ap.recurring_period__c == 'Yearly') {
      invoiceInterval = 365;
    }else if (ap.recurring_period__c == 'Half Yearly') {
      invoiceInterval = 183;
    }else{
      invoiceInterval = 7;
    }
    
    if(ap.Product_status__c == 'Active') { //if product is active, assume it remains active till the end of month. Ignore the coming schedule pause for god sake
      while(ap.last_invoice_date__c.addDays(invoiceInterval) <= lastDayOfMonth) {
        forcastInvoices++;
        ap.last_invoice_date__c = ap.last_invoice_date__c.addDays(invoiceInterval);
      }
    } else { //if product is paused, calculate how many invoices will be generated since resume day
      while(ap.activeat__c.addDays(invoiceInterval) <= lastDayOfMonth) {
        forcastInvoices++;
        ap.activeat__c = ap.activeat__c.addDays(invoiceInterval);
      }
    }
    return forcastInvoices * ap.product_price__c;
  }
  
  public void getOriginalStats() {
    Decimal existingRevenue = 0;
    Payment__c[] ps = [select 
                Payment_Amount__c 
              from 
                payment__c 
              where 
                payment_date__c = this_month 
              and 
                payment_type__c != 'Credit' 
              and
                invoice__r.account_product__r.ownerId in: cms
              and 
                (invoice__r.account_product__r.name like '%adwords%' 
                or invoice__r.account_product__r.name like '%facebook%' 
                or invoice__r.account_product__r.name like '%yahoo%' 
                or invoice__r.account_product__r.name like '%admob%'
                )
              and invoice__r.account_product__r.SLX_Product__r.product_recurring__c = 'Yes'
              ];
              
    for(Payment__c p : ps) {
      existingRevenue += p.Payment_Amount__c;
    }
              
    Decimal forecastRevenue = 0;
    Account_Product__c[] aps = [select 
                    id,
                    Product_Price__c,
                    Recurring_Period__c,
                    Product_Status__c,
                    activeat__c,
                    last_invoice_date__c
                  from
                    Account_Product__c
                  where 
                    OwnerId in: cms
                  and 
                    Product_Status__c = 'Active' 
                  and
                    recurring_period__c != null
                  and
                    recurring_period__c != 'N/A'
                  and
                    last_invoice_date__c != null
                  and
                    (name like '%adwords%' or name like '%facebook%' or name like '%yahoo%' or name like '%admob%')
                  ];
                  
    Account_Product__c[] current_pause =  [select 
                        id,
                        Product_Price__c,
                        Recurring_Period__c,
                        Product_Status__c,
                        activeat__c,
                        last_invoice_date__c
                      from
                        Account_Product__c
                      where 
                        OwnerId in: cms
                      and 
                          Product_Status__c = 'Paused'
                      and
                        recurring_period__c != null
                      and
                        recurring_period__c != 'N/A'
                      and
                        last_invoice_date__c != null
                      and
                        (name like '%adwords%' or name like '%facebook%' or name like '%yahoo%' or name like '%admob%')
                      ];
    
    
    system.debug(aps.size());
    for(Account_Product__c ap : aps) {
      forecastRevenue += calculateForecast(ap);
    }
    system.debug(existingRevenue);
    system.debug(forecastRevenue);
    
    this.revenue = existingRevenue + forecastRevenue;
    
    Decimal revenueLastTwoMonthes = 0;
    //ps = [select 
    //      payment_amount__c 
    //    from 
    //      payment__c 
    //    where 
    //      payment_date__c = Last_N_MONTHS:2 
    //    and 
    //      invoice__r.account_product__r.ownerId in: cms
    //    and 
    //      payment_type__c != 'Credit' 
    //    and 
    //      (invoice__r.account_product__r.name like '%adwords%' 
    //      or invoice__r.account_product__r.name like '%facebook%' 
    //      or invoice__r.account_product__r.name like '%yahoo%' 
    //      or invoice__r.account_product__r.name like '%admob%'
    //      )
    //    ];
    //for(payment__c p : ps) {
    //  revenueLastTwoMonthes += p.payment_amount__c;
    //}
    
    
    //this.averageRevenue = (this.revenue + revenueLastTwoMonthes) / 3;
    //String cm_name = ;
    
    // get last month revenue
    try{
      this.lastMonthRevenue = [Select 
                    Revenue__c 
                  from 
                    CM_Stats__c 
                  where Name =: [select Name from user where ID =: cms].Name 
                    order by createdDate DESC 
                    limit 1].Revenue__c;
    }catch(Exception e){
      system.debug(e.getMessage());
      this.lastMonthRevenue = 0;
    }
    
    Cases__c[] cancelCases = [select id from Cases__c where Account_Resolution__c = 'Cancellation' and unresolved_date__c = this_month and ownerId in: cms];
    this.actualCancels = cancelCases.size();
    //this.allProductsThisMonth = this.actualCancels + aps.size();
    this.allProductsThisMonth = aps.size();
    system.debug(aps.size());
    
    //Cases__c[] pauseCases = [select id from Cases__c where Account_Resolution__c = 'Pause' and unresolved_date__c = this_month and ownerId in: cms];
    //this.actualPauses = pauseCases.size();
    this.actualPauses = current_pause.size();
    
    // get last three months average retention rate & active rate
    try{
      CM_Stats__c[] cm_stats = [Select 
                    Total_Pause_Rate__c,
                    Cancelled_Rate__c 
                  from 
                    CM_Stats__c 
                  where Name =: [select Name from user where ID =: cms].Name 
                    order by createdDate DESC 
                    limit 3];
      decimal totalCancelRate = 0;
      decimal totalPauseRate = 0;                
      for(CM_Stats__c cm_stat : cm_stats){
        totalCancelRate += cm_stat.Cancelled_Rate__c;
        totalPauseRate += cm_stat.Total_Pause_Rate__c;
      }
      this.averageRetentionRate = 1 - (totalCancelRate/(100*cm_stats.size()));
      this.averageActiveRate    = 1 - (totalPauseRate/(100*cm_stats.size()));
    }catch(Exception e){
      system.debug(e.getMessage());
      this.averageRetentionRate = 0;
      this.averageActiveRate = 0;
    }
    if(this.allProductsThisMonth != 0 ) {
      this.cancelRate = (decimal)this.actualCancels / this.allProductsThisMonth;
      this.pauseRate = (decimal)this.actualPauses / this.allProductsThisMonth;
      
      this.retentionRate = 1 - this.cancelRate;
      this.activeRate = 1 - this.pauseRate;
    }
  }
  
  public void calculate() {
    if(this.cancelPrice == Null)   this.cancelPrice = 0;
    if(this.pausePrice == Null)   this.pausePrice = 0;
    if(this.pauseWeek == Null)     this.pauseWeek = 0;
    if(this.waive == Null)       this.waive = 0;
    if(this.refund == Null)     this.refund = 0;
    if(this.kpiCancels == Null)   this.kpiCancels = 0;
    if(this.kpiPauses == Null)     this.kpiPauses = 0;
    if(this.kpiNewClients == Null)   this.kpiNewClients = 0;
    
    this.cancelRevenueMonthly = this.cancelPrice * this.weeksTillEndOfMonth;
    this.cancelRevenueYearly = this.cancelPrice * this.weeksTillEndOfYear;
    this.minusCancelRevenue = this.revenue - this.cancelRevenueMonthly;
    
    decimal actualPauseWeekInMonth = this.pauseWeek < this.weeksTillEndOfMonth ? this.pauseWeek : this.weeksTillEndOfMonth; 
    decimal actualPauseWeekInYear = this.pauseWeek < this.weeksTillEndOfYear ? this.pauseWeek : this.weeksTillEndOfYear; 
    this.pauseRevenueMonthly = this.pausePrice * actualPauseWeekInMonth;
    this.pauseRevenueYearly = this.pausePrice * actualPauseWeekInYear;
    this.minusPauseRevenue = this.minusCancelRevenue - this.pauseRevenueMonthly;
    
    this.minusWaiveRevenue = this.minusPauseRevenue - waive;
    this.minusRefundRevenue = this.minusWaiveRevenue - refund;
    
    if((this.allProductsThisMonth + this.kpiNewClients) != 0 ) {
      this.newCancelRate = (decimal)(this.actualCancels + this.kpiCancels) / (this.allProductsThisMonth + this.kpiNewClients);
      this.newPauseRate = (decimal)(this.actualPauses + this.kpiPauses) / (this.allProductsThisMonth + this.kpiNewClients);
      system.debug(this.actualCancels);
      system.debug(this.actualPauses);
      system.debug(this.allProductsThisMonth);
      this.newActiveRate = 1 - this.newPauseRate;
      this.newRetentionRate = 1 -this.newCancelRate;
    }
  }
  
  public static set<Id> getSubordinateRoles(Id roleId) {
      map<Id, set<Id>> parentAndChildren = new map<Id, set<Id>>();
      set<Id> children;
      for(UserRole ur : [select Id, ParentRoleId from UserRole]) {
          children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
          children.add(ur.Id);
          parentAndChildren.put(ur.ParentRoleId, children);
      }
      return getSubordinateRoles(roleId, parentAndChildren);
  }
  
  public static set<Id> getSubordinateRoles(Id roleId, map<Id, set<Id>> parentAndChildren) {
      set<Id> subordinateRoles = new set<Id>();
      set<Id> remainingSubordinateRoles = new set<Id>();
      if(parentAndChildren.containsKey(roleId)) {
          subordinateRoles.addAll(parentAndChildren.get(roleId));
          for(Id subRoleId : subordinateRoles) {
              remainingSubordinateRoles.addAll(getSubordinateRoles(subRoleId, parentAndChildren));
          }
      }
      subordinateRoles.addAll(remainingSubordinateRoles);
      return subordinateRoles;
  }
  
  private Integer getBusinessDays(Datetime sdate, Datetime edate){
    integer count=0;
      Date d1 = Date.valueOf(sdate);
      Date d2 = Date.valueOf(edate);
      integer wDay = d1.daysBetween(d2) ;
   
      do{
         if(sdate.format('EEEE') == 'Saturday') {
            count++;
          }
          if(sdate.format('EEEE') == 'Sunday') {
            count++;
          }
      sdate= sdate.adddays(1);
      }while(sdate<=edate);
   
      wDay = wDay-count+1;
      return wDay;
  }
}