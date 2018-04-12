/*
	Caculate the total lost revenue of paused products for each client manager in last month
*/

public with sharing class PauseRevenue {
	//Key is CM's name, value is his/her lost revenue.
	public Map<String, Decimal> teamAMap  {get; set;}
	public Map<String, Decimal> teamBMap  {get; set;}
	
	public PauseRevenue () {
		User[] teamA = [select name from user where userRole.name like '%Client Manager Team A%'];
		User[] teamB = [select name from user where userRole.name like '%Client Manager Team B%'];
						
		teamAMap  = new Map<String, Decimal>();
		teamBMap  = new Map<String, Decimal>();
		//Initial lost map, in case some client manager has no cancelled product in last month. Should display them in table as well
		for (user u : teamA) {
			teamAMap.put(u.name, 0);
		}
		for (user u : teamB) {
			teamBMap.put(u.name, 0);
		}
		
		Set<String> cmAs = teamAMap.keyset();
		Set<String> cmBs = teamBMap.keyset();
		
		Account_product__c[] aps = [select
									product_price__c, 
									pauseat__c,
         							activeat__c, 
									Recurring_Period__c,
									owner.name
								from
									Account_Product__c
								Where
									Recurring_Period__c != null
								And
									Recurring_Period__c != 'N/A'
								And
									Name Like '%Adwords%'
								And
									(pauseat__c = Last_month or (pauseat__c < Last_month and (activeat__c = Last_month or activeat__c > Last_Month)))
								And
									activeat__c != null
								And
									(Owner.name in :cmAs or Owner.name in :cmBs)];
		if (aps.size() > 0) {
			for(Account_product__c ap : aps) {
				Decimal singleProductLost = caculateLost(ap.Recurring_Period__c, ap.Product_Price__c, ap.pauseat__c, ap.activeat__c);
	    		Decimal tmp;
	    		if (cmAs.contains(ap.owner.Name)) {
	    			tmp = teamAMap.get(ap.owner.Name);
	    			tmp += singleProductLost;
	    			teamAMap.put(ap.owner.Name, tmp);
	    		} else if(cmBs.contains(ap.owner.Name)) {
	    			tmp = teamBMap.get(ap.owner.Name);
	    			tmp += singleProductLost;
	    			teamBMap.put(ap.owner.Name, tmp);
	    		}			
	    	}
		}
		teamAMap.put('#Total', sumup('Team A'));
		teamBMap.put('#Total', sumup('Team B'));
	}
	
	private Decimal caculateLost(String recurPeriod, Decimal price, Date pauseDate, Date activeDate ) {
		Decimal sum = 0;
		
		Date ld = Date.today().toStartOfMonth().addDays(-1);
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
			cycle = 1;
		}
		sum = cycle * price;
		
		return sum;
	}
	
	public Decimal sumup (String teamName) {
		Decimal total = 0;
		List<Decimal> revenues;
		if (teamName.equals('Team A')) {
			revenues = teamAMap.values();
		} else if (teamName.equals('Team B')) {
			revenues = teamBMap.values();
		} else {
			
		}
		for (Decimal d : revenues) {
			total += d;
		}
		return total;
	}
	
	
	@isTest(SeeAllData=true)
	static void coverageTest () {
		Test.startTest();
		Account acc = new Account();
		acc.name = 'My Test Account';
		insert acc;
		
        User u = [SELECT id FROM user WHERE IsActive = true LIMIT 1];
		
		Account_product__c ap = new Account_product__c();
		ap.Account__c = acc.id;
		ap.Ownerid = u.id;
		ap.name = 'Adwords Management';
        ap.Product_Price__c = 69.0;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.product_status__c = 'Cancelled';
        ap.pauseat__c = Date.today().toStartOfMonth().addDays(-15);
        ap.activeat__c = Date.today();
        ap.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-17);
		insert ap;
		
		Account_product__c ap1 = new Account_product__c();
		ap1.Account__c = acc.id;
		ap1.Ownerid = u.id;
		ap1.name = 'Adwords Management';
        ap1.Product_Price__c = 69.0;
        ap1.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap1.Recurring_Period__c ='Monthly';
        ap1.Payment_Option__c = 'Eway';
        ap1.product_status__c = 'Cancelled';
        ap1.pauseat__c = Date.today().toStartOfMonth().addDays(-50);
        ap1.activeat__c = Date.today();
        ap1.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-20);
		insert ap1;
				
		Account_product__c ap2 = new Account_product__c();
		ap2.Account__c = acc.id;
		ap2.Ownerid = u.id;
		ap2.name = 'Adwords Management';
        ap2.Product_Price__c = 69.0;
        ap2.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap2.Recurring_Period__c ='Monthly';
        ap2.Payment_Option__c = 'Eway';
        ap2.product_status__c = 'Cancelled';
        ap2.pauseat__c = Date.today().toStartOfMonth().addDays(-20);
        ap2.activeat__c = Date.today().toStartOfMonth().addDays(-10);
        ap2.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-20);
		insert ap2;
		
		Account_product__c ap3 = new Account_product__c();
		ap3.Account__c = acc.id;
		ap3.Ownerid = u.id;
		ap3.name = 'Adwords Management';
        ap3.Product_Price__c = 69.0;
        ap3.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap3.Recurring_Period__c ='Monthly';
        ap3.Payment_Option__c = 'Eway';
        ap3.product_status__c = 'Cancelled';
        ap3.pauseat__c = Date.today().toStartOfMonth().addDays(-50);
        ap3.activeat__c = Date.today().toStartOfMonth().addDays(-10);
        ap3.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-20);
		insert ap3;
		
		PauseRevenue cr = new PauseRevenue();
		
		Test.stopTest();
	}

}