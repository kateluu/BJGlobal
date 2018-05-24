@istest
public with sharing class CheckoutControllerTest {

    static SLX_Product__c productMgmt;
    static SLX_Product__c productSetup;
    static SLX_Product__c productFBMgmt;
    static SLX_Product__c productFBSetup;
    static SLX_Product__c productAddonMgmt;
    static SLX_Product__c productAddonSetup;
    static SLX_Product__c productMgmtGMT;
    static SLX_Product__c productSetupGMT;
    static SLX_Product__c productAddonGMT;
    static SLX_Product__c productMgmtSEO;
    static SLX_Product__c productSetupSEO;
    static SLX_Product__c productMgmtSLXnz;
    static SLX_Product__c productSetupSLXnz;
    static SLX_Product__c productMgmtGMTnz;
    static SLX_Product__c productSetupGMTnz;
    static Account existingAccount;

    static User siteUserSLX;
    static User siteUserGMT;

    // Initialize records required for test cases
    static void init(){

        // Load payment gateway config
        // Eway2
        insert new PaymentGateway__c(
            Name                = 'Eway Rapid SLX AU',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Password__c         = 'examplepassword'
        );
        insert new PaymentGateway__c(
            Name                = 'Eway Rapid GMT AU',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Password__c         = 'examplepassword'
        );

        // Commweb2
        insert new PaymentGateway__c(
            Name                = 'Commweb SLX NZ',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Operation_ID__c     = 'exampleopid',
            Password__c         = 'examplepassword'
        );

        insert new PaymentGateway__c(
            Name                = 'Commweb GMT NZ',
            MerchantURL__c      = 'https://example.com',
            Access_Code__c      = 'exampleaccesscode',
            Operation_ID__c     = 'exampleopid',
            Password__c         = 'examplepassword'
        );

        // Load the checkout users for runAs()
        siteUserSLX = [SELECT Id, Name FROM User WHERE Name = 'Checkout SLX Site Guest User'];
        siteUserGMT = [SELECT Id, Name FROM User WHERE Name = 'Checkout GMT Site Guest User'];

        // Setup companies
        insert new List<Company__c>{
            new Company__c(
                Name = 'SponsoredLinX',
                Business_Name__c = 'SponsoredLinX',
                Checkout_Site__c = 'checkout_SLX',
                Payment_Gateway__c = 'Eway2',
                CurrencyIsoCode  = 'AUD'
            ),
            new Company__c(
                Name = 'Get More Traffic',
                Business_Name__c = 'GMT Australia',
                Checkout_Site__c = 'checkout_GMT',
                Payment_Gateway__c = 'Eway2',
                CurrencyIsoCode  = 'AUD'
            ),
            new Company__c(
                Name = 'SponsoredLinX New Zealand',
                Business_Name__c = 'SponsoredLinX New Zealand',
                Checkout_Site__c = 'checkout_SLX',
                Payment_Gateway__c = 'CommWeb2',
                CurrencyIsoCode  = 'NZD'
            ),
            new Company__c(
                Name = 'Get More Traffic New Zealand',
                Business_Name__c = 'GMT New Zealand',
                Checkout_Site__c = 'checkout_GMT',
                Payment_Gateway__c = 'CommWeb2',
                CurrencyIsoCode  = 'NZD'
            )
        };

        // Setup products
        productMgmt = new SLX_Product__c(
            Name = 'Adwords Basic Weekly Management',
            product_price__c = 79.00,
            product_recurring__c = 'Yes',
            recurring_period__c = 'Weekly',
            company_name__c = 'SponsoredLinx',
            Product_Family__c = 'Adwords',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productSetup = new SLX_Product__c(
            Name = 'Adwords Basic Setup',
            product_price__c = 199.00,
            product_recurring__c = 'No',
            recurring_period__c = '',
            company_name__c = 'SponsoredLinx',
            Product_Family__c = 'Adwords',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productFBMgmt = new SLX_Product__c(
            Name = 'Facebook Consultation',
            product_price__c = 79.00,
            product_recurring__c = 'Yes',
            recurring_period__c = 'Weekly',
            company_name__c = 'SponsoredLinx',
            Product_Family__c = 'Facebook',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productFBSetup = new SLX_Product__c(
            Name = 'Facebook Consultation Setup',
            product_price__c = 299.00,
            product_recurring__c = 'No',
            recurring_period__c = '',
            company_name__c = 'SponsoredLinx',
            Product_Family__c = 'Facebook',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productAddonMgmt = new SLX_Product__c(
            Name = 'ConvertoPages Monthly Management',
            product_price__c = 49.00,
            product_recurring__c = 'Yes',
            recurring_period__c = 'Monthly',
            company_name__c = 'SponsoredLinx',
            Product_Family__c = 'Web',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productAddonSetup = new SLX_Product__c(
            Name = 'ConvertoPages Setup',
            product_price__c = 99.00,
            product_recurring__c = 'No',
            company_name__c = 'SponsoredLinx',
            Product_Family__c = 'Web',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productMgmtSEO = new SLX_product__c(
            name = 'SEO Standard Monthly Management',
            product_price__c = 899.00,
            product_recurring__c = 'yes',
            recurring_period__c = 'Monthly',
            company_name__c = 'SponsoredLinX',
            product_family__c = 'SEO',
            isactive__c = true,
            Billed_In_Advance__c = true,
            currencyisocode  = 'AUD'
        );

        productSetupSEO = new SLX_product__c(
            name = 'SEO Standard Setup',
            product_price__c = 899.00,
            product_recurring__c = 'No',
            recurring_period__c = '',
            company_name__c = 'SponsoredLinX',
            product_family__c = 'SEO',
            isactive__c = true,
            Is_Ghost__c = true,
            currencyisocode  = 'AUD'
        );

        productMgmtGMT = new SLX_Product__c(
            Name = 'Adwords Basic Weekly Management',
            product_price__c = 79.00,
            product_recurring__c = 'Yes',
            recurring_period__c = 'Weekly',
            company_name__c = 'Get More Traffic',
            Product_Family__c = 'Adwords',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productSetupGMT = new SLX_Product__c(
            Name = 'Adwords Basic Setup',
            product_price__c = 199.00,
            product_recurring__c = 'No',
            recurring_period__c = '',
            company_name__c = 'Get More Traffic',
            Product_Family__c = 'Adwords',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productAddonGMT = new SLX_Product__c(
            Name = 'ConvertoPages Monthly Management',
            product_price__c = 49.00,
            product_recurring__c = 'Yes',
            recurring_period__c = 'Monthly',
            company_name__c = 'Get More Traffic',
            Product_Family__c = 'Web',
            IsActive__c = true,
            CurrencyIsoCode  = 'AUD'
        );

        productMgmtSLXnz = new SLX_product__c(
            name = 'SEO Standard Monthly Management',
            product_price__c = 899.00,
            product_recurring__c = 'yes',
            recurring_period__c = 'Monthly',
            company_name__c = 'SponsoredLinX New Zealand',
            product_family__c = 'SEO',
            isactive__c = true,
            Billed_In_Advance__c = true,
            currencyisocode  = 'NZD'
        );

        productSetupSLXnz = new SLX_product__c(
            name = 'SEO Standard Setup',
            product_price__c = 899.00,
            product_recurring__c = 'No',
            recurring_period__c = '',
            company_name__c = 'SponsoredLinX New Zealand',
            product_family__c = 'SEO',
            isactive__c = true,
            Is_Ghost__c = true,
            currencyisocode  = 'NZD'
        );

        productMgmtGMTnz = new SLX_product__c(
            name = 'SEO Standard Monthly Management',
            product_price__c = 899.00,
            product_recurring__c = 'yes',
            recurring_period__c = 'Monthly',
            company_name__c = 'Get More Traffic New Zealand',
            product_family__c = 'SEO',
            isactive__c = true,
            Billed_In_Advance__c = true,
            currencyisocode  = 'NZD'
        );

        productSetupGMTnz = new SLX_product__c(
            name = 'SEO Standard Setup',
            product_price__c = 899.00,
            product_recurring__c = 'No',
            recurring_period__c = '',
            company_name__c = 'Get More Traffic New Zealand',
            product_family__c = 'SEO',
            isactive__c = true,
            Is_Ghost__c = true,
            currencyisocode  = 'NZD'
        );
        insert new List<SLX_Product__c>{productMgmt, productSetup, productFBMgmt, productFBSetup, productAddonMgmt, productAddonSetup, productMgmtGMT, productSetupGMT, productAddonGMT, productMgmtSEO, productMgmtSLXnz, productSetupSLXnz, productMgmtGMTnz, productSetupGMTnz, productSetupSEO};

        // Create PDF attachment for the signup email
        Attachment attachment = new Attachment(
            Body = Blob.valueOf('This is the body of the PDF'),
            Name = String.valueOf('Welcome to sponsoredlinx Profile.pdf'),
            ParentId = productMgmt.Id
        );
        insert attachment;

        // Setup salesperson account
        Account accountSalesperson = new Account(
            Name                    = 'Bob Salesman',
            username__c             = 'bob.salesman',
            Type                    = 'Employee',
            Employee_Department__c  = 'Sales'
        );

        // Setup company account (default account for signup)
        Account accountCompanySLX = new Account(
            Name                    = 'SponsoredLinX',
            username__c             = 'ben@sponsoredlinx.com'
        );

        Account accountCompanyGMT = new Account(
            Name                    = 'Get More Traffic',
            username__c             = 'ben@getmoretraffic.com.au'
        );

        // Setup existing account
        existingAccount = new Account(
            Name                    = 'Steve Existingclient',
            username__c             = 'steve.existingclient@sponsoredlinx.com',
//            Unique_Id__c            = '630278478',
            name_on_card__c         = 'Steve Clientman',
            card_month_expiry__c    = '9',
            card_year_expiry__c     = '2028'
        );
        insert new List<Account> {accountSalesperson, accountCompanySLX, accountCompanyGMT, existingAccount};

        // Contacts should be created before Account Products
        List<Contact> newContacts = new List<Contact>();
        for (String contact_type : new List<String> {'Billing','Reports','Marketing'}){
            newContacts.add( 
                new Contact(
                    FirstName         = 'Steve',
                    LastName          = 'Existingclient',
                    AccountId         = existingAccount.Id,
                    Phone             = '0407040404',
                    Email             = existingAccount.username__c,
                    Title             = contact_type
                )
            );
        }
        insert newContacts;

        // Share all accounts with the checkout user. This is to emulate the sharing rule, which salesforce doesn't
        // apply in test cases. See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_bulk_sharing_understanding.htm
        List<AccountShare> accountShares = new List<AccountShare>();
        for (User shareUser : new List<User>{siteUserSLX, siteUserGMT}){
            for (Account shareAccount : new List<Account>{accountSalesperson, accountCompanySLX, accountCompanyGMT, existingAccount}){
                accountShares.add( new AccountShare(
                    AccountId = shareAccount.Id,
                    UserOrGroupId = shareUser.Id,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit'
                ));
            }
        }
        insert accountShares;

        // setup promocodes
        promotions__c promotion99 = new promotions__c(
            name = 'free week 99 off setup fee',
            promotion_description__c = 'discount of $99 off the setup fee',
            isactive__c = true,
            setup_discount__c = 99.00,
            setup_discount_type__c = '$',
            management_discount__c = 0.00,
            management_discount_type__c = '$'
        );
        promotions__c promotion199 = new promotions__c(
            name = 'no setup fee',
            promotion_description__c = 'no setup fee',
            isactive__c = true,
            setup_discount__c = 100,
            setup_discount_type__c = '%',
            management_discount__c = 0.00,
            management_discount_type__c = '$'
        );
        promotions__c promotionaddon = new promotions__c(
            name = '$20 discount',
            promotion_description__c = '$20 discount',
            isactive__c = true,
            setup_discount__c = 20.00,
            setup_discount_type__c = '$',
            management_discount__c = 20.00,
            management_discount_type__c = '$'
        );

        promotions__c promotiongmt = new promotions__c(
            name = 'referral only',
            promotion_description__c = 'referral only',
            isactive__c = true,
            setup_discount__c = 0,
            setup_discount_type__c = '$',
            management_discount__c = 0,
            management_discount_type__c = '$'
        );
        insert new list<promotions__c>{promotion99, promotion199, promotionaddon, promotiongmt};

        promocode__c promocode99 = new promocode__c(
            name = 'BSALPFW',
            promotions__c = promotion99.id,
            promocode_description__c = 'premium free week',
            isactive__c = true,
            account__c = accountsalesperson.id // <---- salesperson
        );
        promocode__c promocode199 = new promocode__c(
            name = 'BSALNSU',
            promotions__c = promotion199.id,
            promocode_description__c = 'premium no setup',
            isactive__c = true,
            account__c = accountsalesperson.id // <---- salesperson
        );
        promocode__c promocodeaddon = new promocode__c(
            name = '20setup',
            promotions__c = promotionaddon.id,
            promocode_description__c = '$20 setup discount',
            isactive__c = true
        );
        promocode__c promocodegmt = new promocode__c(
            name = 'INVGMT',
            promotions__c = promotiongmt.id,
            promocode_description__c = 'direct debit',
            isactive__c = true
        );
        insert new list<promocode__c>{promocode99, promocode199, promocodeaddon, promocodegmt};
    }

    // insert into the SLX checkout using a promocode, addon (with promocode) and creditcard payment
    @istest
    static void testSubmitSLX() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();

        system.runAs(siteuserSLX) {
            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            pageref.getParameters().put('promocode', 'BSALPFW' );
            pageref.getParameters().put('locale', 'AUD' );
            pageref.getParameters().put('accountid', existingAccount.id ); // To test loading existing account
            pageref.getParameters().put('uid', '2889239' );
            test.setCurrentPage(pageref);

            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // clear the cart
            controller.clearcart();
            controller.removeAddons();

            // display empty cart
            controller.index();

            // add an addon product and promocode
            pageref = page.checkoutMain_slx;
            pageref.getParameters().put('addon-1', productaddonmgmt.id + ',' + productaddonsetup.id + ':20setup');
            pageref.getheaders().put('referer', 'http://sponsoredlinx.com/');
            pageref.getheaders().put('host', 'developer-bjbglobal.cs5.force.com');
            test.setCurrentPage(pageref);
            controller.addpackage();

            // Test removing the packages
            pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'removePackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            pageref.getParameters().put('addon-1', productaddonmgmt.id + ',' + productaddonsetup.id + ':20setup');
            test.setCurrentPage(pageref);
            controller.index();

            // Add the packages again
            pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            pageref.getParameters().put('promocode', 'BSALPFW' );
            test.setCurrentPage(pageref);
            controller.index();

            // add an addon product and promocode
            pageref = page.checkoutMain_slx;
            pageref.getParameters().put('addon-1', productaddonmgmt.id + ',' + productaddonsetup.id + ':20setup');
            pageref.getheaders().put('referer', 'http://sponsoredlinx.com/');
            pageref.getheaders().put('host', 'developer-bjbglobal.cs5.force.com');
            test.setCurrentPage(pageref);
            controller.addpackage();

            // display non-empty cart
            system.assertNotEquals(null, controller.getCart());
            system.assertNotEquals(null, controller.getPackages());
            system.assertEquals(false, controller.getiscartempty());
            system.assertEquals('BSALPFW', controller.getpromocode());
            system.assertEquals('AUD', controller.getLocale());
            system.assertEquals('checkout_SLX', controller.getSiteName());
            system.assertNotEquals(null, controller.getSiteWrapperURL());
            system.assertNotEquals(null, controller.getAddonsURL());
            system.assertNotEquals(null, controller.getstateoptions());
            system.assertNotEquals(null, controller.getcreditcardoptions());
            system.assertNotEquals(null, controller.getdayoptions());
            system.assertNotEquals(null, controller.getmonthoptions());
            system.assertNotEquals(null, controller.getcardyearoptions());
            system.assertNotEquals(null, controller.getbirthyearoptions());
            system.assertNotEquals(null, controller.getpaymenttypeoptions());
            system.assertNotEquals(null, controller.getJsonCart());
            system.assertNotEquals(null, controller.getTotalDiscountDescription());
            system.assertNotEquals(null, controller.getProductFamilies());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error));

            map<string,decimal> totals = controller.gettotals();
            system.debug('totals ' + totals);

            system.assertEquals(79.00, totals.get('weekly'), 'incorrect totals');
            system.assertEquals(29.00, totals.get('monthly'), 'incorrect totals'); // (49 -20)
            system.assertEquals(179.00, totals.get('setup'), 'incorrect totals'); // ((199 -99) + (99 -20))

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');
            controllerpage2.paymentTestType = paymentGateway.TEST_FAILURE;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';

            controllerpage2.termsAdwords1           = true;
            controllerpage2.termsAdwords2           = true;
            controllerpage2.termsAdwords3           = true;
            controllerpage2.termsAdwords4           = true;
            controllerpage2.termsAdwords5           = true;

            controllerpage2.termsFacebook1          = true;
            controllerpage2.termsFacebook2          = true;
            controllerpage2.termsFacebook3          = true;
            controllerpage2.termsFacebook4          = true;
            controllerpage2.termsFacebook5          = true;

            controllerpage2.termsWeb1                  = true;
            controllerpage2.termsWeb2                  = true;
            controllerpage2.termsWeb3                  = true;
            controllerpage2.termsWeb4                  = true;
            controllerpage2.termsWeb5                  = true;

            controllerpage2.termsSeo1                  = true;
            controllerpage2.termsSeo2                  = true;
            controllerpage2.termsSeo3                  = true;
            controllerpage2.termsSeo4                  = true;
            controllerpage2.termsSeo5                  = true;

            controllerpage2.paymenttype                 = 'Credit Card';
            controllerpage2.cardtype                    = 'Visa';
            controllerpage2.applypaymenttype();
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // submit the checkout (should return a pagereference and no error messages)
            controllerpage2.paymentTestType = paymentGateway.TEST_SUCCESS;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;
            pagereference resultsuccess = controllerpage2.submitCheckout();

            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created not created
            sign_up__c[] signups = [SELECT id, name, Product_Type__c, Invoiceno__c FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');
            system.assertEquals('AdWords Management', signups[0].Product_Type__c, 'Incorrect product type on signup');
            system.assertNotEquals(null, signups[0].Invoiceno__c, 'Signup missing invoice number');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');

            // check that contacts were created
            Contact[] contacts = [SELECT Id, Title, FirstName, LastName, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Account.Id = :accounts[0].id];
            system.assertEquals(3, contacts.size(), 'contacts not created');
            for (contact myContact : contacts){
                system.assertEquals(controllerpage2.signup.Firstname__c, myContact.FirstName);
                system.assertEquals(controllerpage2.signup.Lastname__c, myContact.LastName);
                system.assertEquals(controllerpage2.signup.MailingStreet__c, myContact.MailingStreet);
                system.assertEquals(controllerpage2.signup.MailingCity__c, myContact.MailingCity);
                system.assertEquals(controllerpage2.signup.MailingState__c, myContact.MailingState);
                system.assertEquals(controllerpage2.signup.MailingPostalCode__c, myContact.MailingPostalCode);

                if (myContact.Title == 'Marketing'){
                    system.assertEquals(controllerpage2.signup.Phone__c, myContact.Phone);
                    system.assertEquals(controllerpage2.signup.Mobile__c, myContact.MobilePhone);
                }
            }

            // check that the account_products were created
            account_product__c[] accproducts = [SELECT id, name FROM account_product__c WHERE account__c = :accounts[0].id];
            system.assertEquals(4, accproducts.size(), 'account_products were not created');

            // check that the setup invoice was created (one for each setup product)
            invoice__c[] invoices = [SELECT id, name, status__c FROM invoice__c WHERE account__c = :accounts[0].id];
            system.assertEquals(2, invoices.size(), 'invoice not created');
            for (invoice__c invoice : invoices){
                system.assertEquals('PAID', invoice.status__c, 'invoice was not marked paid');
            }

            // check that the payments was created (one for each setup product)
            Payment__c[] payments = [SELECT id, name FROM Payment__c WHERE account__c = :accounts[0].id];
            system.assertEquals(2, payments.size(), 'payments not created');
        }

        test.stoptest();
    }


    // insert into the SLX checkout using an existing account and creditcard payment
    @istest
    static void testSubmitSLXExisting() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();

        system.runAs(siteuserSLX) {

            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // clear the cart
            controller.clearcart();

            // display empty cart
            controller.index();

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            pageref.getParameters().put('promocode', 'BSALPFW' );
            test.setCurrentPage(pageref);
            controller.index();

            // display non-empty cart
            system.assertNotEquals(null, controller.getCart());
            system.assertNotEquals(null, controller.getPackages());
            system.assertEquals(false, controller.getiscartempty());
            system.assertEquals('BSALPFW', controller.getpromocode());
            system.assertNotEquals(null, controller.getSiteWrapperURL());
            system.assertNotEquals(null, controller.getstateoptions());
            system.assertNotEquals(null, controller.getcreditcardoptions());
            system.assertNotEquals(null, controller.getdayoptions());
            system.assertNotEquals(null, controller.getmonthoptions());
            system.assertNotEquals(null, controller.getcardyearoptions());
            system.assertNotEquals(null, controller.getbirthyearoptions());
            system.assertNotEquals(null, controller.getpaymenttypeoptions());
            system.assertNotEquals(null, controller.getjsoncart());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error));

            map<string,decimal> totals = controller.gettotals();
            system.debug('totals ' + totals);

            system.assertEquals(79.00, totals.get('weekly'), 'incorrect totals');
            system.assertEquals(100.00, totals.get('setup'), 'incorrect totals'); // (199 -99) 

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');
            controllerpage2.paymentTestType = paymentGateway.TEST_FAILURE;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.existingclient@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';

            controllerpage2.termsAdwords1                  = true;
            controllerpage2.termsAdwords2                  = true;
            controllerpage2.termsAdwords3                  = true;
            controllerpage2.termsAdwords4                  = true;
            controllerpage2.termsAdwords5                  = true;

            controllerpage2.paymenttype                 = 'Credit Card';
            controllerpage2.cardtype                    = 'Visa';
            controllerpage2.applypaymenttype();
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // submit the checkout (should return a pagereference and no error messages)
            controllerpage2.paymentTestType = paymentGateway.TEST_SUCCESS;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;
            pagereference resultsuccess = controllerpage2.submitCheckout();

            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created not created
            sign_up__c[] signups = [SELECT id, name, Product_Type__c, Invoiceno__c FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');
            system.assertEquals('AdWords Management', signups[0].Product_Type__c, 'Incorrect product type on signup');
            system.assertNotEquals(null, signups[0].Invoiceno__c, 'Signup missing invoice number');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c, card_token__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');
            system.assertNotEquals(null, accounts[0].card_token__c, 'Card number in account does not match');

            // check that the account_products were created
            account_product__c[] accproducts = [SELECT id, name FROM account_product__c WHERE account__c = :accounts[0].id];
            system.assertEquals(2, accproducts.size(), 'account_products were not created');

            // check that the setup invoice was created (one for each setup product)
            invoice__c[] invoices = [SELECT id, name, status__c FROM invoice__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, invoices.size(), 'invoice not created');
            for (invoice__c invoice : invoices){
                system.assertEquals('PAID', invoice.status__c, 'invoice was not marked paid');
            }

            // check that the payments was created (one for each setup product)
            Payment__c[] payments = [SELECT id, name FROM Payment__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, payments.size(), 'payments not created');
        }

        test.stoptest();
    }


    // attempt to add a gmt product into the SLX cart, and ensure it gives an error
    @istest
    static void testAddInvalidProduct() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();
        system.runAs(siteuserSLX) {
            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // try to add a gmt package into the SLX cart
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmtgmt.id + ',' + productSetupgmt.id );
            test.setCurrentPage(pageref);
            controller.index();

            // display non-empty cart
            system.assertEquals(true, controller.getiscartempty());

            system.assertEquals(true, ApexPages.hasMessages(ApexPages.severity.error), 'page should contain error');
        }

        test.stoptest();
    }

    // insert into the SLX checkout using a failure creditcard payment
    @istest
    static void testSubmitSLXCreditCardError() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();

        system.runAs(siteuserSLX) {

            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            test.setCurrentPage(pageref);
            controller.index();

            // display non-empty cart
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');
            controllerpage2.paymentTestType = paymentGateway.TEST_FAILURE;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';

            controllerpage2.paymenttype                 = 'Credit Card';
            controllerpage2.applypaymenttype();
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // first test with a failure response from the gateway (should return null with page errors)
            controllerpage2.paymentTestType = paymentGateway.TEST_FAILURE;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;
            pagereference resultfailure = controllerpage2.submitCheckout();
            system.assertEquals(null, resultfailure);
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.severity.error), 'page should contain errors'); // check that the page contains an error

            // check that the signup record not created
            sign_up__c[] signups = [SELECT id, name FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(0, signups.size(), 'signup was created but should not have been.');

            // check that the account not created
            account[] accounts = [SELECT id, name, payment_option__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(0, accounts.size(), 'account was created but should not have been.');
        }

        test.stoptest();
    }

    // insert into the SLX checkout using a direct debit payment
    @istest
    static void testSubmitSLXDirectDebit() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();
        system.runAs(siteuserSLX) {
            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // clear the cart
            pagereference pagerefclear = page.checkoutMain_slx;
            pagerefclear.getParameters().put('do', 'clearcart');
            test.setCurrentPage(pagerefclear);
            controller.clearcart();

            // display empty cart
            controller.index();

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productFBMgmt.id + ',' + productFBSetup.id );
            test.setCurrentPage(pageref);
            controller.index();

            // display non-empty cart
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';
            controllerpage2.termsDD1                = true;

            controllerpage2.paymenttype             = 'direct debit';
            controllerpage2.applypaymenttype();
            controllerpage2.acc.account_no__c       = '12345679';
            controllerpage2.acc.bsb__c              = '012-012';
            controllerpage2.birthday                = '31';
            controllerpage2.birthmonth              = '12';
            controllerpage2.birthyear               = '1990';

            // submit the checkout (should return a pagereference and no error messages)
            pagereference resultsuccess = controllerpage2.submitCheckout();

            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created
            sign_up__c[] signups = [SELECT id, name, Product_Type__c FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');
            system.assertEquals('Social Marketing', signups[0].Product_Type__c, 'Incorrect product type on signup');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');

            // check that contacts were created
            Contact[] contacts = [SELECT Title, Id FROM Contact WHERE Account.Id = :accounts[0].id];
            system.assertEquals(3, contacts.size(), 'contacts not created');

            // check that the account_products were created
            account_product__c[] accproducts = [SELECT id, name FROM account_product__c WHERE account__c = :accounts[0].id];
            system.assertEquals(2, accproducts.size(), 'account_products were not created');
            system.assertEquals('Other', accounts[0].payment_option__c, 'account.payment_option__c for direct debit should be Other');

            // check that the setup invoice was created
            invoice__c[] invoices = [SELECT id, name, status__c FROM invoice__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, invoices.size(), 'invoice not created');
            for (invoice__c invoice : invoices){
                system.assertEquals('AUTHORISED', invoice.status__c, 'invoice was not marked AUTHORISED');
            }
        }
        test.stoptest();
    }

    // attempt to insert into the SLX checkout using a direct debit with invalid bsb and account number
    @istest
    static void testSubmitSLXDirectDebitError() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();
        system.runAs(siteuserSLX) {
            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            test.setCurrentPage(pageref);
            controller.index();

            // display non-empty cart
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';

            controllerpage2.paymenttype             = 'direct debit';
            controllerpage2.applypaymenttype();
            controllerpage2.acc.account_no__c       = '1234567912456789';
            controllerpage2.acc.bsb__c              = '0123';
            controllerpage2.birthday                = '31';
            controllerpage2.birthmonth              = '12';
            controllerpage2.birthyear               = '1990';

            // submit the checkout (should return a pagereference and no error messages)
            pagereference resultsuccess = controllerpage2.submitCheckout();

            system.assertEquals(null, resultsuccess, 'no success page pagereference');
            system.assertNotEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page should contain errors');

            // check that the signup record was created
            sign_up__c[] signups = [SELECT id, name FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(0, signups.size(), 'signup was created but it should not have been');

            // check that the account not created
            account[] accounts = [SELECT id, name, payment_option__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(0, accounts.size(), 'account was created but should not have been.');
        }
        test.stoptest();
    }

    // test adding non-existant promocode
    @istest
    static void testPromoError() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();
        system.runAs(siteuserSLX) {
            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmt.id + ',' + productSetup.id );
            test.setCurrentPage(pageref);
            controller.index();

            // apply a non-existant promocode
            controller.setpromocode('badpromocode');
            controller.applypromocode();

            system.assertEquals(null, controller.getpromocode());
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.severity.error), 'page should contain errors');
        }

        test.stoptest();
    }

    // insert into the SLX checkout using a promocode that covers the entire setup cost
    @istest
    static void testSubmitSLXSEONoCharge() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();

        system.runAs(siteuserSLX) {

            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmtSEO.id + ',' + productSetupSEO.id );
            pageref.getParameters().put('promocode', 'BSALNSU' );
            test.setCurrentPage(pageref);
            controller.index();

            // display non-empty cart
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error));

            map<string,decimal> totals = controller.gettotals();
            system.debug('totals ' + totals);

            system.assertEquals(899.00, totals.get('monthly'), 'incorrect totals');
            system.assertEquals(0.00, totals.get('setup'), 'incorrect totals'); // (199 - 199)

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');
            controllerpage2.paymentTestType = paymentGateway.TEST_FAILURE;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';

            controllerpage2.termsAdwords1                  = true;
            controllerpage2.termsAdwords2                  = true;
            controllerpage2.termsAdwords3                  = true;
            controllerpage2.termsAdwords4                  = true;
            controllerpage2.termsAdwords5                  = true;

            controllerpage2.paymenttype                 = 'Credit Card';
            controllerpage2.cardtype                    = 'Visa';
            controllerpage2.applypaymenttype();
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // submit the checkout (should return a pagereference and no error messages)
            controllerpage2.paymentTestType = paymentGateway.TEST_SUCCESS;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;
            pagereference resultsuccess = controllerpage2.submitCheckout();

            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created
            sign_up__c[] signups = [SELECT id, name, Product_Type__c FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');
            system.assertEquals('SEO', signups[0].Product_Type__c, 'Incorrect product type on signup');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');

            // check that contacts were created
            Contact[] contacts = [SELECT Title, Id FROM Contact WHERE Account.Id = :accounts[0].id];
            system.assertEquals(3, contacts.size(), 'contacts not created');

            // check that the account_products were created
            account_product__c[] accproducts = [SELECT id, name FROM account_product__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, accproducts.size(), 'account_products were not created');

            // check that the setup invoice was created using the total for the SEO management product
            invoice__c[] invoices = [SELECT id, name, status__c FROM invoice__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, invoices.size(), 'invoice not created');
            for (invoice__c invoice : invoices){
                system.assertEquals('PAID', invoice.status__c, 'invoice was not marked paid');
            }
        }

        test.stoptest();
    }

    // insert into the gmt checkout with an existing customer account using a promocode, addon (with promocode) and creditcard payment
    @istest
    static void testSubmitGMT() {
        init();

        string sitename = 'checkout_GMT';

        // run tests
        test.starttest();
        system.runAs(siteusergmt) {
            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'AUD');

            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmtgmt.id + ',' + productSetupgmt.id );
            test.setCurrentPage(pageref);
            controller.index();

            // apply a promocode
            controller.setpromocode('INVGMT');
            controller.applypromocode();

            system.debug('controller.paymenttype: ' + controller.paymenttype);

            // add an addon product and promocode
            pageref = page.checkoutMain_slx;
            pageref.getParameters().put('addon-1', productaddongmt.id);
            pageref.getheaders().put('referer', 'http://sponsoredlinx.com/');
            pageref.getheaders().put('host', 'developer-bjbglobal.cs5.force.com');
            test.setCurrentPage(pageref);
            controller.addpackage();

            // display non-empty cart
            system.assertNotEquals(null, controller.getCart());
            system.assertEquals(false, controller.getiscartempty());
            system.assertEquals('Invoice', controller.paymenttype);
