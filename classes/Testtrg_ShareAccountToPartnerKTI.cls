@isTest(seeAllData=True)
public class Testtrg_ShareAccountToPartnerKTI {
    public static testMethod void methodTesttrg_ShareAccountToPartnerKTI() {
        Account[] parentAccounts=new Account[] {
            new Account(Name='Test Account PA',Organization_Name__c='SSSP PA',Do_Not_Share__c=False),
            new Account(Name='Test Account 1PA',Organization_Name__c='SSSA PA',Do_Not_Share__c=False) ,   
            new Account(Name='Test Account 2PA',Organization_Name__c='SSSA PA',Do_Not_Share__c=False)    
        };
        insert parentAccounts;
        Account[] accounts=new Account[] {
            new Account(Name='Test Account',Organization_Name__c='SSSP',Do_Not_Share__c=False,KTI_Parent_Id__c=parentAccounts[0].Id),
            new Account(Name='Test Account 1',Organization_Name__c='SSSA',Do_Not_Share__c=False)
        };
        insert accounts;
        List<Account> accList=[Select Id From Account Where ConnectionReceivedId != NULL];
        if(accList.size() > 0) {
            Contact[] contacts =new Contact[] {
                 new Contact(LastName='Test Contact',AccountId=accList.get(0).Id)
            };
            insert contacts;
        }
        List<Account> accountList=new List<Account>();
        
        String str;
        for(Account account: [Select Id,Organization_Name__c From Account]) {
            account.Organization_Name__c='Changed';
            str= parentAccounts[0].Id;
            account.KTI_Id__c=str.subString(0,15);
            
            account.KTI_Parent_Id__c=parentAccounts[1].Id;
            accountList.add(account);  
        }
        update accountList;
        
            List<Account> acc=[Select Id,Organization_Name__c,ParentId,KTI_Id__c From Account Where Id= :accounts[0].Id];
            acc.get(0).Organization_Name__c='Changed';
            
            acc.get(0).ParentId=parentAccounts[2].Id;
            acc.get(0).KTI_Id__c=parentAccounts[1].Id;
            acc.get(0).KTI_Parent_Id__c=parentAccounts[0].Id;
            update acc;
            
            List<Account> acc1=[Select Id,Organization_Name__c,ParentId,Do_Not_Share__c From Account Where Id= :accounts[0].Id Limit 1];
            List<Contact> conList=[Select Id,AccountId From Contact Limit 1];
            conList.get(0).AccountId=acc1.get(0).Id;
            update conList;
            acc1.get(0).Organization_Name__c='Changed';
            acc1.get(0).ParentId=parentAccounts[2].Id;
            acc1.get(0).Do_Not_Share__c=True;
            // acc1.get(0).KTI_Parent_Id__c=NULL;
            update acc1;
             
    }
}