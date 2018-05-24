global class SLXWebService {
    
    global boolean TestCases = false;
    
    public class InvalidParamsException extends Exception {}

    global class WebServiceResultAccountId {
        WebService Boolean status;
        WebService String result;
        WebService String message;
    }
    global class WebServiceResultInvoiceList {
        WebService Boolean status;
        WebService List<Invoice__c> result;
        WebService String message;
    }
    global class WebServiceResultSignupList {
        WebService Boolean status;
        WebService List<Sign_Up__c> result;
        WebService String message;
    }
    global class WebServiceResultExcludeList {
        WebService Boolean status;
        WebService List<Invoice_Exclude__c> result;
        WebService String message;
    }
    global class WebServiceResultAccountDetails {
        WebService Boolean status;
        WebService String Name;
        WebService String BusinessName;
        WebService Boolean SendInvoice;
        WebService String FirstName;
        WebService String LastName;
        WebService String Email;
        WebService String Address;
        WebService String City;
        WebService String State;
        WebService String Country;
        WebService String PostalCode;
        WebService String CompanyName;
        WebService String CompanyAddress;
        WebService String CompanyLogo;
        WebService String CompanyPhone;
        WebService String message;
    }

    global class WebServiceResultBoolean {
        WebService Boolean status;
        WebService Boolean result;
        WebService String message;
    }
    global class WebServiceResultAccount {
        WebService Boolean status;
        WebService Account result;
        WebService String message;
    }
    global class WebServiceResultListAccount {
        WebService Boolean status;
        WebService List<Account> result;
        WebService String message;
    }
    global class WebServiceResultListContact {
        WebService Boolean status;
        WebService List<Contact> result;
        WebService String message;
    }
    global class WebServiceResultListGroupMember {
        WebService Boolean status;
        WebService List<GroupMember> result;
        WebService String message;
    }
    global class WebServiceResultListGroup {
        WebService Boolean status;
        WebService List<Group> result;
        WebService String message;
    }
    global class WebServiceResultUser {
        WebService Boolean status;
        WebService User result;
        WebService String message;
    }
    global class WebServiceResultEricaUser {
        WebService Boolean status;
        WebService Mcc_login__c result;
        WebService String message;
    }
    global class WebServiceResultActivityReport {
        WebService Boolean status;
        WebService String message;
    }
    global class WebServiceResultSendInvoice {
        WebService Boolean status;
        WebService String message;      
    }
    
    WebService static WebServiceResultAccountId getAccountIdFromReference(String reference) {
        WebServiceResultAccountId return_result = new WebServiceResultAccountId();

        List<Account> accounts = [SELECT Id FROM Account WHERE Unique_Id__c =: reference];
        Account account;

        if(accounts.size() > 0) {
            account = accounts[0];

            return_result.status = true;
            return_result.result = account.Id;
            return_result.message = 'Account Id is fetched';
        }
        else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Unable to find account with that reference';
        }

        return return_result;
    }

    WebService static WebServiceResultInvoiceList getYesterdayInvoiceList() {
        WebServiceResultInvoiceList return_result = new WebServiceResultInvoiceList();

        List<Invoice__c> invoices = [
            SELECT 
                Id, 
                Name, 
                Payment_Batch__c, 
                Payment_Message__c, 
                Payment_Response__c, 
                Account__c, 
                Amex__c, 
                Account_Product__c, 
                Account_Product__r.Name, 
                Account_Product__r.Product_Number__c, 
                Account_Product__r.Description__c, 
                Amount_Credited__c, Amount_Due__c, 
                Amount_Paid__c, 
                Due_Date__c, 
                Invoice_Batch__c, 
                Invoice_Number__c, 
                Invoice_Total__c, 
                Issue_Date__c, 
                Payment_Option__c, 
                Processed__c, 
                Process_Message__c, 
                Reference__c, 
                Xero_Contact_Id__c, 
                Xero_Invoice_Id__c 
            FROM 
                Invoice__c 
            WHERE 
                Invoice__c.Issue_Date__c = YESTERDAY
            AND 
                Invoice__c.Exclude_Invoice__c = false 
            AND 
                Invoice__c.Account__r.Send_Invoice__c = true 
            ORDER BY 
                Issue_Date__c DESC];

        if(invoices.size() > 0) {
            return_result.status = true;
            return_result.result = invoices;
            return_result.message = 'Successfully fetched the list of invoices';
        }
        else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Can not find any invoice from the batch';
        }

        return return_result;
    }

