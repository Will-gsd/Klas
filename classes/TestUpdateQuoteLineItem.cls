@isTest(SeeAllData = TRUE)
public class TestUpdateQuoteLineItem{
    
    public class HttpResponseForAsset implements HttpCalloutMock {
        List<QuoteLineItem> qtList = [SELECT Id,KTI_Quote_Line_Item_Id__c FROM QuoteLineItem LIMIT 5];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kti_QuoteLineItemId\":\"987654rf243\",\"kts_QuoteLineItemId\":\"'+qtList[0].Id+'\"}],\"isSuccess\":true}"';
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(TestJSONContent);
            res.setStatus('Ok');
            return res;
        }
    }
    
    static testMethod void quoteLineItemupdate() {
        
        List<Account> accList = [SELECT Id,Name,KTI_ID__c FROM Account WHERE KTI_ID__c != NULL];
        Opportunity opp = new Opportunity(Name = 'Test opp',AccountId = accList[0].Id,StageName = 'Prospecting',CloseDate = System.Today() + 2,KTI_Id__c = 'ktiOppIdforTest');
        //Insert opp;
        List<Opportunity> oppList = [SELECT id,Name FROM Opportunity WHERE ConnectionReceivedId != NULL LIMIT 5];
        Quote q;
        List<QuoteLineItem> qLI = new List<QuoteLineItem>();
        Contact con = new Contact(LastName = 'Test Contact',AccountId = accList[0].Id);
        insert con;
        
        List<Product2> prodList = new List<Product2>{new Product2(Name = 'Test Prod 1',KTI_Product_Id__c='ktiProd1'),new Product2(Name = 'Test Prod 2',KTI_Product_Id__c='ktiProd2')};
        Insert prodList;  
        
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2 = new PriceBook2(Name = 'Test',IsActive = TRUE);
        Insert pb2;
        
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standard.Id,product2Id = prodList[0].Id, UnitPrice = 100,isactive = true);
        Insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = pb2.Id,product2Id = prodList[0].Id, UnitPrice = 100,isactive = true);
        Insert pbe1;
        
        if(accList != NULL && accList.Size() > 0 && oppList != NULL && oppList.size() > 0) {
            q = new Quote(Name = 'Test Quote 1',ContactId = con.Id,opportunityId = oppList[0].Id,KTI_Quote_Id__c = '0Q0g000000025VlCAI',Pricebook2Id=pb2.Id);
            Insert q;
        
            /*q.Name = 'Test Quott 1';
            q.Updated_in_Source__c = TRUE;
            q.KTI_Quote_Id__c = 'testQuoteId';
            update q;*/
            
            qLI = new List<QuoteLineItem>{new QuoteLineItem(QuoteId=q.Id,product2Id = prodList[0].Id,UnitPrice=100,Quantity = 1,PricebookEntryId=pbe1.Id),
            new QuoteLineItem(QuoteId=q.Id,product2Id = prodList[0].Id,Quantity = 1,UnitPrice=100,PricebookEntryId=pbe1.Id,KTI_Quote_Line_Item_Id__c = 'Test')};
            Insert qLI;
            
            qLI[0].Updated_in_Source__c = TRUE;
            
            update qLI;
        }
        
        Test.setMock(HttpCalloutMock.class, new HttpResponseForAsset());
        Test.StartTest();
        
        List<UpdateQuoteLineItem.QuoteLineItemClass> qtLIClsList = new List<UpdateQuoteLineItem.QuoteLineItemClass>();
        UpdateQuoteLineItem.QuoteLineItemClass qtLICls = new UpdateQuoteLineItem.QuoteLineItemClass();
        
        qtLICls.kti_quoteId = q.KTI_Quote_Id__c; 
        qtLICls.kti_ProductId = prodList[0].KTI_Product_Id__c;
        qtLICls.CurrencyIsoCode = 'USD';
        qtLICls.kti_pricebookName = 'Test';
        qtLICls.Quantity = 2;
        
        qtLIClsList.add(qtLICls);
        
        UpdateQuoteLineItem.QuoteLineItemClass qtLICls1 = new UpdateQuoteLineItem.QuoteLineItemClass();
        qtLICls1.kti_quoteId = q.KTI_Quote_Id__c; 
        qtLICls1.kti_quoteLineItemId = qLI[1].KTI_Quote_Line_Item_Id__c;
        qtLICls1.kti_ProductId = prodList[1].KTI_Product_Id__c;
        qtLICls1.CurrencyIsoCode = 'USD';
        qtLICls1.kti_pricebookName = 'Test';
        qtLICls1.Quantity = 2;
        
        qtLIClsList.add(qtLICls1);
        
        String JsonMsg=JSON.serialize(qtLIClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/updateQuoteLineItem';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateQuoteLineItem.postQuoteLineItemUpsert();
        Test.StopTest();
    }
}