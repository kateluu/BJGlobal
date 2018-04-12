public  class DailyStats {
	
	private Daily_Stats__c daily_stats;
	
	public DailyStats(){
		// Declare a daily stats object 
		this.daily_stats = new Daily_Stats__c();
		// Total Sales Reps
		this.daily_stats.Sales_Reps__c = [select count()
										  from   Account
										  where  Active__c = true
										  and    Type= 'Employee'
										  and    Employee_Department__c='Sales'
										  ]-6; 
		// Active sales reps: number of sales reps who started 30 days ago
		this.daily_stats.Active_Sales_Reps__c = [select count()
												 from   Account
												 where  Active__c = true
												 and    Type= 'Employee'
												 and    Employee_Department__c='Sales'
												 and    CreatedDate < LAST_N_DAYS:30
												  ]-6; 
		// Number of Active clients: active accounts who has active recurring products
		this.daily_stats.Active_Clients__c = [select count()
											  from   Account
											  where  Active__c = true
											  and    Type != 'Employee'
											 ];
		
		Integer total_active_products = 0;
		// Number of Active Products group by company
		AggregateResult[] groupedResults =[select SLX_Product__r.Company_Name__c, count(id)
								              from   Account_Product__c
								              where  Product_Status__c = 'Active'
								              and    (Name like '%Adwords%'
								              	      or Name like '%Facebook%'
								              	      or Name like '%Admob%'
								              	      or Name like '%Yahoo%'
								              	      or Name like '%google+%')
								              and    Recurring_Period__c !=''
								              and    Recurring_Period__c != 'N/A'
								              group by SLX_Product__r.Company_Name__c
								             ];
		for (AggregateResult ar : groupedResults)  {
			if(ar.get('company_name__c') == 'SponsoredLinx'){
				this.daily_stats.SLX_Active_Products__c = Decimal.valueOf(ar.get('expr0') +'');
			}else if(ar.get('company_name__c') == 'Get More Traffic'){
				this.daily_stats.GMT_Active_Products__c =  Decimal.valueOf(ar.get('expr0') +'');
			}else if(ar.get('company_name__c') == 'SponsoredLinX New Zealand'){
				this.daily_stats.SLX_NZ_Active_Products__c =  Decimal.valueOf(ar.get('expr0') +'');
			}
			total_active_products += Integer.valueOf(ar.get('expr0') +'');
		}
		
		this.daily_stats.Active_Products__c = total_active_products;
								             
		// Number of Active Products
//		this.daily_stats.Active_Products__c =[select SLX_Product__r.Company_name__c, count(id)
//								              from   Account_Product__c
//								              where  Product_Status__c = 'Active'
//								              and    (Name like '%Adwords%'
//								              	      or Name like '%Facebook%'
//								              	      or Name like '%Admob%'
//								              	      or Name like '%Yahoo%'
//								              	      or Name like '%google+%')
//								              and    Recurring_Period__c !=''
//								              and    Recurring_Period__c != 'N/A'
//								             ];
		// Number of Active Adwords Products
		this.daily_stats.Active_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										             ];
		// Number of Active SEO Products
		this.daily_stats.Active_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										             ];
		// Number of Active Converto Products
		this.daily_stats.Active_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										             ];										             		
		// Number of Active Facebook Products
		this.daily_stats.Active_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										             ];		
		// Number of Active Admob Products
		this.daily_stats.Active_Admob_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Admob%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										             ];		
		// Number of Active google+ Products
		this.daily_stats.Active_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										             ];	
		// Number of sign ups today								             
		this.daily_stats.Setups__c  = [select Count()
									   from   Sign_Up__c
									   where CreatedDate = today
									   ];
		// Number of cancels today								             
		this.daily_stats.Cancels__c  = [select Count()
									   from    Client_History__c
									   where   CreatedDate = today
									   and     Type__c = 'Cancelled'
									   ];
		// Number of pauses today								             
		this.daily_stats.Pauses__c  = [select Count()
									   from    Client_History__c
									   where   CreatedDate = today
									   and     Type__c = 'Paused'
									   ];									   
									   
									   
		this.daily_stats.Date__c = Date.today();
		this.daily_stats.Name    = DateTime.now().format('EEEE dd-MM-yyyy') + ' Stats';		

		
		// for GMT		
		generateForGMT('Get More Traffic');
		
		// for GMTNZ
		//companyName = Company_Name__c.getInstance('GMTNZ').Value__c;
		generateForGMTNZ('Get More Traffic New Zealand');
		
		// for SLX
		//companyName = Company_Name__c.getInstance('SLX').Value__c;
		generateForSLX('SponsoredLinx');
		
		// for SLXNZ
		//companyName = Company_Name__c.getInstance('SLXNZ').Value__c;
		generateForSLXNZ('SponsoredLinX New Zealand');
		
		insert daily_stats;
	}
	
	public  void generateForGMT(String companyName){
		//String companyName = '';
		//companyName = Company_Name__c.getValues('GMT').Value__c;
		
										             
		/*-------- for active products --------*/
		// number of active clients
		this.daily_stats.GMT_Active_Clients__c = [select count()
										               from   Account
										               where  Active__c = true										               
										               and    BJB_Company__r.name = :companyName];
		
		// Number of Active Adwords Products
		this.daily_stats.GMT_Active_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName];
		
		// Number of Active SEO Products
		this.daily_stats.GMT_Active_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Active Converto Products
		this.daily_stats.GMT_Active_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Active Facebook Products
		this.daily_stats.GMT_Active_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Active google+ Products
		this.daily_stats.GMT_Active_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	

		// Number of Other Active Products
		List<Account_Product__c > others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Active'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		Integer count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.GMT_Active_Products__c = count;


		/*-------- for paused products --------*/
		// Number of Paused Adwords Products
		this.daily_stats.GMT_Paused_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused SEO Products
		this.daily_stats.GMT_Paused_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused Converto Products
		this.daily_stats.GMT_Paused_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.GMT_Paused_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Paused google+ Products
		this.daily_stats.GMT_Paused_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Paused'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.GMT_Paused_Products__c = count;

		/*-------- for setup products --------*/
		this.daily_stats.GMT_Setup_Adwords_Products__c = [SELECT count()
										               FROM   Account_Product__c										               
										               WHERE  Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and 	  SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										               							 
										             ];
		// Number of Paused SEO Products
		this.daily_stats.GMT_Setup_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];
		// Number of Paused Converto Products
		this.daily_stats.GMT_Setup_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.GMT_Setup_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];		
		// Number of Paused google+ Products
		this.daily_stats.GMT_Setup_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__r.company_name__c = :companyName
										   and    Sign_Up_del__r.Status__c = 'New' 										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.GMT_Setup_Products__c = count;

	}

		public void generateForGMTNZ(String companyName){
		
										             
		/*-------- for active products --------*/
		// number of active clients
		this.daily_stats.GMT_NZ_Active_Clients__c = [select count()
										               from   Account
										               where  Active__c = true										               
										               and    BJB_Company__r.name = :companyName];

		// Number of Active Adwords Products
		this.daily_stats.GMT_NZ_Active_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName];
		
		// Number of Active SEO Products
		this.daily_stats.GMT_NZ_Active_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Active Converto Products
		this.daily_stats.GMT_NZ_Active_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Active Facebook Products
		this.daily_stats.GMT_NZ_Active_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Active google+ Products
		this.daily_stats.GMT_NZ_Active_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	

		// Number of Other Active Products
		List<Account_Product__c > others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Active'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		Integer count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.GMT_NZ_Active_Products__c = count;


		/*-------- for paused products --------*/
		// Number of Paused Adwords Products
		this.daily_stats.GMT_NZ_Paused_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused SEO Products
		this.daily_stats.GMT_NZ_Paused_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused Converto Products
		this.daily_stats.GMT_NZ_Paused_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.GMT_NZ_Paused_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Paused google+ Products
		this.daily_stats.GMT_NZ_Paused_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Paused'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.GMT_NZ_Paused_Products__c = count;

		/*-------- for setup products --------*/
		this.daily_stats.GMT_NZ_Setup_Adwords_Products__c = [SELECT count()
										               FROM   Account_Product__c										               
										               WHERE  Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and 	  SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										               							 
										             ];
		// Number of Paused SEO Products
		this.daily_stats.GMT_NZ_Setup_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];
		// Number of Paused Converto Products
		this.daily_stats.GMT_NZ_Setup_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.GMT_NZ_Setup_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];		
		// Number of Paused google+ Products
		this.daily_stats.GMT_NZ_Setup_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__r.company_name__c = :companyName
										   and    Sign_Up_del__r.Status__c = 'New' 										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.GMT_Setup_Products__c = count;

	}
	

	public void generateForSLX(String companyName){
		/*-------- for active products --------*/
		// number of active clients
		this.daily_stats.SLX_Active_Clients__c = [select count()
										               from   Account
										               where  Active__c = true										               
										               and    BJB_Company__r.name = :companyName];

		// Number of Active Adwords Products
		this.daily_stats.SLX_Active_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName];
		
		// Number of Active SEO Products
		this.daily_stats.SLX_Active_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Active Converto Products
		this.daily_stats.SLX_Active_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Active Facebook Products
		this.daily_stats.SLX_Active_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Active google+ Products
		this.daily_stats.SLX_Active_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	

		// Number of Other Active Products
		List<Account_Product__c > others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Active'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		Integer count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.SLX_Active_Products__c = count;


		/*-------- for paused products --------*/
		// Number of Paused Adwords Products
		this.daily_stats.SLX_Paused_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused SEO Products
		this.daily_stats.SLX_Paused_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused Converto Products
		this.daily_stats.SLX_Paused_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.SLX_Paused_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Paused google+ Products
		this.daily_stats.SLX_Paused_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Paused'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.SLX_Paused_Products__c = count;

		/*-------- for setup products --------*/
		this.daily_stats.SLX_Setup_Adwords_Products__c = [SELECT count()
										               FROM   Account_Product__c										               
										               WHERE  Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and 	  SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										               							 
										             ];
		// Number of Paused SEO Products
		this.daily_stats.SLX_Setup_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];
		// Number of Paused Converto Products
		this.daily_stats.SLX_Setup_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.SLX_Setup_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];		
		// Number of Paused google+ Products
		this.daily_stats.SLX_Setup_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__r.company_name__c = :companyName
										   and    Sign_Up_del__r.Status__c = 'New' 										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.SLX_Setup_Products__c = count;

	}
	

	public void generateForSLXNZ(String companyName){
		
										             
		/*-------- for active products --------*/

		// number of active clients
		this.daily_stats.SLX_NZ_Active_Clients__c = [select count()
										               from   Account
										               where  Active__c = true										               
										               and    BJB_Company__r.name = :companyName];

		// Number of Active Adwords Products
		this.daily_stats.SLX_NZ_Active_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName];
		
		// Number of Active SEO Products
		this.daily_stats.SLX_NZ_Active_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Active Converto Products
		this.daily_stats.SLX_NZ_Active_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Active Facebook Products
		this.daily_stats.SLX_NZ_Active_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Active google+ Products
		this.daily_stats.SLX_NZ_Active_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Active'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	

		// Number of Other Active Products
		List<Account_Product__c > others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Active'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		Integer count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.SLX_NZ_Active_Products__c = count;


		/*-------- for paused products --------*/
		// Number of Paused Adwords Products
		this.daily_stats.SLX_NZ_Paused_Adwords_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused SEO Products
		this.daily_stats.SLX_NZ_Paused_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];
		// Number of Paused Converto Products
		this.daily_stats.SLX_NZ_Paused_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.SLX_NZ_Paused_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];		
		// Number of Paused google+ Products
		this.daily_stats.SLX_NZ_Paused_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Product_Status__c = 'Paused'
										               and    Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Product_Status__c = 'Paused'										               
							               and    Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__c IN (SELECT id FROM SLX_Product__c WHERE company_name__c = :companyName)										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.SLX_NZ_Paused_Products__c = count;

		/*-------- for setup products --------*/
		this.daily_stats.SLX_NZ_Setup_Adwords_Products__c = [SELECT count()
										               FROM   Account_Product__c										               
										               WHERE  Name like '%Adwords%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and 	  SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										               							 
										             ];
		// Number of Paused SEO Products
		this.daily_stats.SLX_NZ_Setup_SEO_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%SEO%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];
		// Number of Paused Converto Products
		this.daily_stats.SLX_NZ_Setup_Converto_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Converto%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];										             		
		// Number of Paused Facebook Products
		this.daily_stats.SLX_NZ_Setup_Facebook_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%Facebook%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];		
		// Number of Paused google+ Products
		this.daily_stats.SLX_NZ_Setup_Google_Products__c = [select count()
										               from   Account_Product__c
										               where  Name like '%google+%'
										               and    Recurring_Period__c !=''
										               and    Recurring_Period__c != 'N/A'
										               and    SLX_Product__r.company_name__c = :companyName
										               and    Sign_Up_del__r.Status__c = 'New' 

										             ];	
		// Number of Other Paused Products
		others = [select id, name
							               from   Account_Product__c
							               where  Recurring_Period__c !=''
							               and    Recurring_Period__c != 'N/A'
							               and    SLX_Product__r.company_name__c = :companyName
										   and    Sign_Up_del__r.Status__c = 'New' 										               
							            ];
		//Remove not matching products
		count = 0;
		for(Account_Product__c item: others){
			if(!(item.name.containsIgnoreCase('facebook') || (item.name.containsIgnoreCase('seo')) || item.name.containsIgnoreCase('adwords') || item.name.containsIgnoreCase('google'))){
				count++;
			}
		}
		this.daily_stats.SLX_NZ_Setup_Products__c = count;

	}

}