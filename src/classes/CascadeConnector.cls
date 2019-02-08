public class CascadeConnector {

	//Define the method signature to be implemented in classes that implements the interface
	//Example method
	public static String endpoint_prod {get;set;}
    public static String action {get;set;}
    public static String method {get;set;}
    public static String requestBody{get;set;}
    public static String token{get;set;}
    public static String isTest{get;set;}

    
    public CascadeConnector(String isTestMode){
        endpoint_prod = 'https://disruptdigital.executestrategy.net/api/v2';       
        token = 'Bearer oNXnNVDqFEctKs6y9vzzxI3CdmEuSmHuMcG0Y4VW';        
        requestBody ='';
        isTest = isTestMode;
    }


    public class Metric{
    	String fieldName {get;set;}
    	Decimal fieldValue {get;set;}
    	String createdDate {get;set;}

    	public Metric(){
    	}
    }

	public class GoalHistory{
        String field_name {get;set;}
        String goal_id {get;set;}
        String new_value {get;set;}
        String created_at {get;set;}

    	public GoalHistory(){
    	}
    }


    public static String initGoalHistory(GoalHistory itemProgress){
        return JSON.serialize(itemProgress);    
    }

	public static List<Metric> buildMetrics(){
        List<Metric> metrics = new List<Metric>();
        String sqlString = '';
        String metricItem = '';
        Metric item = new Metric();
        Decimal val = 0.00;
        val.setScale(2); 

        
        

        //Active Clients - SLX - Adwords - daily
        sqlString = 'Select count() from Account_Product__c where Product_Status__c = \'Active\' and Product_Type__c = \'Adwords Management\' and Recurring__c = true and BJB_Company__c like \'SponsoredLinX\'';
        //AggregateResult[] groupedResults  = Database.query(sqlString);        
        val= Database.countQuery(sqlString);     
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        
        item.fieldName = '13';
        item.fieldValue = val;
        metrics.add(item);
        Integer activeClientSLXAdwords = val.intValue();
    

        //Active Clients - GMT - Adwords - daily
        sqlString = 'Select count() from Account_Product__c where Product_Status__c = \'Active\' and Product_Type__c = \'Adwords Management\' and Recurring__c = true and BJB_Company__c like \'Get More Traffic\'';
        val= Database.countQuery(sqlString);   
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '5';
        item.fieldValue = val;
        metrics.add(item);
        Integer activeClientGMTAdwords = val.intValue();
  
        

        //Active Clients - SLX - SEO - daily
        sqlString = 'Select count() from Account_Product__c where Product_Status__c = \'Active\' and Product_Type__c = \'SEO\' and Recurring__c = true';
        val= Database.countQuery(sqlString);      
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}

        item = new Metric();
        item.fieldName = '19';
        item.fieldValue = val;
        metrics.add(item);
  	    Integer activeClientSEO = val.intValue();
  
        //Active Clients - SLX - Social - daily
        sqlString = 'Select count() from Account_Product__c where Product_Status__c = \'Active\' and Product_Type__c = \'Social Marketing\' and Recurring__c = true and BJB_Company__c like \'SponsoredLinX\'';
        val= Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}

        item = new Metric();
        item.fieldName = '105';
        item.fieldValue = val;
        metrics.add(item);
        Integer activeClientSLXSocial = val.intValue();
  
        //Active Clients - GMT - Social - daily
        //metricItem = 'Select count() from Account_Product__c where Product_Status__c = \'Active\' and Product_Type__c = \'Social Marketing\' and Recurring__c = true and BJB_Company__c like \'Get More Traffic\'';
        //metrics.put('105',metricItem );


        //Churn rate - SLX - Adwords - daily
        sqlString = 'Select count() FROM Cases__c Where Cancellation_Date__c = THIS_MONTH and Product_Type__c = \'Adwords Management\' and BJB_Company__c like \'SponsoredLinX\'';
        val= Database.countQuery(sqlString);
        val = (activeClientSLXAdwords == 0)?0:(val*100).divide(activeClientSLXAdwords,2);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '18';
        item.fieldValue = val;
        metrics.add(item);
        

        //Churn rate - GMT - Adwords - daily
        sqlString = 'Select count() FROM Cases__c Where Cancellation_Date__c = THIS_MONTH and Product_Type__c = \'Adwords Management\' and BJB_Company__c like \'Get More Traffic\'';
        val= Database.countQuery(sqlString);        
        val = (activeClientGMTAdwords == 0)?0:(val*100).divide(activeClientGMTAdwords,2);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '30';
        item.fieldValue = val;
        metrics.add(item);


        //Churn rate - SLX - SEO - daily
        sqlString = 'Select count() FROM Cases__c Where Cancellation_Date__c = THIS_MONTH and Product_Type__c = \'SEO\' and BJB_Company__c like \'SponsoredLinX\'';
        val= Database.countQuery(sqlString);
        val = (activeClientSEO == 0)?0:(val*100).divide(activeClientSEO,2);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '103';
        item.fieldValue = val;
        metrics.add(item);


        //Churn rate - SLX - Social - daily
        sqlString = 'Select count() FROM Cases__c Where Cancellation_Date__c = THIS_MONTH and Product_Type__c = \'Social Marketing\' and BJB_Company__c like \'SponsoredLinX\'';
        val= Database.countQuery(sqlString);
        val = (activeClientSLXSocial == 0)?0:(val*100).divide(activeClientSLXSocial,2);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}

        item = new Metric();
        item.fieldName = '33';
        item.fieldValue = val;
        metrics.add(item);

		////Churn rate - GMT - Social - daily
        //metricItem = 'Select count() FROM Cases__c Where Cancellation_Date__c = THIS_MONTH and Product_Type__c = \'Social Marketing\' and BJB_Company__c like \'SponsoredLinX\'';
        //metrics.put('33',metricItem);

        // BTS - SLX - Adwords - daily - % back to sales cases processed by Total sales made
        // BTS: select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c = 'Adwords Management' and BJB_Company__c like 'SponsoredLinX%' 
        sqlString = 'select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c = \'Adwords Management\' and BJB_Company__c like \'SponsoredLinX%\'';
        Integer valBTS = Database.countQuery(sqlString);        
		//Total Sales: Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c = 'Adwords Management' and Bjb_Company__r.Name like 'SponsoredLinX%'
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c = \'Adwords Management\' and Bjb_Company__r.Name like \'SponsoredLinX%\'';
        Integer valTotalSales = Database.countQuery(sqlString);
        val = (valTotalSales == 0)?0:(Decimal.valueOf(valBTS*100)).divide(valTotalSales,2);
        val.setScale(2);        
	    if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}

        item = new Metric();
        item.fieldName = '25';
        item.fieldValue = val;
        metrics.add(item);


        // BTS - GMT - Adwords - daily - % back to sales cases processed by Total sales made
  		//BTS: select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c = 'Adwords Management' and BJB_Company__c like 'Get More Traffic%' 		
        sqlString = 'select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c = \'Adwords Management\' and BJB_Company__c like \'Get More Traffic%\' ';
        valBTS = Database.countQuery(sqlString);        

		//Total Sales: Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c = 'Adwords Management' and Bjb_Company__r.Name like 'Get More Traffic%'
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c = \'Adwords Management\' and Bjb_Company__r.Name like \'Get More Traffic%\'';
        valTotalSales = Database.countQuery(sqlString);
        val = (valTotalSales == 0)?0:(Decimal.valueOf(valBTS*100)).divide(valTotalSales,2);
        val.setScale(2);        
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '24';
        item.fieldValue = val;
        metrics.add(item);


        // BTS - SLX - SEO - daily - % back to sales cases processed by Total sales made
  		//BTS: select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c = 'SEO' and BJB_Company__c like 'SponsoredLinX%' 
        sqlString = 'select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c = \'SEO\' and BJB_Company__c like \'SponsoredLinX%\'';
        valBTS = Database.countQuery(sqlString);        

		//Total Sales: Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c = 'SEO' and Bjb_Company__r.Name like 'SponsoredLinX%'
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c = \'SEO\' and Bjb_Company__r.Name like \'SponsoredLinX%\'';
        valTotalSales = Database.countQuery(sqlString);
        val = (valTotalSales == 0)?0:(Decimal.valueOf(valBTS*100)).divide(valTotalSales,2);
        val.setScale(2);        
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '27';
        item.fieldValue = val;
        metrics.add(item);


		// BTS - SLX - Social - daily - % back to sales cases processed by Total sales made
  		//BTS: select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c like 'Social%' and BJB_Company__c like 'SponsoredLinX%' 		
        sqlString = 'select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c like \'Social%\' and BJB_Company__c like \'SponsoredLinX%\'';
        valBTS = Database.countQuery(sqlString);        

		//Total Sales: Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c like 'Social%' and Bjb_Company__r.Name like 'SponsoredLinX%'
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c like \'Social%\' and Bjb_Company__r.Name like \'SponsoredLinX%\'';
        valTotalSales = Database.countQuery(sqlString);
        val = (valTotalSales == 0)?0:(Decimal.valueOf(valBTS*100)).divide(valTotalSales,2);
        val.setScale(2);        
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '37';
        item.fieldValue = val;
        metrics.add(item);

        /*
		// BTS - GMT - Social - daily - % back to sales cases processed by Total sales made
  		//BTS: select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c like 'Social%' and BJB_Company__c like 'SponsoredLinX%' 		
        sqlString = 'select count() from cases__c where bts__c = true and createdDate = this_Month and product_type__c like \'Social%\' and BJB_Company__c like \'SponsoredLinX%\'';
        valBTS = Database.countQuery(sqlString);        

		//Total Sales: Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c like 'Social%' and Bjb_Company__r.Name like 'SponsoredLinX%'
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = THIS_MONTH and Product_Type__c like \'Social%\' and Bjb_Company__r.Name like \'SponsoredLinX%\'';
        valTotalSales = Database.countQuery(sqlString);
        val = (valTotalSales == 0)?0:valBTS/valTotalSales;
        val.setScale(2);        
        metrics.put('37',val);
        */

        // Group Revenue
        sqlString = 'select sum(Payment_Amount__c) from Payment__c where payment_Date__c = THIS_MONTH and Payment_Type__c != \'Credit\'';
        AggregateResult[] groupedResults  = Database.query(sqlString);
        val = (groupedResults[0].get('expr0') != null)?Decimal.valueOf(''+groupedResults[0].get('expr0')):0.00 ;
        system.debug('val = ' + val) ;
        item = new Metric();
        item.fieldName = '48';
        item.fieldValue = val;
        metrics.add(item);

        // Leads - SLX NZ - Adwords -daily
        sqlString = 'select count() from lead where createdDate = THIS_MONTH and From_Source__c like \'%nz%\' and Status != \'Spam\'';        
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}

        item = new Metric();
        item.fieldName = '70';
        item.fieldValue = val;
        metrics.add(item);

        // Leads	SLX AU	Online Chat	daily
        sqlString = 'Select count() from lead where status!= \'Spam\' and from_source__c like \'%online chat%\' and createddate = this_month and BJB_Company__c like \'SponsoredLinX%\'';        
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '87';
        item.fieldValue = val;
        metrics.add(item);

        // Leads	GMT	Online Chat	daily	88
        sqlString = 'select count() from lead where status!= \'Spam\' and from_source__c like \'%online chat%\' and createddate = this_month and BJB_Company__c like \'Get More Traffic%\'';        
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '88';
        item.fieldValue = val;
        metrics.add(item);

        //Sales	SLX	Adwords	daily	23
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = This_year and Product_Type__c = \'Adwords Management\' and Bjb_Company__r.Name like \'SponsoredLinX%\''  ;     
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '23';
        item.fieldValue = val;
        metrics.add(item);

        //Sales	GMT	Adwords	daily	22        
        sqlString = 'Select count() from Sign_Up__c where CreatedDate = This_year and Product_Type__c = \'Adwords Management\' and Bjb_Company__r.Name like \'Get More Traffic%\'';
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '22';
        item.fieldValue = val;
        metrics.add(item);

        //Sales	SLX	SEO	daily	26
		sqlString = 'Select count() from Sign_Up__c where CreatedDate = This_year and Product_Type__c = \'SEO\' and Bjb_Company__r.Name like \'SponsoredLinX%\'';        
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '26';
        item.fieldValue = val;
        metrics.add(item);
        
        //Sales	SLX	Social	daily	35
		sqlString = 'Select count() from Sign_Up__c where CreatedDate = This_year and Product_Type__c like \'social%\' and Bjb_Company__r.Name like \'SponsoredLinX%\'';        
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '35';
        item.fieldValue = val;
        metrics.add(item);

        //Sales	GMT	Social	daily	34        
		sqlString = 'Select count() from Sign_Up__c where CreatedDate = This_year and Product_Type__c like \'social%\' and Bjb_Company__r.Name like \'Get More Traffic%\'';
        val = Database.countQuery(sqlString);
        if(isTest == 'true') {
			system.debug('val = ' + val) ;
		}
        item = new Metric();
        item.fieldName = '34';
        item.fieldValue = val;
        metrics.add(item);

        return metrics;

    }


    @future(callout=true)
    public static void updateProgress(){
    	List<Metric> metrics = buildMetrics();
    	for(Metric item:metrics){
    		if(isTest == 'true') {
    			system.debug('name = ' + item.fieldName + ' ; value = ' + item.fieldValue);
    		}
    		addGoalHistory(item.fieldName, item.fieldValue);  
    	}
    }
    

    
    public static void addGoalHistory(String goalID , Decimal newValue)
    { 
        action ='/goal_histories';    
        method ='POST';
        
        //String sqlString= 'Select count() res from Account_Product__c where Product_Status__c = \'Active\' and Product_Type__c = \'Adwords Management\' and Recurring__c = true and BJB_Company__c like \'SponsoredLinX\'';
        //AggregateResult[] groupedResults  = Database.query(sqlString);
        //Integer val = Integer.valueOf(groupedResults[0].get('res').toString().trim());
        Integer val = 1080;
        
        // build the request base on query result and metric parameter
        // build input object
        // GoalHistory itemProgress = new GoalHistory();
        // itemProgress.goal_id ='104';
        // itemProgress.field_name ='progress';
        // itemProgress.new_value = ''+val;
        // itemProgress.created_at = String.valueofGMT(System.DateTime.now()-1);
        if(isTest == 'true') {
        	system.debug('addGoalHistory :: name = ' + goalID + ' ; value = ' + newValue);
    	}
        GoalHistory itemProgress = new GoalHistory();
        itemProgress.goal_id =goalID ;
        itemProgress.field_name ='progress';
        itemProgress.new_value = ''+newValue;
        itemProgress.created_at = String.valueofGMT(System.DateTime.now()-1);


        system.debug('call 1');

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('goal_history');
        gen.writeObject(itemProgress);
        gen.writeEndObject();
        requestBody = gen.getAsString();


        //requestBody = initGoalHistory(itemProgress);
        
        // build request
        try{
	        HttpRequest req = new HttpRequest();
	        Http h = new Http();
	        if(!Test.isRunningTest()){
	            endpoint_prod = 'https://disruptdigital.executestrategy.net/api/v2';       
	            token  = 'Bearer oNXnNVDqFEctKs6y9vzzxI3CdmEuSmHuMcG0Y4VW';     
	            action = 'goal_histories';
	            method = 'POST';  
	            
	            req.setEndpoint(endpoint_prod + '/' + action );
	            req.setMethod(method);
	            req.setBody(requestBody); 
	            system.debug('requestBody = ' + requestBody);
	            req.setTimeout(60000);

	            // header.
	            req.setHeader('Authorization', token);
	            req.setHeader('Accept', 'application/json');            
	            req.setHeader('Content-Type', 'application/json');
	            system.debug(req);

	            // send request
	            HTTPResponse res = h.send(req);
	            //system.debug('Response: ' + EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
	            //res.getBody();
	            
	            // extract the response
	            Map<String, Object> response = (Map<String, Object> )JSON.deserializeUntyped(res.getBody());
	        } 
        }catch(System.CalloutException ex){
			System.debug('Cascade Callout Error: '+ ex);
			System.debug(ex.getMessage());			
			System.debug('addGoalHistory :: name = ' + goalID + ' ; value = ' + newValue);
		}
    }

}