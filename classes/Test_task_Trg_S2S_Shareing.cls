@isTest(SeeAllData = TRUE)
public Class Test_task_Trg_S2S_Shareing{
    public class HttpResponseForTask implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody(TestJSONContent);
            res.setStatusCode(200);
            res.setBody('success');
            res.setStatus('Ok');
            return res;
        }
    }
     Public Static TestMethod Void testShareTaskMethod(){
         
         Test.setMock(HttpCalloutMock.class, new HttpResponseForTask());
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Asset> assetList = new List<Asset>();
         List<Product2> product2List = new List<Product2>();
         List<Case> caseList = new List<Case>();
         List<Quote> quoteList = new List<Quote>();
         Account Acc = new Account(Name = 'Test Acc',Organization_Name__c = 'SS');
         //Insert Acc;
         accList = [SELECT Id,Name,ConnectionReceivedId FROM Account WHERE ConnectionReceivedId != null LIMIT 5];
         oppList = [SELECT Id,Name,ConnectionReceivedId FROM Opportunity WHERE ConnectionReceivedId != null LIMIT 5];
         product2List = [SELECT Id,Name,ConnectionReceivedId FROM Product2 WHERE ConnectionReceivedId != null LIMIT 5];
         caseList = [SELECT Id,ConnectionReceivedId FROM case WHERE ConnectionReceivedId != null LIMIT 5];
         assetList = [SELECT Id FROM Asset LIMIT 5];
         quoteList = [SELECT Id FROM Quote LIMIT 5];
         
         List<Contact> conList = new List<Contact>{new Contact(LastName = 'Tst Con1',AccountId = accList[0].Id,KTI_Contact_Id__c = '003tktsId1234567'),
                                 new Contact(LastName = 'Tst Con1',AccountId = accList[0].Id,KTI_Contact_Id__c = '003tktsId1238907')
         };
         Insert conList;
         
         List<Lead> ldList = [SELECT Id FROM Lead WHERE ConnectionReceivedId != null AND KTI_Lead_Id__c != null LIMIT 5];
         
         List<Task> tsk = new List<Task>{new Task(WhatId = accList[0].Id,WhoId = conList[0].Id,Subject = 'Email'),
         new Task(whoId = ldList[0].Id,Subject='Meeting'),
         new Task(WhatId = accList[2].Id,WhoId = conList[0].Id,Subject = 'Email'),
         new Task(WhatId = product2List[1].Id,WhoId = conList[0].Id,Subject = 'Email')
         };
         Insert tsk;
         
         Task tk = new Task(WhatId = assetList[2].Id,WhoId = conList[0].Id,Subject = 'Email');
         //Insert tk;
         
         tsk[0].WhatId = accList[1].Id;
         tsk[1].WhatId = oppList[0].Id;
         tsk[1].WhoId = conList[0].Id;
         tsk[2].WhatId = assetList[0].Id;
         tsk[3].WhatId = caseList[0].Id;
         update tsk;
         
         tsk[0].WhatId = product2List[1].Id;
         tsk[1].KTI_con_lead_Id__c = '003tktsId1238907';
         tsk[2].whoId = ldList[1].Id;
         tsk[2].whatId = null;
         tsk[3].WhatId = quoteList[0].Id;
         update tsk;
         
     }
}