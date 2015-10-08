@isTest(SeeAllData = TRUE)
public class TestShareAssetToPartner {
    
    public class HttpResponseForAsset implements HttpCalloutMock {
        Asset asset = [SELECT Id,KTI_Asset_Id__c FROM Asset WHERE KTI_Asset_Id__c != NULL Limit 1];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kts_assetId\":\"'+asset.Id+'\",\"kti_assetId\":\"'+asset.KTI_Asset_Id__c+'\"}],\"isSuccess\":true}"';
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
    
    static testMethod void assetInsert() {
        
        Account acc = new Account(Name = 'Test Acc',AccountSource = 'New Customer',Organization_Name__c = 'Test Org');
        Insert acc;
        
                      
        Test.setMock(HttpCalloutMock.class, new HttpResponseForAsset());
        
        List<Asset> aList = new List<Asset>{new Asset(Name = 'Asset1', AccountId = acc.Id)};
        Insert aList;
        
        aList[0].Updated_in_Source__c = TRUE;
        update aList;
         
        AssetExternalSharing.responseClass resCls = new AssetExternalSharing.responseClass();
        AssetExternalSharing.ResponseToSend resTosnd = new AssetExternalSharing.ResponseToSend();
           
    }
    
}