/*
OLD VERSION of the above function, using batches instead of Invoice__c.Issue_Date__c = YESTERDAY
    WebService static WebServiceResultInvoiceList getYesterdayInvoiceList() {
        WebServiceResultInvoiceList return_result = new WebServiceResultInvoiceList();
        List<Invoice_Batch__c> today_batches = [
            SELECT 
                Id, 
                Batch_Date__c, 
                Batch_Error_Response__c, 
                Batch_Number__c, 
                Batch_Processed__c, 
                Batch_Records__c, 
                status__c, 
                Batch_Type__c 
            FROM 
                Invoice_Batch__c 
            WHERE 
                Invoice_Batch__c.Batch_Date__c = yesterday 
            AND 
                Invoice_Batch__c.Batch_Type__c = 'Invoices' 
            and 
                Name Like '%Today%'];

        List<id> batch_ids = new List<id>();
        
        if(today_batches.size() > 0) {
            for(Invoice_Batch__c batch : today_batches) {
                batch_ids.add(batch.id);
            }

            List<Invoice__c> invoices = [
                SELECT 
                    Id, 
                    Name, 
                    Payment_Batch__c, 
                    Payment_Message__c, 
                    Payment_Response__c, 
                    Account__c, 
                    Amex__c, 
                    Account_Product__c, 
                    Account_Product__r.Name, 
                    Account_Product__r.Product_Number__c, 
                    Account_Product__r.Description__c, 
                    Amount_Credited__c, Amount_Due__c, 
                    Amount_Paid__c, 
                    Due_Date__c, 
                    Invoice_Batch__c, 
                    Invoice_Number__c, 
                    Invoice_Total__c, 
                    Issue_Date__c, 
                    Payment_Option__c, 
                    Processed__c, 
                    Process_Message__c, 
                    Reference__c, 
                    Xero_Contact_Id__c, 
                    Xero_Invoice_Id__c 
                FROM 
                    Invoice__c 
                WHERE 
                    Invoice__c.Invoice_Batch__c in :batch_ids 
                AND 
                    Invoice__c.Exclude_Invoice__c = false 
                AND 
                    Invoice__c.Account__r.Send_Invoice__c = true 
                ORDER BY 
                    Issue_Date__c DESC];

            if(invoices.size() > 0) {
                return_result.status = true;
                return_result.result = invoices;
                return_result.message = 'Successfully fetched the list of invoices';
            }
            else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Can not find any invoice from the batch';
            }
        }
        else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Failed finding a correct batch';
        }

        return return_result;
    }
    */

    WebService static WebServiceResultInvoiceList getTodayInvoiceList() {
        WebServiceResultInvoiceList return_result = new WebServiceResultInvoiceList();

        List<Invoice__c> invoices = [
            SELECT 
                Id, 
                Name, 
                Amex__c, 
                Payment_Batch__c, 
                Payment_Message__c, 
                Payment_Response__c, 
                Account__c, 
                Account_Product__c, 
                Account_Product__r.Name, 
                Account_Product__r.Product_Number__c, 
                Account_Product__r.Description__c, 
                Account_Product__r.Recurring_Period__c,
                Account_Product__r.SLX_Product__r.company_name__c,
                Account__r.Website, 
                Amount_Credited__c, 
                Amount_Due__c, 
                Amount_Paid__c, 
                Due_Date__c, 
                Invoice_Batch__c, 
                Invoice_Number__c, 
                Invoice_Total__c, 
                Issue_Date__c, 
                Payment_Option__c, 
                Processed__c, 
                Process_Message__c, 
                Reference__c,
                (select 
                    Payment_Date__c, 
                    Payment_Type__c, 
                    Payment_Amount__c,
                    Payment_Option__c 
                from 
                    Payments__r
                Order By
                    Payment_Date__c ASC)
            FROM 
                Invoice__c 
            WHERE 
                Invoice__c.Issue_Date__c = TODAY
            AND 
                Invoice__c.Exclude_Invoice__c = false 
            AND 
                (Invoice__c.Account__r.Send_Invoice__c = true 
                OR  
                Invoice__c.Payment_Option__c = 'Other'
                OR  
                Invoice__c.Payment_Option__c = 'EFT')
            AND
            	Invoice__c.Status__c != 'VOID'
            AND 
            	Invoice__c.Status__c != 'NO CHARGE'
            ORDER BY 
                Issue_Date__c DESC];

        if(invoices.size() > 0) {
            return_result.status = true;
            return_result.result = invoices;
            return_result.message = 'Successfully fetched the list of invoices';
        } else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Can not find any invoice from the batch';
        }

        return return_result;
    }