//            system.assertEquals(null, controller.getpromocode()); // the DDGMT promocode should only change the payment type, not set an actual promocode
            system.assertEquals('INVGMT', controller.getpromocode()); // INVGMT does set an actual promocode
            system.assertNotEquals(null, controller.getSiteWrapperURL());
            system.assertNotEquals(null, controller.getAddonsURL());
            system.assertNotEquals(null, controller.getstateoptions());
            system.assertNotEquals(null, controller.getcreditcardoptions());
            system.assertNotEquals(null, controller.getmonthoptions());
            system.assertNotEquals(null, controller.getcardyearoptions());
            system.assertNotEquals(null, controller.getpaymenttypeoptions());
            system.assertNotEquals(null, controller.getjsoncart());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            map<string,decimal> totals = controller.gettotals();
            system.assertEquals(79.00, totals.get('weekly'), 'incorrect totals');
            system.assertEquals(49.00, totals.get('monthly'), 'incorrect totals');
            system.assertEquals(199.00, totals.get('setup'), 'incorrect totals');


            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'AUD');
            controllerpage2.paymentTestType = paymentGateway.TEST_SUCCESS;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // submit the checkout (should return a pagereference and no error messages)
            pagereference resultsuccess = controllerpage2.submitCheckout();
            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created
            sign_up__c[] signups = [SELECT id, name, Product_Type__c, Invoiceno__c FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');
            system.assertEquals('AdWords Management', signups[0].Product_Type__c, 'Incorrect product type on signup');
            system.assertNotEquals(null, signups[0].Invoiceno__c, 'Signup missing invoice number');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');
        }
        test.stoptest();
    }

    // insert into the SLX nz checkout using creditcard payment
    @istest
    static void testSubmitSLXNZ() {
        init();

        string sitename = 'checkout_SLX';

        // run tests
        test.starttest();
        system.runAs(siteuserSLX) {
            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_slx;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmtSLXnz.id + ',' + productSetupSLXnz.id );
            test.setCurrentPage(pageref);

            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'NZD');

            controller.index();

            system.debug('getMessages: ' + ApexPages.getMessages());

            // display non-empty cart
            system.assertNotEquals(null, controller.getCart());
            system.assertEquals(false, controller.getiscartempty());
            system.assertEquals(null, controller.getpromocode());
            system.assertNotEquals(null, controller.getSiteWrapperURL());
            system.assertNotEquals(null, controller.getstateoptions());
            system.assertNotEquals(null, controller.getcreditcardoptions());
            system.assertNotEquals(null, controller.getmonthoptions());
            system.assertNotEquals(null, controller.getcardyearoptions());
            system.assertNotEquals(null, controller.getpaymenttypeoptions());
            system.assertNotEquals(null, controller.getjsoncart());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // seo product should be duplicated into monthly and setup
            map<string,decimal> totals = controller.gettotals();
            system.assertEquals(899.00, totals.get('monthly'), 'incorrect totals');
            system.assertEquals(899.00, totals.get('setup'), 'incorrect totals');

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'NZD');
            controllerpage2.paymentTestType = paymentGateway.TEST_SUCCESS;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // submit the checkout (should return a pagereference and no error messages)
            pagereference resultsuccess = controllerpage2.submitCheckout();
            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created
            sign_up__c[] signups = [SELECT id, name FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c, CurrencyIsoCode FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');
            system.assertEquals('Commweb', accounts[0].payment_option__c, 'nz payment option should be commweb');
            system.assertEquals('NZD', accounts[0].CurrencyIsoCode, 'NZ currency should be NZD');

            // check that contacts were created
            Contact[] contacts = [SELECT Title, Id FROM Contact WHERE Account.Id = :accounts[0].id];
            system.assertEquals(3, contacts.size(), 'contacts not created');

            // check that the account_products were created (seo should only have one product)
            account_product__c[] accproducts = [SELECT id, name FROM account_product__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, accproducts.size(), 'account_products were not created');

            // check that the setup invoice was created
            invoice__c[] invoices = [SELECT id, name, status__c FROM invoice__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, invoices.size(), 'invoice not created');
            for (invoice__c invoice : invoices){
                system.assertEquals('PAID', invoice.status__c, 'invoice was not marked paid');
            }

            // check that the project was created for SEO
            SFDC_Projects__c[] projects = [SELECT id, name FROM SFDC_Projects__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, projects.size(), 'projects were not created');
        }
        test.stoptest();
    }


    // insert into the SLX nz checkout using creditcard payment
    @istest
    static void testSubmitGMTNZ() {
        init();

        string sitename = 'checkout_GMT';

        // run tests
        test.starttest();
        system.runAs(siteuserGMT) {
            // add a package (from an external link)
            pagereference pageref = page.checkoutMain_gmt;
            pageref.getParameters().put('do', 'addpackage');
            pageref.getParameters().put('package', productMgmtGMTnz.id + ',' + productSetupGMTnz.id );
            test.setCurrentPage(pageref);

            CheckoutController controller = new CheckoutController();
            controller.setSite(sitename, 'NZD');

            controller.index();

            system.debug('getMessages: ' + ApexPages.getMessages());

            // display non-empty cart
            system.assertNotEquals(null, controller.getCart());
            system.assertEquals(false, controller.getiscartempty());
            system.assertEquals(null, controller.getpromocode());
            system.assertNotEquals(null, controller.getSiteWrapperURL());
            system.assertNotEquals(null, controller.getstateoptions());
            system.assertNotEquals(null, controller.getcreditcardoptions());
            system.assertNotEquals(null, controller.getmonthoptions());
            system.assertNotEquals(null, controller.getcardyearoptions());
            system.assertNotEquals(null, controller.getpaymenttypeoptions());
            system.assertNotEquals(null, controller.getjsoncart());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // seo product should be duplicated into monthly and setup
            map<string,decimal> totals = controller.gettotals();
            system.assertEquals(899.00, totals.get('monthly'), 'incorrect totals');
            system.assertEquals(899.00, totals.get('setup'), 'incorrect totals');

            // submit the checkout
            CheckoutController controllerpage2 = new CheckoutController();
            controllerpage2.setSite(sitename, 'NZD');
            controllerpage2.paymentTestType = paymentGateway.TEST_SUCCESS;
            controllerpage2.testGateway = paymentGateway.GATEWAY_LOCAL;

            controllerpage2.signup.firstname__c     = 'Steve';
            controllerpage2.signup.lastname__c      = 'Clientman';
            controllerpage2.signup.Email__c         = 'steve.clientman+'+ utility.generateRandomString(12) +'@sponsoredlinx.com';
            controllerpage2.signup.phone__c         = '0404040404';
            controllerpage2.signup.company__c       = 'find a tradie';
            controllerpage2.signup.website__c       = 'findatradie.com.au';

            controllerpage2.signup.street__c        = '100 Wickham St';
            controllerpage2.signup.city__c          = 'Fortitude Valley';
            controllerpage2.signup.postalcode__c    = '4006';
            controllerpage2.signup.state__c         = 'QLD';
            controllerpage2.cardDetails.card_number     = '4444333322221111';
            controllerpage2.cardDetails.card_cvn        = '123';
            controllerpage2.acc.name_on_card__c         = 'Steve Clientman';
            controllerpage2.acc.card_month_expiry__c    = '5';
            controllerpage2.acc.card_year_expiry__c     = '2020';

            // submit the checkout (should return a pagereference and no error messages)
            pagereference resultsuccess = controllerpage2.submitCheckout();
            system.assertNotEquals(null, resultsuccess, 'no success page pagereference');
            system.assertEquals('/apex/CheckoutRedir', resultsuccess.geturl());
            system.assertEquals(false, ApexPages.hasMessages(ApexPages.severity.error), 'page contains errors');

            // check that the signup record was created
            sign_up__c[] signups = [SELECT id, name FROM sign_up__c WHERE status__c = 'new' AND username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, signups.size(), 'signup not created');

            // check that the account was created
            account[] accounts = [SELECT id, name, payment_option__c, CurrencyIsoCode FROM account WHERE username__c = :controllerpage2.signup.Email__c LIMIT 1];
            system.assertEquals(1, accounts.size(), 'account not created');
            system.assertEquals('Commweb', accounts[0].payment_option__c, 'nz payment option should be commweb');
            system.assertEquals('NZD', accounts[0].CurrencyIsoCode, 'NZ currency should be NZD');

            // check that contacts were created
            Contact[] contacts = [SELECT Title, Id FROM Contact WHERE Account.Id = :accounts[0].id];
            system.assertEquals(3, contacts.size(), 'contacts not created');

            // check that the account_products were created (seo should only have one product)
            account_product__c[] accproducts = [SELECT id, name FROM account_product__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, accproducts.size(), 'account_products were not created');

            // check that the setup invoice was created
            invoice__c[] invoices = [SELECT id, name, status__c FROM invoice__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, invoices.size(), 'invoice not created');
            for (invoice__c invoice : invoices){
                system.assertEquals('PAID', invoice.status__c, 'invoice was not marked paid');
            }

            // check that the project was created for SEO
            SFDC_Projects__c[] projects = [SELECT id, name FROM SFDC_Projects__c WHERE account__c = :accounts[0].id];
            system.assertEquals(1, projects.size(), 'projects were not created');
        }
        test.stoptest();
    }

}