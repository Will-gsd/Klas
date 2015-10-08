@isTest(SeeAllData = TRUE)
Public class TestUpdateQuote {
    public class HttpResponseForQuote implements HttpCalloutMock {
        List<Quote> qteList = [SELECT Id FROM Quote WHERE Name = 'Quote1'];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kts_QuoteId\":\"'+qteList[0].Id+'\",\"kti_QuoteId\":\"0Q0g00000001vloCAA\"}],\"isSuccess\":true}"';
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(TestJSONContent);
            res.setStatusCode(200);
            //res.setBody('success');
            res.setStatus('Ok');
            return res;
        }
    }
    public Static testmethod void testUpdateQuoteMethod() {
        Opportunity opp;
        Contact con;
        Account acc = new Account(Name = 'Test Acc',AccountSource = 'New Customer',Organization_Name__c = 'Test Org');
        Insert acc;
        
        List<Account> sharedAcc = [SELECT Id, Name, KTI_Id__c, connectionReceivedId FROM Account WHERE KTI_Id__c != NULL];
        System.Debug('sharedAcc '+sharedAcc );
        
        if ( sharedAcc != NULL && sharedAcc.Size() > 0 ) {
            
            con = new Contact(LastName = 'Test Con',AccountId=sharedAcc[0].Id,KTI_Contact_Id__c = '003M00k000cAxBZAAA');
            Insert con;
        }
        
        if ( sharedAcc != NULL && sharedAcc.Size() > 0 ) {
            opp = new Opportunity(Name = 'opp1',StageName= 'closed',CloseDate = System.today()+2,AccountId=sharedAcc[0].Id,KTI_ID__c = '006M00m000CKBbA');
            insert opp;
        }
        Test.setMock(HttpCalloutMock.class, new HttpResponseForQuote());
        
        Quote q = new Quote(Name = 'quote1', OpportunityId = opp.Id,ContactId = con.Id);
        Insert q; 
        
        List<UpdateQuote.QuoteClass> qteClsList = new List<UpdateQuote.QuoteClass>();
        UpdateQuote.QuoteClass qteCls = new UpdateQuote.QuoteClass();
        qteCls.kts_Quote_Id = q.Id;
        qteCls.Name = 'test qte';
        qteCls.email = 'test@gmail.com';
        qteCls.phone = '9876543210';
        qteCls.pricebookName = 'Test';
        qteCls.opportunityId = opp.KTI_Id__c;
        qteCls.contactId = con.KTI_Contact_Id__c;
        qteCls.kti_Quote_Id = 'testqtiId';
        
        qteClsList.add(qteCls);
        String JsonMsg=JSON.serialize(qteClsList);
        
        Test.startTest();
    
   //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateQuote';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateQuote.postQuoteLink();
        Test.stopTest();

    }
}