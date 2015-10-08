public class QuoteAttachmentExternalSharing {
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
    public class ResponseClass {
        public string kti_attachId;
        public String kts_attachId;
    }
    public class ResponseToSend {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }

    @future(callout=true)
    public static void sendQuoteAttach(Set<Id> attIdSet) {
        
        if( attIdSet != null && attIdSet.size() > 0 ) {
            List<AttachmentClass> attList = new List<AttachmentClass>();
            for( Attachment a:[ SELECT ID, Name, ParentId, Body, Description, ContentType, IsPrivate, 
                                        BodyLength, ConnectionSentId, ConnectionReceivedId FROM Attachment WHERE Id IN:attIdSet] ) {
                AttachmentClass attCls = new AttachmentClass();
                attCls.attId = a.Id;
                attCls.attName = a.Name;
                attCls.ParentId = a.ParentId;
                if( a.Body != null ) { 
                    attCls.attBody = EncodingUtil.base64Encode(a.Body);
                }
                attCls.Description = a.Description;
                attCls.ContentType = a.ContentType;
                attCls.IsPrivate = a.IsPrivate;
                attCls.BodyLength = a.BodyLength;
                attCls.ConnectionSentId = a.ConnectionSentId;
                attCls.ConnectionReceivedId = a.ConnectionReceivedId;
                attList.add(attCls);                   
            }
            if( attList != null && attList.size() > 0 ) {
                try {
                    Http h = new Http();
                    HttpRequest hreq = new HttpRequest();
                    hreq.setHeader('Content-Type', 'application/json');
                    hreq.setEndPoint( System.label.EndPointUrl + '/services/apexrest/receiveQuoteAttach/' );
                    hreq.setMethod('POST');
                    hreq.setBody(JSON.serialize(attList));
                    
                    HttpResponse hres = h.send(hreq);
                    
                    if( hres.getStatusCode() == 200 && hres.getStatus().toUpperCase() == 'OK' ) {
                        System.debug(':::::hres::::'+hres.getBody());
                    }
                    
                } catch(Exception ex) {
                    System.debug('::::::message:::'+ex.getMessage());
                }
                    
            }
            
            
            
            
        }
    }
}