global class xeroSignupPaymentsBatch implements Database.batchable<Signup_Payments__c>,Database.AllowsCallouts {
    
    global Iterable<Signup_Payments__c> start(Database.batchableContext info) {     
        return new xeroSignupPaymentsIterator();    
    }
    
    global void execute(Database.batchableContext info, List<Signup_Payments__c> scope) {
     String consumerkey  = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
      String privatekey   = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
                + 'RB2LtaiVosnxlB6Bji69sx3pM8AEaNrCWjetjktgdF/611Aqy83IABFLT926KWxt\n'
                + 'nmE2EfdeC3PE/gTf1ASgQ+seD6LyxWpy62G75dtz56bxoERkN6LYLfF5IQIDAQAB\n'
                + 'AoGAUR0B39ZJ6/CDadgl/tzh6u73FDAgpSjgsQQojct0397gzSjYP+kQXmugWSL7\n'
                + '3/PpRXCQ+j4yz6w5g1rMLBwyClds5nn0Tsi2TZbxx/uGdcb8/ulYfEySw7CJspDk\n'
                + 'Bw7m37IHDJn/bLHHZdxKQMed4/8Z8HBzGbaRz8kMhU8f+x0CQQDMnVIChO9BVYb1\n'
                + 'd1PL+eVQWzY2bOxs+yfFrw6RYCvIpEsVGpvuFLYD4NKCD/3YDwNzFVCsIyiFKCxX\n'
                + 'vn2aGhjbAkEAwB4pfRFW9fKqiuDr+Xohn2L/5eYiwtqDrFKzCS7zwDFRCjPKP7oY\n'
                + 'FaqoW+c3bRdBJ99otB6lWsSd9elSCgXIswJBAJv2ZmZpMX1ZVc+QrxzRVAtWGxKN\n'
                + 'IAFJx10VPENvTLBZGqnxaF2nB74ZBhwBWHnxp61219D904r7viD7n/1wWvUCQBdu\n'
                + 'Vk8Lo1iBzSz8+6rEq38d+unWJJ0xO2fz+iP/lvj0ytZ8tIkLME7MLpZu38KtWGP9\n'
                + 'im6VYkNswXsxhrD0PaMCQGMmLGr8gsq9GeRkBetGTH4QiLFEpLanNXoCnStmuAF8\n'
                + '6Wikk/7w1vjZNzJUX43BWBkYKT2O9waibBowkVP4EBQ=\n';
        sfxero.XeroCredentials cred = new sfxero.XeroCredentials(consumerKey, '', privateKey);
        sfxero.XeroPaymentResponse payResponse;
        List<sfxero.XeroPayment> xeroPayments;
        
        for(Signup_Payments__c xero_signuppayment : scope){
            sfxero.XeroPayment payment = new sfxero.XeroPayment();
            xeroPayments = new List<sfxero.XeroPayment>();

            sfxero.XeroAccount acc  = new sfxero.XeroAccount();
            acc.code                = '11110A';
            acc.accountId           = '13e0ed04-3754-405f-9495-b79c3d6dd06e';
            payment.acc             = acc;

            payment.amount          = xero_signuppayment.Amount__c;
            //payment.invoiceId         = xero_signuppayment.Xero_Invoice_Id__c;

            sfxero.XeroInvoice inv  = new sfxero.XeroInvoice();
            inv.invoiceNumber       = xero_signuppayment.Name;
            payment.inv             = inv;

            payment.paymentDate     = Date.newInstance(xero_signuppayment.CreatedDate.year(),xero_signuppayment.CreatedDate.month(),xero_signuppayment.CreatedDate.day());
            System.debug('Xero Payment: '+payment);
            xeroPayments.add(payment);
            try {
                System.debug('xero_signuppayment: '+xero_signuppayment);
                payResponse = sfxero.XeroAPI.putPayments(cred, xeroPayments);
                System.debug('XERO Signup Payment Response : '+payResponse);
                if(payResponse.status != 'OK') {                
                    xero_signuppayment.Last_Response__c = payResponse.badrequest.requestValidations[0];
                    update xero_signuppayment;
                } else {
                    delete xero_signuppayment;
                }                   
            } catch (Exception e) {
                System.debug('Exception: '+e);
                xero_signuppayment.Last_Response__c = 'FAILURE: !Check XERO! : '+e.getMessage();
                update xero_signuppayment;
            }
        }
    }
    
    global void finish(Database.batchableContext info){
        
    }
    
    public static testMethod void testxeroSignupPayments() {
        Test.startTest();
        xeroSignupPaymentsBatch scriptBatch = new xeroSignupPaymentsBatch();
        ID batchprocessid = Database.executeBatch(scriptBatch);
        Test.stopTest();
    }
    
}