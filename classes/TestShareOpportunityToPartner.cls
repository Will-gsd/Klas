@isTest(seeAllData=True) 
public class TestShareOpportunityToPartner {
    static testMethod void methodTestShareOpportunityToPartner() {
       /* Account[] accounts=new Account[] {
            new Account(Name='Test Account'),
            new Account(Name='Test Account 1')
        };
        insert accounts; */
        List<Account> accList=[Select Id,KTI_Id__c From Account Where Do_Not_Share__c=False AND ConnectionReceivedId != NULL];
        if(accList != NULL && accList.size() > 0) {
            Opportunity[] opportunities=new Opportunity[] {
                new Opportunity(Name='Test Opportunity',AccountId=accList.get(0).Id,closeDate=System.TODAY(),StageName='Prospecting', KTI_Price_Book_Name__c ='Contract Price'),
                new Opportunity(Name='Test Opportunity 1',AccountId=accList.get(0).Id,closeDate=System.TODAY(),StageName='Prospecting'),
                new Opportunity(Name='Test Opportunity 2',closeDate=System.TODAY(),StageName='Prospecting')
            };
            insert opportunities;
            List<Opportunity> oppList=[Select Id From Opportunity where AccountId= NULL Limit 1];
           // List<Opportunity> oppList1==new List<Opportunity>();
            if(oppList != NULL && oppList.size() > 0) {
                oppList.get(0).AccountId=accList.get(0).Id;
               oppList.get(0).KTI_AccountId__c=accList.get(0).KTI_Id__c;
               // oppList1.add(oppList.get(0));
            }
            update oppList;
        }
        
    }
}