@isTest(SeeAllData = TRUE)
public class TestUpdateAsset {
    
    public class HttpResponseForAsset implements HttpCalloutMock {
        List<Asset> astList = [SELECT Id,KTI_Asset_Id__c FROM Asset WHERE KTI_Asset_Id__c != NULL];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kts_assetId\":\"'+astList[0].Id+'\",\"kti_assetId\":\"'+astList[0].KTI_Asset_Id__c+'\"}],\"isSuccess\":true}"';
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
        
        List<Account> accList = [SELECT Id,Name,KTI_Id__c FROM Account WHERE KTI_Id__c != null LIMIT 1];
        List<Contact> conList =  [SELECT Id,Name,KTI_Contact_Id__c FROM Contact WHERE KTI_Contact_Id__c != null LIMIT 1];
        List<Opportunity> oppList = [SELECT Id,Name,KTI_Id__c FROM Opportunity WHERE KTI_Id__c != null LIMIT 1]; 
              
        Test.setMock(HttpCalloutMock.class, new HttpResponseForAsset());
        
        Asset a = new Asset(Name = 'Asset1', AccountId = accList[0].Id);
        Insert a; 
        
        Product2 newPro = new Product2(Name = 'Test Product',ProductCode = 'PRO 1',KTI_Product_Id__c = '01tg0000002WOl1');
        Insert newPro;
        
        AssetExternalSharing.responseClass resCls = new AssetExternalSharing.responseClass();
        AssetExternalSharing.ResponseToSend resTosnd = new AssetExternalSharing.ResponseToSend();
           
        List<UpdateAssets.AssetClass> astClsList = new List<UpdateAssets.AssetClass>();
        UpdateAssets.AssetClass astCls = new UpdateAssets.AssetClass();
        astCls.assetName = 'Asset1';
        astCls.asstId = 'ktiassetId';
        astCls.kts_Asset_Id = a.Id;
        astCls.product2Id = newPro.KTI_Product_Id__c;
        if(accList != null && accList.size() > 0) astCls.asstAccountId   = accList[0].KTI_Id__c;
        if(conList != null && conList.size() > 0) astCls.asstContactId   = conList[0].KTI_Contact_Id__c;
        if(oppList != null && oppList.size() > 0) astCls.asstOpportunity = oppList[0].KTI_Id__c;
        astCls.assetdescription = 'Test';
        astCls.serialNumber = 'S-123';
        astCls.IsCompetitorProd = FALSE;
        
        astClsList.add(astCls);
        String JsonMsg=JSON.serialize(astClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateAsset';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateAssets.postFormRegistration();

    }
    
}