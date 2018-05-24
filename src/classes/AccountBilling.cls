public with sharing class AccountBilling {

    public Account acc {get;set;}
    public CardDetails cardDetails {get; set;} {cardDetails = new CardDetails();}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AccountBilling(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) controller.addFields(new String[]{'Id', 'Name', 'Card_Number__c', 'Card_Number_Masked__c', 'Name_On_Card__c', 'Card_Month_Expiry__c', 'Card_Year_Expiry__c', 'Card_CVN__c', 'Unique_Id__c', 'currencyIsoCode', 'BJB_Company__c'});
        this.acc = (Account)controller.getRecord();

        // Populate the card number field with the previous masked value from the account
        this.cardDetails.Card_Number = this.acc.Card_Number_Masked__c;
    }

    // Submit 'update'
    public PageReference submitUpdate() {
        // Error checking
        if (String.isBlank(this.cardDetails.Card_Number)){
            System.debug('Error: Please enter a card number');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a card number'));
        }

        if (String.isBlank(this.acc.Name_On_Card__c)){
            System.debug('Error: Please enter the name on the credit card');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the name on the credit card'));
        }

        if (String.isBlank(this.acc.Card_Month_Expiry__c)){
            System.debug('Error: Please enter the card month expiry');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the card month expiry'));
        }

        if (String.isBlank(this.acc.Card_Year_Expiry__c)){
            System.debug('Error: Please enter the card year expiry');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the card year expiry'));
        }

        // create card transaction payment
        if ( !ApexPages.hasMessages() ) {
            try{
                paymentGateway pay = new paymentGateway();
                pay.updateAccountToken(this.acc, this.cardDetails.Card_Number, this.cardDetails.Card_CVN);
                update this.acc;
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }

        if ( ApexPages.hasMessages() ) {
            // Display errors
            return null;
        } else {
            PageReference MyPage = new PageReference('/'+this.acc.id);
            MyPage.setRedirect(true);
            return MyPage;
        }

    }

    // Return to the account page
    public PageReference returnToAccount() {
        PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }
}