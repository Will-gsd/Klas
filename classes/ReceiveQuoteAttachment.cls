@RestResource(UrlMapping='/receiveQuoteAttach/')
global class ReceiveQuoteAttachment {
     public Class AttachmentClass {
        public String attId;
        public String attName;
        public String ParentId;
        public String attBody;
        public String Description;
        public String ContentType;
        public Boolean IsPrivate;
        public Decimal BodyLength;
        public String ConnectionSentId;
        public String ConnectionReceivedId;

    }
    /*public class ResponseClass {
        public string kti_attachId;
        public String kts_attachId;
    }
    public class ResponseToSend {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }*/
    @HttpPost
    global static string receiveAttach() {
        RestRequest req = RestContext.request;
        
        //ResponseToSend resToSend = new ResponseToSend();
        System.debug(':::toString::::'+req.requestBody.toString());
        String jsonStr = req.requestBody.toString();
        
        Map<Id, Id> ktiQuoteIdktsquoteIdMap = new Map<Id, Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        
        List<Attachment> AttachmentInsertList = new List<Attachment>();
        try {
            List<AttachmentClass> attchList = (List<AttachmentClass>)JSON.deserialize(jsonStr,List<AttachmentClass>.Class);
            
            for(AttachmentClass attcls : attchList) {
                if(attcls.ParentId != null ) {
                    quoteIdSet.add(attcls.ParentId);
                }
            }
            System.debug(':quoteIdSet:::'+quoteIdSet);
            if(quoteIdSet != null && quoteIdSet.size() > 0 ) {
                for( Quote q: [SELECT id, KTI_Quote_Id__c FROM Quote WHERE KTI_Quote_Id__c != null AND KTI_Quote_Id__c IN:quoteIdSet]) {
                    ktiQuoteIdktsquoteIdMap.put(q.KTI_Quote_Id__c, q.Id); 
                }
            }
            System.debug('::ktiQuoteIdktsquoteIdMap::'+ktiQuoteIdktsquoteIdMap);
            for(AttachmentClass attcls : attchList) {
                if( attcls.attBody != null && attcls.ParentId != null && ktiQuoteIdktsquoteIdMap.containsKey(attcls.ParentId) ) {
                    Attachment att = new Attachment( Name = attcls.attName, ParentId = ktiQuoteIdktsquoteIdMap.get(attcls.ParentId),
                                                     Body = EncodingUtil.base64Decode(attcls.attBody), Description = attcls.Description,
                                                     ContentType = attcls.ContentType, IsPrivate = attcls.IsPrivate != null ? attcls.IsPrivate : false);
                    AttachmentInsertList.add(att);
                }
            }
            if( AttachmentInsertList != null && AttachmentInsertList.size() > 0 ) {
                AssetClass.helperFlagForQuoteAttach = TRUE;
                insert AttachmentInsertList;
                
            }
        
        } catch(Exception ex) {
            System.debug('::::message::::'+ex.getMessage());
            return ex.getMessage();
        }
        
        
        
        return 'success';
    }    
}