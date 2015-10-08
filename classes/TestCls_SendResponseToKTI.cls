@isTest(SeeAllData = TRUE)
public class TestCls_SendResponseToKTI {

     public class HttpResponseForCon implements HttpCalloutMock {
        
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
    static testmethod void Cls_SendResponseToKTSMethod(){
        Map<String,String> accKTIIdAndKTSIdMap = new Map<String,String>();
        Map<String,String> conKTIIdAndKTSIdMap = new Map<String,String>();
        Map<Id,Id> leadKTIIdAndKTSIdMap = new Map<Id,Id>();
        Map<Id,Id> prodKTIIdAndKTSIdMap = new Map<Id,Id>();
        Map<String,String> oppKtiIdAndKtsIdMap = new Map<String,String>();
        Map<String,String> caseKTIIdAndKTSIdMap = new Map<String,String>();
        Map<String,String> taskKTIIdAndKTSIdMap = new Map<String,String>();
        
        Account acc = new Account(Name = 'Test Acc 1',KTI_Id__c = '001pg000000G2xU');
        Insert acc;
        
        List<Account> accList = [SELECT Id FROM Account WHERE ConnectionReceivedId != NULL Limit 5];
        Contact con = new Contact(LastName = 'Test Con 1',AccountId = accList[0].Id,KTI_Contact_Id__c = '01pg0000000G2xU');
        Insert con;
        
        Lead ld = new Lead(LastName = 'Test Lead1',Company ='Test',Status = 'Open',KTI_Lead_Id__c = '01pg0000000G2xU');
        Insert ld;
        
        Product2 pro = new Product2(Name = 'Test Pro 1',ProductCode = 'Pro 1',KTI_Product_Id__c = '01pg0000000G2xU');
        Insert pro;
        
        Opportunity opp = new Opportunity(Name = 'Test opp',StageName='Evaluation',CloseDate=System.Today(),Type='Hardware',KTI_Id__c = '006g0000000G2xU');
        Insert opp;
        
        Case c = new Case(AccountId=accList[0].Id,KTI_Case_Id__c = '500M00000066xX2');
        Insert c;
        
        Task tsk = new Task(WhatId = accList[0].Id,WhoId = con.Id,Subject = 'Email',KTI_Task_Id__c='003tktsId1238907');
        Insert tsk;
        
        Test.setMock(HttpCalloutMock.class, new HttpResponseForCon());
        accKTIIdAndKTSIdMap.put('001pg000000G2xU',acc.Id);
        Cls_SendResponseToKTI.updateAccountKTSIdToKTI(accKTIIdAndKTSIdMap);
        conKTIIdAndKTSIdMap.put('01pg0000000G2xU',con.Id);
        Cls_SendResponseToKTI.updateContactKTSIdToKTI(conKTIIdAndKTSIdMap);
        leadKTIIdAndKTSIdMap.put('01pg0000000G2xU',ld.Id);
        Cls_SendResponseToKTI.updateLeadKTSToKTI(leadKTIIdAndKTSIdMap);
        prodKTIIdAndKTSIdMap.put('01pg0000000G2xU',pro.Id);
        Cls_SendResponseToKTI.updateProductKTSIdToKTI(prodKTIIdAndKTSIdMap);
        oppKtiIdAndKtsIdMap.put('006g0000000G2xU',opp.Id);
        Cls_SendResponseToKTI.updateOpportunityKTSIdToKTI(oppKtiIdAndKtsIdMap);
        caseKTIIdAndKTSIdMap.put('500M00000066xX2',c.Id);
        Cls_SendResponseToKTI.updateCaseKTSIdToKTI(caseKTIIdAndKTSIdMap);
        taskKTIIdAndKTSIdMap.put('003tktsId1238907',tsk.Id);
        Cls_SendResponseToKTI.updateTaskKTSIdToKTI(taskKTIIdAndKTSIdMap);
        
    }
}