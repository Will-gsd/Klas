@isTest(SeeAllData = TRUE)
public class TestShareQuoteToPartner {
    
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
    
    static testMethod void quoteInsert() {
        List<Opportunity> opp = new List<Opportunity>();
        Contact con;
        
        List<Account> sharedAcc = [SELECT Id,Name,connectionSentId,connectionReceivedId FROM Account ORDER BY CreatedDate DESC];
        System.Debug('sharedAcc '+sharedAcc );
        
        if ( sharedAcc != NULL && sharedAcc.Size() > 0 ) {
            
            con = new Contact(LastName = 'Test Con',AccountId=sharedAcc[2].Id);
            Insert con;
        }
        
        if ( sharedAcc != NULL && sharedAcc.Size() > 0 ) {
            opp = [SELECT Id FROM Opportunity WHERE connectionReceivedId!=NULL LIMIT 5];
            //opp = new Opportunity(Name = 'opp1',StageName= 'closed',CloseDate = System.today()+2,AccountId=sharedAcc[2].Id);
            //insert opp;
        }
                
        Test.setMock(HttpCalloutMock.class, new HttpResponseForQuote());
        
        Quote q = new Quote(Name = 'quote1', OpportunityId = opp[0].Id,ContactId = con.Id);
        Insert q; 
        QuoteExternalSharing.responseClass resCls = new QuoteExternalSharing.responseClass();
        QuoteExternalSharing.ResponseToSend resTosnd = new QuoteExternalSharing.ResponseToSend();
           
    }
    
}