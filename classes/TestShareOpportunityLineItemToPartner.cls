@isTest(seeALLData=True)
public class TestShareOpportunityLineItemToPartner {

    public class HttpResponseForOppLineItem implements HttpCalloutMock {
        List<OpportunityLineItem> oppLIList = [SELECT Id FROM OpportunityLineItem LIMIT 5];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kti_OpportunityLineItemId\":\"987654rf243\",\"kts_OpportunityLineItemId\":\"'+oppLIList[0].Id+'\"}],\"isSuccess\":true}"';
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(TestJSONContent);
            res.setStatus('Ok');
            return res;
        }
    }
    
    static testMethod void methodTestShareOpportunityLineItemToPartner() {
        List<Account> accList = [SELECT Id,Name,KTS_ID__c FROM Account WHERE KTS_ID__c != NULL];
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Testing Product 1', ProductCode = 'tp1', Family = 'Others', IsActive = true));
        products.add(new Product2(Name = 'Testing Product 2', ProductCode = 'tp2', Family = 'Others', IsActive = true));
        products.add(new Product2(Name = 'Testing Product 3', ProductCode = 'tp3', Family = 'Others', IsActive = true));
        insert products;

        Pricebook2 priceBook = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];

        PriceBook2 priceBook2 = new PriceBook2(Name = 'Test',IsActive = TRUE);
        Insert priceBook2;

        PricebookEntry priceBookEntry1 = new PricebookEntry(Pricebook2Id = priceBook.Id, product2Id = products[0].Id, UnitPrice = 100, isactive = true);
        Insert priceBookEntry1;
        
        PricebookEntry priceBookEntry2 = new PricebookEntry(Pricebook2Id = priceBook2.Id, product2Id = products[0].Id, UnitPrice = 100, isactive = true);
        Insert priceBookEntry2;

        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        
        Opportunity[] opps=new Opportunity[] {
            new Opportunity(Name='Test Opportunity',CloseDate=System.TODAY(),StageName='Prospecting'),
            new Opportunity(Name='Test Opportunity 1',CloseDate=System.TODAY(),StageName='Prospecting')
        };
        insert opps;
        
        List<Opportunity> opList=[Select Id,KTI_Id__c  From Opportunity Where ConnectionReceivedId != NULL AND KTI_Id__c != NULL];
        
        if(accList != NULL && accList.Size() > 0 && opList != NULL && opList.size() > 0) {
            
            oLIList = new List<OpportunityLineItem>{
                new OpportunityLineItem(OpportunityId=opList.get(0).Id,Quantity = 1,UnitPrice = 100,PriceBookEntryId=priceBookEntry1.Id,Updated_in_Source__c = FALSE),
                new OpportunityLineItem(OpportunityId=opList.get(0).Id,Quantity = 1,UnitPrice = 100,PricebookEntryId=priceBookEntry1.Id,KTI_Opportunity_Line_Item_Id__c='00kM0000007G3CAIA0')
            };
            Insert oLIList;
        }
        test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpResponseForOppLineItem());

        test.stopTest();
        
    }
}