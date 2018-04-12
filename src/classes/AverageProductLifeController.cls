public with sharing class AverageProductLifeController {
    public Data[] result {get; set;}
    public CData[] compare {get; set;}
    public string filterType {get; set;}
    public string reportType {get; set;}
    public boolean isActiveCMOnly {get; set;}
    public boolean isActiveSAOnly {get; set;}
    public boolean isComparePromo {get; set;}
    public boolean isDisplayScatter {get; set;}
    //dump object, only use its Start_Date__c and End_Date__c fields for datepicker in visualforce page
    public Account_Product__c ap {get; set;}
    public Decimal averageLifeForAll {get; set;}
    public Decimal averageRevenueForAll {get; set;}
    
    public AverageProductLifeController () {
        filterType = 'PP';
        reportType = 'life';
        isActiveCMOnly = true;
        isActiveSAOnly = true;
        isComparePromo = false;
        isDisplayScatter = false;
        ap = new Account_Product__c();
    }
   
    public List<SelectOption> getTypes() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('PP', 'Package & Price'));
            options.add(new SelectOption('CM', 'Client Manager'));
            options.add(new SelectOption('SA', 'Salesperson'));
        return options;
    }
    
    public void getResults () {
        //If the user has not provide a start date and end date, then define a default time range large enough to contain all the products
        ap.Start_Date__c = (ap.Start_Date__c == null? Date.newInstance(2000, 1, 1) : ap.Start_Date__c);
        ap.End_Date__c = (ap.End_Date__c == null? Date.today() : ap.End_Date__c);
        
        if (filterType == 'PP') {
            searchByPackage();
        } else if (filterType == 'CM') {
            searchByCM();
        } else if (filterType == 'SA') {
            searchBySales();
        }
        
        if (reportType == 'life') {
        	calculateAverageLifetimeForAllProduct();
        } else if (reportType == 'revenue') {
        	calculateAverageRevenueForAll();
        }
    }
    
    private void calculateAverageLifetimeForAllProduct () {
    	Account_Product__c[] aps = [select 
    									id 
    								from 
    									Account_product__c 
    								where 
    									Recurring_Period__c = 'Weekly' 
    								and 
    									((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) 
    									or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
    	Client_History__c[] chs = [select 
    									start_date__c, end_date__c 
    								from 
    									Client_History__c 
    								where 
    									type__c = 'Active' 
    								and 
    									Account_Product__c in :aps];
		averageLifeForAll = getAverageActivePeriod(chs, aps.size()); 
    }
    
    private void calculateAverageRevenueForAll () {
    	Account_Product__c[] aps = [select 
    									id 
    								from 
    									Account_product__c 
    								where 
    									Recurring_Period__c = 'Weekly' 
    								and 
    									((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) 
    									or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
    									
	    Payment__c[] ps = [select 
	    						Payment_Type__c, Payment_Amount__c 
	    					from 
	    						Payment__c 
	    					where 
	    						Invoice__c != null 
	    					and 
	    						Invoice__r.Account_Product__c in :aps];
	    system.debug('\n*********************' + aps);
	    averageRevenueForAll = getRevenue(ps) / aps.size();
	    aps.clear();
	    ps.clear();
    }
    	
    
    private void searchByPackage () {
        Decimal average;
        Decimal average1;
    	Decimal total;
		Decimal total1;
		result = new List<Data>();
        compare = new List<CData>();
        
        Map<String, List<Decimal>> packageBreakDown = new Map<String, List<Decimal>>();
        packageBreakDown.put('Maintenance', new Decimal[]{29.0, 49.0});
        packageBreakDown.put('Standard', new Decimal[]{19.0, 29.0, 49.0, 69.0});
        packageBreakDown.put('Optimised', new Decimal[]{49.0, 59.0, 69.0, 89.0, 99.0});
        packageBreakDown.put('Premium', new Decimal[]{49.0, 69.0, 89.0, 99.0});
        
        if(!isComparePromo) {
        	if (reportType == 'life') {
	            for (String name : packageBreakDown.keySet()) {
	                String tmp = 'Adwords%' + name + '%';
	                for (Decimal price : packageBreakDown.get(name)) {
	                    Account_Product__c[] aps = [select id from Account_product__c where Name Like :tmp and Product_Price__c = :price and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
	                    Client_History__c[] chs = [select start_date__c, end_date__c from Client_History__c where type__c = 'Active' and Account_Product__c in :aps];
	                    average = getAverageActivePeriod(chs, aps.size()); 
	                    result.add(new Data(name+' '+price, average, aps.size()));
	                }
	            }
        	} else if (reportType == 'revenue') {
	            for (String name : packageBreakDown.keySet()) {
	                String tmp = 'Adwords%' + name + '%';
	                for (Decimal price : packageBreakDown.get(name)) {
	                    Account_Product__c[] aps = [select id from Account_product__c where Name Like :tmp and Product_Price__c = :price and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
	                    Payment__c[] ps = [select Payment_Type__c, Payment_Amount__c from Payment__c where Invoice__c != null and Invoice__r.Account_Product__c in :aps];
	                    total = getRevenue(ps); 
	                    result.add(new Data(name+' '+price, total, aps.size()));
	                    aps.clear();
	                	ps.clear();
	                }
	            }
        	}
        } else {
            Map<String, String> packagePromo = new Map<String, String>();
            packagePromo.put('Standard', 'stdispr');
            packagePromo.put('Optimised', 'opdispr');
            packagePromo.put('Premium', 'prdispr');
            
            Map<String, Decimal> promoDiscount = new Map<String, Decimal>();
            promoDiscount.put('Standard', 20.0);
            promoDiscount.put('Optimised', 20.0);
            promoDiscount.put('Premium', 10.0);
            
            if (reportType == 'life') {
	            for (String name : packagePromo.keySet()) {
	                String tmp = 'Adwords%' + name + '%';
	                for (Decimal price : packageBreakDown.get(name)) {
	                    Account_Product__c[] aps = [select id from Account_product__c where Name Like :tmp and Product_Price__c = :price and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
	                    Client_History__c[] chs = [select start_date__c, end_date__c from Client_History__c where type__c = 'Active' and Account_Product__c in :aps];
	                    average = getAverageActivePeriod(chs, aps.size());
	                    Account_Product__c[] aps1 = [select id from Account_product__c where Name Like :tmp and Sign_Up_del__r.Promocode__r.name = :packagePromo.get(name) and Product_Price__c = :(price - promoDiscount.get(name)) and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
	                    Client_History__c[] chs1 = [select start_date__c, end_date__c from Client_History__c where type__c = 'Active' and Account_Product__c in :aps1];
	                    average1 = getAverageActivePeriod(chs1, aps1.size()); 
	                    compare.add(new CData(name+' '+price, average, aps.size(), average1, aps1.size()));
	                }
	            }
            } else if (reportType == 'revenue') {
	            for (String name : packagePromo.keySet()) {
	                String tmp = 'Adwords%' + name + '%';
	                for (Decimal price : packageBreakDown.get(name)) {
	                    Account_Product__c[] aps = [select id from Account_product__c where Name Like :tmp and Product_Price__c = :price and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
	                    Payment__c[] ps = [select Payment_Type__c, Payment_Amount__c from Payment__c where Invoice__c != null and Invoice__r.Account_Product__c in :aps];
	                    total = getRevenue(ps);
	                    Account_Product__c[] aps1 = [select id from Account_product__c where Name Like :tmp and Sign_Up_del__r.Promocode__r.name = :packagePromo.get(name) and Product_Price__c = :(price - promoDiscount.get(name)) and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c))];
	                    Payment__c[] ps1 = [select Payment_Type__c, Payment_Amount__c from Payment__c where Invoice__c != null and Invoice__r.Account_Product__c in :aps1];
	                    total1 = getRevenue(ps1); 
	                    compare.add(new CData(name+' '+price, total, aps.size(), total1, aps1.size()));
	                }
	            }
            }
        }
    }
    
    private void searchByCM () {
    	/*
        List<AggregateResult> ars;
        if (isActiveCMOnly) {
            ars = [select ownerId, owner.name, count(id) from account_product__c where ownerId != null and owner.IsActive = true and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)) group by ownerId, owner.name];
        } else {
            ars = [select ownerId, owner.name, count(id) from account_product__c where ownerId != null and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)) group by ownerId, owner.name];
        }
        Map<Id, String> owners = new Map<Id, String>();
        Map<Id, Integer> ownersNumber = new Map<Id, Integer>();
        for(AggregateResult ar : ars) {
            owners.put((Id)ar.get('ownerId'), (string)ar.get('Name'));
            ownersNumber.put((Id)ar.get('ownerId'), (Integer)ar.get('expr0'));
        }
        
        Map<Id, AccountHistory[]> ahmap = new Map<Id, AccountHistory[]>();
        Set<Id> accountIds = new Set<Id>();
        for(AccountHistory ah : [select CreatedDate, OldValue, NewValue, accountId From AccountHistory where field='Owner']) {
		    if(String.valueOf(ah.OldValue).isAlphaSpace() && ah.OldValue != 'Ben Bradshaw') {
		    	if (ahmap.containsKey(ah.accountId)) {
		    		AccountHistory[] tmp = ahmap.get(ah.accountId);
		    		tmp.add(ah);
		    		ahmap.put(ah.accountId, tmp);
		    	} else {
		    		ahmap.put(ah.accountId, new AccountHistory[]{ah});	
		    	}
		        accountIds.add(ah.accountId);
		    }
		}
		
		//Important Map holding all histories telling which Client Manager managing what product during what time, separated by CM's name
		Map<String, CMHistory[]> cmhmap = new Map<String, CMHistory[]>();
		
		Map<Id, CMHistory[]> pmap = new Map<Id, CMHistory[]>();

		//Get all account_products, filter by recuring period = 'weekly', so not only the adwords product, may include some other product like SEO product.		
		Account_product__c[] aps = [select id, account__c, owner.Name, product_status__c, createdDate, Start_Date__c, End_Date__c, Cancellation_Date__c, cancelat__c from Account_Product__c where Recurring_Period__c = 'Weekly'];

		for (Account_product__c ap : aps) {
			
			//Create the begin date and end date for a account_product
			Date startDate = (date.valueof(ap.createdDate) < ap.Start_Date__c ? date.valueof(ap.createdDate) : ap.Start_Date__c);
			Date endDate;
			if (ap.product_status__c == 'Cancelled') {
				endDate = (ap.End_Date__c < ap.Cancellation_Date__c ? ap.End_Date__c : ap.Cancellation_Date__c);
				endDate = (endDate < ap.cancelat__c ? endDate : ap.cancelat__c);
			} else {
				endDate = Date.today();
			}
			
			CMHistory cmh;
			
			if (accountIds.contains(ap.account__c)) { //those product with a owner change history
				AccountHistory[] ahs = ahmap.get(ap.account__c);
				
				AHWrapper[] ahWrappers = new List<AHWrapper>();
				for (AccountHistory ah : ahs) {
					ahWrappers.add(new AHWrapper(ah));
				}
				ahWrappers.sort();
				
				for(integer i = 0; i <= ahWrappers.size(); i++) {
					if (i == 0) {
						cmh = new CMHistory(String.valueOf(ahWrappers[i].ah.OldValue), ap.id, startDate, Date.valueOf(ahWrappers[i].ah.CreatedDate.addDays(-1)));
					} else if (i == ahWrappers.size()) {
						cmh = new CMHistory(String.valueOf(ahWrappers[i-1].ah.NewValue), ap.id, Date.valueOf(ahWrappers[i-1].ah.CreatedDate), endDate);
					} else {
						cmh = new CMHistory(String.valueOf(ahWrappers[i].ah.OldValue), ap.id, Date.valueOf(ahWrappers[i-1].ah.CreatedDate), Date.valueOf(ahWrappers[i].ah.CreatedDate.addDays(-1)));
					}
				}
			} else { //products without owner change
				cmh = new CMHistory(ap.owner.Name, ap.id, startDate, endDate);
			}
			
			//put the CMHistory into the name map
			if (cmhmap.containsKey(ap.owner.Name)) {
	    		CMHistory[] tmp = cmhmap.get(ap.owner.Name);
	    		tmp.add(cmh);
	    		cmhmap.put(ap.owner.Name, tmp);
	    	} else {
	    		cmhmap.put(ap.owner.Name, new CMHistory[]{cmh});	
	    	}
	    	
	    	//put the CMHistory into the productId map
			if (pmap.containsKey(ap.id)) {
	    		CMHistory[] tmp = pmap.get(ap.id);
	    		tmp.add(cmh);
	    		pmap.put(ap.id, tmp);
	    	} else {
	    		pmap.put(ap.id, new CMHistory[]{cmh});	
	    	}
		}
		
		//get all client histories and separate them by productId
		Map<id, Client_History__c[]> chmap = new Map<id, Client_History__c[]>();
		for (Client_History__c ch : [select start_date__c, end_date__c, Account_Product__c from Client_History__c where type__c = 'Active' and Account_Product__c in (Select id from Account_Product__c where Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)))]) {
			if (chmap.containsKey(ch.Account_Product__c)) {
				Client_History__c[] tmp = chmap.get(ch.Account_Product__c);
				tmp.add(ch);
				chmap.put(ch.Account_Product__c, tmp);
			} else {
				chmap.put(ch.Account_Product__c, new Client_History__c[]{ch});
			}
		}
		*/
        List<AggregateResult> ars;
        if (isActiveCMOnly) {
            ars = [select 
            			ownerId, owner.name, count(id) 
					from 
						account_product__c 
					where 
						ownerId != null 
					and 
						owner.IsActive = true 
					and 
						(owner.profile.name = 'SLX Client Manager' 
						or owner.profile.name = 'SLX Client Team Manager') 
					and 
						Recurring_Period__c = 'Weekly' 
					and 
						((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) 
						or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)) 
					group by 
						ownerId, owner.name];
        } else {
            ars = [select 
            			ownerId, owner.name, count(id) 
            		from 
            			account_product__c 
            		where 
            			ownerId != null
            		and 
						(owner.profile.name = 'SLX Client Manager' 
						or owner.profile.name = 'SLX Client Team Manager')  
            		and 
            			Recurring_Period__c = 'Weekly' 
            		and 
            			((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) 
            			or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)) 
            		group by 
            			ownerId, owner.name];
        }
        Map<Id, String> owners = new Map<Id, String>();
        Map<Id, Integer> ownersNumber = new Map<Id, Integer>();
        for(AggregateResult ar : ars) {
            owners.put((Id)ar.get('ownerId'), (string)ar.get('Name'));
            ownersNumber.put((Id)ar.get('ownerId'), (Integer)ar.get('expr0'));
        }
        
        result = new List<Data>();
        for (Id ownerId : owners.Keyset()) {
            if (reportType == 'life') {
            	Decimal average;
                Client_History__c[] chs = [select start_date__c, end_date__c from Client_History__c where type__c = 'Active' and Account_Product__c in (Select id from Account_Product__c where ownerId =: ownerId and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)))];
                average = getAverageActivePeriod(chs, ownersNumber.get(ownerId));
                result.add(new Data(owners.get(ownerId), average, (integer)ownersNumber.get(ownerId)));
            } else if (reportType == 'revenue') {
            	Decimal total;
            	Payment__c[] ps = [select Payment_Type__c, Payment_Amount__c from Payment__c where Invoice__c != null and Invoice__c in (Select id from Invoice__c where Account_Product__r.ownerId =: ownerId and Account_Product__r.Recurring_Period__c = 'Weekly' and ((Account_Product__r.CreatedDate >= :ap.Start_Date__c and Account_Product__r.CreatedDate <= :ap.End_Date__c) or (Account_Product__r.Start_Date__c >= :ap.Start_Date__c and Account_Product__r.Start_Date__c <= :ap.End_Date__c)))];
                total = getRevenue(ps);
                result.add(new Data(owners.get(ownerId), total, (integer)ownersNumber.get(ownerId)));
          	}
        }
    }
    
    /*
    private void interset (CMHistory[] cmhs, Client_History__c[] chs) {
    	if (cmhs == null || chs == null || cmhs.size() == 0 || chs.size() == 0) {
    		
    	}
    	for (integer i = 0; i < cmhs.size(); i++) {
    		for (Client_History__c ch : chs) {
    			if (ch.end_date__c < cmhs[i].startDate || ch.start_date__c > cmhs[i].endDate) {
    				cmhs.remove(i);
    			} else if (ch.start_date__c >= cmhs[i].startDate && ch.end_date__c <= cmhs[i].endDate) {
    				cmhs[i].startDate = ch.start_date__c;
    				cmhs[i].endDate = ch.end_date__c;
    			} else if (ch.start_date__c < cmhs[i].startDate && cmhs[i].startDate < ch.end_date__c && ch.end_date__c < cmhs[i].endDate) {
    				cmhs[i].endDate = ch.end_date__c;
    			} else if (cmhs[i].startDate < ch.start_date__c && ch.start_date__c < cmhs[i].endDate && cmhs[i].endDate < ch.end_date__c) {
    				cmhs[i].startDate = ch.start_date__c;
    			}
    		}
    	}    	
    }
    */
    
    private void searchBySales () {
        List<AggregateResult> ars;
        if (isActiveSAOnly) {
            ars = [select Sign_Up_del__r.Salesperson__c, Sign_Up_del__r.Salesperson__r.name, count(id) 
            		from account_product__c 
            		where Sign_Up_del__r.Salesperson__c != null 
            		and Sign_Up_del__r.Salesperson__r.Type = 'Employee' 
            		and Sign_Up_del__r.Salesperson__r.Employee_Department__c = 'Sales' 
            		and Sign_Up_del__r.Salesperson__r.Active__c = true 
            		and Recurring_Period__c = 'Weekly'
					and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) 
						or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)) 
					group by Sign_Up_del__r.Salesperson__c, Sign_Up_del__r.Salesperson__r.name];
        } else {    
            ars = [select Sign_Up_del__r.Salesperson__c, Sign_Up_del__r.Salesperson__r.name, count(id) 
            		from account_product__c 
            		where Sign_Up_del__r.Salesperson__c != null
            		and Sign_Up_del__r.Salesperson__r.Type = 'Employee' 
            		and Sign_Up_del__r.Salesperson__r.Employee_Department__c = 'Sales' 
            		and Recurring_Period__c = 'Weekly' 
            		and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) 
            				or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)) 
            		group by Sign_Up_del__r.Salesperson__c, Sign_Up_del__r.Salesperson__r.name];
        }
        Map<Id, String> sales = new Map<Id, String>();
        Map<Id, Integer> salesNumber = new Map<Id, Integer>();
        for(AggregateResult ar : ars) {
            sales.put((Id)ar.get('Salesperson__c'), (string)ar.get('Name'));
            salesNumber.put((Id)ar.get('Salesperson__c') , (integer)ar.get('expr0'));
        }
        
        result = new List<Data>();
        for(Id salesId : sales.keyset()) {
        	if(reportType == 'life') {
        		Decimal average;
	            Client_History__c[] chs = [select start_date__c, end_date__c from Client_History__c where type__c = 'Active' and Account_Product__c in (Select id from Account_Product__c where Sign_Up_del__r.Salesperson__c =: salesId and Recurring_Period__c = 'Weekly' and ((CreatedDate >= :ap.Start_Date__c and CreatedDate <= :ap.End_Date__c) or (Start_Date__c >= :ap.Start_Date__c and Start_Date__c <= :ap.End_Date__c)))];
	            average = getAverageActivePeriod(chs, salesNumber.get(salesId));
	            result.add(new Data(sales.get(salesId), average, (integer)salesNumber.get(salesId)));
        	} else if (reportType == 'revenue') {
        		Decimal total;
        		Payment__c[] ps = [select Payment_Type__c, Payment_Amount__c from Payment__c where Invoice__c != null and Invoice__c in (Select id from Invoice__c where Account_Product__r.Sign_Up_del__r.Salesperson__c =: salesId and Account_Product__r.Recurring_Period__c = 'Weekly' and ((Account_Product__r.CreatedDate >= :ap.Start_Date__c and Account_Product__r.CreatedDate <= :ap.End_Date__c) or (Account_Product__r.Start_Date__c >= :ap.Start_Date__c and Account_Product__r.Start_Date__c <= :ap.End_Date__c)))];
	            total = getRevenue(ps);
	            result.add(new Data(sales.get(salesId), total, (integer)salesNumber.get(salesId)));
        	}
        }
    }
    
    public PageReference exportCSV () {
        PageReference csv = new PageReference('/apex/AverageProductLifeCSV');
        return csv;
    }
    
    public Decimal getRevenue(Payment__c[] ps) {
    	if(ps == null || ps.size() == 0) return 0;
    	
    	Decimal sum = 0;
    	for (Payment__c p : ps) {
    		if (p.Payment_Type__c == 'Credit') {
    			//do nothing
    		} else if (p.Payment_Type__c == 'Refund') {
    			sum -= p.Payment_Amount__c;
    		} else {
    			sum += p.Payment_Amount__c;
    		}
    	}   	
    	
    	return sum;
    }
    
    public Decimal getAverageActivePeriod(Client_History__c[] chs, integer size) {
        if (chs == null || chs.size() == 0) {
            return 0;
        }
        Decimal sum = 0;
        for (Client_History__c ch : chs) {
            if (ch.end_date__c != null) {
                sum += ch.start_date__c.daysBetween(ch.end_date__c); 
            } else {
                sum += ch.start_date__c.daysBetween(Date.today());
            }
        }
        return sum / 7 / size;
    }
    
    public class Data {
        public String name { get; set; }
        public Decimal weeks { get; set; }
        public integer quantity {get; set;}
        public Data(String name, Decimal weeks, integer quantity) {
            this.name = name;
            this.weeks = weeks;
            this.quantity = quantity;
        }
    }
    
    public class CData { //Filter by package, compare with discount product
        public String name { get; set; }
        public Decimal Normal { get; set; }
        public Decimal Discount { get; set; }
        public integer NormalQuantity {get; set;}
        public integer DiscountQuantity {get; set;}
        public CData(String name, Decimal weeks, integer quantity, Decimal compareWeeks, integer compareQuantity) {
            this.name = name;
            this.Normal = weeks;
            this.NormalQuantity = quantity;
            this.Discount = compareWeeks;
            this.DiscountQuantity = compareQuantity;
        }
    }
    
    /*
    public class CMHistory {
    	public String name {get; set;}
    	public Id product {get; set;}
    	public Date startDate {get; set;}
    	public Date endDate {get; set;}
    	public CMHistory(String name, Id product, Date startDate, Date endDate) {
            this.name = name;
            this.product = product;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
    */
    
    public class AHWrapper implements Comparable {
	    public AccountHistory ah;
	    
	    public AHWrapper(AccountHistory ah) {
	        this.ah = ah;
	    }
	    
	    public Integer compareTo(Object compareTo) {
	        AHWrapper compareToAH = (AHWrapper)compareTo;
	        
	        // The return value of 0 indicates that both elements are equal. 
	        Integer returnValue = 0;
	        if (ah.CreatedDate > compareToAH.ah.CreatedDate) {
	            // Set return value to a positive value. 
	            returnValue = 1;
	        } else if (ah.CreatedDate < compareToAH.ah.CreatedDate) {
	            // Set return value to a negative value. 
	            returnValue = -1;
	        }
	        return returnValue;       
	    }
	}
    
    static testMethod void testPPLife() {
        Account acc = new Account();
        acc.name = 'acc1';
        insert acc;
        Account_product__c ap = new Account_product__c();
        ap.Account__c = acc.id;
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.name = 'AdWords Weekly Standard Management';
        insert ap;
        Client_History__c ch1 = new Client_History__c();
        ch1.Account_Product__c = ap.id;
        ch1.Type__c = 'Active';
        ch1.start_date__c = date.newInstance(2012, 10, 1);
        insert ch1;
        Test.startTest();
        
        
        AverageProductLifeController con = new AverageProductLifeController();
        List<SelectOption> options = con.getTypes();
        
        //Package & Price, Life Report, No Comparison
        con.filterType = 'PP';
        con.reportType = 'life';
        con.isComparePromo = false;
        con.getResults();
        
        //Package & Price, Life Report, Comparison
        con.filterType = 'PP';
        con.reportType = 'life';
        con.isComparePromo = true;
        con.getResults();
        
        con.exportCSV();
        Test.stopTest();    
    
    }
    
    static testMethod void testPPRevenue() {
        Account acc = new Account();
        acc.name = 'acc';
        insert acc;
        Account_product__c ap = new Account_product__c();
        ap.Account__c = acc.id;
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.name = 'AdWords Weekly Standard Management';
        ap.Start_Date__c = Date.today().adddays(-1);
        insert ap;
        Client_History__c ch1 = new Client_History__c();
        ch1.Account_Product__c = ap.id;
        ch1.Type__c = 'Active';
        ch1.start_date__c = date.newInstance(2012, 10, 1);
        insert ch1;
        Test.startTest();
        
        
        AverageProductLifeController con = new AverageProductLifeController();
        List<SelectOption> options = con.getTypes();
        
        //Package & Price, Revenue Report, No Comparison
        con.filterType = 'PP';
        con.reportType = 'revenue';
        con.isComparePromo = false;
        con.getResults();
        
        //Package & Price, Revenue Report, Comparison
        con.filterType = 'PP';
        con.reportType = 'revenue';
        con.isComparePromo = true;
        con.getResults();
        
        Test.stopTest();
    }
    
    static testMethod void testCM() {
        Account acc = new Account();
        acc.name = 'acc1';
        insert acc;
        Account_product__c ap = new Account_product__c();
        ap.Account__c = acc.id;
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.name = 'AdWords Weekly Standard Management';
        ap.Start_Date__c = Date.today().adddays(-1);
        insert ap;
        Client_History__c ch1 = new Client_History__c();
        ch1.Account_Product__c = ap.id;
        ch1.Type__c = 'Active';
        ch1.start_date__c = date.newInstance(2012, 10, 1);
        insert ch1;
        Test.startTest();
        
        
        AverageProductLifeController con = new AverageProductLifeController();
        List<SelectOption> options = con.getTypes();
        
        //Client Manager, Life Report, Active, No Scatter
        con.filterType = 'CM';
        con.reportType = 'life';
        con.isActiveCMOnly = true;
        con.isDisplayScatter = false;
        con.getResults();
        
        //Client Manager, Life Report, Not Active, No Scatter
        con.filterType = 'CM';
        con.reportType = 'life';
        con.isActiveCMOnly = false;
        con.isDisplayScatter = false;
        con.getResults();
        
        //Client Manager, Life Report, Active, Scatter
        con.filterType = 'CM';
        con.reportType = 'life';
        con.isActiveCMOnly = true;
        con.isDisplayScatter = true;
        con.getResults();
        
        //Client Manager, Life Report, Active, No Scatter
        con.filterType = 'CM';
        con.reportType = 'life';
        con.isActiveCMOnly = true;
        con.isDisplayScatter = false;
        con.getResults();
        
        //Client Manager, Revenue Report, Active
        con.filterType = 'CM';
        con.reportType = 'revenue';
        con.isActiveCMOnly = true;
        con.getResults();
        
        //Client Manager, Revenue Report, Not Active
        con.filterType = 'CM';
        con.reportType = 'revenue';
        con.isActiveCMOnly = false;
        con.getResults();
        
        Test.stopTest();
    }
    
    static testMethod void testSA() {
        Account acc = new Account();
        acc.name = 'acc1';
        insert acc;
        Account_product__c ap = new Account_product__c();
        ap.Account__c = acc.id;
        ap.Product_Price__c = 19.99;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Cheque';
        ap.name = 'AdWords Weekly Standard Management';
        ap.Start_Date__c = Date.today().adddays(-1);
        insert ap;
        Client_History__c ch1 = new Client_History__c();
        ch1.Account_Product__c = ap.id;
        ch1.Type__c = 'Active';
        ch1.start_date__c = date.newInstance(2012, 10, 1);
        insert ch1;
        Test.startTest();
        
        
        AverageProductLifeController con = new AverageProductLifeController();
        List<SelectOption> options = con.getTypes();
        
        //Salesperson, Life Report, Active
        con.filterType = 'SA';
        con.reportType = 'life';
        con.isActiveSAOnly = true;
        con.getResults();
        
        //Salesperson, Life Report, Not Active
        con.filterType = 'SA';
        con.reportType = 'life';
        con.isActiveSAOnly = false;
        con.getResults();
        
        //Salesperson, Revenue Report, Active
        con.filterType = 'SA';
        con.reportType = 'revenue';
        con.isActiveSAOnly = true;
        con.getResults();
        
        //Salesperson, Revenue Report, Not Active
        con.filterType = 'SA';
        con.reportType = 'revenue';
        con.isActiveSAOnly = false;
        con.getResults();

        Test.stopTest(); 
    }
}