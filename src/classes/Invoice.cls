global with sharing class Invoice {
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

  public class addInvoicesResult {
    public Boolean status;
    public String message;
  }

  public class emailInvoicesResult {
    public Boolean status;
    public String message;
  }

  global class WebServiceResultExcludeInvoice {
    WebService Boolean status;
    WebService String message;
  }

  global class WebServiceResultIncludeInvoice {
    WebService Boolean status;
    WebService String message;
  }

/*
  public static void editInvoiceStatus(String product_number, String invoice_status) {
    // set xero credentials
    sfxero.XeroCredentials credentials = new sfxero.XeroCredentials();
    credentials.consumerKey = XeroWebService.consumerkey;
    credentials.privateKey =  XeroWebService.privatekey;
    List<Account_Product__c> account_products;
    Account_Product__c account_product;
    account_products = [SELECT Product_Number__c, Product_Status__c, Product_Price__c, Name, Id, Account__c, Cancellation_Date__c, Last_Invoice_Date__c, Start_Date__c, End_Date__c, Recurring_Frequency__c, Recurring_Period__c, Company__c FROM Account_Product__c WHERE Product_Number__c =: product_number];
    List<sfxero.XeroInvoice> invoices = new List<sfxero.XeroInvoice>();
    String params = '';

    if(account_products.size() > 0) {
      account_product = account_products[0];

      // we need to get the account and fetch the xero id
      Account account;
      account = [SELECT Id, Xero_Sync_Id__c, Unique_Id__c FROM Account WHERE Account.Id =: account_product.Account__c];

      // fetch the invoice
      params = 'Contact.ContactID.ToString()="' + account.Xero_Sync_Id__c + '"&&Type="ACCREC"&&Status<>"AUTHORISED"&&';
      sfxero.XeroInvoiceResponse invResponse;
      invResponse = sfxero.XeroAPI.getInvoicesAll(credentials, null, params, '');
      invoices = invResponse.invoices;

      sfxero.XeroInvoiceResponse invoice_response;
      sfxero.XeroInvoice invoice = new sfxero.XeroInvoice();
      invoice.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCREC;
      if(invoice_status == 'Active') {
        invoice.status = sfxero.XeroInvoice.XeroInvoiceStatus.AUTHORISED;
      }
      else if(invoice_status == 'Cancelled' || invoice_status == 'Paused' || invoice_status == 'Suspended') {
        invoice.status = sfxero.XeroInvoice.XeroInvoiceStatus.DELETED;
      }

      try {
        invoice_response = sfxero.XeroAPI.postInvoices(credentials);
      }
      catch (Exception e) {
            System.debug('Exception: ' + e);
      }
    }
  }
*/

  /**
   * add new invoice by product number
   * this method is used to add a new invoice by product number
   *
   * @param String product_number
   */
/*
  public static void addInvoiceByProductNumber(String product_number) {
    // set xero credentials
    sfxero.XeroCredentials credentials = new sfxero.XeroCredentials(Invoice.consumerkey, '', Invoice.privatekey);
//    credentials.consumerKey = XeroWebService.consumerkey;
//    credentials.privateKey =  XeroWebService.privatekey;
    List<Account_Product__c> account_products;
    Account_Product__c account_product;
    account_products = [SELECT Product_Number__c, Product_Status__c, Product_Price__c, Name, Id, Account__c, Cancellation_Date__c, Last_Invoice_Date__c, Start_Date__c, End_Date__c, Recurring_Frequency__c, Recurring_Period__c, Company__c FROM Account_Product__c WHERE Product_Number__C =: product_number];

    if(account_products.size() > 0) {
      account_product = account_products[0];

      // we need to get the account and fetch the xero id
      Account account;
      account = [SELECT Id, Xero_Sync_Id__c, Unique_Id__c FROM Account WHERE Account.Id =: account_product.Account__c];

      // define xero contact(s) and prepare the xero response
      List<sfxero.XeroContact> xero_contacts;
      sfxero.XeroContact xero_contact = new sfxero.XeroContact();
      String contact_id = account.Xero_Sync_Id__c;
      sfxero.XeroContactResponse contact_response;

      // to avoid xero calls at test, we create 'fake' invoices and xero response
      if(isTest) {
        sfxero.XeroContact.XeroAddress xero_address = new sfxero.XeroContact.XeroAddress();
        List<sfxero.XeroContact.XeroAddress> xero_addresses = new List<sfxero.XeroContact.XeroAddress>();

        sfxero.XeroContact.XeroPhone xero_phone = new sfxero.XeroContact.XeroPhone();
        List<sfxero.XeroContact.XeroPhone> xero_phones = new List<sfxero.XeroContact.XeroPhone>();

        xero_phone.areaCode = '07';
        xero_phone.countryCode = '+61';
        xero_phone.phoneNumber = '33334444';
        xero_phone.phoneType = sfxero.XeroContact.XeroPhoneType.DEFAULTPHONE;
        xero_phones.add(xero_phone);
        xero_address.addressLine1 = 'addressLine1';
        xero_address.addressLine2 = 'addressLine2';
        xero_address.addressLine3 = 'addressLine3';
        xero_address.addressLine4 = 'addressLine4';
        xero_address.addressType = sfxero.XeroContact.XeroAddressType.STREET;
        xero_address.city = 'city';
        xero_address.country = 'country';
        xero_address.postalCode = 'postalCode';
        xero_address.region = 'region';
        xero_addresses.add(xero_address);

        xero_contact.phones = xero_phones;
        xero_contact.addresses = xero_addresses;
      } else {
        // fetch the xero contact
        try {
          contact_response = sfxero.XeroAPI.getContactById(credentials, contact_id);
          xero_contacts = contact_response.contacts;
          xero_contact = xero_contacts[0];
        }
        catch (Exception e) {
              System.debug('Exception: ' + e);
        }
      }

      // create a list of invoices
      List<sfxero.XeroInvoice> invoices = new List<sfxero.XeroInvoice>();

      // create a new invoice for this account product
      sfXero.XeroInvoice invoice = new sfXero.XeroInvoice();

      System.debug('invoice contact :' + xero_contact);
      // append the same xero contact into xero invoice
      invoice.contact = xero_contact;

      // early on we set the branding theme id for current product
      String brandingid = '';
      List<Company__c> companies = [SELECT Id, Name, Business_Name__c, Address__c, Email__c, Logo_Code__c, Phone__c, Branding_Theme_Id__c FROM Company__c WHERE Id =: account_product.Company__c];
      Company__c company = null;

      if (companies.size() > 0) {
        company = companies[0];
        brandingid = company.Branding_Theme_Id__c;
      }
      // default, set to sponsoredlinx
      else {
        brandingid = 'f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7';
      }
*/
/*
      // sponsoredlinx
      if(account_product.Company__c == 'a0C90000002PU4f') {
        brandingid = 'f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7';
      }
      // getmoretraffic
      else if(account_product.Company__c == 'a0C90000002PU4V') {
        brandingid = 'ef12522f-ebaa-40a9-ac6c-9875e65e71da';
      }
      // crankit
      else if(account_product.Company__c == 'a0C90000002PU4L') {
        brandingid = '70516ac3-9e70-4b6c-b6ca-a70282ba42ad';
      }
      // bjbglobal
      else if(account_product.Company__c == 'a0C90000002PU4Q') {
        brandingid = '5359048f-59b8-4093-9197-e63a5e0e6b0e';
      }
      // default, set to sponsoredlinx
      else {
        brandingid = 'f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7';
      }
*/
/*
      invoice.brandingThemeID = brandingid;

      // get the last invoice date and recurring period, also
      // calculate the days and months between the dates
      String recurring_period = account_product.Recurring_Period__c;
      System.debug('Recurring period: ' + recurring_period);

      date start_date = account_product.Start_Date__c;
      System.debug('Start date: ' + start_date);

      date end_date = account_product.End_Date__c;
      System.debug('End date: ' + end_date);

      date last_invoice_date = account_product.Last_Invoice_Date__c;
      System.debug('Last invoice date: ' + last_invoice_date);

      date today_date = date.today();
      System.debug('Today date: ' + today_date);

      Integer subscription_days = 0;
      Integer subscription_months = 0;
      if(start_date != null) {
        subscription_days = start_date.daysBetween(today_date);
        System.debug('Subscription days: ' + subscription_days);

        subscription_months = start_date.monthsBetween(today_date);
        System.debug('Subscription months: ' + subscription_months);
      }

      // let's create a line item for this product
      System.debug('Creating a new line item');
      sfxero.XeroLineItem line_item = new sfxero.XeroLineItem();
      line_item.description = account_product.Product_Number__c + ' - ' + account_product.Name;
      line_item.unitAmount = account_product.Product_Price__c;
      line_item.quantity = 1;
      line_item.lineAmount = account_product.Product_Price__c;
      System.debug('Creating a new line item: ' + line_item);

      // add this line item into invoice
      invoice.addLineItem(line_item);
      System.debug('Adding line item to this invoice:' + line_item);

      // since we will have one product per invoice, we also
      // save the price into the invoice totals
      invoice.total = account_product.Product_Price__c;

      // issued date should be exactly the end of current recurring period
      invoice.reference = String.valueOf(account.Unique_Id__c);
      invoice.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCREC;
      invoice.status = sfxero.XeroInvoice.XeroInvoiceStatus.DRAFT;
      invoice.lineAmountTypes = sfxero.XeroInvoice.XeroLineAmountType.INCLUSIVE;

      // append the invoice into the list of invoices
      System.debug('Adding invoice into the list: ' + invoice);
      invoices.add(invoice);
      System.debug('All Invoices list: ' + invoices);

      sfxero.XeroInvoiceResponse invoice_response;
      try {
        invoice_response = sfxero.XeroAPI.postInvoices(invoices, credentials);
        System.debug('Post Invoice Response:' + invoice_response);
      } catch (Exception e) {
            System.debug('Exception:' + e);
      }
    }
  }
*/

  WebService static WebServiceResultExcludeInvoice excludeInvoice(String invoice_number) {
    WebServiceResultExcludeInvoice return_result = new WebServiceResultExcludeInvoice();
    List<Invoice__c> invoices = [SELECT Id, Name, Account__c, Invoice_Number__c, Exclude_Invoice__c FROM Invoice__c WHERE Invoice__c.Invoice_Number__c =: invoice_number];
    List<Invoice_Exclude__c> excludes = [SELECT Id, Invoice_Number__c FROM Invoice_Exclude__c];

    if(invoices.size() > 0) {
      Invoice__c the_invoice = invoices[0];
      Boolean found = false;
      if(excludes.size() > 0) {
        for(Invoice_Exclude__c invoice_exclude : excludes) {
          if(invoice_exclude.Invoice_Number__c == the_invoice.Invoice_Number__c) {
            found = true;
          }
        }
      }

      if(found == false) {
        // if we can not find it in the list we ADD it into the list
        /*
        Invoice_Exclude__c invoice_exclude = new Invoice_Exclude__c();
        invoice_exclude.Name = the_invoice.Name;
        invoice_exclude.Invoice_Number__c = invoice_number;
        invoice_exclude.Account__c = the_invoice.Account__c;
        insert invoice_exclude;


        System.debug('This invoice has been ADDED into exclude list: ' + the_invoice);
        return_result.status = true;
        return_result.message = 'This invoice has been added into exclude list';
        */
      }
      else {
        return_result.status = true;
        return_result.message = 'This invoice is already in the exclude list';
      }

      // now we set ALL invoices with this number to be excluded
      for(Integer i = 0; i < invoices.size(); i++) {      
        invoices[i].Exclude_Invoice__c = true;
      }
      update invoices;
    }
    else {
      return_result.status = false;
      return_result.message = 'Can not find invoice with this number';
    }

    return return_result;
  }


  WebService static WebServiceResultIncludeInvoice includeInvoice(String invoice_number) {
    WebServiceResultIncludeInvoice return_result = new WebServiceResultIncludeInvoice();
    List<Invoice__c> invoices = [SELECT Id, Name, Account__c, Invoice_Number__c, Exclude_Invoice__c FROM Invoice__c WHERE Invoice__c.Invoice_Number__c =: invoice_number];
    List<Invoice_Exclude__c> excludes = [SELECT Id, Invoice_Number__c FROM Invoice_Exclude__c];

    if(invoices.size() > 0) {
      Invoice__c the_invoice = invoices[0];
      Boolean found = false;
      if(excludes.size() > 0) {
        for(Invoice_Exclude__c invoice_exclude : excludes) {
          if(invoice_exclude.Invoice_Number__c == the_invoice.Invoice_Number__c) {
            found = true;
            delete invoice_exclude;

            System.debug('This invoice has been ADDED into exclude list: ' + the_invoice);
            return_result.status = true;
            return_result.message = 'This invoice has been removed from exclude list';
          }
        }
      }

      if(found == false) {
        return_result.status = true;
        return_result.message = 'This invoice was not in exclude list';
      }

      // now we set ALL invoices with this number to be excluded
      for(Integer i = 0; i < invoices.size(); i++) {      
        invoices[i].Exclude_Invoice__c = false;
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
  public static void setInvoiceExcludeFlag() {
    // we loop the list of today's invoice
    List<Invoice_Batch__c> todaysBatches = [SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' AND Batch_Date__c =: Date.today()];
    /*
    if(todaysBatches.size() > 0) {
      Invoice_Batch__c todaysBatch = todaysBatches[0];
      // grab the list of invoices
      List<Invoice__c> invoices = [SELECT Id,Name,Payment_Batch__c,Payment_Message__c,Payment_Response__c,Account__c,Account_Product__c,Amount_Credited__c,Amount_Due__c,Amount_Paid__c,Due_Date__c,Invoice_Batch__c,Invoice_Number__c,Invoice_Total__c,Issue_Date__c,Payment_Option__c,Processed__c,Process_Message__c,Reference__c,Xero_Contact_Id__c,Xero_Invoice_Id__c, Exclude_Invoice__c FROM Invoice__c WHERE Invoice_Batch__c =: todaysBatch.Id];
      System.debug('All Invoices: ' + invoices);

      // grabthe list of excluded invoices
      List<Invoice_Exclude__c> invoices_exclude = [SELECT Invoice_Number__c FROM Invoice_Exclude__c];
      if(invoices_exclude.size() > 0) {
        // match them, loop over the invoice list and for each invoice
        // we loop the exclude list and match the invoice number. if
        // found a match, current invoice needs to be set as 'excluded'
            for(Integer i = 0; i < invoices.size(); i++) {
          System.debug('Updating Invoice: ' + invoices[i]);
          for(Invoice_Exclude__c invoice_exclude : invoices_exclude) {
            if(invoices[i].Invoice_Number__c == invoice_exclude.Invoice_Number__c) {
              invoices[i].Exclude_Invoice__c = true;
            }
          }
            }
      }

      update invoices;
    }
    */
  }
	

  /**
   * emailInvoices
   * this method is used to send a single invoice to the customer. it grabs
   * the invoice number from param, but since salesforce invoice object does
   * not have the complete details, the method has to fetch the actual invoice
   * from Xero using invoice number.
   * It then 'builds' an invoice email object using the data from Xero invoice
   * and use it to send the email.
   *
   * @param String invoice_number salesforce invoice object
   */
/*
  public static void emailInvoices(String invoice_number) {
    // prepare credentials for xero callouts
    sfxero.XeroCredentials credentials = new sfxero.XeroCredentials(Invoice.consumerkey, '', Invoice.privatekey);
//    credentials.consumerKey  = Invoice.consumerkey;
//    credentials.privateKey  = Invoice.privatekey;

    // creating the list of invoices and invoices sent
    List<Invoice__c> invoices = new List<Invoice__c>();
    Invoice__c the_invoice = new Invoice__c();
    List<Invoice_Sent__c> invoices_sent = new List<Invoice_Sent__c>();

    // creating the list of emails
    List<Messaging.Email> emails = new List<Messaging.Email>();

    sfxero.XeroInvoiceResponse xero_invoice_response;
    invoices = [SELECT Id, Name, Invoice_Number__c FROM Invoice__c WHERE Invoice__c.Invoice_Number__c =: invoice_number];

    if(invoices.size() > 0) {
      the_invoice = invoices[0];

      // to avoid xero calls at test, we create 'fake' invoices and xero response
      if(isTest) {
        sfxero.XeroInvoice xero_invoice = new sfxero.XeroInvoice();
        List<sfxero.XeroInvoice> xero_invoices = new List<sfxero.XeroInvoice>();

        sfxero.XeroLineItem xero_lineItem = new sfxero.XeroLineItem();
        List<sfxero.XeroLineItem> xero_lineItems = new List<sfxero.XeroLineItem>();

        sfxero.XeroContact xero_contact = new sfxero.XeroContact();

        sfxero.XeroContact.XeroAddress xero_address = new sfxero.XeroContact.XeroAddress();
        List<sfxero.XeroContact.XeroAddress> xero_addresses = new List<sfxero.XeroContact.XeroAddress>();

        sfxero.XeroContact.XeroPhone xero_phone = new sfxero.XeroContact.XeroPhone();
        List<sfxero.XeroContact.XeroPhone> xero_phones = new List<sfxero.XeroContact.XeroPhone>();

        xero_phone.areaCode = '07';
        xero_phone.countryCode = '+61';
        xero_phone.phoneNumber = '33334444';
        xero_phone.phoneType = sfxero.XeroContact.XeroPhoneType.DEFAULTPHONE;
        xero_phones.add(xero_phone);
        xero_address.addressLine1 = 'addressLine1';
        xero_address.addressLine2 = 'addressLine2';
        xero_address.addressLine3 = 'addressLine3';
        xero_address.addressLine4 = 'addressLine4';
        xero_address.addressType = sfxero.XeroContact.XeroAddressType.STREET;
        xero_address.city = 'city';
        xero_address.country = 'country';
        xero_address.postalCode = 'postalCode';
        xero_address.region = 'region';
        xero_addresses.add(xero_address);

        xero_contact.phones = xero_phones;
        xero_contact.addresses = xero_addresses;

        xero_lineItem.description = '1234 - sdfsadfasfdsdfsadf';
        xero_lineItem.quantity = 1.0;
        xero_lineItem.lineAmount = 5.00;
        xero_lineItem.unitAmount = 5.00;
        xero_lineItems.add(xero_lineItem);

        xero_invoice.reference = 'ACC00123';
        xero_invoice.lineItems = xero_lineItems;
        xero_invoice.contact = xero_contact;
        xero_invoice.total = 50.50;
        xero_invoice.issuedDate = date.newinstance(2010, 01, 01);
        xero_invoice.dueDate = date.newinstance(2010, 01, 08);
        xero_invoices.add(xero_invoice);

        xero_invoice_response = new sfxero.XeroInvoiceResponse();
        xero_invoice_response.httpResponseCode = 200;
        xero_invoice_response.status = 'OK';
        xero_invoice_response.invoices = xero_invoices;
      } else {
        try {
          xero_invoice_response = sfxero.XeroAPI.getInvoiceByNumber(credentials, the_invoice.Invoice_Number__c);
          System.debug('INVOICE_RESPONSE: ' + xero_invoice_response);
        }
        catch(Exception e) {
          System.debug('Exception: ' + e);
        }
      }

      // if there is good response and status we can be sure that we get
      // correct result
      if(xero_invoice_response.httpResponseCode == 200 && xero_invoice_response.status == 'OK') {
        // prepare all necessary account fields for email
        String contact_name;
        String business_name;
        String email_address;
        String reference;
        String address1;
        String address2;
        String address3;
        String address4;
        String contact_address = '';
        String account_number;
        String city;
        String region;
        String country;
        String postalCode;
        String subtotal;
        String tax;
        String total;
        String amountPaid;
        String amountDue;
        String issuedDate;
        String dueDate;

        // our company detail fields
        String company_name;
        String company_address;
        String company_logo;
        String company_phone;


        List<sfxero.XeroLineItem> line_items = new List<sfxero.XeroLineItem>();

        sfxero.XeroInvoice xero_invoice  = xero_invoice_response.invoices[0];
        account_number  = xero_invoice.reference;
        // if there is no account number, we are trying to get it from somewhere
        // else other than the xero invoice itself. however it is not as easy as
        // it sounds since the reference (account number) is the only field that
        // connects a xero invoice to a salesforce account. we are in trouble.
        // one idea is to use the email address from inside xero contact from
        // this curent invoice, and use it to perform search for the correct
        // salesforce account or contact. this sounds acceptable but somewhat a
        // bit lame since depending on email address can be quite confusing at
        // search (multiple emails), but we don't have any choice for now.
        // dumb@ss !! it turns out that we are looping each Invoice__c and that
        // class has account id in it which we can use to fetch its unique id.
        if(account_number == null) {
          // get the account id from current sf invoice
          Id account_id = the_invoice.Account__c;

          // fetch the account along with the unique id
          Account account;
          account = [SELECT Id, Unique_Id__c FROM Account WHERE Id =: account_id];

          // get the account number (which should be the reference)
          account_number = account.Unique_Id__c;
        }

        sfxero.XeroContact xero_contact  = xero_invoice.contact;

        contact_name  = xero_contact.firstName + ' ' + xero_contact.lastName;
        business_name  = xero_contact.orgName;
        line_items    = xero_invoice.lineItems;
        email_address  = xero_contact.emailAddress;

        for(sfxero.XeroContact.XeroAddress xero_address : xero_contact.addresses) {
          if(String.valueOf(xero_address.addressType) == 'STREET') {
            address1  = String.valueOf(xero_address.addressLine1);
            address2  = String.valueOf(xero_address.addressLine2);
            address3  = String.valueOf(xero_address.addressLine3);
            address4  = String.valueOf(xero_address.addressLine4);
            city    = String.valueOf(xero_address.city);
            region    = String.valueOf(xero_address.region);
            country    = String.valueOf(xero_address.country);
            postalCode  = String.valueOf(xero_address.postalCode);
          }
        }

        // we build the address from separate lines
        if(address1.length() > 0) {
          contact_address += address1;
        }
        if(address2.length() > 0) {
          contact_address += '\n<br />' + address2;
        }
        if(address3.length() > 0) {
          contact_address += '\n<br />' + address3;
        }
        if(address4.length() > 0) {
          contact_address += '\n<br />' + address4;
        }
        if(city.length() > 0) {
          contact_address += '\n<br />' + city;
        }
        if(region.length() > 0) {
          // if city and region both exist, we append region BEHIND
          // city
          if(city.length() > 0) {
            contact_address += ', ' + region;
          }
          else {
            contact_address += '\n<br />' + region;
          }
        }
        if(postalCode.length() > 0) {
          contact_address += '\n<br />' + postalCode;
        }

        subtotal      = String.valueOf(xero_invoice.subTotal);
        tax          = String.valueOf(xero_invoice.totalTax);
        total        = String.valueOf(xero_invoice.total);
        amountPaid      = String.valueOf(xero_invoice.amountPaid);
        amountDue      = String.valueOf(xero_invoice.amountDue);

        issuedDate      = String.valueOf(xero_invoice.issuedDate.day()) + '/' + String.valueOf(xero_invoice.issuedDate.month()) + '/' + String.valueOf(xero_invoice.issuedDate.year());
        dueDate        = String.valueOf(xero_invoice.dueDate.day()) + '/' + String.valueOf(xero_invoice.dueDate.month()) + '/' + String.valueOf(xero_invoice.dueDate.year());

        // get the email template and fetch the template content string
        EmailTemplate email_template = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Invoice'];
        String template_content = email_template.HtmlValue;
        String email_content = template_content;

        // start replacing the content with real values
        if(account_number != null) {
          email_content = email_content.replace('[account-number]', account_number);
        }
        // set the business name
        if(business_name != null) {
          email_content = email_content.replace('[contact-business-name]', business_name);
        }
        // if business name is not available, we use account name
        else {
          email_content = email_content.replace('[contact-business-name]', contact_name);
        }
        if(contact_address != null) {
          email_content = email_content.replace('[contact-address]', contact_address);
        }

        email_content = email_content.replace('[invoice-number]', the_invoice.Invoice_Number__c);
        email_content = email_content.replace('[invoice-issue-date]', issuedDate);
        email_content = email_content.replace('[invoice-due-date]', dueDate);

        email_content = email_content.replace('[invoice-subtotal]', ((subtotal != null) ? subtotal : '0.00'));
        email_content = email_content.replace('[invoice-tax]', ((tax != null) ? tax : '0.00'));
        email_content = email_content.replace('[invoice-total]', ((total != null) ? total : '0.00'));
        email_content = email_content.replace('[invoice-amount-paid]', ((amountPaid != null) ? amountPaid : '0.00'));
        email_content = email_content.replace('[invoice-amount-due]', ((amountDue != null) ? amountDue : '0.00'));

        // now we are adding the line items
        // first we should fetch the block template for line items
        // from database, which we will use for individual line item
        EmailTemplate line_item_template = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Invoice_Line_Item'];
        String line_item_content = line_item_template.HtmlValue;
        String line_items_string = '';

        // get the actual line items and loop them
        if(line_items.size() > 0) {
          for(sfxero.XeroLineItem line_item : line_items) {
            // use the line item block template, replace the placeholders
            // with the actual values from this line item
            String line_item_string = line_item_content;
            line_item_string = line_item_string.replace('[line-item-description]', line_item.description);
            line_item_string = line_item_string.replace('[line-item-amount]', String.valueOf(line_item.lineAmount));

            // and append this line item string to whole collection
            line_items_string += line_item_string;
          }

          // and replace the invoice content with the block content of
          // line items
          email_content = email_content.replace('[line-items]', line_items_string);
        }

        Id company_id;
        // sponsoredlinx
        if(xero_invoice.brandingThemeID == 'f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7') {
          company_id = 'a0C90000002PU4f';
        }
        // getmoretraffic
        else if(xero_invoice.brandingThemeID == 'ef12522f-ebaa-40a9-ac6c-9875e65e71da') {
          company_id = 'a0C90000002PU4V';
        }
        // crankit
        else if(xero_invoice.brandingThemeID == '70516ac3-9e70-4b6c-b6ca-a70282ba42ad') {
          company_id = 'a0C90000002PU4L';
        }
        // bjbglobal
        else if(xero_invoice.brandingThemeID == '5359048f-59b8-4093-9197-e63a5e0e6b0e') {
          company_id = 'a0C90000002PU4Q';
        }
        // default, set to sponsoredlinx
        else {
          company_id = 'a0C90000002PU4f';
        }

        // first we get the company details using the id,
        // then we extract the info into strings
        Company__c company  = [Select Business_Name__c, Address__c, Phone__c, Logo_Code__c From Company__c WHERE Id =: company_id];
        company_name    = company.Business_Name__c;
        company_address    = company.Address__c;
        company_phone    = company.Phone__c;
        company_logo    = company.Logo_Code__c;
        String company_abn  = '18 851 640 813';

        // then, we perform the remaining replacement on company details
        email_content = email_content.replace('[company-name]', company_name);
        email_content = email_content.replace('[company-address]', company_address);
        email_content = email_content.replace('[company-logo]', company_logo);
        email_content = email_content.replace('[company-phone]', company_phone);
        email_content = email_content.replace('[company-abn]', company_abn);

        // all done, we start setting the default email fields
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        String[] toAddresses  = new String[] { email_address };
        String[] toAddresses  = new String[] { 'krishna.silalahi@bjbglobal.com.au' };
//        String[] bccAddresses = new String[] { 'accounts@sponsoredlinx.com.au' };
        mail.setToAddresses(toAddresses);
//        mail.setBccAddresses(bccAddresses);
        mail.setReplyTo('accounts@sponsoredlinx.com.au');
        mail.setSenderDisplayName(company_name + ' Account');
        mail.setSubject(email_template.Subject + ' - ' + the_invoice.Invoice_Number__c);
        mail.setUseSignature(false);

        // and set the email content
        mail.setHtmlBody(email_content);

        // and append this email to the list
        emails.add(mail);

        // and also add this into the list of sent invoices
        Invoice_Sent__c invoice_sent = new Invoice_Sent__c();
        invoice_sent.Name = the_invoice.Name;
        invoice_sent.Invoice_Number__c = the_invoice.Invoice_Number__c;
        invoice_sent.Email__c = String.valueOf(email_address);
        invoices_sent.add(invoice_sent);
      }
      // the result of invoice fetch from Xero failed, we only print
      // system debug error since we shouldn't break the for loop
      else {
        System.debug('Invoice with that number can not be found in Xero: ' + the_invoice.Invoice_Number__c);
      }
    }


    // finally we can send all the emails
    Messaging.SendEmailResult[] r;
    try {
      r = Messaging.sendEmail(emails);
      System.debug('Send email result: ' + r);

      // finally, we can save the list of all invoices sent
      upsert invoices_sent;
    }
    catch(Exception e) {
      System.debug('Send email result: ' + r);
    }
  }
*/

/*
  static testMethod void addInvoiceFromProductTest() {
    Test.startTest();

    Account account            = new Account();
    account.Name            = 'Test Account';
    account.Company__c          = 'SponsoredLinX';
    account.username__c          = 'test@test.com';
    account.password__c          = 'test';
    account.Xero_Sync_ID__c        = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    insert account;

    Contact contact            = new Contact();
    contact.AccountId          = account.Id;
    contact.title            = 'Billing';
    contact.FirstName          = 'bob';
    contact.LastName          = 'down';
    contact.Email            = 'down@bob.com';
    contact.MailingStreet        = 'sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
    contact.MailingCity          = 'brisbane';
    contact.MailingPostalCode      = '4500';
    contact.MailingState        = 'Queensland';
    contact.MailingCountry        = 'Australia';
    insert contact;

    Account_Product__c account_product    = new Account_Product__c();
    account_product.Account__c        = account.id;
    account_product.Company__c        = 'a0C90000002PU4f'; // linked to sponsoredlinx
    account_product.Name          = 'Test Product';
    account_product.Product_Price__c    = 10.00;
    account_product.Product_Status__c    = 'Active';
    account_product.Recurring_Frequency__c  = 1;
    account_product.Start_Date__c      = date.newinstance(2010, 12, 1); 
    account_product.Last_Invoice_Date__c  = date.newinstance(2010, 12, 1);
    account_product.Recurring_Period__c    = 'Weekly'; 
    insert account_product;

    Invoice.addInvoiceFromProduct( account_product.Id );
    Test.stopTest();
  }
*/
  public static testMethod void excludeInvoiceTest() {
    Test.startTest();
    
    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
    insert acc;

    List<Account_Product__c> testProducts = new List<Account_Product__c>();
    for(Integer i=0;i<1;i++) {                              
        Account_Product__c item = new Account_Product__c(Name ='Super Charged Management'+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Traditional Products').getRecordTypeId());
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
    invoice1.Amount_Due__c = 4.50 ;
    invoice1.Status__c = 'AUTHORISED';
    insert invoice1;

    Invoice_Exclude__c exclude = new Invoice_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    Invoice.excludeInvoice(invoice1.Invoice_Number__c);
    Test.stopTest();
  }

  public static testMethod void excludeInvoiceErrorTest() {
    Test.startTest();
    
    Account acc = new Account(Name ='TestAccount2', username__c='TestAccount2', password__c='TestAccount2', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
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

    Invoice_Exclude__c exclude = new Invoice_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    Invoice.excludeInvoice('fakeinvoicenumber');
    Test.stopTest();
  }

  public static testMethod void includeInvoiceTest() {
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
    insert invoice1;

    Invoice_Exclude__c exclude = new Invoice_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    Invoice.includeInvoice(invoice1.Invoice_Number__c);
    Test.stopTest();
  }

  public static testMethod void setInvoiceExcludeFlagTest() {
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


	
    Invoice_Batch__c batch1 = new Invoice_Batch__c();
    batch1.Name = '';
    batch1.Batch_Date__c = Date.today();
    batch1.Batch_Type__c = 'Invoices';
//SELECT Id,Name,Batch_Date__c,Batch_Number__c,Batch_Processed__c,status__c,Batch_Type__c FROM Invoice_Batch__c WHERE Batch_Type__c = 'Invoices' AND Batch_Date__c =: Date.today()

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
    invoice1.Exclude_Invoice__c = true;
    insert invoice1;

    Invoice_Exclude__c exclude = new Invoice_Exclude__c();
    exclude.name = 'test invoice';
    exclude.Invoice_Number__c = 'test--001';
    exclude.Account__c = null;
    exclude.Email__c = null;
    insert exclude;

    Invoice.setInvoiceExcludeFlag();
    Test.stopTest();
  }

/*
  public static testMethod void emailInvoicesTest1() {
    Test.startTest();

    Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08');
    insert account;
    Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
    insert contact;

    Invoice__c invoice1 = new Invoice__c();
    invoice1.name = 'test invoice';
    invoice1.Payment_Option__c = 'Other';
    invoice1.Invoice_Number__c = 'test--001';
    invoice1.Invoice_Batch__c = null;
    invoice1.Payment_Batch__c = null;
    invoice1.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    invoice1.Account__c = null;
    invoice1.Amount_Due__c = 4.50;

    Invoice__c invoice2 = new Invoice__c();
    invoice2.name = 'test invoice';
    invoice2.Payment_Option__c = 'Other';
    invoice2.Invoice_Number__c = 'test--002';
    invoice2.Invoice_Batch__c = null;
    invoice2.Payment_Batch__c = null;
    invoice2.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
    invoice2.Account__c = account.Id;
    invoice2.Amount_Due__c = 3.50;

    Invoice__c invoice3 = new Invoice__c();
    invoice3.name = 'test invoice';
    invoice3.Payment_Option__c = 'Other';
    invoice3.Invoice_Number__c = 'test--003';
    invoice3.Invoice_Batch__c = null;
    invoice3.Payment_Batch__c = null;
    invoice3.Xero_Contact_Id__c = 'E786047F-6FF3-4D62-B28D-6100D373AA08';
    invoice3.Account__c = account.Id;
    invoice3.Amount_Due__c = 1.50;

    insert invoice1;
    insert invoice2;
    insert invoice3;

//    Invoice email = new Invoice();
    Invoice.isTest = true;
//    email.emailInvoices( invoice1 );
    Invoice.emailInvoices( invoice1.Invoice_Number__c );
    Test.stopTest();
  }
*/
}