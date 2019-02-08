global with sharing class InvoiceReminder {
  public static boolean isTest = false;
  public static String consumerkey  = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
  public static String privatekey   = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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

  global class WebServiceResultExcludeInvoice {
    WebService Boolean status;
    WebService String message;
  }

  global class WebServiceResultIncludeInvoice {
    WebService Boolean status;
    WebService String message;
  }


  WebService static WebServiceResultExcludeInvoice excludeInvoiceReminder(String invoice_number) {
    WebServiceResultExcludeInvoice return_result = new WebServiceResultExcludeInvoice();
    List<Invoice__c> invoices = [SELECT Id, Name, Account__c, Invoice_Number__c, Exclude_Reminder__c FROM Invoice__c WHERE Invoice__c.Invoice_Number__c =: invoice_number];
    List<Invoice_Reminder_Exclude__c> excludes = [SELECT Id, Invoice_Number__c FROM Invoice_Reminder_Exclude__c];

    if(invoices.size() > 0) {
      Invoice__c the_invoice = invoices[0];
      Boolean found = false;
      if(excludes.size() > 0) {
        for(Invoice_Reminder_Exclude__c invoice_reminder_exclude : excludes) {
          if(invoice_reminder_exclude.Invoice_Number__c == the_invoice.Invoice_Number__c) {
            found = true;
          }
        }
      }

      if(found == false) {
      	/*
        // if we can not find it in the list we ADD it into the list
        Invoice_Reminder_Exclude__c invoice_reminder_exclude = new Invoice_Reminder_Exclude__c();
        invoice_reminder_exclude.Name = the_invoice.Name;
        invoice_reminder_exclude.Invoice_Number__c = invoice_number;
        invoice_reminder_exclude.Account__c = the_invoice.Account__c;
        insert invoice_reminder_exclude;

        System.debug('This invoice has been ADDED into invoice reminder exclude list: ' + the_invoice);
        return_result.status = true;
        return_result.message = 'This invoice has been added into invoice reminder exclude list';
        */
      }
      else {
        return_result.status = true;
        return_result.message = 'This invoice is already in the invoice reminder exclude list';
      }

      // now we set ALL invoices with this number to be excluded
      for(Integer i = 0; i < invoices.size(); i++) {      
        invoices[i].Exclude_Reminder__c = true;
      }
      update invoices;
    }
    else {
      return_result.status = false;
      return_result.message = 'Can not find invoice with this number';
    }

    return return_result;
  }


  WebService static WebServiceResultIncludeInvoice includeInvoiceReminder(String invoice_number) {
    WebServiceResultIncludeInvoice return_result = new WebServiceResultIncludeInvoice();
    List<Invoice__c> invoices = [SELECT Id, Name, Account__c, Invoice_Number__c, Exclude_Reminder__c FROM Invoice__c WHERE Invoice__c.Invoice_Number__c =: invoice_number];
    List<Invoice_Reminder_Exclude__c> excludes = [SELECT Id, Invoice_Number__c FROM Invoice_Reminder_Exclude__c];

    if(invoices.size() > 0) {
      Invoice__c the_invoice = invoices[0];
      Boolean found = false;
      if(excludes.size() > 0) {
        for(Invoice_Reminder_Exclude__c invoice_reminder_exclude : excludes) {
          if(invoice_reminder_exclude.Invoice_Number__c == the_invoice.Invoice_Number__c) {
            found = true;
            delete invoice_reminder_exclude;

            System.debug('This invoice has been ADDED into invoice reminder exclude list: ' + the_invoice);
            return_result.status = true;
            return_result.message = 'This invoice has been removed from invoice reminder exclude list';
          }
        }
      }

      if(found == false) {
        return_result.status = true;
        return_result.message = 'This invoice was not in invoice reminder exclude list';
      }

      // now we set ALL invoices with this number to be excluded
      for(Integer i = 0; i < invoices.size(); i++) {      
        invoices[i].Exclude_Reminder__c = false;
      }
      update invoices;
    }
    else {
      return_result.status = false;
      return_result.message = 'Can not find invoice with this number';
    }

    return return_result;
  }


  @future (callout=false)
  public static void setInvoiceReminderExcludeFlag() {
    // we loop the list of today's invoice
    List<Invoice_Batch__c> todaysBatches = [SELECT Id, Name, Batch_Date__c, Batch_Number__c, Batch_Processed__c, status__c, Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' AND Batch_Date__c =: Date.today()];
    /*
    if(todaysBatches.size() > 0) {
      Invoice_Batch__c todaysBatch = todaysBatches[0];
      // grab the list of invoices
      List<Invoice__c> invoices = [SELECT Id,Name,Payment_Batch__c,Payment_Message__c,Payment_Response__c,Account__c,Account_Product__c,Amount_Credited__c,Amount_Due__c,Amount_Paid__c,Due_Date__c,Invoice_Batch__c,Invoice_Number__c,Invoice_Total__c,Issue_Date__c,Payment_Option__c,Processed__c,Process_Message__c,Reference__c,Xero_Contact_Id__c,Xero_Invoice_Id__c, Exclude_Invoice__c, Exclude_Reminder__c FROM Invoice__c WHERE Invoice_Batch__c =: todaysBatch.Id];
      System.debug('All Invoices: ' + invoices);

      // grabthe list of excluded invoices
      List<Invoice_Reminder_Exclude__c> invoices_reminder_exclude = [SELECT Invoice_Number__c FROM Invoice_Reminder_Exclude__c];
      if(invoices_reminder_exclude.size() > 0) {
        // match them, loop over the invoice list and for each invoice
        // we loop the exclude list and match the invoice number. if
        // found a match, current invoice needs to be set as 'excluded'
            for(Integer i = 0; i < invoices.size(); i++) {
          System.debug('Updating Invoice: ' + invoices[i]);
          for(Invoice_Reminder_Exclude__c invoice_reminder_exclude : invoices_reminder_exclude) {
            if(invoices[i].Invoice_Number__c == invoice_reminder_exclude.Invoice_Number__c) {
              invoices[i].Exclude_Reminder__c = true;
            }
          }
            }
      }

      update invoices;
    }
    */
  }


  public static testMethod void excludeInvoiceReminderTest() {
    Test.startTest();
    
    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
    insert acc;

    List<Account_Product__c> testProducts = new List<Account_Product__c>();
    for(Integer i=0;i<1;i++) {                              
        Account_Product__c item = new Account_Product__c(Name ='Social Engage '+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Tiger Pistol Product').getRecordTypeId());
        testProducts.add(item);
    }
    insert testProducts; 

	
    Invoice__c invoice1 = new Invoice__c();
    invoice1.name = 'test invoice';
    invoice1.Payment_Option__c = 'Other';
    invoice1.Invoice_Number__c = 'test--001';
    invoice1.Invoice_Batch__c = null;
    invoice1.Payment_Batch__c = null;
    invoice1.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    invoice1.Account__c = acc.Id;
    invoice1.Account_Product__c = testProducts.get(0).Id;
    invoice1.Amount_Due__c = 4.50;
    insert invoice1;

    Invoice_Reminder_Exclude__c exclude = new Invoice_Reminder_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    InvoiceReminder.excludeInvoiceReminder(invoice1.Invoice_Number__c);
    Test.stopTest();
  }

  public static testMethod void excludeInvoiceReminderErrorTest() {
    Test.startTest();
    
    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
    insert acc;

    List<Account_Product__c> testProducts = new List<Account_Product__c>();
    for(Integer i=0;i<1;i++) {                              
        Account_Product__c item = new Account_Product__c(Name ='Social Engage '+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Tiger Pistol Product').getRecordTypeId());
        testProducts.add(item);
    }
    insert testProducts; 



    Invoice__c invoice1 = new Invoice__c();
    invoice1.name = 'test invoice';
    invoice1.Payment_Option__c = 'Other';
    invoice1.Invoice_Number__c = 'test--001';
    invoice1.Invoice_Batch__c = null;
    invoice1.Payment_Batch__c = null;
    invoice1.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    invoice1.Account__c = acc.Id;
    invoice1.Account_Product__c = testProducts.get(0).Id;
    invoice1.Amount_Due__c = 4.50;
    insert invoice1;

    Invoice_Reminder_Exclude__c exclude = new Invoice_Reminder_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    InvoiceReminder.excludeInvoiceReminder('fakeinvoicenumber');
    Test.stopTest();
  }

  public static testMethod void includeReminderInvoiceTest() {
    Test.startTest();
    
    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
    insert acc;

    List<Account_Product__c> testProducts = new List<Account_Product__c>();
    for(Integer i=0;i<1;i++) {                              
        Account_Product__c item = new Account_Product__c(Name ='Social Engage '+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Tiger Pistol Product').getRecordTypeId());
        testProducts.add(item);
    }
    insert testProducts; 

    Invoice__c invoice1 = new Invoice__c();
    invoice1.name = 'test invoice';
    invoice1.Payment_Option__c = 'Other';
    invoice1.Invoice_Number__c = 'test--001';
    invoice1.Invoice_Batch__c = null;
    invoice1.Payment_Batch__c = null;
    invoice1.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    invoice1.Account__c = acc.Id;
    invoice1.Account_Product__c = testProducts.get(0).Id;
    invoice1.Amount_Due__c = 4.50;
    invoice1.Exclude_Invoice__c = true;
    invoice1.Exclude_Reminder__c = true;
    insert invoice1;

    Invoice_Reminder_Exclude__c exclude = new Invoice_Reminder_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    InvoiceReminder.includeInvoiceReminder(invoice1.Invoice_Number__c);
    Test.stopTest();
  }

  public static testMethod void setInvoiceReminderExcludeFlagTest() {
    Test.startTest();

    Invoice_Batch__c batch1 = new Invoice_Batch__c();
    batch1.Name = '';
    batch1.Batch_Date__c = Date.today();
    batch1.Batch_Type__c = 'Invoices';
    
    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
    insert acc;

    List<Account_Product__c> testProducts = new List<Account_Product__c>();
    for(Integer i=0;i<1;i++) {                              
        Account_Product__c item = new Account_Product__c(Name ='Social Engage '+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Traditional Products').getRecordTypeId());
        testProducts.add(item);
    }
    insert testProducts; 

    Invoice__c invoice1 = new Invoice__c();
    invoice1.name = 'test invoice';
    invoice1.Payment_Option__c = 'Other';
    invoice1.Invoice_Number__c = 'test--001';
    invoice1.Invoice_Batch__c = batch1.Id;
    invoice1.Payment_Batch__c = null;
    invoice1.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    invoice1.Account__c = acc.Id;
    invoice1.Account_Product__c = testProducts.get(0).Id;
    invoice1.Amount_Due__c = 4.50;
    invoice1.Exclude_Invoice__c = false;
    invoice1.Exclude_Reminder__c = false;
    insert invoice1;

    Invoice_Reminder_Exclude__c exclude = new Invoice_Reminder_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    InvoiceReminder.setInvoiceReminderExcludeFlag();
    Test.stopTest();
  }

}