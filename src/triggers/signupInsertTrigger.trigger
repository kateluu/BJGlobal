/**
 * Created by HanhLuu on 9/02/2018.
 */

trigger SignupInsertTrigger on Sign_Up__c (after insert) {
    List<Task> calltasks = new List<Task>();
    for (Sign_Up__c signup : System.trigger.new){

        if (signup.Cart_SF__c != null){
            Cart mycart          = (Cart) JSON.deserialize(signup.Cart_SF__c, Cart.class);

            Account acc = [SELECT Id, Name, Company__c, Payment_Option__c, Unique_Id__c, CurrencyIsoCode FROM Account WHERE id = :signup.Account__c LIMIT 1];

            Payment_Attempt__c paymentAttempt;
            if ( signup.Payment_Attempt__c != null ) {
                paymentAttempt = [SELECT Id, CurrencyIsoCode, Payment_Type__c, Payment_Option__c, Invoice_Number__c, Gateway_Transaction_Id__c, Status__c, Response_Code__c, Response_Message__c FROM Payment_Attempt__c WHERE id = :signup.Payment_Attempt__c LIMIT 1];
            }

            // Loop through the products
            List<CartItem> myPackage = mycart.getPackageFromPackageData(mycart.myPackageData);

            for (CartItem myCartItem : myPackage) {

                // Don't insert ghost products, eg SEO setup.
                if (myCartItem.isGhost == true){
                    continue;
                }

                // Create account_products
                Account_Product__c accountProduct = new Account_Product__c();
                accountProduct.Name                     = myCartItem.product.Name;
                accountProduct.Description__c           = signup.FromSource__c + ' Invoice';
                accountProduct.Account__c               = signup.Account__c;
                accountProduct.SLX_Product__c           = myCartItem.product.id;
                accountProduct.Product_Price__c         = myCartItem.priceNet; // Price net of discounts
                accountProduct.Recurring_Period__c      = myCartItem.product.recurring_period__c;
                accountProduct.Last_Invoice_Date__c     = Date.today();
                accountProduct.Sign_Up_del__c           = signup.Id;
                accountProduct.Payment_Option__c        = acc.Payment_Option__c;
                accountProduct.CurrencyIsoCode          = signup.CurrencyIsoCode;

                insert accountProduct;

                // Create an invoice for setup products, or the SEO management product
                if ( myCartItem.isChargeableAtOrder() ){

                    Invoice__c invoice = new Invoice__c();
                    invoice.Name                  = acc.Company__c;
                    invoice.Account__c            = signup.Account__c;
//                  invoice.Last_Email_Sent__c    = accountProduct.Last_Invoice_Date__c;
                    invoice.Issue_Date__c         = accountProduct.Last_Invoice_Date__c;
                    invoice.Due_Date__c           = accountProduct.Last_Invoice_Date__c;
                    invoice.Account_Product__c    = accountProduct.id;
                    invoice.Reference__c          = acc.Unique_Id__c;
                    invoice.Amount_Credited__c    = 0;
                    invoice.Invoice_Total__c      = accountProduct.Product_Price__c;
                    invoice.CurrencyIsoCode       = acc.CurrencyIsoCode;

                    if (invoice.Invoice_Total__c == 0) {
                        // No charge (completed covered by promo)
                        invoice.Status__c             = 'NO CHARGE';
                        invoice.Amount_Paid__c        = 0;
                    }
                    else if (paymentAttempt != null && paymentAttempt.Status__c == 'SUCCESS') {
                        // Credit card
                        invoice.Status__c             = 'PAID';
                        invoice.Amount_Paid__c        = accountProduct.Product_Price__c;
                        // PaymentAttempts differentiate between Commweb and Commweb2 because they're different gateways, however from
                        // the invoice onwards we want to just display it as Commweb for accounts simplicity.
                        if (paymentAttempt.Payment_Option__c == 'Commweb2'){
                            invoice.Payment_Option__c     = 'Commweb';
                        } else {
                            invoice.Payment_Option__c     = paymentAttempt.Payment_Option__c;
                        }
                    }
                    else if ( acc.Payment_Option__c == 'Other' || acc.Payment_Option__c == 'Direct Debit') {
                        // Direct debit
                        invoice.Status__c             = 'AUTHORISED';
                        invoice.Amount_Paid__c        = 0;
                        invoice.Payment_Option__c     = 'Other';
                    } else {
                        system.debug('No payment attempt found');
                        throw new customException('No payment attempt found');
                    }

                    invoice.Amount_Due__c         = invoice.Invoice_Total__c - invoice.Amount_Paid__c;

                    // We want the invoice number from the signup, not the payment attempt because it includes the '-1' suffix.
                    invoice.Invoice_Number__c     = signup.Invoiceno__c;

                    if (paymentAttempt != null) {
//                        invoice.Invoice_Number__c     = paymentAttempt.Invoice_Number__c;

                        // Payment_Response__c must be max 20 chars
                        String transId = paymentAttempt.Gateway_Transaction_Id__c;
                        transId = transId.length() > 15 ? transId.substring(0, 15) : transId;
                        invoice.Payment_Response__c   = transId;

                        if (paymentAttempt.Status__c == 'SUCCESS'){
                            invoice.Payment_Message__c    = 'SUCCESS: ' + utility.ifnull(paymentAttempt.Response_Code__c, '') + ': ' + paymentAttempt.Response_Message__c;
                        } else {
                            invoice.Payment_Message__c    = 'FAILURE: ' + utility.ifnull(paymentAttempt.Response_Code__c, '') + ': ' + paymentAttempt.Response_Message__c;
                        }
                    } else {
//                        invoice.Invoice_Number__c     = checkoutController.getNextInvoiceNumber();
                    }

                    system.debug('inserting invoice ' + invoice);

                    insert invoice;

                    if ( paymentAttempt != null && paymentAttempt.Status__c == 'SUCCESS' ) {
                        // Credit card: Create a payment record
                        Payment__c payment = new Payment__c();
                        payment.Account__c               = signup.Account__c;
                        payment.Payment_Amount__c        = invoice.Amount_Paid__c; // Not necessarily the full amount of the payment attempt, as separate invoices for each addon reference the same payment attempt
                        payment.Invoice__c               = invoice.id;
                        payment.Invoice_Number__c        = invoice.Invoice_Number__c;
                        payment.Payment_Date__c          = accountProduct.Last_Invoice_Date__c;
                        payment.Account_Product__c       = accountProduct.id;

                        payment.CurrencyIsoCode          = paymentAttempt.CurrencyIsoCode;
                        payment.Payment_Type__c          = paymentAttempt.Payment_Type__c;
                        payment.Payment_Option__c        = paymentAttempt.Payment_Option__c;
                        payment.Payment_Owner__c         = UserInfo.getUserId();

                        insert payment;
                    }
                }

                // create a project if product is SEO
                if (signup.Product_Type__c == 'SEO'){
                    SFDC_Projects__c newProject = new SFDC_Projects__c();
                    newProject.Account__c           = accountProduct.Account__c;
                    newProject.Account_Product__c   = accountProduct.id;
                    newProject.Sign_Up__c           = signup.id;
                    newProject.Project_Type__c      = signup.Product_Type__c;
                    newProject.Name                 = acc.Company__c;
                    newProject.Phone_Number__c      = signup.Phone__c;
                    newProject.Email__c             = signup.Email__c;
                    newProject.Sold_by__c           = 'Unknown';
                    newProject.CurrencyIsoCode      = accountProduct.CurrencyIsoCode;

                    if (signup.Product_Type__c == 'ConvertoPages'){
                        newProject.Name             = acc.Company__c + ' - Converto';
                    }

                    insert newProject;
                }
            }
        }
//        if (NULL != signup.Team_Leader__c){
//            Task callTass = new Task(Subject ='Setup Call To Client within 2 hours',  WhoId = signup.Team_Leader__c, Whatid=signup.id, Status = 'Not Started', Priority = 'High');
//            calltasks.add(callTass);
//        }
//        if (calltasks.size()>0){
//            insert calltasks;
//        }
    }


}