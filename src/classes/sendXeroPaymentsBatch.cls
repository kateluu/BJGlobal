global class sendXeroPaymentsBatch implements Database.batchable<Invoice_Payments__c>,Database.AllowsCallouts {
    global Iterable<Invoice_Payments__c> start(Database.batchableContext info) {
        return new sendXeroPayments('Today');
    }
    global void execute(Database.batchableContext info, List<Invoice_Payments__c> scope){
    	/*
          String consumerKey = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
          String privateKey = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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
        
        for(Invoice_Payments__c xero_payment : scope){
            sfxero.XeroPayment payment = new sfxero.XeroPayment();
            xeroPayments = new List<sfxero.XeroPayment>();
            
            sfxero.XeroAccount acc  = new sfxero.XeroAccount();
            acc.accountID           = xero_payment.Xero_Account_Id__c;
            acc.code                = xero_payment.Xero_Account_Code__c;
            payment.acc             = acc;
            payment.amount          = xero_payment.Payment_Amount__c;
            sfXero.XeroInvoice inv  = new sfXero.XeroInvoice();
            inv.invoiceId           = xero_payment.Xero_Invoice_Id__c;
            inv.invoiceNumber       = xero_payment.Xero_Invoice_Number__c;
            payment.inv             = inv;          
            payment.paymentDate     = xero_payment.Payment_Date__c;
            System.debug('Xero Payment: '+payment);
            xeroPayments.add(payment);
            try {
                payResponse = sfxero.XeroAPI.putPayments(cred, xeroPayments);
                System.debug('XERO Payment Response : '+payResponse);
                xero_payment.xero_response__c = 'SUCCESS: Successfull Payment';
                update xero_payment;
            } catch (Exception e) {
                System.debug('Exception: '+e);
                xero_payment.xero_response__c = 'FAILURE: !Check XERO! : XERO API Not Responding : Payment Error';
                update xero_payment;
            }
        }  
        */     
    }
    global void finish(Database.batchableContext info){
    	/*
        String batchName = DateTime.now().format('EEEE') + ' Payment Batch';
        Invoice_Batch__c todaysBatch;
        List<Invoice__c> allInvoices = new List<Invoice__c>();
        List<Invoice_Batch__c> todaysBatches = [SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Payments' and status__c = 'Payments In Progress' and Batch_Date__c =: Date.today() and Name=:batchName];
        if(todaysBatches.size() > 0) {
            todaysBatch = todaysBatches[0];
            todaysBatch.status__c = 'Payments Processed';
            todaysBatch.Batch_Processed__c = 'Yes';
            update todaysBatch;
        }   
        */        
    }
    
    public static testMethod void testBatch() {
        Test.startTest();
        sendXeroPaymentsBatch scriptBatch = new sendXeroPaymentsBatch();
        ID batchprocessid = Database.executeBatch(scriptBatch);
        Test.stopTest();
     }
}