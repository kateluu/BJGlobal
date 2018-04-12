trigger EndofMonthBeforeInsert on End_of_Month__c (before insert) {
	Map<Integer, String> monthsMap = new Map<Integer, String>{
	  1 => 'January',
	  2 => 'February',
	  3 => 'March',
	  4=> 'April',
	  5 => 'May',
	  6 => 'June',
	  7 => 'July',
	  8 => 'August',
	  9 => 'September',
	  10 => 'October',
	  11 => 'November',
	  12 => 'December'
	};
	if (System.trigger.new.size() == 1){
		try {
			End_of_Month__c eom = System.trigger.new[0];
			system.debug(eom);
			String cm_name = [select Name from user where id =: eom.Client_Manager__c].Name;
			system.debug(cm_name);
			
			CM_Stats__c[] cm_stats = [select Total_Pause_Rate__c, 
									 cancelled_rate__c, 
									 Active__c, 
									 Revenue__c, 
									 Unpaid_Revenue__c,
									 Report_date__c,
									 cancelled_revenue__c,
									 paused_revenue__c,
									 Total_Offsets__c
							  from 
							  		CM_Stats__c 
							  where 
							  		Name =: cm_name 
							  order by 
							  		Report_Date__c desc 
							  limit 3 ];
			system.debug(cm_stats);
			if(cm_stats.size() == 3){
    			system.debug( 100 - cm_stats[0].Total_Pause_Rate__c);
    			system.debug(monthsMap.get((cm_stats[0].Report_date__c.addDays(-1)).month()));
    			
    			eom.Month_1__c     = monthsMap.get((cm_stats[0].Report_date__c.addDays(-1)).month());
		        eom.Active_1__c    = 100 - cm_stats[0].Total_Pause_Rate__c;
		 	    eom.Retention_1__c = 100 - cm_stats[0].cancelled_rate__c;
		    	eom.No_of_Client_1__c  = cm_stats[0].Active__c;
		    	eom.Total_Revenue_Received_1__c = cm_stats[0].Revenue__c;
		    	eom.Total_Unpaid_Revenue_1__c = cm_stats[0].Unpaid_Revenue__c;
		    	eom.cancelled_revenue_1__c  = cm_stats[0].cancelled_revenue__c;
		    	eom.Total_Offsets_1__c  = cm_stats[0].Total_Offsets__c + cm_stats[0].paused_revenue__c;
		    	
		    	eom.Month_2__c     = monthsMap.get((cm_stats[1].Report_date__c.addDays(-1)).month());
		        eom.Active_2__c    = 100 - cm_stats[1].Total_Pause_Rate__c;
		 	    eom.Retention_2__c = 100 - cm_stats[1].cancelled_rate__c;
		    	eom.No_of_Clients_2__c  = cm_stats[1].Active__c;
		    	eom.Total_Revenue_Received_2__c = cm_stats[1].Revenue__c;
		    	eom.Total_Unpaid_Revenue_2__c = cm_stats[1].Unpaid_Revenue__c;
		    	eom.cancelled_revenue_2__c  = cm_stats[1].cancelled_revenue__c;
		    	eom.Total_Offsets_2__c  = cm_stats[1].Total_Offsets__c + cm_stats[1].paused_revenue__c;
		    	
		    	
		    	eom.Month_3__c     = monthsMap.get((cm_stats[2].Report_date__c.addDays(-1)).month());
		        eom.Active_3__c    = 100 - cm_stats[2].Total_Pause_Rate__c;
		 	    eom.Retention_3__c = 100 - cm_stats[2].cancelled_rate__c;
		    	eom.No_of_Clients_3__c  = cm_stats[2].Active__c;
		    	eom.Total_Revenue_Received_3__c = cm_stats[2].Revenue__c;
		    	eom.Total_Unpaid_Revenue_3__c = cm_stats[2].Unpaid_Revenue__c;
		    	eom.cancelled_revenue_3__c  = cm_stats[2].cancelled_revenue__c;
		    	eom.Total_Offsets_3__c  = cm_stats[2].Total_Offsets__c + cm_stats[2].paused_revenue__c;
		    	
		    	
				eom.Avg_Active__c    = (eom.Active_1__c + eom.Active_2__c + eom.Active_3__c)/3;
		 	    eom.Avg_Retention__c   = (eom.Retention_1__c + eom.Retention_2__c + eom.Retention_3__c)/3;
		    	eom.Avg_No_of_Clients__c  = (eom.No_of_Client_1__c + eom.No_of_Clients_2__c + eom.No_of_Clients_3__c)/3;
		    	eom.Total_Revenue_Received__c = (eom.Total_Revenue_Received_1__c + eom.Total_Revenue_Received_2__c + eom.Total_Revenue_Received_3__c)/3;
		    	eom.Total_Unpaid_Revenue_Avg__c = (eom.Total_Unpaid_Revenue_1__c + eom.Total_Unpaid_Revenue_2__c + eom.Total_Unpaid_Revenue_3__c)/3;   
		    	eom.cancelled_revenue_Avg__c = (eom.cancelled_revenue_1__c + eom.cancelled_revenue_2__c + eom.cancelled_revenue_3__c)/3; 
		    	eom.Total_Offsets_Avg__c = (eom.Total_Offsets_1__c + eom.Total_Offsets_2__c + eom.Total_Offsets_3__c)/3;  	
			}else if(cm_stats.size() == 2){
				system.debug( 100 - cm_stats[0].Total_Pause_Rate__c);
    			system.debug(monthsMap.get((cm_stats[0].Report_date__c.addDays(-1)).month()));
    			
    			eom.Month_1__c     = monthsMap.get((cm_stats[0].Report_date__c.addDays(-1)).month());
		        eom.Active_1__c    = 100 - cm_stats[0].Total_Pause_Rate__c;
		 	    eom.Retention_1__c = 100 - cm_stats[0].cancelled_rate__c;
		    	eom.No_of_Client_1__c  = cm_stats[0].Active__c;
		    	eom.Total_Revenue_Received_1__c = cm_stats[0].Revenue__c;
		    	eom.Total_Unpaid_Revenue_1__c = cm_stats[0].Unpaid_Revenue__c;
		    	eom.cancelled_revenue_1__c  = cm_stats[0].cancelled_revenue__c;
		    	eom.Total_Offsets_1__c  = cm_stats[0].Total_Offsets__c + cm_stats[0].paused_revenue__c;

		    	eom.Month_2__c     = monthsMap.get((cm_stats[1].Report_date__c.addDays(-1)).month());
		        eom.Active_2__c    = 100 - cm_stats[1].Total_Pause_Rate__c;
		 	    eom.Retention_2__c = 100 - cm_stats[1].cancelled_rate__c;
		    	eom.No_of_Clients_2__c  = cm_stats[1].Active__c;
		    	eom.Total_Revenue_Received_2__c = cm_stats[1].Revenue__c;
		    	eom.Total_Unpaid_Revenue_2__c = cm_stats[1].Unpaid_Revenue__c;
		    	eom.cancelled_revenue_2__c  = cm_stats[1].cancelled_revenue__c;
		    	eom.Total_Offsets_2__c  = cm_stats[1].Total_Offsets__c + cm_stats[1].paused_revenue__c;
			}else if(cm_stats.size() == 1){
				system.debug( 100 - cm_stats[0].Total_Pause_Rate__c);
    			system.debug(monthsMap.get((cm_stats[0].Report_date__c.addDays(-1)).month()));
    			
    			eom.Month_1__c     = monthsMap.get((cm_stats[0].Report_date__c.addDays(-1)).month());
		        eom.Active_1__c    = 100 - cm_stats[0].Total_Pause_Rate__c;
		 	    eom.Retention_1__c = 100 - cm_stats[0].cancelled_rate__c;
		    	eom.No_of_Client_1__c  = cm_stats[0].Active__c;
		    	eom.Total_Revenue_Received_1__c = cm_stats[0].Revenue__c;
		    	eom.Total_Unpaid_Revenue_1__c = cm_stats[0].Unpaid_Revenue__c;
		    	eom.cancelled_revenue_1__c  = cm_stats[0].cancelled_revenue__c;
		    	eom.Total_Offsets_1__c  = cm_stats[0].Total_Offsets__c + cm_stats[0].paused_revenue__c;
		    }
		
		}catch(exception e){
			
		}
	}
	

}