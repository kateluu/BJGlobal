public with sharing class EricaPageController {
    
    public User current_user {set;get;}
    public Boolean display {get; set;}
    public Boolean display_list {get; set;}
    public List<Mcc_Login__c> mccs {get;set;}
    public String selected_mcc {get;set;}
    private static Blob cryptoKey;

    
    public EricaPageController(){
        // Get the Role of the current logged in User
        this.current_user = [select Id, 
                                    UserRole.Name,
                                    UserRole.ID
                                from User 
                                where id =: UserInfo.getUserId()
                             ];
        system.debug(current_user);
        // Get the sub role id of the current user
        Set<ID> subRoleIDs = RoleUtils.getAllSubRoleIds(new Set<ID>{current_user.UserRole.ID});
        system.debug(subRoleIDs);
        // Get all the mcc logins below this user
        mccs = new List<Mcc_Login__c>([Select Id, Name, Owner.Name From Mcc_Login__c where 
            Owner.UserRole.ID IN :subRoleIDs or OwnerID =: current_user.Id]);
        system.debug(mccs);
        
        if(mccs.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Your MCC login details havent been saved in SF yet'));
            this.display = false;
            this.display_list = false;
        }else if(mccs.size() == 1){
            system.debug(mccs);
            this.display = true;
            this.display_list = false;
            String text = mccs[0].Name;
            String encrypted = EricaPageController.encrypt(text);
           
            
            
       //     ApexPages.currentPage().getParameters().put('username', mccs[0].Name);
            ApexPages.currentPage().getParameters().put('username', encrypted );
        }else{
            this.display = false;
            this.display_list = true;
        }
    }
    
    public void updateEricaView(){
        system.debug('selected MCC-->'+selected_mcc);
        
        if(selected_mcc != null && selected_mcc != ''){
            display = true;
            String InputString = selected_mcc;
      
           
           
           String encrypted = EricaPageController.encrypt(InputString);

            
            ApexPages.currentPage().getParameters().put('username', encrypted );
        }else{
            display = false;
        }
        
    }
    
    public List<SelectOption> getMccList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for(Mcc_Login__c mcc : mccs){
            options.add(new SelectOption(mcc.Name, mcc.Owner.Name + ' - ' + mcc.Name));
        }
        options.sort();
        return options;

    }
    
    public static String encrypt(String toBeEncryptedString){
        String encryptionKey = 'iesa5n%f$P6aG(g6'; // <-- 16 character encryption key goes here
        Blob key = Blob.valueOf(encryptionKey);
        
    
       
        Blob exampleIv = Blob.valueOf('ExamplejofgIV123');
        
        Blob data = Blob.valueOf(toBeEncryptedString);
        Blob encrypted = Crypto.encrypt('AES128', key, exampleIv, data);  
        
        // Decode the decrypted data
           
            
        return EncodingUtil.convertToHex(encrypted);
    }
    

    
    
    
    
    
    
    
    
    
}