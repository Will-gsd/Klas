public class QuoteLineItemExternalSharing {
    public class QuoteLineItemClass {
        public String kts_quoteLineItemId;
        public String kts_quoteId;
        public String CurrencyIsoCode;
        public String Description;
        public Decimal ListPrice;
        public String pricebookEntryId;
        public Decimal Quantity;
        public Decimal TotalPrice;
        public Decimal UnitPrice;
        
        public String kts_ProductId;
        public String kts_pricebookId;
        public String kts_pricebookName;
        
        //SELECT CurrencyIsoCode,Description,Id,ListPrice,
            //PricebookEntryId,Quantity,QuoteId,TotalPrice,
            //UnitPrice FROM QuoteLineItem
    }
    public class responseClass {
        public string kti_QuoteLineItemId;
        public String kts_QuoteLineItemId;
    }
    
    public class ResponseMsgClass {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }
    @future(callout=true)
    public static void doPost(Set<Id> quotelineItemIdSet) {
        List<QuoteLineItemClass> qliclsList = new List<QuoteLineItemClass>();
        if( quotelineItemIdSet != null && quotelineItemIdSet.size()>0 ) {
           for(QuoteLineItem qli:[SELECT CurrencyIsoCode,Description,Id,LineNumber,ListPrice,PricebookEntryId,Quantity,
                                         QuoteId,SortOrder,TotalPrice,UnitPrice,PricebookEntry.Name,PricebookEntry.product2Id, 
                                         PricebookEntry.product2.Name, PricebookEntry.Pricebook2Id,PricebookEntry.Pricebook2.Name 
                                  FROM QuoteLineItem
                                  WHERE Id IN:quotelineItemIdSet]) {
                QuoteLineItemClass qliclass = new QuoteLineItemClass();
                qliclass.kts_quoteLineItemId = qli.Id;                       
                qliclass.kts_quoteId = qli.QuoteId;
                qliclass.CurrencyIsoCode = qli.CurrencyIsoCode;
                qliclass.Description = qli.Description;
                qliclass.ListPrice = qli.ListPrice;
                qliclass.pricebookEntryId = qli.PricebookEntryId;
                qliclass.Quantity = qli.Quantity;
                qliclass.TotalPrice = qli.TotalPrice;
                qliclass.UnitPrice = qli.UnitPrice;
                qliclass.kts_ProductId = qli.PricebookEntry.Product2Id!=null?String.valueOf(qli.PricebookEntry.Product2Id).subString(0,15):'';
                qliclass.kts_pricebookId = qli.PricebookEntry.Pricebook2Id;
                qliclass.kts_pricebookName = qli.PricebookEntry.Pricebook2.Name;
                qliclsList.add(qliclass);                  
            }
            
            Http h = new Http();
            HttpRequest hreq = new HttpRequest();
            hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/receiveQuoteLineItem/');
            //hreq.setHeader('Authorization', 'Bearer 00Dg0000003NtmR!AQ0AQGv21f9FUC8q089x.LpvMBfOnENA8baqfkeYUHUpKPtliJls1rcboSvBTFC4Bf5O9Y9vHY3I6nJoOXtzQaoH6EkMX10v');
            hreq.setMethod('POST');
            
            System.debug('::::::'+JSON.serialize(qliclsList));
             hreq.setHeader('Content-Type', 'application/json');
            hreq.setBody(JSON.serialize(qliclsList));
            HttpResponse hres = h.send(hreq);
            System.debug(':::::'+hres.getbody());
            
            if(hres.getStatus() == 'OK' && hres.getStatusCode() == 200) {
                
                String jsonStr = hres.getBody().unescapeJava();
                System.debug(':::::jsonStr '+jsonStr);
                String jsonStr1 = jsonStr.unescapeCsv();
                system.debug(':::::jsonStr1 '+jsonStr1 );
                
                ResponseMsgClass res = (ResponseMsgClass)JSON.deserialize(jsonStr1 , ResponseMsgClass.class);
                List<QuoteLineItem> updateQuoteLineItemList = new List<QuoteLineItem>();
                Map<String,String> quoteLineItemKtsandKtiIdMap = new Map<String,String>();
                
                if ( res != null && res.isSuccess == TRUE && res.responseResult == 'Success' ) {
            
                    for ( responseClass assetcls : res.resClsList ) {
                        
                        quoteLineItemKtsandKtiIdMap.put(assetcls.kts_QuoteLineItemId,assetcls.kti_QuoteLineItemId);
                    }
                    
                    
                    for( QuoteLineItem qt : [SELECT Id, KTI_Quote_Line_Item_Id__c FROM QuoteLineItem WHERE Id IN : quoteLineItemKtsandKtiIdMap.Keyset()] ) {
                        
                        if(qt.KTI_Quote_Line_Item_Id__c != quoteLineItemKtsandKtiIdMap.get(qt.Id) ) {
                            
                            QuoteLineItem q = new QuoteLineItem();
                            q.Id = qt.Id;
                            q.KTI_Quote_Line_Item_Id__c = quoteLineItemKtsandKtiIdMap.get(q.Id);
                            q.Updated_in_Source__c = TRUE;
                            updateQuoteLineItemList.add(q);
                        }
                    }
                    if ( updateQuoteLineItemList != NULL && updateQuoteLineItemList.Size() > 0 ) {
                        update updateQuoteLineItemList;
                    }
                    System.debug(':::updateQuoteLineItemList::'+updateQuoteLineItemList);
                }
            
            }else{
                System.debug(':::::Failure:::::'+hres.getBody());
            }
        }
    }
    
        
}