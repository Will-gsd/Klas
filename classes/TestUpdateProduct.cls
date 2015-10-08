@isTest
public Class TestUpdateProduct {
    static testMethod void productUpdateMethod() {
        
        Product2 newPro = new Product2(Name = 'Test Product',ProductCode = 'PRO 1');
        Insert newPro;
           
        List<UpdateProduct.KTSAndKTIId> productClsList = new List<UpdateProduct.KTSAndKTIId>();
        UpdateProduct.KTSAndKTIId productCls = new UpdateProduct.KTSAndKTIId();
        productCls.ktsId = newPro.Id;
        productCls.ktiId = '00QM05r0h0acqGn' ;
        
        productClsList.add(productCls);
        
        String JsonMsg=JSON.serialize(productClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateProduct';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateProduct.updateProductKTIId();

    }
}