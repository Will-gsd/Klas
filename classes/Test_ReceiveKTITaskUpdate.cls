@isTest(SeeAllData = TRUE)
public Class Test_ReceiveKTITaskUpdate{
    Public Static TestMethod Void testReceiveTaskMethod(){
         
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Asset> assetList = new List<Asset>();
        List<Product2> product2List = new List<Product2>();
        List<Case> caseList = new List<Case>();
        List<Quote> quoteList = new List<Quote>();
        Account Acc = new Account(Name = 'Test Acc',Organization_Name__c = 'SS');
        //Insert Acc;
        accList = [SELECT Id,Name,ConnectionReceivedId,KTI_Id__c FROM Account WHERE ConnectionReceivedId != null LIMIT 5];
        oppList = [SELECT Id,Name,ConnectionReceivedId,KTI_Id__c FROM Opportunity WHERE ConnectionReceivedId != null LIMIT 5];
        product2List = [SELECT Id,Name,ConnectionReceivedId,KTI_Product_Id__c FROM Product2 WHERE ConnectionReceivedId != null LIMIT 5];
        caseList = [SELECT Id,ConnectionReceivedId,KTI_Case_Id__c FROM case WHERE ConnectionReceivedId != null LIMIT 5];
        assetList = [SELECT Id,KTI_Asset_Id__c FROM Asset WHERE KTI_Asset_Id__c != null LIMIT 5 ];
        quoteList = [SELECT Id,KTI_Quote_Id__c FROM Quote WHERE KTI_Quote_Id__c != null LIMIT 5 ];
         
        List<Contact> conList = new List<Contact>{new Contact(LastName = 'Tst Con1',AccountId = accList[0].Id,KTI_Contact_Id__c = '003tktsId1234567'),
                                new Contact(LastName = 'Tst Con1',AccountId = accList[0].Id,KTI_Contact_Id__c = '003tktsId1238907')
        };
        Insert conList;
        
        List<Lead> ldList = [SELECT Id,KTI_Lead_Id__c FROM Lead WHERE ConnectionReceivedId != null AND KTI_Lead_Id__c != null LIMIT 5];
        
        List<Task> tsk = new List<Task>{new Task(WhatId = accList[0].Id,WhoId = conList[0].Id,Subject = 'Email',KTI_Task_Id__c='Test11111111111'),
        new Task(whoId = ldList[0].Id,Subject='Meeting',KTI_Task_Id__c='Test22222222222'),
        new Task(WhatId = oppList[2].Id,WhoId = conList[0].Id,Subject = 'Email',KTI_Task_Id__c='Test33333333333'),
        new Task(WhatId = product2List[1].Id,WhoId = conList[0].Id,Subject = 'Email',KTI_Task_Id__c='Test44444444444'),
        new Task(WhatId = accList[1].Id,WhoId = conList[0].Id,Subject = 'Email',KTI_Task_Id__c='Test55555555555'),
        new Task(WhatId = accList[3].Id,WhoId = conList[0].Id,Subject = 'Email',KTI_Task_Id__c='Test66666666666')
        };
        Insert tsk;
         
        List<ReceiveKTITaskUpdate.TaskClass> tskClassList = new List<ReceiveKTITaskUpdate.TaskClass>();
        
        ReceiveKTITaskUpdate.TaskClass tskCls1 = new ReceiveKTITaskUpdate.TaskClass();
        tskCls1.tskId = tsk[0].KTI_Task_Id__c;
        tskCls1.whatId = accList[0].KTI_Id__c;
        tskCls1.WhoId = '003tktsId1238907';
        tskCls1.subject = tsk[0].Subject;
        tskCls1.status = 'Not Started';
        tskCls1.priority = 'Normal';
        tskClassList.add(tskCls1);
        
        ReceiveKTITaskUpdate.TaskClass tskCls2 = new ReceiveKTITaskUpdate.TaskClass();
        tskCls2.tskId = tsk[1].KTI_Task_Id__c;
        tskCls2.whatId = oppList[1].KTI_Id__c;
        tskCls2.WhoId = conList[0].KTI_Contact_Id__c;
        tskCls2.subject = tsk[1].Subject;
        tskCls2.status = 'Not Started';
        tskCls2.priority = 'Normal';
        //tskClassList.add(tskCls2);
        
        ReceiveKTITaskUpdate.TaskClass tskCls3 = new ReceiveKTITaskUpdate.TaskClass();
        tskCls3.tskId = tsk[2].KTI_Task_Id__c;
        tskCls3.whatId = product2List[0].KTI_Product_Id__c;
        tskCls3.WhoId = conList[0].KTI_Contact_Id__c;
        tskCls3.subject = tsk[2].Subject;
        tskCls3.status = 'Not Started';
        tskCls3.priority = 'Normal';
        tskClassList.add(tskCls3);
        
        ReceiveKTITaskUpdate.TaskClass tskCls4 = new ReceiveKTITaskUpdate.TaskClass();
        tskCls4.tskId = tsk[3].KTI_Task_Id__c;
        tskCls4.whatId = caseList[0].KTI_Case_Id__c;
        tskCls4.WhoId = '003tktsId1238907';
        tskCls4.subject = tsk[3].Subject;
        tskCls4.status = 'Not Started';
        tskCls4.priority = 'Normal';
        tskClassList.add(tskCls4);
        
        ReceiveKTITaskUpdate.TaskClass tskCls5 = new ReceiveKTITaskUpdate.TaskClass();
        tskCls5.tskId = tsk[4].KTI_Task_Id__c;
        tskCls5.whatId = assetList[0].KTI_Asset_Id__c;
        tskCls5.WhoId = conList[0].KTI_Contact_Id__c;
        tskCls5.subject = tsk[4].Subject;
        tskCls5.status = 'Not Started';
        tskCls5.priority = 'Normal';
        tskClassList.add(tskCls5);
        
        ReceiveKTITaskUpdate.TaskClass tskCls6 = new ReceiveKTITaskUpdate.TaskClass();
        tskCls6.tskId = tsk[5].KTI_Task_Id__c;
        tskCls6.whatId = null;
        tskCls6.WhoId = ldList[0].KTI_Lead_Id__c;
        tskCls6.subject = tsk[5].Subject;
        tskCls6.status = 'Not Started';
        tskCls6.priority = 'Normal';
        tskClassList.add(tskCls6);
        
        String JsonMsg=JSON.serialize(tskClassList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ReceiveKTITaskUpdate';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ReceiveKTITaskUpdate.postFormRegistration(); 
     }
 }