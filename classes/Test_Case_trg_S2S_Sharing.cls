@isTest(SeeAllData = TRUE)
public Class Test_Case_trg_S2S_Sharing{
   
    Public Static TestMethod Void testShareCaseMethod(){
        
        List<Account> accList = [SELECT Id,Name,ConnectionReceivedId,KTI_Id__c FROM Account WHERE ConnectionReceivedId != null AND KTI_Id__c != null LIMIT 5];
        if( accList != null && accList.size() > 0 ) {
            List<Case> caseList = new List<Case>{new Case(AccountId=accList[0].Id,KTI_Case_Id__c = '500M00000066xX2'),
                new Case(AccountId=accList[0].Id),
                new Case(AccountId=accList[0].Id,KTI_Case_Id__c = '500M00000066xX1')
            };
            Insert caseList;
            
            caseList[1].AccountId = accList[1].Id;
            caseList[1].KTI_Parent_Case_Id__c = '500M00000066xX1';
            caseList[2].KTI_Account_Id__c = accList[1].KTI_Id__c;
            caseList[2].ParentId = caseList[0].Id;
            
            update caseList;
        }
        
    }
}