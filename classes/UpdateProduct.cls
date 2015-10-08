@RestResource(UrlMapping='/updateProduct/')
global class UpdateProduct {
    public class KTSAndKTIId {
        public String ktsId;
        public String ktiId;
    }
    @HttpPOST
    global static string updateProductKTIId(){
    
        RestRequest req = RestContext.request;
        List<Product2> updateProductList = new List<Product2>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> productKtsIdAndKtiIdMap = new Map<String,String>();
        
        for(KTSAndKTIId str : IdClsList) {
            productKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
        }
        
        System.Debug('<----productKtsIdAndKtiIdMap---->'+productKtsIdAndKtiIdMap );
        if( productKtsIdAndKtiIdMap != NULL && productKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Product2 prod : [SELECT Id, KTS_Product_Id__c, KTI_Product_Id__c FROM Product2 WHERE Id IN : productKtsIdAndKtiIdMap.KeySet()]) {
                prod.KTI_Product_Id__c = productKtsIdAndKtiIdMap.get(prod.Id).substring(0,15);
                updateProductList.add(prod);
            }
            System.Debug('<----updateProductList---->'+updateProductList);

            if( updateProductList != NULL && updateProductList.Size() > 0 ) {
                update updateProductList;
            }
        }
        
        return NULL;
    }
}