@isTest
private class AccountBillingTest {
	
	@isTest static void test_method_one() {
        // Setup existing account
        Account existingAccount = new Account(
            Name                    = 'Steve Existingclient',
            username__c             = 'steve.existingclient@sponsoredlinx.com',
            name_on_card__c         = 'Steve Clientman',
            card_number_masked__c   = '5454111122221111',
            card_month_expiry__c    = '9',
            card_year_expiry__c     = '2028',
            card_cvn__c             = '789'

        );
        insert existingAccount;

		// Load the controller
		ApexPages.currentPage().getParameters().put('id', existingAccount.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(existingAccount);
        AccountBilling controller = new AccountBilling(stdController);

        controller.submitUpdate();

        controller.returnToAccount();
	}
	
}