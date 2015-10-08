@isTest(SeeAllData = TRUE)
public Class Test_UpdateTask{
   
    Public Static TestMethod Void testUpdateTaskMethod(){
        List<Account> accList = [SELECT Id,Name,ConnectionReceivedId,KTI_Id__c FROM Account WHERE ConnectionReceivedId != null AND KTI_Id__c != null LIMIT 5];
         
        Task tsk = new Task(WhatId = accList[0].Id,Subject = 'Email',KTI_Task_Id__c='003tktsId1238907');
        Insert tsk;
        
        List<UpdateTask.KTSAndKTIId> taskClsList = new List<UpdateTask.KTSAndKTIId>();
        UpdateTask.KTSAndKTIId taskCls = new UpdateTask.KTSAndKTIId();
        taskCls.ktsId = tsk.Id;
        taskCls.ktiId = '003tktsId1238907' ;
        
        taskClsList.add(taskCls);
        
        String JsonMsg=JSON.serialize(taskClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateTask';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateTask.updateTaskKTIId();
    }
}