/*
OLD VERSION of the above function, using batches instead of Invoice__c.Issue_Date__c = TODAY
    WebService static WebServiceResultInvoiceList getTodayInvoiceList() {
        WebServiceResultInvoiceList return_result = new WebServiceResultInvoiceList();
        System.debug('test1');
        List<Invoice_Batch__c> today_batches = [
            SELECT 
                Id, 
                Batch_Date__c, 
                Batch_Error_Response__c, 
                Batch_Number__c, 
                Batch_Processed__c, 
                Batch_Records__c, 
                status__c, 
                Batch_Type__c 
            FROM 
                Invoice_Batch__c 
            WHERE 
                Invoice_Batch__c.Batch_Date__c =: Date.today() 
            AND 
                Invoice_Batch__c.Batch_Type__c = 'Invoices' 
            AND 
                Name Like '%Today%'];
                
        List<id> batch_ids = new List<id>();
                        
        if(today_batches.size() > 0) {
            for(Invoice_Batch__c batch : today_batches) {
                batch_ids.add(batch.id);
            }

            List<Invoice__c> invoices = [
                SELECT 
                    Id, 
                    Name, 
                    Amex__c, 
                    Payment_Batch__c, 
                    Payment_Message__c, 
                    Payment_Response__c, 
                    Account__c, 
                    Account_Product__c, 
                    Account_Product__r.Name, 
                    Account_Product__r.Product_Number__c, 
                    Account_Product__r.Description__c, 
                    Account_Product__r.Recurring_Period__c,
                    Account_Product__r.SLX_Product__r.company_name__c,
                    Account__r.Website, 
                    Amount_Credited__c, 
                    Amount_Due__c, 
                    Amount_Paid__c, 
                    Due_Date__c, 
                    Invoice_Batch__c, 
                    Invoice_Number__c, 
                    Invoice_Total__c, 
                    Issue_Date__c, 
                    Payment_Option__c, 
                    Processed__c, 
                    Process_Message__c, 
                    Reference__c,
                    (select 
                        Payment_Date__c, 
                        Payment_Type__c, 
                        Payment_Amount__c,
                        Payment_Option__c 
                    from 
                        Payments__r
                    Order By
                        Payment_Date__c ASC)
                FROM 
                    Invoice__c 
                WHERE 
                    Invoice__c.Invoice_Batch__c in :batch_ids 
                AND 
                    Invoice__c.Exclude_Invoice__c = false 
                AND 
                    (Invoice__c.Account__r.Send_Invoice__c = true 
                    OR  
                    Invoice__c.Payment_Option__c = 'Other')
                ORDER BY 
                    Issue_Date__c DESC];

            if(invoices.size() > 0) {
                return_result.status = true;
                return_result.result = invoices;
                return_result.message = 'Successfully fetched the list of invoices';
            } else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Can not find any invoice from the batch';
            }
        } else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Failed finding a correct batch';
        }

        return return_result;
    }
*/

    WebService static WebServiceResultSignupList getYesterdaySignupList() {
        WebServiceResultSignupList return_result = new WebServiceResultSignupList();

        List<Sign_Up__c> yesterday_signups = [SELECT Name, Invoiceno__c, Signup_Date__c, CreatedDate, Account__c, Product_Type__c, Product_Company__c FROM Sign_Up__c WHERE CreatedDate = YESTERDAY AND Invoiceno__c != ''];

        if(yesterday_signups.size() > 0) {
            return_result.status = true;
            return_result.result = yesterday_signups;
            return_result.message = 'Successfully fetched the list of yesterday\'s signups';
        }
        else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Can not find any signup from yesterday';
        }

        return return_result;
    }


    WebService static WebServiceResultExcludeList getExcludeInvoiceList() {
        WebServiceResultExcludeList return_result = new WebServiceResultExcludeList();

        List<Invoice_Exclude__c> excludes = [SELECT Id, Invoice_Number__c  FROM Invoice_Exclude__c];

        if(excludes.size() > 0) {
            return_result.status = true;
            return_result.result = excludes;
            return_result.message = 'Successfully fetched the list of excluded invoices';
        }
        else {
            return_result.status = false;
            return_result.result = null;
            return_result.message = 'Can not find any invoice inside exclude list';
        }
        return return_result;
    }


    WebService static WebServiceResultAccountDetails getAccountDetails(Id account_id, String branding_theme_id) {
        WebServiceResultAccountDetails return_result = new WebServiceResultAccountDetails();
        List<Account> accounts = [SELECT Id, Name, Company__c, Send_Invoice__c FROM Account WHERE Account.Id =: account_id];
        System.debug('Accounts:' + accounts);
        Account account;
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode FROM Contact WHERE Contact.AccountId =: account_id AND Contact.Title = 'Billing'];
        System.debug('Contacts:' + contacts);
        Contact contact;
        // default company to sponsoredlinx
        if(branding_theme_id == '' || branding_theme_id == null) {
            branding_theme_id = 'f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7';
        }
        List<Company__c> companies = [SELECT Id, Address__c, Business_Name__c, Email__c, Logo_Code__c, Phone__c FROM Company__c WHERE Company__c.Branding_Theme_Id__c =: branding_theme_id];
        System.debug('Companies:' + companies);
        Company__c company;

        if(accounts.size() == 0) {
            return_result.status = false;
            return_result.message = 'Can not find the account: ' + account_id;
            return return_result;
        }
        else if(contacts.size() == 0) {
            return_result.status = false;
            return_result.message = 'Can not find a billing contact associated with account: ' + account_id;
            return return_result;
        }
        else if(companies.size() == 0) {
            return_result.status = false;
            return_result.message = 'Can not find a company associated with branding id: ' + branding_theme_id;
            return return_result;
        }
        else {
            account = accounts[0];
            contact = contacts[0];
            company = companies[0];

            return_result.status = true;
            return_result.Name = account.Name;
            return_result.BusinessName = account.Company__c;
            return_result.SendInvoice = account.Send_Invoice__c;
            return_result.FirstName = contact.FirstName;
            return_result.LastName = contact.LastName;
            return_result.Email = contact.Email;
            return_result.Address = contact.MailingStreet;
            return_result.City = contact.MailingCity;
            return_result.State = contact.MailingState;
            return_result.Country = contact.MailingCountry;
            return_result.PostalCode = contact.MailingPostalCode;
            return_result.CompanyName = company.Business_Name__c;
            return_result.CompanyAddress = company.Address__c;
            return_result.CompanyLogo = company.Logo_Code__c;
            return_result.CompanyPhone = company.Phone__c;
            return_result.message = 'Successfully fetched all necessary details';
            System.debug('return_result:' + return_result);
            return return_result;
        }

        return return_result;
    }


    /**
    *   Fetch account's details
    *   @param Id userId
    *   @return Account
    */
    WebService static WebServiceResultAccount getAccountDetailsByUserId(String userId) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            Account[] accounts = [SELECT Id, Name, username__c, user_id__c, Account.Owner.FirstName, Account.Owner.LastName, Account.Owner.Email, Account.Owner.Phone, Account.Owner.Extension, (SELECT Id, Name, FirstName, LastName, Email, Title FROM Contacts), (SELECT Id, Name, Description__c, Product_Number__c, Product_Package__c, Product_Price__c, Product_Status__c, Recurring_Frequency__c, Recurring_Period__c FROM Account_Products__r) FROM Account WHERE user_id__c =: userId];

            if(accounts.size() > 0) {
                Account account = accounts[0];

                return_result.status = true;
                return_result.message = 'Account successfully found';
                return_result.result = account;
            } else {
                return_result.status = false;
                return_result.message = 'Account not found';
                return_result.result = null;
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Account not found';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }


    /**
    *   Fetch account's details
    *   @param Id accountId
    *   @return Account
    */
    WebService static WebServiceResultAccount getAccountDetailsByAccountId(String accountId) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            Account[] accounts = [SELECT Id, Name, username__c, user_id__c, Account.Owner.FirstName, Account.Owner.LastName, Account.Owner.Email, Account.Owner.Phone, Account.Owner.Extension, (SELECT Id, Name, FirstName, LastName, Email, Title FROM Contacts), (SELECT Id, Name, Description__c, Product_Number__c, Product_Package__c, Product_Price__c, Product_Status__c, Recurring_Frequency__c, Recurring_Period__c, Adwords_Email__c, Adwords_ID__c, Start_Date__c, End_Date__c FROM Account_Products__r) FROM Account WHERE Id =: accountId];

            if(accounts.size() > 0) {
                Account account = accounts[0];

                return_result.status = true;
                return_result.message = 'Account successfully found';
                return_result.result = account;
            } else {
                return_result.status = false;
                return_result.message = 'Account not found';
                return_result.result = null;
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Account not found';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }
    
    
      /**
    *   Fetch account's credit card details (For Eway processment)
    *   @param Id accountId
    *   @return Account
    */
    WebService static WebServiceResultAccount getCreditCardDetailsByAccountId(String accountId) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            Account[] accounts = [SELECT Id, Name, Name_On_Card__c,
              Card_Number__c,
              Card_Month_Expiry__c,
              Unique_Id__c,
              Card_Year_Expiry__c,
              Card_CVN__c, 
            (SELECT Id, Name, FirstName, LastName, Email, Title FROM Contacts Where Title = 'Billing') 
          FROM Account WHERE Id =: accountId];

            if(accounts.size() > 0) {
                Account account = accounts[0];

                return_result.status = true;
                return_result.message = 'Account successfully found';
                return_result.result = account;
            } else {
                return_result.status = false;
                return_result.message = 'Account not found';
                return_result.result = null;
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Account not found';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }


    /**
    *   Fetch account's details
    *   @param Id username
    *   @return Account
    */
    WebService static WebServiceResultAccount getAccountDetailsByUsername(String username) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            Account[] accounts = [SELECT Id, Name, username__c, password__c, user_id__c, Account.Owner.FirstName, Account.Owner.LastName, Account.Owner.Email, Account.Owner.Phone, Account.Owner.Extension, (SELECT Id, Name, FirstName, LastName, Email, Title FROM Contacts), (SELECT Id, Name, Description__c, Product_Number__c, Product_Package__c, Product_Price__c, Product_Status__c, Recurring_Frequency__c, Recurring_Period__c, Adwords_Email__c, Adwords_ID__c, Start_Date__c, End_Date__c FROM Account_Products__r) FROM Account WHERE username__c =: username];

            if(accounts.size() > 0) {
                Account account = accounts[0];

                return_result.status = true;
                return_result.message = 'Account successfully found';
                return_result.result = account;
            } else {
                return_result.status = false;
                return_result.message = 'Account not found';
                return_result.result = null;
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Account not found';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }
    
    
    //Fetch Account by username__c
    WebService static WebServiceResultAccount getAccountFromUsername(String username) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();
        try {
            if (username.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Uername is empty';
                return return_result;
            }
            username = string.escapeSingleQuotes(username.trim());
            Account[] Accounts = [SELECT Id, Name, username__c FROM Account where username__c =:username];
            
            if(accounts.size() > 0) {
                Account account = accounts[0];
                return_result.status = false;
                return_result.result = account;
                return_result.message = 'Succesful';
            }
        }
        catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Error in fetching account details';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        
        return return_result;
    }


    /**
    *   Fetch account login details
    *   @param String email
    *   @return Contact
    */
    WebService static WebServiceResultListContact getLoginDetailsByEmail(String email) {
        WebServiceResultListContact return_result = new WebServiceResultListContact();

        try {
            if (email.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Email address is empty';
                return return_result;
            }

            email = string.escapeSingleQuotes(email.trim());
            Contact[] contacts = [SELECT Account.Name, Account.username__c, Account.password__c, Name, FirstName, LastName, Email, Title FROM Contact WHERE email =: email and Title = 'Billing'];

            if(contacts.size() > 0) {
                return_result.status = true;
                return_result.result = contacts;
                return_result.message = 'Successfully fetched account details';
            } else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Cannot find any account with that email address';
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Error in fetching account details';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }
    
    /**
    *   Fetch account login details
    *   @param String email
    *   @return Account
    */
    WebService static WebServiceResultListContact getLoginDetailsByUsername(String email) {
        WebServiceResultListContact return_result = new WebServiceResultListContact();

        try {
            if (email.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Email address is empty';
                return return_result;
            }

            email = string.escapeSingleQuotes(email.trim());
            Contact[] contacts = [SELECT Account.Name, Account.username__c, Account.password__c, Name, FirstName, LastName, Email, Title FROM Contact WHERE Account.username__c =: email and Title = 'Billing'];
            
            if(contacts.size() > 0) {
                return_result.status = true;
                return_result.result = contacts;
                return_result.message = 'Successfully fetched account details';
            } else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Cannot find any account with that email address';
            }
            
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Error in fetching account details';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }
    
    

    /**
    *   Validates for external projects that the username and password entered match against the account record
    *   @param String name
    *   @param String password
    *   @return Account
    */
    WebService static WebServiceResultAccount validateAccountCredentials(String name, String password) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            if (name.length() == 0 || password.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Username or Password is empty';
                return return_result;
            }

            name = string.escapeSingleQuotes(name.trim());
            password = password.trim();
            Account[] accounts = 
                [
                    SELECT
                        Id,
                        Name,
                        username__c,
                        password__c,
                        Xero_Sync_ID__c,
                        Payment_Option__c,
                        Unique_Id__c,
                        IsDeleted,
                        CreatedDate,
                        LastModifiedDate,
                        Account.Owner.FirstName,
                        Account.Owner.LastName,
                        Account.Owner.Email,
                        Account.Owner.Phone,
                        Account.Owner.Extension,
                        (
                            SELECT
                                Id,
                                Name,
                                FirstName,
                                LastName,
                                Email,
                                Title
                            FROM Contacts
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Description__c,
                                Product_Number__c,
                                Product_Package__c,
                                Product_Price__c,
                                Product_Status__c,
                                Recurring_Frequency__c,
                                Recurring_Period__c,
                                Adwords_Email__c,
                                Adwords_ID__c,
                                Start_Date__c,
                                End_Date__c,
                                OwnerId
                            FROM Account_Products__r
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Last_Crawl_Date__c,
                                Send_SEO_Report__c,
                                website_url__c
                            FROM seoWebsites__r
                        )
                    FROM Account
                    WHERE username__c =:name
                ];

            if(accounts.size() > 0) {
                Account account = accounts[0];
                if (password.equals(account.password__c)) {
                    return_result.status = true;
                    return_result.result = account;
                    return_result.message = 'Account credentials successfully validated';
                } else {
                    return_result.status = false;
                    return_result.result = null;
                    return_result.message = 'Invalid Username or Password3';
                }
            } else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Invalid Username or Password4';
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Invalid Username or Password5';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }


    /**
    *   Validates for external projects that the username and password entered match against the account record
    *   @param String name
    *   @param String password
    *   @return Account
    */
    WebService static WebServiceResultAccount validateUser(String name) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            if (name.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Username or Password is empty';
                return return_result;
            }

            name = string.escapeSingleQuotes(name.trim());
            Account[] accounts = 
                [
                    SELECT
                        Id,
                        Name,
                        username__c,
                        Xero_Sync_ID__c,
                        Payment_Option__c,
                        Unique_Id__c,
                        IsDeleted,
                        CreatedDate,
                        LastModifiedDate,
                        Account.Owner.FirstName,
                        Account.Owner.LastName,
                        Account.Owner.Email,
                        Account.Owner.Phone,
                        Account.Owner.Extension,
                        (
                            SELECT
                                Id,
                                Name,
                                FirstName,
                                LastName,
                                Email,
                                Title
                            FROM Contacts
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Description__c,
                                Product_Number__c,
                                Product_Package__c,
                                Product_Price__c,
                                Product_Status__c,
                                Recurring_Frequency__c,
                                Recurring_Period__c,
                                Adwords_Email__c,
                                Adwords_ID__c,
                                Start_Date__c,
                                End_Date__c,
                                OwnerId
                            FROM Account_Products__r
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Last_Crawl_Date__c,
                                Send_SEO_Report__c,
                                website_url__c
                            FROM seoWebsites__r
                        )
                    FROM Account
                    WHERE username__c =:name
                ];

            if(accounts.size() > 0) {
                Account account = accounts[0];
                    return_result.status = true;
                    return_result.result = account;
                    return_result.message = 'Account credentials successfully validated';
            } else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Invalid Username';
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Invalid Username';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }


    /**
    *   Validates for external projects that the username and password entered match against the account record
    *   @param String name
    *   @param String password
    *   @return Account
    */
    WebService static WebServiceResultAccount getAccountFromName(String name) {
        WebServiceResultAccount return_result = new WebServiceResultAccount();

        try {
            if (name.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Name cannot be empty.';
                return return_result;
            }

            name = string.escapeSingleQuotes(name.trim());
            Account[] accounts = 
                [
                    SELECT
                        Id,
                        Name,
                        username__c,
                        Xero_Sync_ID__c,
                        Payment_Option__c,
                        Unique_Id__c,
                        IsDeleted,
                        CreatedDate,
                        LastModifiedDate,
                        Account.Owner.FirstName,
                        Account.Owner.LastName,
                        Account.Owner.Email,
                        Account.Owner.Phone,
                        Account.Owner.Extension,
                        (
                            SELECT
                                Id,
                                Name,
                                FirstName,
                                LastName,
                                Email,
                                Title
                            FROM Contacts
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Description__c,
                                Product_Number__c,
                                Product_Package__c,
                                Product_Price__c,
                                Product_Status__c,
                                Recurring_Frequency__c,
                                Recurring_Period__c,
                                Adwords_Email__c,
                                Adwords_ID__c,
                                Start_Date__c,
                                End_Date__c,
                                OwnerId
                            FROM Account_Products__r
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Last_Crawl_Date__c,
                                Send_SEO_Report__c,
                                website_url__c
                            FROM seoWebsites__r
                        )
                    FROM Account
                    WHERE Name =:name
                ];

            if(accounts.size() > 0) {
                Account account = accounts[0];
                    return_result.status = true;
                    return_result.result = account;
                    return_result.message = 'Success';
            } else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Failure';
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Failure';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }


    /**
    *   Updates an account's details
    *   @param Account account
    *   @return Account
    */
    WebService static WebServiceResultBoolean updateAccountDetails(Account account) {
        WebServiceResultBoolean return_result = new WebServiceResultBoolean();

        try {
            update account;
            return_result.status = true;
            return_result.message = 'Account successfully updated';
            return_result.result = true;
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Invalid Account specified';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = true;
            return_result.message = e.getMessage();
            return_result.result = false;
        }
        return return_result;
    }


    /**
    *   Updates a contact's details
    *   @param Contact contact
    *   @return Contact
    */
    WebService static WebServiceResultBoolean updateContactDetails(Contact contact) {
        WebServiceResultBoolean return_result = new WebServiceResultBoolean();

        try {
            update contact;
            return_result.status = true;
            return_result.message = 'Contact successfully updated';
            return_result.result = true;
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Invalid Contact specified';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = true;
            return_result.message = e.getMessage();
            return_result.result = false;
        }
        return return_result;
    }


    /**
    *   Fetch user's details
    *   @param Id userId
    *   @return User
    */

    WebService static WebServiceResultUser getUserDetailsById(Id userId) {
        WebServiceResultUser return_result = new WebServiceResultUser();

        try {
            User[] users = [SELECT Id, Name, FirstName, LastName, Email, CreatedDate, LastModifiedDate FROM User WHERE Id =: userId];

            if(users.size() > 0) {
                User user = users[0];

                return_result.status = true;
                return_result.message = 'User successfully found';
                return_result.result = user;
            } else {
                return_result.status = false;
                return_result.message = 'User not found';
                return_result.result = null;
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'User not found';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }


    /**
    *   Fetch user's details
    *   @param Id userId
    *   @return User
    */
/*
    WebService static WebServiceResultUser getUserDetailsByUserId(String userId) {
        WebServiceResultUser return_result = new WebServiceResultUser();

        try {
            User[] users = [SELECT Id, Name, FirstName, LastName, Email, CreatedDate, LastModifiedDate FROM User WHERE user_id__c =: userId];

            if(users.size() > 0) {
                User user = users[0];

                return_result.status = true;
                return_result.message = 'User successfully found';
                return_result.result = user;
            } else {
                return_result.status = false;
                return_result.message = 'User not found';
                return_result.result = null;
            }
        } catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'User not found';
            return_result.result = null;
        } catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }
*/

    /**
    *   Validates for external projects that the username and password entered match against the users record
    *   @param String name
    *   @param String password
    *   @return Account
    */
    WebService static WebServiceResultUser validateUserCredentials(String name, String password) {
        WebServiceResultUser return_result = new WebServiceResultUser();

        try {
            if (name.length() == 0 || password.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Username or Password cannot be empty';
                return return_result;
            }

            name = string.escapeSingleQuotes(name.trim());
            password = password.trim();
            User[] users = [SELECT Id, Username, password__c, Department, Division, Adwords_Email__c, Email, EmployeeNumber, IsActive, UserRole.Name, UserRole.ParentRoleId, Profile.Name, CreatedDate, LastModifiedDate FROM User WHERE Username=:name];

            if(users.size() > 0){
                User user = users[0];
                if (password.equals(user.password__c)) {
                    return_result.status = true;
                    return_result.result = user;
                    return_result.message = 'User credentials successfully validated';
                }
                else {
                    return_result.status = false;
                    return_result.result = null;
                    return_result.message = 'Invalid username or password';
                }
            }
            else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'The username does not exist';
            }
        }
        catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Invalid username or password';
            return_result.result = null;
        }
        catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }
    
    /**
    *   Validates for external projects that the username and password entered match against the Mcc Logins record
    *   @param String name
    *   @param String password
    *   @return Account
    */
    WebService static WebServiceResultEricaUser validateEricaUserCredentials(String name, String password) {
        WebServiceResultEricaUser return_result = new WebServiceResultEricaUser();

        try {
            if (name.length() == 0 || password.length() == 0) {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'Username or Password cannot be empty';
                return return_result;
            }

            name = string.escapeSingleQuotes(name.trim());
            password = password.trim();
            Mcc_login__c[] users = [SELECT Id, Name, Adwords_Password__c, Role__c, Company__c, OwnerId, Owner.Name FROM Mcc_login__c WHERE Name=:name];

            if(users.size() > 0){
                Mcc_login__c user = users[0];
                if (password.equals(user.Adwords_Password__c)) {
                    return_result.status = true;
                    return_result.result = user;
                    return_result.message = 'User credentials successfully validated';
                }
                else {
                    return_result.status = false;
                    return_result.result = null;
                    return_result.message = 'Invalid username or password';
                }
            }
            else {
                return_result.status = false;
                return_result.result = null;
                return_result.message = 'The username does not exist';
            }
        }
        catch (NullPointerException e) {
            return_result.status = false;
            return_result.message = 'Invalid username or password';
            return_result.result = null;
        }
        catch (Exception e) {
            return_result.status = false;
            return_result.message = e.getMessage();
            return_result.result = null;
        }
        return return_result;
    }

    /**
    *   Fetches all the groups based off the role of a user
    *   @param Id user_id
    *   @return GroupMember
    */
    WebService static WebServiceResultListGroup getUserRoleGroups(String userId) {
        WebServiceResultListGroup return_result = new WebServiceResultListGroup();
        String userRoleType = Schema.SObjectType.UserRole.getKeyPrefix();
        
        List<Group> userGroups = new List<Group>();
        
        try {
            //get the user's role
            User user = [SELECT u.UserRoleId FROM User u WHERE Id = :userId];

            //get a list of groups that use that role
            List<Group> groups = [SELECT g.Type, g.SystemModstamp, g.RelatedId, g.OwnerId, g.Name, g.LastModifiedDate, g.LastModifiedById, 
                                         g.Id, g.Email, g.DoesSendEmailToMembers, g.DoesIncludeBosses, g.CreatedDate, g.CreatedById
                                  FROM Group g 
                                  WHERE g.RelatedId = :user.UserRoleId];

            for (Group groupLookup : groups) {
                if (Limits.getCallouts() < Limits.getLimitCallouts()) {
                    List<GroupMember> groupMembersRec = [SELECT g.UserOrGroupId, g.SystemModstamp, g.Id, g.GroupId FROM GroupMember g WHERE UserOrGroupId = :groupLookup.Id];
                
                    for (GroupMember groupMemberRec : groupMembersRec) {
                        Group groupRec = [SELECT g.Type, g.SystemModstamp, g.RelatedId, g.OwnerId, g.Name, g.LastModifiedDate, g.LastModifiedById, 
                                             g.Id, g.Email, g.DoesSendEmailToMembers, g.DoesIncludeBosses, g.CreatedDate, g.CreatedById
                                      FROM Group g 
                                      WHERE g.Id = :groupMemberRec.GroupId];
                        userGroups.add(groupRec);   
                    }   
                } else {
                    
                }
            }

            return_result.result = userGroups;
            return_result.status = true;
            return_result.message = 'successfully fetched user\'s groups';
        } catch (Exception e) {
            return_result.status = true;
            return_result.message = e.getMessage() + ' ' + e.getTypeName();
            return_result.result = null;
        }
        
        return return_result;
    }
    
    /**
    *   Run CM daily ActivityReport because salesforce scheduler fucked up, we have to use cron in 
    *   other server to call this method.
    *   @param boolean
    *   @return WebServiceResultActivityReport
    */
    WebService static WebServiceResultActivityReport runActivityReport(Boolean isTest) {
        WebServiceResultActivityReport result = new WebServiceResultActivityReport();
        
        try{
            ActivityReport ar = new ActivityReport(isTest);
            
            result.status = true;
            result.message = 'Successfully send CM ActivityReport';
        } catch(Exception e) {
            result.status = false;
            result.message = e.getMessage() + ' ' + e.getTypeName();
        }
        
        return result;
    }
    
    /**
    *   Send invoice web service
    */
    WebService static WebServiceResultSendInvoice sendInvoice(String invNum) {
        WebServiceResultSendInvoice result = new WebServiceResultSendInvoice();
        
        try{
            Invoice__c inv = [select id from Invoice__c where invoice_number__c =: invNum limit 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(inv);
            SendInvoice si = new SendInvoice(sc);
            si.send();
            result.status = true;
            result.message = 'Invoice sent successfully.';
        } catch(Exception e) {
            result.status = false;
            result.message = 'Invoice failed to send.';
        }
        
        return result;
    } 

    public static Set<Id> GetUserIdsFromGroupRole(Id roleId) {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        
        List<User> users = [Select Id From User Where UserRoleId = :roleId];
        for (User user : users) {
            result.add(user.Id);
        }
        
        return result;  
    }

    static testMethod void getAccountIdFromReferenceTest() {
        Account account         = new Account();
        account.Name            = 'Test Account';
        account.Company__c      = 'SponsoredLinX';
        account.username__c     = 'test@test.com';
        account.password__c     = 'test';
        insert account;

        SLXWebService.getAccountIdFromReference(account.Unique_Id__c);
    }
    static testMethod void getTodayInvoiceListTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08');
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;


        Invoice_Batch__c batch2 = new Invoice_Batch__c();
        batch2.name = DateTime.now().format('EEEE') + ' Invoice Batch';
        batch2.status__c = 'Batch Approved';
        batch2.Batch_Type__c = 'Invoices';
        batch2.Batch_Processed__c = 'No';
        insert batch2;

        Invoice__c invoice1 = new Invoice__c();
        invoice1.name = 'test invoice';
        invoice1.Payment_Option__c = 'Other';
        invoice1.Invoice_Number__c = 'test--001';
        invoice1.Invoice_Batch__c = batch2.id;
        invoice1.Payment_Batch__c = null;
        invoice1.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
        invoice1.Account__c = account.Id;
        invoice1.Amount_Due__c = 4.50;

        Invoice__c invoice2 = new Invoice__c();
        invoice2.name = 'test invoice';
        invoice2.Payment_Option__c = 'Other';
        invoice2.Invoice_Number__c = 'test--002';
        invoice2.Invoice_Batch__c = batch2.id;
        invoice2.Payment_Batch__c = null;
        invoice2.Xero_Contact_Id__c = 'E786047F-6DD3-4D62-B28D-6100D373AA08';
        invoice2.Account__c = account.Id;
        invoice2.Amount_Due__c = 3.50;

        Invoice__c invoice3 = new Invoice__c();
        invoice3.name = 'test invoice';
        invoice3.Payment_Option__c = 'Other';
        invoice3.Invoice_Number__c = 'test--003';
        invoice3.Invoice_Batch__c = batch2.id;
        invoice3.Payment_Batch__c = null;
        invoice3.Xero_Contact_Id__c = 'E786047F-6FF3-4D62-B28D-6100D373AA08';
        invoice3.Account__c = account.Id;
        invoice3.Amount_Due__c = 1.50;

        insert invoice1;
        insert invoice2;
        insert invoice3;

        SLXWebService.getTodayInvoiceList();
        Test.stopTest();
    }
    static testMethod void getYesterdaySignupListTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08');
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;

        Sign_Up__c signup = new Sign_Up__c();
        signup.name = 'Test Signup';
        signup.Invoiceno__c = 'test-signup-001';
        signup.Account__c = account.Id;

        insert signup;

        SLXWebService.getYesterdaySignupList();
        Test.stopTest();
    }
    static testMethod void getExcludeInvoiceListTest() {
        Test.startTest();
        SLXWebService.getExcludeInvoiceList();
        Test.stopTest();
    }

    static testMethod void getAccountDetailsTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetails(account.Id, company.Branding_Theme_Id__c);
        Test.stopTest();
    }

    static testMethod void getAccountDetailsByUserIdTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetailsByUserId(account.user_id__c);
        Test.stopTest();
    }

    static testMethod void getAccountDetailsByUserIdErrorTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetailsByUserId('fakeuserid');
        Test.stopTest();
    }

    static testMethod void getAccountDetailsByAccountIdTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetailsByAccountId(account.Id);
        Test.stopTest();
    }

    static testMethod void getAccountDetailsByAccountIdErrorTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetailsByAccountId('fakeaccountid');
        Test.stopTest();
    }

    static testMethod void getAccountDetailsByUsernameTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetailsByUsername(account.username__c);
        Test.stopTest();
    }

    static testMethod void getAccountDetailsByUsernameErrorTest() {
        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountDetailsByUsername('fakeusername');
        Test.stopTest();
    }

    // null username, null password
    static testMethod void validateAccountCredentialsTestNull() {
        String name = null;
        String password = null;
        SLXWebService.validateAccountCredentials(name, password);
    }

    // empty username, empty password
    static testMethod void validateAccountCredentialsTest0() {
        String name = '';
        String password = '';
        SLXWebService.validateAccountCredentials(name, password);
    }

    // correct username, correct password
    static testMethod void validateAccountCredentialsTest1() {
        Account account         = new Account();
        account.Name            = 'Test Account';
        account.Company__c      = 'SponsoredLinX';
        account.username__c     = 'test@test.com';
        account.password__c     = 'test';
        insert account;

        SLXWebService.validateAccountCredentials('test@test.com', 'test');
    }

    // correct username, wrong password
    static testMethod void validateAccountCredentialsTest2() {
        Account account         = new Account();
        account.Name            = 'Test Account';
        account.Company__c      = 'SponsoredLinX';
        account.username__c     = 'test@test.com';
        account.password__c     = 'test';
        insert account;

        SLXWebService.validateAccountCredentials('test@test.com', 'fakepass');
    }

    // wrong username, correct password
    static testMethod void validateAccountCredentialsTest3() {
        Account account         = new Account();
        account.Name            = 'Test Account';
        account.Company__c      = 'SponsoredLinX';
        account.username__c     = 'test@test.com';
        account.password__c     = 'test';
        insert account;

        SLXWebService.validateAccountCredentials('fakename', 'fakepass');
    }

    static testMethod void updateAccountDetailsTest1() {
        Account acc = new Account(Name='newaccount',username__c='test',password__c='test',company__c='company');
        insert acc;

        SLXWebService.updateAccountDetails(acc);
    }

    static testMethod void updateAccountDetailsTest2() {
        Account account = null;
        SLXWebService.updateAccountDetails(account);
    }

    // null username, null password
    static testMethod void validateUserCredentialsTestNull() {
        String name = null;
        String password = null;
        SLXWebService.validateUserCredentials(name, password);
    }

    // empty username, empty password
    static testMethod void validateUserCredentialsTest0() {
        String name = '';
        String password = '';
        SLXWebService.validateUserCredentials(name, password);
    }

    static testMethod void getUserRoleGroupsTest1() {
        String user_id = '4077';
        SLXWebService.getUserRoleGroups(user_id);
    }

    static testMethod void getUserRoleGroupsTest2() {
        String user_id = '00590000000XrwZ';
        SLXWebService.getUserRoleGroups(user_id);
    }

    static testMethod void GetUserIdsFromGroupRoleTest() {
        String role_id = '00E90000000X53p';
        SLXWebService.GetUserIdsFromGroupRole(role_id);
    }

    static testMethod void variableTest() {
        WebServiceResultBoolean result1 = new WebServiceResultBoolean();
        result1.status = true;
        result1.message = 'Result 1';

        WebServiceResultAccount result2 = new WebServiceResultAccount();
        result2.status = true;
        result2.message = 'Result 2';

        WebServiceResultListAccount result3 = new WebServiceResultListAccount();
        result3.status = true;
        result3.message = 'Result 3';

        WebServiceResultListGroupMember result4 = new WebServiceResultListGroupMember();
        result4.status = true;
        result4.message = 'Result 4';

        WebServiceResultListGroup result5 = new WebServiceResultListGroup();
        result5.status = true;
        result5.message = 'Result 5';

        WebServiceResultUser result6 = new WebServiceResultUser();
        result6.status = true;
        result6.message = 'Result 6';
    }

    static testMethod void getLoginDetailsByEmailTest() {
        WebServiceResultListContact  result1 = new WebServiceResultListContact ();
            Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getAccountFromUsername('fakeusername');
        Test.stopTest();
    }
    
    static testMethod void getLoginDetailsByEmailTest1() {
        WebServiceResultListContact  result1 = new WebServiceResultListContact ();
            Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        SLXWebService.getLoginDetailsByEmail('test@gmail.com');
        Test.stopTest();
    }
    
    static testMethod void getLoginDetailsByEmailTest2() {
        WebServiceResultListContact  result1 = new WebServiceResultListContact();
        WebServiceResultUser return_result = new WebServiceResultUser();

        Test.startTest();

        Account account = new Account(name='test',company__c='test',username__c='test',password__c='test',user_id__c='1234',Name_On_Card__c='test test',Card_Number__c='1111222233334444',Card_Month_Expiry__c='02',Card_Year_Expiry__c='11',Xero_Sync_ID__c='E786047F-6DD3-4D62-B28D-6100D373AA08',Send_Invoice__c=true);
        insert account;
        Contact contact = new Contact(FirstName='test',LastName='test',Title='Billing',Email='Email@email.com',MailingStreet='MailingStreet',MailingCity='MailingCity',MailingPostalCode='MailingPostalCode',MailingState='MailingState',MailingCountry='MailingCountry',AccountId=account.Id);
        insert contact;
        Company__c company = new Company__c(Name='test company',Email__c='Email@email.com',Address__c='test address',Business_Name__c='business name',Logo_Code__c='logo test',Phone__c='phone test',Branding_Theme_Id__c='f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7');
        insert company;

        Profile objProfileSalesAdmin = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce Platform' LIMIT 1][0];
        User user = new User(username='sss123test@test.com',FirstName='test',LastName='test',Email='test@test.com',Alias='test',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=objProfileSalesAdmin.Id);
        insert user;

        SLXWebService.updateContactDetails(contact);
        ID thisId = account.Id;
        SLXWebService.getUserDetailsById(thisId);
        Test.stopTest();
    }
    
}