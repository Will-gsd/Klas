public class OpportunityLineItemExternalSharing {
    public class OpportunityLineItemClass {
        public String kts_opportunityLineItemId;
        public String kts_opportunityId;
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
    }
    
    public class responseClass {
        public string kti_OpportunityLineItemId;
        public String kts_OpportunityLineItemId;
    }
    
    public class ResponseMsgClass {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }
    @future(callout=true)
    public static void doPost(Set<Id> opliIdSet) {
    
        List<OpportunityLineItemClass> opliclsList = new List<OpportunityLineItemClass>();
        if( opliIdSet != null && opliIdSet.size()>0 ) {
        
           for( OpportunityLineItem opli : [ SELECT CurrencyIsoCode, Description, Id, ListPrice, PricebookEntryId, Quantity,
                                                 OpportunityId, SortOrder, TotalPrice, UnitPrice, PricebookEntry.Name, PricebookEntry.product2Id, 
                                                 PricebookEntry.product2.Name, PricebookEntry.Pricebook2Id, PricebookEntry.Pricebook2.Name 
                                            FROM OpportunityLineItem
                                            WHERE Id IN :opliIdSet
                                           ]) {
                OpportunityLineItemClass opliclass = new OpportunityLineItemClass();
                opliclass.kts_opportunityLineItemId = opli.Id;                       
                opliclass.kts_opportunityId = opli.OpportunityId != NULL ? String.valueOf(opli.OpportunityId).subString(0,15) : opli.OpportunityId;
                opliclass.CurrencyIsoCode = opli.CurrencyIsoCode; 
                opliclass.Description = opli.Description;
                opliclass.ListPrice = opli.ListPrice;
                opliclass.pricebookEntryId = opli.PricebookEntryId;
                opliclass.Quantity = opli.Quantity;
                opliclass.TotalPrice = opli.TotalPrice;
                opliclass.UnitPrice = opli.UnitPrice;
                opliclass.kts_ProductId = opli.PricebookEntry.Product2Id != NULL? String.valueOf(opli.PricebookEntry.Product2Id).subString(0,15) : '';
                opliclass.kts_pricebookId = opli.PricebookEntry.Pricebook2Id;
                opliclass.kts_pricebookName = opli.PricebookEntry.Pricebook2.Name;
                opliclsList.add(opliclass);                  
            }
            
            Http h = new Http();
            HttpRequest hreq = new HttpRequest();
            hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/receiveOpportunityLineItem/');
            hreq.setMethod('POST');
            hreq.setHeader('Content-Type', 'application/json');
            hreq.setBody(JSON.serialize(opliclsList));
            
            System.debug('Request body : ' + hreq.getBody());
            HttpResponse hres = h.send(hreq);
            System.debug('Response body : ' + hres.getBody());
            
            if(hres.getStatus() == 'OK' && hres.getStatusCode() == 200) {
                
                String jsonStr = hres.getBody().unescapeJava();
                System.debug('After escaping java : ' + jsonStr);
                
                String jsonStr1 = jsonStr.unescapeCsv();
                system.debug('After escaping CSV : ' + jsonStr1 );
                
                ResponseMsgClass res = (ResponseMsgClass)JSON.deserialize(jsonStr1 , ResponseMsgClass.class);
                List<OpportunityLineItem> updateOpportunityLineItemList = new List<OpportunityLineItem>();
                Map<String,String> oppLineItemKtsandKtiIdMap = new Map<String,String>();
                
                if ( res != null && res.isSuccess == TRUE && res.responseResult == 'Success' ) {
            
                    for ( responseClass assetcls : res.resClsList ) {
                        
                        oppLineItemKtsandKtiIdMap.put(assetcls.kts_opportunityLineItemId, assetcls.kti_OpportunityLineItemId);
                    }
                    
                    for( OpportunityLineItem opli : [SELECT Id, KTI_Opportunity_Line_Item_Id__c FROM OpportunityLineItem WHERE Id IN : oppLineItemKtsandKtiIdMap.Keyset()] ) {
                        
                        if(opli.KTI_Opportunity_Line_Item_Id__c != oppLineItemKtsandKtiIdMap.get(opli.Id) ) {
                            
                            OpportunityLineItem oppli1 = new OpportunityLineItem();
                            oppli1.Id = opli.Id;
                            oppli1.KTI_Opportunity_Line_Item_Id__c = oppLineItemKtsandKtiIdMap.get(oppli1.Id);
                            oppli1.Updated_in_Source__c = TRUE;
                            updateOpportunityLineItemList.add(oppli1);
                        }
                    }
                    if ( updateOpportunityLineItemList != NULL && updateOpportunityLineItemList.Size() > 0 ) {
                        update updateOpportunityLineItemList;
                    }
                    System.debug(':::updateOpportunityLineItemList::'+updateOpportunityLineItemList);
                }
            
            }else{
                System.debug(':::::Failure:::::'+hres.getBody());
            }
        }
    }
    
        
}