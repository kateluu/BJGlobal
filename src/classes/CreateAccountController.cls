public with sharing class CreateAccountController {
    
    public Account account {get; set;}
	public Promocode__c pcode {get; set;}

    public CreateAccountController(){
    	this.account = new Account();
    	this.pcode = new Promocode__c();
    	this.account.phone = '1300859600';
    }
    
    public pageReference save() {
    	SavePoint sp = Database.setSavepoint();
    	try {
    		account.username__c   = account.Name.replace(' ', '.');
    		account.password__c   = account.Name.replace(' ', '.');
    		account.email__c      = account.Name.replace(' ', '.') + '@sponsoredlinx.com';
    		account.type          = 'Employee';
    		upsert(account);
    		this.pcode.account__c = this.account.ID;
    		upsert(pcode);
    		
    		//Insert Conventional Promocodes for new Salesperson
	    	if(account.Employee_Department__c == 'Sales' && account.Type == 'Employee' && account.Active__c == true) {
	    		
	    		Promotions__c pfw = [select id from Promotions__c where name='Free Week 99 Off Setup Fee' limit 1];
				Promotions__c ofw = [select id from Promotions__c where name='Free Week 89 Off Setup Fee' limit 1];
				Promotions__c sfw = [select id from Promotions__c where name='Free Week 79 Off Setup Fee' limit 1];
				Promotions__c pso = [select id from Promotions__c where name='Discounted Adwords Premium' limit 1];
				Promotions__c oss = [select id from Promotions__c where name='Discounted Adwords Optimised' limit 1];
				Promotions__c mws = [select id from Promotions__c where name='Discounted Adwords Standard' limit 1];
				Promotions__c sdw = [select id from Promotions__c where name='$10 off management' limit 1];
				
				Map<String, Promotions__c> promotionMap = new Map<String, Promotions__c>();
				promotionMap.put('PFW', pfw);
				promotionMap.put('PSO', pso);
				promotionMap.put('OFW', ofw);
				promotionMap.put('OSS', oss);
				promotionMap.put('SFW', sfw);
				promotionMap.put('SDW', sdw);
				promotionMap.put('MWS', mws);
				
				Map<String, String> descriptionMap = new Map<String, String>();
				descriptionMap.put('PFW', 'Premium Free Week');
				descriptionMap.put('PSO', 'Premium Service Optimised Price');
				descriptionMap.put('OFW', 'Optimised Free Week');
				descriptionMap.put('OSS', 'Optimised Service Standard Price');
				descriptionMap.put('SFW', 'Standard Free Week');
				descriptionMap.put('SDW', 'Standard Discount Weekly Management');
				descriptionMap.put('MWS', 'Multiple Website Sign up');
	    		
	    		Set<String> pcodeNames = new Set<String>();
				for (Promocode__c pc : [select id, name from Promocode__c where account__c = :account.id]) {
					pcodeNames.add(pc.name);
				}
				
				List<Promocode__c> pcodes = new list<promocode__c>();
				
			    string fn = account.name.split(' ', 2)[0];
			    string ln = account.name.split(' ', 2)[1];
				for (String prefix : promotionMap.keyset()) {
					string name = prefix + fn.substring(0,1).toUpperCase() + ln.substring(0,3).toUpperCase();
					if(!pcodeNames.contains(name)) {
						Promocode__c pc = new Promocode__c();
						pc.Account__c = account.id;
						pc.isActive__c = true;
						pc.Promocode_Description__c = descriptionMap.get(prefix);
						pc.Promotions__c = promotionMap.get(prefix).id;
						pc.name = name;
						pcodes.add(pc);
					}
				}
				
				insert pcodes;
	    	}
    	} catch(Exception e) {
    		Database.rollback(sp);
    		ApexPages.addMessages(e);
            return null;
    	}
    	PageReference accountPage = new PageReference('/' + account.Id);
    	return accountPage;
    }
    
    @isTest(SeeAllData=true)
    public static void test() {
    	Test.StartTest();

		CreateAccountController con = new CreateAccountController();
		con.account = new Account(Name='Test test', Employee_Department__c = 'Sales', Active__c= true);
		con.pcode = new Promocode__c(Name='test12321', Promocode_Description__c= 'test');
		con.save();

		Test.stopTest();
    
    }

}