@isTest(SeeAllData = TRUE)
public Class Test_UpdateCase{
   
    Public Static TestMethod Void testUpdateCaseMethod(){
        
        List<Account> accList = [SELECT Id,Name,ConnectionReceivedId,KTI_Id__c FROM Account WHERE ConnectionReceivedId != null AND KTI_Id__c != null LIMIT 5];
        if( accList != null && accList.size() > 0 ) {
            List<Case> caseList = new List<Case>{new Case(AccountId=accList[0].Id,KTI_Case_Id__c = '500M00000066xX2'),
                new Case(AccountId=accList[0].Id),
                new Case(AccountId=accList[0].Id,KTI_Case_Id__c = '500M00000066xX1')
            };
            Insert caseList;
        
            List<UpdateCase.KTSAndKTIId> caseClsList = new List<UpdateCase.KTSAndKTIId>();
            UpdateCase.KTSAndKTIId caseCls = new UpdateCase.KTSAndKTIId();
            caseCls.ktsId = caseList[0].Id;
            caseCls.ktiId = '500QM05rh0acqGn' ;
            
            caseClsList.add(caseCls);
            
            String JsonMsg=JSON.serialize(caseClsList);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
    
            req.requestURI = '/services/apexrest/UpdateCase';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            
            UpdateCase.updateCaseKTIId();
        }
    }
}