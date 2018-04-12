/*
	Caculate the total lost revenue of cancelled products for each client manager in last month
*/

public with sharing class CancellationRevenue {
	//Key is CM's name, value is his/her lost revenue.
	public Map<String, Decimal> teamAMap  {get; set;}
	public Map<String, Decimal> teamBMap  {get; set;}
	
	public CancellationRevenue () {
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
		
		//Get the cancelled account list from cancellation cases. Avoid counting in the downgrade/upgrade cancellation product
		Set<Id> cancelAccs = new Set<Id>();
		Cases__c[] cas = [select
							account__c
						from
							cases__c
						where
							CaseType__c = 'Cancellation'
						and
							cancellation_date__c = last_month
						];
		for(Cases__c ca : cas) {
			cancelAccs.add(ca.account__c);
		}
		
		Account_product__c[] aps = [select
									product_price__c, 
									last_invoice_date__c, 
									cancelat__c, 
									Recurring_Period__c,
									owner.name
								from
									Account_Product__c
								Where
									Product_Status__c = 'Cancelled'
								And
									Recurring_Period__c != null
								And
									Recurring_Period__c != 'N/A'
								And
									Name Like '%Adwords%'
								And
									cancelat__c = Last_month
								And
									(Owner.name in :cmAs or Owner.name in :cmBs)
								And
									account__c in :cancelAccs	
								];
		if (aps.size() > 0) {
			for(Account_product__c ap : aps) {
				Decimal singleProductLost = caculateLost(ap.Recurring_Period__c, ap.Product_Price__c, ap.cancelat__c, ap.Last_Invoice_Date__c);
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
	
	private Decimal caculateLost(String recurPeriod, Decimal price, Date cancelDate, Date lastInvoiceDate ) {
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
		
		return sum;
	}
	
	public Decimal sumup (String teamName) {
		Decimal total = 0;
		List<Decimal> revenues;
		if (teamName.equals('Team A')) {
			revenues = teamAMap.values();
		} else if (teamName.equals('Team B')) {
			revenues = teamBMap.values();
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
        
        Cases__c ca = new Cases__c();
        ca.account__c = acc.id;
        ca.CaseType__c = 'Cancellation';
        ca.cancellation_date__c = Date.today().toStartOfMonth().addDays(-15);
        ca.X2012_Action_Taken_to_Save__c = 'blah blah';
        insert ca;
		
		Account_product__c ap = new Account_product__c();
		ap.Account__c = acc.id;
		ap.Ownerid = u.id;
		ap.name = 'Adwords Management';
        ap.Product_Price__c = 69.0;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.product_status__c = 'Cancelled';
        ap.cancelat__c = Date.today().toStartOfMonth().addDays(-15);
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
        ap1.cancelat__c = Date.today().toStartOfMonth().addDays(-15);
        ap1.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-20);
		insert ap1;
		
		CancellationRevenue cr = new CancellationRevenue();
		
		Test.stopTest();
	}

}