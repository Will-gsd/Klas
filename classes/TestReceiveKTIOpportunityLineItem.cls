@isTest(seeAllData=True)
public class TestReceiveKTIOpportunityLineItem {
    
    public class HttpResponseForOLI implements HttpCalloutMock {
    List<OpportunityLineItem> oppLIList = [SELECT Id FROM OpportunityLineItem LIMIT 5];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kts_OpportunityLineItemId\":\"'+oppLIList[0].Id+'\",\"kti_OpportunityLineItemId\":\"987654rf243\"}],\"isSuccess\":true}"';
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(TestJSONContent);
            res.setStatus('Ok');
            return res;
        }
    }
    
    static testMethod void methodTestReceiveKTIOpportunityLineItem() {
        
        List<Account> accList = [SELECT Id,Name,KTI_ID__c FROM Account WHERE KTI_ID__c != NULL];
        //Opportunity opp = new Opportunity(Name = 'Test opp',AccountId = accList[0].Id,StageName = 'Prospecting',CloseDate = System.Today() + 2,KTS_Id__c = 'ktsOppIdforTest');
        //Insert opp;
        List<Opportunity> oppList = [SELECT id,Name FROM Opportunity WHERE ConnectionReceivedId != NULL LIMIT 5];
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        Contact con = new Contact(LastName = 'Test Contact',AccountId = accList[0].Id);
        insert con;
        
        //List<Product2> prodList = [SELECT Id,Name,KTI_Product_Id__c FROM Product2 WHERE ConnectionReceivedId != null];
        List<Product2> prodList = new List<Product2>{new Product2(Name = 'Test Prod 1',KTI_Product_Id__c='ktiProd1'),new Product2(Name = 'Test Prod 2',KTI_Product_Id__c='ktiProd2')};
        Insert prodList; 
        
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2 = new PriceBook2(Name = 'Test',IsActive = TRUE);
        Insert pb2;
       
        Opportunity opp = new Opportunity(Name = 'Test opp',AccountId = accList[0].Id,StageName = 'Prospecting',CloseDate = System.Today() + 2,KTI_Id__c = 'ktiOppIdforTest',PriceBook2Id=pb2.Id);
        Insert opp;
        
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standard.Id,product2Id = prodList[0].Id, UnitPrice = 100,isactive = true);
        Insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = pb2.Id,product2Id = prodList[0].Id, UnitPrice = 100,isactive = true);
        Insert pbe1;
        
        if(accList != NULL && accList.Size() > 0 && oppList != NULL && oppList.size() > 0) {
            
            oLIList = new List<OpportunityLineItem>{new OpportunityLineItem(OpportunityId=opp.Id,Quantity = 1,UnitPrice = 100,PriceBookEntryId=pbe1.Id),
            new OpportunityLineItem(OpportunityId=opp.Id,Quantity = 1,UnitPrice = 100,PricebookEntryId=pbe1.Id,KTI_Opportunity_Line_Item_Id__c = 'Test')};
            Insert oLIList;
        }
        
        Test.setMock(HttpCalloutMock.class, new HttpResponseForOLI());
        TEst.StartTest();
        List<ReceiveKTIOpportunityLineItem.OpportunityLineItemClass> opliClsList = new List<ReceiveKTIOpportunityLineItem.OpportunityLineItemClass>();
        ReceiveKTIOpportunityLineItem.OpportunityLineItemClass opliCls = new ReceiveKTIOpportunityLineItem.OpportunityLineItemClass();
        opliCls.kti_pricebookName = 'Test';
        opliCls.kti_opportunityId = opp.KTI_Id__c;
        opliCls.CurrencyIsoCode = 'USD';
        opliCls.Quantity = 2;
        opliCls.kti_ProductId = prodList[0].KTI_Product_Id__c ;
        
        opliClsList.add(opliCls);
        
        ReceiveKTIOpportunityLineItem.OpportunityLineItemClass opliCls1 = new ReceiveKTIOpportunityLineItem.OpportunityLineItemClass();
        opliCls1.kti_opportunityLineItemId = oLIList[1].KTI_Opportunity_Line_Item_Id__c;
        opliCls1.kti_pricebookName = 'Test';
        opliCls1.kti_opportunityId = opp.KTI_Id__c;
        opliCls1.CurrencyIsoCode = 'USD';
        opliCls1.kti_ProductId = prodList[1].KTI_Product_Id__c ;
        opliCls1.Quantity = 2;
        //opliCls1.kti_pricebookId = pb2.Id;
        
        opliClsList.add(opliCls1);
        String JsonMsg=JSON.serialize(opliClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/receiveKTIOpportunityLineItem';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ReceiveKTIOpportunityLineItem.postOpportunityLineItemUpsert();
        Test.StopTest();

        
    } 
}