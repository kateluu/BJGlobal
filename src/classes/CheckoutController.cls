public with sharing class CheckoutController {

    public Sign_Up__c signup {get; private set;}
    public Account acc {get; set;}
    public String parentRedirect {get; private set;}
    public String siteName;
    public String fromSource;
    public String emailSignupAddress;
    public String companyName;
    public String locale;

    // Form fields that don't directly correspond to an sObject field
    public String paymentType {get; set;}
    public String cardType {get; set;}
    public String birthDay {get; set;}
    public String birthMonth {get; set;}
    public String birthYear {get; set;}

    public Boolean mailing_address {get; set;}

    public Boolean termsFacebook1 {get; set;}
    public Boolean termsFacebook2 {get; set;}
    public Boolean termsFacebook3 {get; set;}
    public Boolean termsFacebook4 {get; set;}
    public Boolean termsFacebook5 {get; set;}
    public Boolean termsWeb1 {get; set;}
    public Boolean termsWeb2 {get; set;}
    public Boolean termsWeb3 {get; set;}
    public Boolean termsWeb4 {get; set;}
    public Boolean termsWeb5 {get; set;}
    public Boolean termsAdwords1 {get; set;}
    public Boolean termsAdwords2 {get; set;}
    public Boolean termsAdwords3 {get; set;}
    public Boolean termsAdwords4 {get; set;}
    public Boolean termsAdwords5 {get; set;}
    public Boolean termsSeo1 {get; set;}
    public Boolean termsSeo2 {get; set;}
    public Boolean termsSeo3 {get; set;}
    public Boolean termsSeo4 {get; set;}
    public Boolean termsSeo5 {get; set;}
    public Boolean termsVideo1 {get; set;}

    public Boolean termsDD1 {get; set;}

    private Map<String,Boolean> paymentTypesEnabled = new Map<String,Boolean>();

    private Cart mycart;
    private Site mySite;
    private Company__c bjbCompany;

    @TestVisible private Integer paymentTestType {get; set;}
    @TestVisible private Integer testGateway {get; set;}

    // Packages is the extended data about each product, loaded from the database.
    private List<List<CartItem>> packages;

    // Classes
    public class checkoutException extends Exception {}

    // Constructor
    public CheckoutController() {
        acc = new Account();

        if (signup == null){
            signup = new Sign_Up__c();
        }

        // locale can be detected by either ?locale=NZD in the URL, or by checking the iframe referer (parent) URL
        String referer = ApexPages.currentPage().getHeaders().get('Referer');
        String detectedLocale = 'AUD';
        if (ApexPages.currentPage().getParameters().get('locale') != null){
            detectedLocale = ApexPages.currentPage().getParameters().get('locale');
        } else if ( referer == 'http://devnz.crankit.com.au/checkout/' || referer == 'https://www.sponsoredlinx.co.nz/checkout/' || referer == 'https://getmoretraffic.co.nz/checkout/'){
            detectedLocale = 'NZD';
        }

        // Initialize options for this site
        this.setSite(Site.getName(), detectedLocale);

        // Set defaults
        this.paymentType = 'Credit Card';

        this.mailing_address = true;

        if (detectedLocale == 'NZD'){
            signup.GST__c = true;
        }

        // Load details from existing account if the accountid and uid were passed in the URL or cookies
        this.loadAccount();
    }

    // =============================================================
    // Actions
    // =============================================================

    // Index page
    public PageReference index() {
        try{
            // Action should be in the 'do' parameter, we can't use 'action' in GET because it interferes with salesforce postback in some cases.
            String action = ApexPages.currentPage().getParameters().get('do');

            // Add products that were submitted (parameters from external links)
            if ( action == 'addPackage' ){
                return this.addPackage();
            } else if ( action == 'removePackage' ){
                return this.removePackage();
            } else if ( action == 'clearCart' ){
                return this.clearCart();
            }

            return null;
        } catch (Exception e) {
            system.debug('Error in index: ' + e.getMessage());
            return Page.Exception;
        }
    }

    // Add package to the cart
    public PageReference addPackage() {

        try{
            // Clear packages so it gets rebuilt with modified cart data
            this.packages = null;

            if ( ApexPages.currentPage().getParameters().get('package') != null ){
                // Split comma-separated list of product ids
                List<String> productIds = ApexPages.currentPage().getParameters().get('package').split('\\,');

                try {
                    mycart.setPackage(productIds);
                } catch (Exception e) {
                    system.debug('Error in addPackage: ' + e.getMessage() );
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid product id'));
                    return null;
                }

                String promocode = ApexPages.currentPage().getParameters().get('promocode');
                if (promocode != null){
                    setPromocode(promocode);
                }
            }

            // There can be multiple addons, but apex doesn't support [] in the query string for multi-dimensional data,
            // so we have to use addon-1, addon-2, addon-3 etc, and loop through the getParameters looking for this pattern.
            // The value for addons are comma-separated product ids optionally followed by colon and a promocode. eg &addon-1=a1BO00000031tBN,a1BO00000031tBR:20setup
            for ( String getKey : ApexPages.currentPage().getParameters().keySet()){
                if ( getKey.startsWith('addon-') ) {
                    String getValue = ApexPages.currentPage().getParameters().get(getKey);

                    // An empty value means we want to remove the addons (eg changing to the 'no thanks' radio button)
                    if (getValue == 'remove'){
                        for (Integer j = 0; j < mycart.myPackageData.addons.size(); j++){
                            mycart.myPackageData.addons.remove(j);
                        }
                    } else {
                        String addonPromocode = getValue.substringAfterLast(':');
                        List<String> addonProductIds = getValue.substringBeforeLast(':').split('\\,');

                        try{
                            mycart.addon(addonProductIds, addonPromocode);
                        } catch (Exception e) {
                            system.debug('Invalid addon product ids: ' + addonProductIds);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid product id'));
                            return null;
                        }
                    }
                }
            }

            saveCart();

            return null;
        } catch (Exception e) {
            system.debug('Error in addPackage: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This item could not be added'));
            return null;
        }
    }

    // Remove package from the cart
    public PageReference removePackage() {

        try{
            // Clear packages so it gets rebuilt with modified cart data
            this.packages = null;

            if ( ApexPages.currentPage().getParameters().get('package') != null ){
                // Remove the main product
                clearCart();
            }

            // There can be multiple addons, but apex doesn't support [] in the query string for multi-dimensional data,
            // so we have to use addon-1, addon-2, addon-3 etc, and loop through the getParameters looking for this pattern.
            // The value for addons are comma-separated product ids optionally followed by colon and a promocode. eg &addon-1=a1BO00000031tBN,a1BO00000031tBR:20setup
            for ( String getKey : ApexPages.currentPage().getParameters().keySet()){
                if ( getKey.startsWith('addon-') ) {
                    String getValue = ApexPages.currentPage().getParameters().get(getKey);

                    // An empty value means we want to remove the addons (eg changing to the 'no thanks' radio button)
                    List<id> addonProductIds = getValue.substringBeforeLast(':').split('\\,');

                    try{
                        for (Integer j = 0; j < mycart.myPackageData.addons.size(); j++){
                            if (Utility.ListFind(mycart.myPackageData.addons[j].productIds, addonProductIds[0])){
                               mycart.myPackageData.addons.remove(j);
                            }
                        }
                    } catch (Exception e) {
                        system.debug('Invalid remove product ids: ' + addonProductIds);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid product id'));
                        return null;
                    }
                }
            }

            saveCart();
        } catch (Exception e) {
            system.debug('Error in addPackage: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This item could not be added'));
        }

        return null;
    }

    // Apply a promocode
    public PageReference applyPromocode() {
        // Applying the promocode is automatically handled in the setter setPromocode()
        return null;
    }

    // Apply a payment type
    public PageReference applyPaymentType() {
        return null;
    }

    // Remove all addons
    public PageReference removeAddons() {
        // Clear packages so it gets rebuilt with modified cart data
        this.packages = null;

        for (Integer j = 0; j < mycart.myPackageData.addons.size(); j++){
            mycart.myPackageData.addons.remove(j);
        }

        saveCart();

        return null;
    }

    // Clear everything from the checkout
    public PageReference clearCart() {
        try{
            mycart.clear();
            saveCart();

            return null;
        } catch (Exception e) {
            return Page.Exception;
        }
    }

    // Submit the checkout
    public PageReference submitCheckout() {

        Payment_Attempt__c paymentAttempt;

        try {
            // Check if there is already a signup for this cookie. This protects against double-submits of the same cart. The MD5 of the
            // serialized cart will be unique to this cookie due to the addTime field.
            String cartSignature = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueof(JSON.serialize(this.mycart))));
            Sign_Up__c[] existingSignups = [SELECT Id, Name FROM Sign_Up__c WHERE Cart_Signature__c = :cartSignature LIMIT 1];
            if (existingSignups.size() > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This cart has already been submitted.'));
                return null;
            }

            if ( this.mailing_address == true ){
                // Use billing address as mailing address
                signup.MailingStreet__c        = signup.Street__c;
                signup.MailingCity__c          = signup.City__c;
                signup.MailingState__c         = signup.State__c;
                signup.MailingPostalCode__c    = signup.PostalCode__c;
            }

            // Create/update the account
            acc.username__c             = signup.Email__c;
            acc.email__c                = signup.Email__c;
            acc.Name                    = signup.Company__c;
            acc.Company__c              = signup.Company__c;
            acc.Website                 = signup.Website__c;
            acc.Send_Invoice__c         = false;
            acc.BJB_Company__c          = bjbCompany.Id;

            acc.BillingStreet           = signup.Street__c;
            acc.BillingCity             = signup.City__c;
            acc.BillingState            = signup.State__c;
            acc.BillingPostalCode       = signup.PostalCode__c;
            acc.Phone                   = signup.Phone__c;
            acc.GST__c                  = signup.GST__c;
            acc.CurrencyIsoCode         = this.locale;

            // Prefix GMT account names with "GetMoreTraffic - "
            if (this.siteName == 'checkout_GMT') {
                acc.Name                = 'GetMoreTraffic - ' + signup.Company__c;
            }

            // Default payment type is Eway for credit card
            if ( this.paymentType == 'Direct Debit' ){
                // We currently use 'other' to mean 'direct debit'. There is no 'direct debit' option in the picklist.
                // acc.Payment_Option__c = 'Direct Debit';
                acc.Payment_Option__c = 'Other';
            } else if ( this.paymentType == 'Invoice' ){
                acc.Payment_Option__c = 'Other';
            } else if ( this.paymentType == 'Credit Card' ){
                if (this.locale == 'NZD') {
                    acc.Payment_Option__c = 'Commweb';
                } else {
                    acc.Payment_Option__c = 'Eway';
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unrecognised payment type'));
                return null;
            }

            signup.CurrencyIsoCode      = this.locale;
            signup.Invoiceno__c         = getNextInvoiceNumber();

            // Process payment
            // This must be done before any of the signup/account is inserted, because if there's a card error we want
            // to display an error and allow them to correct and resubmit. Also because salesforce doesn't let you use a webservice after saving any DML.
            // Get the signup total.
            Decimal totalSetup = this.getTotalSetup();

            // If there is no setup cost, no need to process payment
            if (totalSetup > 0){
                if (this.paymentType == 'Credit Card'){
                    // Use your sponsoredlinx email with +testsuccess to test a success
                    if ( signup.Email__c.endsWith('+testsuccess@sponsoredlinx.com') ){
                        this.paymentTestType = paymentGateway.TEST_SUCCESS;
                    } else if ( signup.Email__c.endsWith('+testfailure@sponsoredlinx.com') ){
                        this.paymentTestType = paymentGateway.TEST_FAILURE;
                    }

                    paymentAttempt = this.processPayment(totalSetup);

                    system.debug('paymentAttempt : ' + paymentAttempt);

                    if (paymentAttempt.Status__c != 'SUCCESS') {
                        String errorMessage = 'Sorry, an error occurred while processing payment: ' + paymentAttempt.Response_Message__c;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    }
                }
            }


            // Lookup from the signup to the successful payment attempt
            if (paymentAttempt != null){
                signup.Payment_Attempt__c   = paymentAttempt.Id;
            } else {
                signup.Payment_Attempt__c   = null;
            }

            // If paying by direct debit, we must validate that the BSB is valid. This must be done
            // even if there is no setup cost.
            if (this.paymentType == 'Direct Debit'){
                if ( isBsbValid(acc.BSB__c) == false ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'BSB is invalid'));
                }

                // Account numbers must be less than 10 digits
                if ( acc.Account_No__c.length() > 10 ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account number should be less than 10 digits'));
                }

                // We can't use the standard date field in Visualforce because it doesn't allow you to select previous years, so
                // we use dropdowns for day/month/year and assemble them into a date here.
                signup.Birthdate__c = Date.newInstance(integer.valueof(birthYear), integer.valueof(birthMonth), integer.valueof(birthDay));
            }

            // If errors were found, redisplay the page instead of inserting the order
            if ( ApexPages.hasMessages(ApexPages.Severity.ERROR) ){
                return null;
            }

            // Check if there is an existing account for this email address
            // Important: We cannot have an Id on the account when the VF page is displayed because Guest user licenses don't have edit
            // access to accounts, so the whole record becomes readonly on the VF page. VF uses the Id field to determine whether it's an existing record.
            Account[] existingAccounts = [SELECT Id, Name, username__c, Unique_Id__c, password__c FROM Account WHERE username__c = :signup.Email__c LIMIT 1];
            if (existingAccounts.size() > 0) {
                system.debug('Using existing account id ' + existingAccounts[0].Id + ', password ' + existingAccounts[0].password__c);
                acc.Id          = existingAccounts[0].Id;
                acc.password__c = existingAccounts[0].password__c;

                // Send an email to accounts so that they can check the modified payment details for the account.
                if (!Test.isRunningTest()){
                    String errorMessage = 'Please check the account ' + existingAccounts[0].Name + ' in Salesforce: ' + 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To') + '/' + existingAccounts[0].Id;
                    Utility.sendEmail(New String[] {'accounts@sponsoredlinx.com'}, 'Cancelled Client Sign Up Again', errorMessage);
                }
            } else {
                system.debug('Creating new account for ' + signup.Email__c);
                acc.password__c             = Utility.generateRandomString(8);
            }

            // Copy the password into the password_on_signup field so that the checkout user can access it in the welcome email template.
            acc.password_on_signup__c         = acc.password__c;

            // Create the account
            upsert acc;

            // Contacts should be created before Account Products
            Map<String, sObject> contactMap = Utility.getSObjectMap('Title', [SELECT Title, Id FROM Contact WHERE Account.Id = :acc.Id]);
            
            List<Contact> newContacts = new List<Contact>();
            for (String contact_type : new List<String> {'Billing','Reports','Marketing'}){
                // Check if there is an existing contact
                if (contactMap.get(contact_type) == null){
                    Contact accContact = new Contact(
                        FirstName         = signup.Firstname__c,
                        LastName          = signup.Lastname__c,
                        AccountId         = acc.Id,
                        Email             = signup.Email__c,
                        Title             = contact_type,
                        MailingStreet     = signup.MailingStreet__c,
                        MailingCity       = signup.MailingCity__c,
                        MailingState      = signup.MailingState__c,
                        MailingPostalCode = signup.MailingPostalCode__c,
                        CurrencyIsoCode   = signup.CurrencyIsoCode
                    );

                    accContact.Phone             = signup.Phone__c;
                    accContact.MobilePhone       = signup.Mobile__c;

                    newContacts.add(accContact);
                }
            }
            insert newContacts;

            // Create the signup
            signup.Status__c            = 'New';
            signup.Username__c          = signup.Email__c;
            signup.Name                 = signup.Firstname__c + ' ' + signup.Lastname__c;
            signup.Industry__c          = acc.Industry;
            signup.FromSource__c        = this.fromSource;
            signup.IPAddress__c         = Utility.getUserIPAddress();
            signup.Account__c           = acc.Id;
            signup.BJB_Company__c       = bjbCompany.Id;
            signup.Form_Name__c         = 'Checkout';
          //  signup.Ownerid              = '00590000000Vmmq';

            if (mycart.myPackageData.promocode != null) {
                for ( Promocode__c promocode : [SELECT Id, Name, Account__c, Account__r.Name FROM Promocode__c WHERE IsActive__c = true AND Name = :mycart.myPackageData.promocode LIMIT 1] ) {
                    signup.Promocode__c         = promocode.Id;

                    if (promocode.Account__c != null && promocode.Account__r.Name != null){
                        system.debug('Using promocode for account ' + promocode.Account__c + ': ' + promocode.Account__r.Name);

                        signup.Salesperson__c       = promocode.Account__c;
                    }
                }
            }

            // Default to the company name as salesperson until override by promocode account
            if (signup.Salesperson__c == null){
                Account[] companyAccounts = [SELECT Id FROM Account WHERE Name = :this.companyName LIMIT 1];
                if (companyAccounts.size() > 0){
                    signup.Salesperson__c       = companyAccounts[0].Id;
                } else {
                    system.debug('Could not find default company account for ' + this.companyName);
                }
            }

            if (this.paymentTestType != null){
                signup.Is_Test__c = true;
            }

            // Serialize the cart so that the signup trigger can create the account_products etc
            signup.Cart_SF__c          = JSON.serialize(this.mycart);
            signup.Cart_Signature__c   = cartSignature;

            // Loop through the products to determine a 'product type' for the signup.
            List<CartItem> items = mycart.getPackageFromPackageData(mycart.myPackageData);

            boolean containsFacebook = false;

            for (CartItem myCartItem : items){
                signup.Product_Type__c = myCartItem.getProductType();

                if (signup.Product_Type__c == 'Social Marketing'){
                    containsFacebook = true;
                }

                if (myCartItem.product.product_recurring__c == 'Yes') {
                    signup.Management_Price__c      = utility.zerofy(signup.Management_Price__c) + utility.zerofy(myCartItem.priceNet);
                } else {
                    signup.Set_Up_Price__c          = utility.zerofy(signup.Set_Up_Price__c) + utility.zerofy(myCartItem.priceNet);
                }
            }

            String baseInvoiceNum = signup.Invoiceno__c;

            if (mycart.myPackageData.addons != null) {
                // Suffix the invoice number of the main product with "-1", and second product with "-2", etc. 
                signup.Invoiceno__c = baseInvoiceNum + '-1';
            }

            // Insert the signup. The signupInsertTrigger creates all the account_products, invoices etc.
            insert signup;

            try {
                sendSignupWelcomeEmail(signup);
            } catch (Exception e) {
                // Swallow the exception and log the error
                system.debug('Could not send welcome email: ' + e.getMessage());
            }

            // If there were addon packages, insert them as separate signups
            integer signupCount = 1;
            if (mycart.myPackageData.addons != null) {
                for (Cart.cartPackageData addonPackageData : mycart.myPackageData.addons){
                    // Create a cart with just the packagedata of the addon package
                    Cart addonCart = new Cart(companyName);
                    addonCart.myPackageData = addonPackageData;

                    // Loop through the products to determine a 'product type' for the signup. We also generate the packagedata so that discounts are applied
                    List<CartItem> addonItems = mycart.getPackageFromPackageData(addonPackageData);

                    if ( addonItems != null && addonItems.size() > 0){
                        signupCount++;

                        // Start with a clone of the primary signup, and update its cart and product type
                        Sign_Up__c addonSignup = signup.clone();
                        addonSignup.Management_Price__c = null;
                        addonSignup.Set_Up_Price__c     = null;
                        addonSignup.Promocode__c        = null;
                        addonSignup.Salesperson__c      = null;
                        addonSignup.Cart_SF__c          = JSON.serialize(addonCart);
                        addonSignup.Invoiceno__c        = baseInvoiceNum + '-' + signupCount.format();
                        addonSignup.Is_Addon__c         = true;

                        if (addonPackageData.promocode != null) {
                            for ( Promocode__c promocode : [SELECT Id, Name, Account__c FROM Promocode__c WHERE IsActive__c = true AND Name = :addonPackageData.promocode LIMIT 1] ) {
                                addonSignup.Promocode__c         = promocode.Id;
                            }
                        }

                        for (CartItem myCartItem : addonItems){
                            addonSignup.Product_Type__c = myCartItem.getProductType();

                            if (addonSignup.Product_Type__c == 'Social Marketing'){
                                containsFacebook = true;
                            }

                            if (myCartItem.product.product_recurring__c == 'Yes') {
                                addonSignup.Management_Price__c      = utility.zerofy(addonSignup.Management_Price__c) + utility.zerofy(myCartItem.priceNet);
                            } else if (myCartItem.product.product_recurring__c == 'No') {
                                addonSignup.Set_Up_Price__c          = utility.zerofy(addonSignup.Set_Up_Price__c) + utility.zerofy(myCartItem.priceNet);
                            }
                        }

                        // Insert the signup. The signupInsertTrigger creates all the account_products etc.
                        insert addonSignup;

                        try {
                            sendSignupWelcomeEmail(addonSignup);
                        } catch (Exception e) {
                            // Swallow the exception and log the error
                            system.debug('Could not send welcome email: ' + e.getMessage());
                        }
                    }
                }
            }

            // Clear the cart now that it has been inserted
            mycart.clear();
            saveCart();

            // Redirect to the success page on the main site. We pass details of the transaction for the tracking code.
            String successPath = '/signup-thanks/';
            if (this.siteName == 'checkout_GMT') {
                successPath = '/success/';
            }

            successPath += '?signupid=' + signup.id + '&total=' + totalSetup + '&bjblocale=' + this.locale;

            if (containsFacebook == true){
                successPath += '&fb=1';
            }

            if (this.siteName == 'checkout_SLX' && this.locale == 'NZD' && !utility.runningInASandbox()) {
                // For sponsoredlinx.co.nz, we need to display the success page on the .co.nz site, not the .com.au that the checkout is displayed on.
                // This is so that the conversion tracking code is attributed to the correct website, and the menus display links to nz products.
                this.parentRedirect = 'https://www.sponsoredlinx.co.nz' + successPath;
            } else if (this.siteName == 'checkout_GMT' && this.locale == 'NZD' && !utility.runningInASandbox()) {
                this.parentRedirect = 'https://getmoretraffic.co.nz' + successPath;
            } else {
                this.parentRedirect = this.getSiteWrapperURL() + successPath;
            }

            PageReference successPage = new PageReference('/apex/CheckoutRedir');
            return successPage;
        } catch (Exception e) {
            // Notify sysadmin
            string submitError = 'For ' + signup.Email__c + '. Error: ' + e.getMessage() + '. On ' + e.getStackTraceString();
            system.debug(submitError);
            Utility.notifySysadmin('Error in submitCheckout', submitError);

            if (paymentAttempt != null && paymentAttempt.Id != null){
                paymentAttempt.Error_Message__c = submitError;
                update paymentAttempt;
            }

            if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry, an error occurred while processing your order. Please contact us.'));
            }

            // We must clear the Id field before redisplaying the VF page, otherwise it will appear in readonly mode.
            acc.Id = null;
            return null;
        }
    }


    // =============================================================
    // Getters/Setters
    // =============================================================

    // Get locale
    public String getLocale(){
        return this.locale;
    }

    // Get SiteName
    public String getSiteName(){
        return this.siteName;
    }

    // Get promocode from cart session
    public String getPromocode(){
        return mycart.myPackageData.promocode;
    }

    // Set promocode in cart session
    public void setPromocode(String value){
        try{
            // The codes DD100 and DDGMT are hacks to change the paymentType to invoice
            if ( value != null ){
                if ( this.siteName == 'checkout_SLX' && value.toUpperCase() == 'DD100' ) {
                    this.paymentType = 'Invoice';
                }

                // For GMT, the direct debit code is INVGMT, and we don't want it to be used in conjunction with other promocodes, so
                // if we later add a different promocode, we want to change the payment method back to credit card.
                if ( this.siteName == 'checkout_GMT' ){
                    if ( value.toUpperCase() == 'INVGMT' ) {
                        this.paymentType = 'Invoice';
                    } else {
                        this.paymentType = 'Credit Card';
                    }
                }
            }

            if ( value == null || value.toUpperCase() != 'DD100' ) {
                // Clear packages so it gets rebuilt with modified cart data.
                // For DD100, we don't want to set it as the actual promocode in the cart, but for INVGMT we do.
                this.packages = null;
                mycart.setPromocode(value);
                saveCart();
            }

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    // Get the cart object
    public Cart getCart() {
        return mycart;
    }

    // Get the type of the primary product
    public Set<String> getProductFamilies(){
        Set<String> productFamilies = new Set<String>();

        for (CartItem myCartItem : mycart.getPackageFromPackageData(mycart.myPackageData)){
            system.debug('product family: ' + myCartItem.getProductFamily());
            productFamilies.add(myCartItem.getProductFamily());
        }

        // Load addon packages
        if (mycart.myPackageData.addons != null){
            for (Cart.cartPackageData addonPackageData : mycart.myPackageData.addons){
                for (CartItem myCartItem : mycart.getPackageFromPackageData(addonPackageData)){
                    productFamilies.add(myCartItem.getProductFamily());
                }
            }
        }

        return productFamilies;
    }

    // Get the expanded cart data, including all product names, prices, discounts, etc
    public List<List<CartItem>> getPackages() {
        // If the cart is already built, don't rebuild it
        if (this.packages == null){
            // Initialize the packages
            this.packages   = new List<List<CartItem>>();

            // Load primary products
            try {
                this.packages.add(mycart.getPackageFromPackageData(mycart.myPackageData));

                // Load addon packages
                if (mycart.myPackageData.addons != null){
                    for (Cart.cartPackageData addonPackageData : mycart.myPackageData.addons){
                        this.packages.add(mycart.getPackageFromPackageData(addonPackageData));
                    }
                }
            } catch (Exception e) {
                system.debug('Error: ' + e.getMessage() + ' on ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }

        return packages;
    }

    // Get the cart totals
    public Map<String,Decimal> getTotals() {
        Map<String,Decimal> totals      = new Map<String,Decimal>();

        // Add up the totals for setup, weekly, monthly
        for ( List<CartItem> items : this.getPackages() ) {
            for ( CartItem item : items ) {
                String totalType = 'setup';
                if (item.product.product_recurring__c == 'Yes' && item.product.recurring_period__c != null){
                    totalType = item.product.recurring_period__c.toLowerCase();
                }

                totals.put(totalType, item.priceNet + utility.zerofy(totals.get(totalType)));
            }
        }

        return totals;
    }

    // Description of total discounts
    public String getTotalDiscountDescription() {
        Map<String,Decimal> totals      = new Map<String,Decimal>();

        String description = '';

        // Add up the totals for setup, weekly, monthly
        for ( List<CartItem> items : this.getPackages() ) {
            for ( CartItem item : items ) {
                String totalType = 'setup';
                if (item.product.product_recurring__c == 'Yes' && item.product.recurring_period__c != null){
                    totalType = item.product.recurring_period__c.toLowerCase();
                }

                totals.put(totalType, item.discount + utility.zerofy(totals.get(totalType)));
            }
        }

        if (totals.get('weekly') > 0){
            if (description != ''){
                description += ' and ';
            }
            description += '$'+totals.get('weekly').intValue()+' weekly';
        }

        if (totals.get('monthly') > 0){
            if (description != ''){
                description += ' and ';
            }
            description += '$'+totals.get('monthly').intValue()+' monthly';
        }

        if (totals.get('setup') > 0){
            if (description != ''){
                description += ' and ';
            }
            description += '$'+totals.get('setup').intValue()+' off the setup fee';
        }

        if (description != ''){
            description = 'You saved ' + description + '!';
        }

        return description;
    }

    // Is the cart empty?
    public Boolean getIsCartEmpty(){
        return mycart.myPackageData.productIds == null || mycart.myPackageData.productIds.isEmpty();
    }

    // Get the address that this checkout should use for the wrapper around the iframe
    public String getSiteWrapperURL(){
        // Use crankit even for live site, prior to launch.
        if (ApexPages.currentPage().getHeaders().get('Referer') == 'http://sponsoredlinx.crankit.com.au/checkout/'){
            return 'http://sponsoredlinx.crankit.com.au';
        } else if (ApexPages.currentPage().getHeaders().get('Referer') == 'http://gmt2016.crankit.com.au/checkout/'){
            return 'http://gmt2016.crankit.com.au';
        } else if (utility.runningInASandbox()){
            return 'http://'+fromSource;
        } else if (this.siteName == 'checkout_SLX' && this.locale == 'NZD') {
            // For NZ, commweb require us to display the checkout on the .com.au domain
            return 'https://www.sponsoredlinx.com.au';
        } else if (this.siteName == 'checkout_GMT' && this.locale == 'NZD') {
            // For NZ, commweb require us to display the checkout on the .com.au domain
            return 'https://getmoretraffic.com.au';
        } else {
            return 'https://'+fromSource;
        }
    }

    // Get the address that this checkout should use for the addons ajax
    public String getAddonsURL(){
        // The ajax must be from a https URL
        if (this.siteName == 'checkout_GMT') {
            if (utility.runningInASandbox()){
                return 'https://getmoretraffic.com.au/wp-content/themes/gmt/checkout-addons-dev.php';
            } else{
                return 'https://getmoretraffic.com.au/wp-content/themes/gmt/checkout-addons.php';
            }
        } else {
            if (utility.runningInASandbox()){
                return 'https://www.sponsoredlinx.com.au/checkout-addons-dev.php';
            } else{
                return 'https://www.sponsoredlinx.com.au/checkout-addons.php';
            }
        }
    }

    // Get the cart in JSON format
    public String getJsonCart(){
        return JSON.serializepretty(mycart.myPackageData);
    }


    // =============================================================
    // Private methods
    // =============================================================

    // Set the site
    @TestVisible
    private void setSite(String setSiteName, String setLocale){
        this.siteName   = setSiteName;
        this.locale     = setLocale;

        if (this.siteName == null){
            return;
        }

        try {
            // Check which force.com site this is being run from
            this.mySite = [SELECT Name, Status, Subdomain, GuestUserId FROM Site WHERE Name = :this.siteName LIMIT 1];
            this.bjbCompany = [SELECT Id, Name, Business_Name__c, Checkout_Site__c, Checkout_Direct_Debit__c, CurrencyIsoCode, Payment_Gateway__c FROM Company__c WHERE Checkout_Site__c = :mySite.Name AND CurrencyIsoCode = :this.locale LIMIT 1];

            // companyName must match the name in SLX_Product__c.company_name__c
            if (this.siteName == 'checkout_SLX') {
                if  (this.locale == 'NZD') {
                    this.companyName        = 'SponsoredLinX New Zealand';
                    this.emailSignupAddress = 'signup@sponsoredlinx.com';
                    if (utility.runningInASandbox()){
                        this.fromSource     = 'devnz.crankit.com.au';
                    } else {
                        this.fromSource     = 'sponsoredlinx.co.nz';
                    }
                } else {
                    this.companyName        = 'SponsoredLinX';
                    this.emailSignupAddress = 'signup@sponsoredlinx.com';
                    if (utility.runningInASandbox()){
                        this.fromSource = 'sponsoredlinx.crankit.com.au';
                    } else {
                        this.fromSource = 'sponsoredlinx.com.au';
                    }
                }
            } else if (this.siteName == 'checkout_GMT') {
                if  (this.locale == 'NZD') {
                    this.companyName        = 'Get More Traffic New Zealand';
                    this.emailSignupAddress = 'signup@getmoretraffic.co.nz';
                    if (utility.runningInASandbox()){
                        this.fromSource     = 'gmt2016.crankit.com.au';
                    } else {
                        this.fromSource     = 'getmoretraffic.co.nz';
                    }
                } else {
                    this.companyName        = 'Get More Traffic';
                    this.emailSignupAddress = 'signup@getmoretraffic.com.au';
                    if (utility.runningInASandbox()){
                        this.fromSource     = 'gmt2016.crankit.com.au';
                    } else {
                        this.fromSource     = 'getmoretraffic.com.au';
                    }
                }
            } else {
                throw new checkoutException('Unrecognised siteName');
            }

            // Initialize a new cart
            this.mycart = new Cart(companyName);

            // Load the cart from cookies
            loadCart();

            // Initialize payment options
            paymentTypesEnabled.put('Credit Card', true);

            if (this.bjbCompany.Checkout_Direct_Debit__c) {
                paymentTypesEnabled.put('Direct Debit', true);
            }

            // In the sandbox, we want to use the test gateway
            if ( utility.runningInASandbox() ){
                this.testGateway        = paymentGateway.GATEWAY_MOCK;
                this.paymentTestType    = paymentGateway.TEST_SUCCESS;
            }
        } catch (Exception e) {
            system.debug('Error in setSite: ' + e.getMessage());
            throw e;
        }
    }

    // Load account from cookies
    private void loadAccount(){
        // https://developer-bjbglobal.cs5.force.com/checkoutslx/?locale=AUD&accountid=001O0000018AawG&uid=296372
        if ( ApexPages.currentPage().getParameters().get('accountid') != null && ApexPages.currentPage().getParameters().get('uid') != null ){
            Map<String,String> saveAccData      = new Map<String,String>{
                'accountid'     => ApexPages.currentPage().getParameters().get('accountid'),
                'uid'           => ApexPages.currentPage().getParameters().get('uid')
            };

            // Save the cart cookie
            ApexPages.currentPage().setCookies(new Cookie[]{new Cookie('account-' + this.siteName + this.locale, JSON.serialize(saveAccData), null, 600, true)});
        }

        // Load the cart from cookies
        Cookie acctCookie = ApexPages.currentPage().getCookies().get('account-' + this.siteName + this.locale);

        if (acctCookie != null) {
            Map<String,String> loadAccData      = (Map<String,String>) JSON.deserialize(acctCookie.getValue(), Map<String,String>.class);

            Id loadAccountId = loadAccData.get('accountid');
            String loadUid = loadAccData.get('uid');

            if ( loadAccountId != null && loadUid != null ){
                system.debug('Loading from existing account');

                Account[] existingAccounts = [
                SELECT Id, Name, username__c, Unique_Id__c, Industry, Number_of_Employees__c, Name_On_Card__c, Card_Number__c, Card_Month_Expiry__c, Card_Year_Expiry__c, Card_CVN__c, Company__c, Website, BillingStreet, BillingCity, BillingPostalCode, BillingState, Phone, GST__c 
                FROM Account 
                WHERE id = :loadAccountId 
                AND Unique_Id__c = :loadUid
                LIMIT 1];

                if (existingAccounts.size() > 0) {
                    system.debug('Using existing account id ' + existingAccounts[0].Id);
                    acc = existingAccounts[0];

                    signup.Company__c               = acc.Company__c;
                    signup.Website__c               = acc.Website;
                    signup.Street__c                = acc.BillingStreet;
                    signup.City__c                  = acc.BillingCity;
                    signup.PostalCode__c            = acc.BillingPostalCode;
                    signup.State__c                 = acc.BillingState;
                    signup.Phone__c                 = acc.Phone;
                    signup.GST__c                   = acc.GST__c;

                    Contact[] billingContacts = [SELECT Title, Id, FirstName, LastName, Phone, MobilePhone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Account.Id = :acc.Id AND Title = 'Billing'];
                    if (billingContacts.size() > 0) {
                        Contact billingContact = billingContacts[0];
                        signup.Firstname__c         = billingContact.FirstName;
                        signup.Lastname__c          = billingContact.LastName;
                        signup.Phone__c             = billingContact.Phone;
                        signup.Mobile__c            = billingContact.MobilePhone;
                        signup.Email__c             = billingContact.Email;
                        signup.MailingStreet__c     = billingContact.MailingStreet;
                        signup.MailingCity__c       = billingContact.MailingCity;
                        signup.MailingState__c      = billingContact.MailingState;
                        signup.MailingPostalCode__c = billingContact.MailingPostalCode;
                    }

                    // Important: We cannot have an Id on the account when the VF page is displayed because Guest user licenses don't have edit
                    // access to accounts, so the whole record becomes readonly on the VF page. VF uses the Id field to determine whether it's an existing record.
                    acc.Id = null;
                }
            }
        }
    }

    // Save the cart to cookies
    private void saveCart(){
        String cartSerialized = this.mycart.getCookieJSON();

        // Build the cookie: path 'null', one day expiry, and isSecure 'false'.
        Cookie cartCookie = new Cookie('cart-' + this.siteName + this.locale, cartSerialized, null, 86400, false);

        // Save the cart cookie
        ApexPages.currentPage().setCookies(new Cookie[]{cartCookie});
    }

    // Load the cart from cookies
    private void loadCart(){
        // Load the cart from cookies
        Cookie cartCookie = ApexPages.currentPage().getCookies().get('cart-' + this.siteName + this.locale);

        if (cartCookie != null) {
            this.mycart.setCookieJSON(cartCookie.getValue());
        }
    }

    // pay for a signup using the submitted payment details
    private Payment_Attempt__c processPayment(Decimal totalSetup){

        String countrycode;
        if (this.locale == 'AUD'){
            countrycode = 'AU';
        } else if (this.locale == 'NZD'){
            countrycode = 'NZ';
        } 

        paymentGateway pay = new paymentGateway();
        pay.setBjbCompany(this.bjbCompany);
        pay.amount                      = totalSetup;
        pay.currencyIsoCode             = signup.CurrencyIsoCode;
        pay.customerFirstName           = signup.Firstname__c;
        pay.customerLastName            = signup.Lastname__c;
        pay.customerEmail               = signup.Email__c;
        pay.customerStreet              = signup.Street__c;
        pay.customerCity                = signup.City__c;
        pay.customerState               = signup.State__c;
        pay.customerPostcode            = signup.PostalCode__c;
        pay.customerCountrycode         = countrycode;
        pay.customerIP                  = Utility.getUserIPAddress();
        pay.cardHoldersName             = acc.Name_On_Card__c;
        pay.cardNumber                  = acc.Card_Number__c;
        pay.cardExpiryMonth             = acc.Card_Month_Expiry__c;
        pay.cardExpiryYear              = acc.Card_Year_Expiry__c;
        pay.cardCVN                     = acc.Card_CVN__c;
        pay.customerInvoiceDescription  = this.companyName + ' Invoice';
        pay.customerInvoiceRef          = signup.Invoiceno__c;
        pay.uniqueAttemptId             = '1';

        // Use a test gateway when in the sandbox or running a test method.
        if ( this.testGateway != null ){
            pay.testGateway                    = this.testGateway;
        }

        // When running a test method, we want to mock a success response
        if ( this.paymentTestType != null ){
            pay.testType                   = this.paymentTestType;
        }

        Payment_Attempt__c paymentAttempt;

        try{
            paymentAttempt = pay.pay();

            // Save the paymentAttempt
            try {
                system.debug('in checkoutController before insert paymentAttempt');
                insert paymentAttempt;
            } catch (Exception e) {
                string errorDetail = 'Error: ' + e.getMessage() + '. On ' + e.getStackTraceString();
                Utility.notifySysadmin('Error inserting payment_attempt', errorDetail + ' payment_attempt: ' + JSON.serialize(paymentAttempt));

                system.debug(errorDetail);
            }
        } catch (Exception e) {
            string errorDetail = 'Error in CheckoutController.processPayment: ' + e.getMessage() + '. On ' + e.getStackTraceString();
            Utility.notifySysadmin('Error in pay.pay', errorDetail);

            system.debug(errorDetail);
        }

        return paymentAttempt;
    }


    // Get the next available invoice number
    public static string getNextInvoiceNumber(){
        // Set the invoice ref to "INV<date>" plus the number of payment today
        // Check how many paymentAttempts have been made today so we can add a number to the INV num
        // We need to count the payments that have happened on the Brisbane timezone, so we use System.TODAY()
        List<Payment__c> todaysPayments = [SELECT Id, Payment_Date__c FROM Payment__c WHERE Payment_Date__c >= :System.TODAY()];

        // Generate a two-digit random number to add to the end of the invoice number. This helps prevent collisions if two invoices are started before the payment is created.
        integer randNum = (math.random() * 99).intValue();

        String customerInvoiceRef = 'INV' + DateTime.now().format('ddMMyy') + (todaysPayments.size() + 1).format().leftPad(4).replaceAll(' ','0') + randNum.format().leftPad(2).replaceAll(' ','0');

        return customerInvoiceRef;
    }

    // Send welcome email for the signup
    private boolean sendSignupWelcomeEmail(Sign_Up__c newSignup) {

        String emailSenderName;
        String emailSenderEmail;

        EmailTemplate emailTemplate = this.getSignupEmailTemplate(newSignup);

        // Get the billing contact to send the email to.
        Contact[] emailContacts = [SELECT Title, Id FROM Contact WHERE Title = 'Billing' AND Account.Id = :acc.Id LIMIT 1];

        if (emailContacts.size() == 0){
            throw new checkoutException('Could not find billing contact for this account to send email');
        }

        Contact emailContact = emailContacts[0];

        if (newSignup.Salesperson__c != null) {
            Account salesperson = [SELECT id, Name, email__c FROM Account WHERE id = :newSignup.Salesperson__c LIMIT 1];
            if (salesperson != null){
                emailSenderName = salesperson.Name;
                emailSenderEmail = salesperson.email__c;
            }
        }

        // Default sender name if we can't determine the salesperson
        if (emailSenderName == null){
            emailSenderName = this.companyName;
            emailSenderEmail = this.emailSignupAddress;
        }

        if (emailTemplate == null){
            system.debug('Could not find emailtemplate for signup email');
        } else if ( emailContact == null) {
            system.debug('Could not find emailContact for signup email');
        } else {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 

            // Who you are sending the email to 
            mail.setTargetObjectId(emailContact.Id); // Contact (for toEmail)
            //mail.setBccAddresses(new String[] {'brendan.west@sponsoredlinx.com'});
            mail.setTemplateId(emailTemplate.Id);
            mail.setWhatId(newSignup.Id); // Signup (for merge fields)
            mail.setBccSender(false);
            mail.setBccAddresses(new string[]{this.emailSignupAddress});
            mail.setUseSignature(false);
            mail.setSenderDisplayName(emailSenderName);
            mail.setReplyTo(emailSenderEmail);

            // Attach any "profile" or "confirmation" PDFs that are attached to the SLX_Products they purchased
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (Attachment a : [SELECT Id, Name, Body, BodyLength FROM Attachment WHERE (Name LIKE '%Profile%' OR Name LIKE '%Confirmation%') AND ParentId IN (SELECT SLX_Product__c FROM Account_Product__c WHERE Sign_Up_del__c = :newSignup.Id) ]) {
                // Add to attachment file list
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                fileAttachments.add(efa);
            }
            mail.setFileAttachments(fileAttachments);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            if (results[0].success) {
                System.debug('The email was sent successfully. ' + results);
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }

        return true;
    }


    // Get the email template to use for a signup
    private EmailTemplate getSignupEmailTemplate(Sign_Up__c newSignup){
        // Get the email template for this product type.
        String templateName;

        Map<String,String> templateMap = new Map<String,String>{
            'AdWords Management'    => 'signup_generic',
            'Social Marketing'      => 'signup_facebook',
            'SEO'                   => 'signup_seo',
            'ConvertoPages'         => 'signup_converto',
            'Google+'               => 'signup_googleplus'
        };

        if (newSignup.Product_Type__c != null && templateMap.get(newSignup.Product_Type__c) != null){
            templateName = templateMap.get(newSignup.Product_Type__c);
        }

        if (templateName == null){
            templateName = 'signup_generic';
        }

        if (this.siteName == 'checkout_GMT') {
            templateName += '_gmt';
        } else if (this.siteName == 'checkout_SLX') {
            templateName += '_slx';
        }

        if (this.locale == 'NZD') {
            templateName += 'nz';
        }
        
        EmailTemplate[] emailTemplates = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];

        if (emailTemplates.size() == 0){
            throw new checkoutException('Could not load email template ' + templateName);
        }

        return emailTemplates[0];
    }

    // Check if a certain BSB is valid
    private static Boolean isBsbValid(String checkBSB){
        // BSBs must be nnnnnn or nnn-nnn
        if ( checkBSB == null || !Pattern.matches('[0-9]{3}-?[0-9]{3}', checkBSB) ){
            return false;
        }

        // The list of valid BSBs is stored in a CSV static resource called bsb
        StaticResource defaultResource = [SELECT Body FROM StaticResource WHERE Name = 'bsb'];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();

        // Check that the BSB exists in the file (file doesn't contain hyphens in BSBs)
        return contentFile.contains(checkBSB.replace('-', ''));
    }

    // Get options for state dropdown
    public List<SelectOption> getStateOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (this.locale != 'NZD') {
            // For GMT, we want the empty option to have the label 'state', because there is no label beside the box.
            if (this.siteName == 'checkout_GMT') {
                options.add(new SelectOption('','State'));
            } else {
                options.add(new SelectOption('',''));
            }
            
            options.add(new SelectOption('VIC','VIC'));
            options.add(new SelectOption('ACT','ACT'));
            options.add(new SelectOption('NSW','NSW'));
            options.add(new SelectOption('QLD','QLD'));
            options.add(new SelectOption('NT','NT'));
            options.add(new SelectOption('SA','SA'));
            options.add(new SelectOption('WA','WA'));
            options.add(new SelectOption('TAS','TAS'));
        }

        return options;
    }

    // Get options for credit card type dropdown
    public List<SelectOption> getCreditCardOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Mastercard','Mastercard'));
        options.add(new SelectOption('Visa','Visa'));
        return options;
    }

    // Get options for day dropdown
    public List<SelectOption> getDayOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','day'));

        Integer currentYear = System.Today().year();
        for (Integer day = 1; day <= 31; day++) {
            options.add(new SelectOption(string.valueOf(day),string.valueOf(day)));
        }

        return options;
    }

    // Get options for month dropdown
    public List<SelectOption> getMonthOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','month'));
        options.add(new SelectOption('1','1 - January'));
        options.add(new SelectOption('2','2 - February'));
        options.add(new SelectOption('3','3 - March'));
        options.add(new SelectOption('4','4 - April'));
        options.add(new SelectOption('5','5 - May'));
        options.add(new SelectOption('6','6 - June'));
        options.add(new SelectOption('7','7 - July'));
        options.add(new SelectOption('8','8 - August'));
        options.add(new SelectOption('9','9 - September'));
        options.add(new SelectOption('10','10 - October'));
        options.add(new SelectOption('11','11 - November'));
        options.add(new SelectOption('12','12 - December'));
        return options;
    }

    // Get options for credit card year dropdown
    public List<SelectOption> getCardYearOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','year'));

        // Display current year plus up to 10 years in the future
        Integer currentYear = System.Today().year();
        for (Integer year = currentYear; year <= currentYear + 10; year++) {
            options.add(new SelectOption(string.valueOf(year),string.valueOf(year)));
        }

        return options;
    }

    // Get options for birth year dropdown
    public List<SelectOption> getBirthYearOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','year'));

        // Display current year plus up to 100 years in the past
        Integer currentYear = System.Today().year();
        for (Integer year = currentYear - 100; year <= currentYear; year++) {
            options.add(new SelectOption(string.valueOf(year),string.valueOf(year)));
        }

        return options;
    }

    // Get options for payment type dropdown
    public List<SelectOption> getPaymentTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Credit Card','Credit Card'));

        if (paymentTypesEnabled.get('Direct Debit') == true){
            options.add(new SelectOption('Direct Debit','Direct Debit'));
        }

        return options;
    }

    // Get total chargable setup amount
    private Decimal getTotalSetup(){
        Decimal totalSetup = 0.00;

        // Loop through the products
        List<CartItem> myPackage = mycart.getPackageFromPackageData(mycart.myPackageData);

        for (CartItem myCartItem : myPackage) {
            // Create an invoice for setup products, or the SEO management product
            if ( myCartItem.isChargeableAtOrder() ){
                totalSetup += myCartItem.priceNet;
            }
        }

        for (Cart.cartPackageData addonPackageData : mycart.myPackageData.addons){
            // Loop through the products to determine a 'product type' for the signup. We also generate the packagedata so that discounts are applied
            List<CartItem> addonItems = mycart.getPackageFromPackageData(addonPackageData);

            for (CartItem myCartItem : addonItems) {
                // Create an invoice for setup products, or the SEO management product
                if ( myCartItem.isChargeableAtOrder() ){
                    totalSetup += myCartItem.priceNet;
                }
            }
        }

        return totalSetup;
    }

}