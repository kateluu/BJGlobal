@isTest
private class ClientPanelAccountBillingTest {
	
	@isTest
    static void testSubmit() {
        string sitename = 'checkout_SLX';

        User siteUserSLX = [SELECT Id, Name FROM User WHERE Name = 'Checkout SLX Site Guest User'];

        String salt = 'abcdefg';

        // Load payment gateway config
        // Eway2
        insert new SystemVars__c(
            Name                = 'main',
            salt__c      		= salt
        );

        // Setup companies
        Company__c company = new Company__c(
            Name = 'SponsoredLinX',
            Business_Name__c = 'SponsoredLinX',
            Checkout_Site__c = 'checkout_SLX',
            Payment_Gateway__c = 'Eway2',
            CurrencyIsoCode  = 'AUD'
        );
        insert company;

        // Setup existing account
        Account existingAccount = new Account(
            Name                    = 'Steve Existingclient',
            username__c             = 'steve.existingclient@sponsoredlinx.com',
            bjb_company__c          = company.Id,
            name_on_card__c         = 'Steve Clientman',
            card_number_masked__c   = '5454111122221111',
            card_month_expiry__c    = '9',
            card_year_expiry__c     = '2028',
            card_cvn__c             = '789'
        );
        insert existingAccount;

        // Share account with the checkout user. This is to emulate the sharing rule, which salesforce doesn't
        // apply in test cases. See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_bulk_sharing_understanding.htm
        insert new AccountShare(
            AccountId = existingAccount.Id,
            UserOrGroupId = siteUserSLX.Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );

        // run tests
        test.starttest();

        system.runAs(siteUserSLX) {
            String sigData = existingAccount.Id + existingAccount.username__c + salt;
            String accountSig = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueof(sigData)));

            // Test error case with no account id
        	ClientPanelAccountBilling controller1 = new ClientPanelAccountBilling();
        	controller1.index();

        	// Test normal case with account id
        	pagereference pageref = page.ClientPanelAccountBilling;
            pageref.getParameters().put('accountid', existingAccount.id ); // To test loading existing account
            pageref.getParameters().put('sig', accountSig);
            test.setCurrentPage(pageref);
        	ClientPanelAccountBilling controller2 = new ClientPanelAccountBilling();
        	controller2.index();

        	controller2.index();
        	controller2.getMonthOptions();
        	controller2.getCardYearOptions();
        	controller2.getSiteWrapperURL();
        	controller2.submitUpdateBilling();
		}

		test.stoptest();
	}
	
}