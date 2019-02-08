public with sharing class ClientPanelAccountBilling {

	public Account acc {get; set;}
    public String paymentType {get; set;}
    public CardDetails cardDetails {get; set;} {cardDetails = new CardDetails();}

    private Id accId;

    // Constructor
    public ClientPanelAccountBilling() {
        this.acc = new Account();

        // Set defaults
        this.paymentType = 'Credit Card';

        // Load details from existing account if the accountid and uid were passed in the URL or cookies
        try{
            this.loadAccount();
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    // Load account from cookies
    private void loadAccount(){

        // Load the salt from system vars. This should match the salt used to generate the signature in clientpanel.
        String salt = SystemVars__c.getValues('main').salt__c;

        Id reqAccountId = ApexPages.currentPage().getParameters().get('accountid');
        String reqSig = ApexPages.currentPage().getParameters().get('sig');

        if ( reqAccountId == null ){
            throw new customException('No account specified');
        }

        Account[] existingAccounts = [
        SELECT Id, Name, username__c, Unique_Id__c, Industry, Number_of_Employees__c, Name_On_Card__c, Card_Number__c, Card_Number_Masked__c, Card_Month_Expiry__c, Card_Year_Expiry__c, Card_CVN__c, Card_Token__c, Company__c, Website, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, GST__c, BJB_Company__c 
        FROM Account 
        WHERE id = :reqAccountId 
        LIMIT 1];

        if (existingAccounts.size() == 0) {
            throw new customException('Could not find account');
        }

        Account checkAccount = existingAccounts[0];

        // Generate the signature for this account and compare it to the one passed in the request
        String sigData = checkAccount.Id + checkAccount.username__c + salt;
        String accountSig = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueof(sigData)));

        system.debug('accountSig: ' + accountSig);

        if (reqSig == accountSig){
            this.acc = checkAccount;

            // Pad the card month with leading zero if it doesn't already have it.
            if (this.acc.Card_Month_Expiry__c != null){
                this.acc.Card_Month_Expiry__c = this.acc.Card_Month_Expiry__c.leftPad(2).replaceAll(' ', '0');
            }

            // Populate the card number field with the previous masked value from the account
            this.cardDetails.Card_Number = this.acc.Card_Number_Masked__c;

            // Important: We cannot have an Id on the account when the VF page is displayed because Guest user licenses don't have edit
            // access to accounts, so the whole record becomes readonly on the VF page. VF uses the Id field to determine whether it's an existing record.
            // We'll store the Id in a private variable so we can add it back to the object before saving it.
            this.accId = this.acc.Id;
            this.acc.Id = null;
        } else {
            throw new customException('Could not verify this account');
        }
    }

    // Get the address that this checkout should use for the wrapper around the iframe
    public String getSiteWrapperURL(){
        // Use crankit even for live site, prior to launch.
        if (utility.runningInASandbox()){
            return 'https://clientpanel.staging.sponsoredlinx.com.au';
        } else {
            return 'https://clientpanel.sponsoredlinx.com.au';
        }
    }

    // Get options for month dropdown
    public List<SelectOption> getMonthOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','month'));

        for( Schema.PicklistEntry pickListVal : Account.Card_Month_Expiry__c.getDescribe().getPicklistValues()){
            options.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }

        return options;
    }

    // Get options for credit card year dropdown
    public List<SelectOption> getCardYearOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','year'));

        for( Schema.PicklistEntry pickListVal : Account.Card_Year_Expiry__c.getDescribe().getPicklistValues()){
            options.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }

        return options;
    }

    // =============================================================
    // Actions
    // =============================================================

    // Index page
    public PageReference index() {
        return null;
    }

    // Submit "update billing details" page.
    public PageReference submitUpdateBilling() {
        try {
            // Generate a token (this also masks the card number so it won't display on the page)
            paymentGateway pay = new paymentGateway();
            pay.updateAccountToken(this.acc, this.cardDetails.Card_Number, this.cardDetails.Card_CVN);

            // Update the account
            // Important: We cannot have an Id on the account when the VF page is displayed because Guest user licenses don't have edit
            // access to accounts, so the whole record becomes readonly on the VF page. VF uses the Id field to determine whether it's an existing record.
            acc.Id = this.accId;
            update this.acc;
            acc.Id = null;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Thank you. Your card details have been updated'));
        } catch (Exception e) {
            // Notify sysadmin
            string submitError = 'Error: ' + e.getMessage() + '. On ' + e.getStackTraceString();
            system.debug(submitError);
            Utility.notifySysadmin('Error in submitUpdateBilling', submitError);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry, an error occurred while updating your payment details. ' + e.getMessage() ));
        }

        return null;
    }
}