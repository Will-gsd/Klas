@isTest
public class TestShareQuoteAttachmentToPartner {
    
    public class MockAttachmentGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('success');
            res.setStatus('Ok');
            return res;
        }
    }
    
    static testMethod void quoteAttachInsert() {
        Opportunity opp = new Opportunity(Name = 'opp1',StageName= 'closed',CloseDate = System.today()+2);
        insert opp;
        
        Quote q = new Quote(Name = 'quote1', OpportunityId = opp.Id);
        insert q;
        
        Test.setMock(HttpCalloutMock.class, new MockAttachmentGenerator());
            
            Attachment attach=new Attachment();    
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=q.id;
            insert attach;
    }
    
}