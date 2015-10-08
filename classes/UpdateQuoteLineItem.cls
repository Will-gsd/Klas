@RestResource(UrlMapping='/updateQuoteLineItem/') 
global without sharing class UpdateQuoteLineItem {
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
        
        public String kti_quoteLineItemId;
        public String kti_quoteId;
        public String kti_ProductId;
        public String kti_pricebookId;
        public String kti_pricebookName;
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
    @HttpPOST
    global static string postQuoteLineItemUpsert(){
        
        Set<String> ktiProductIdSet = new Set<String>();
        Set<String> pricebookNameSet = new Set<String>();
        Set<String> ktiquoteIdSet = new Set<String>();
        Set<String> ktiQuoteLineItemIdSet = new Set<String>();
        Set<String> currencyisocodeSet = new Set<String>();

        Map<String,Id> pricebookNameProductIdISOCodewithPricebookEntryIdMap = new Map<String, Id>();
        Map<String,QuoteLineItemClass> pricebookNameProductIdISOCodewithQuoteLineItemClassMap = new Map<String, QuoteLineItemClass>();
        Map<String, Id> pricebookNamewithIdMap = new Map<String, Id>();
        Map<String, Id> ktiProductIdwithKTSIdMap = new Map<String, Id>();
        Map<String, Id> ktiQuoteIdwithKTSQuoteIdMap = new Map<String, Id>();
        Map<String, QuoteLineItem> ktiQuoteLineItemIdwithKTSQuoteLineItemMap = new Map<String, QuoteLineItem>();
        
        List<PricebookEntry> insertPricebookEntryList = new List<PricebookEntry>();
        List<QuoteLineItem> insertquoteLineItemList = new List<QuoteLineItem>();
        List<QuoteLineItem> updatequoteLineItemList = new List<QuoteLineItem>();
        RestRequest req = RestContext.request;
        ResponseMsgClass resToSend = new ResponseMsgClass();
        System.debug(':::toString::::'+req.requestBody.toString());
        
        String jsonStr = req.requestBody.toString();
        List<QuoteLineItem> updateqliList = new List<QuoteLineItem>();
        
        try { 
            List<QuoteLineItemClass> quotelineItemClsList = (List<QuoteLineItemClass>)JSON.deserialize(jsonStr, List<QuoteLineItemClass>.class);
            System.Debug('<----quotelineItemClsList---->'+quotelineItemClsList);
            for(QuoteLineItemClass qlicls:quoteLineItemClsList){
                if( qlicls.kti_ProductId != NULL && qlicls.kti_ProductId != '' && qlicls.kti_pricebookName != NULL && qlicls.kti_pricebookName != '' ) {
                    String productIdStrTemp = qlicls.kti_ProductId.length() > 15 ? qlicls.kti_ProductId.substring(0,15) : qlicls.kti_ProductId; 
                    ktiProductIdSet.add(productIdStrTemp);
                    ktiQuoteLineItemIdSet.add(qlicls.kti_quoteLineItemId);
                    currencyisocodeSet.add(qlicls.CurrencyIsoCode);
                    pricebookNameSet.add(qlicls.kti_pricebookName);
                    ktiquoteIdSet.add(qlicls.kti_quoteId);
                    pricebookNameProductIdISOCodewithQuoteLineItemClassMap.put(qlicls.kti_pricebookName.toUpperCase()+productIdStrTemp+qlicls.CurrencyIsoCode, qlicls);
                    
                }
            }
            
            if( ktiQuoteLineItemIdSet != null && ktiQuoteLineItemIdSet.size() > 0 ) {
                for( QuoteLineItem qli1 :[  SELECT ID, KTI_Quote_Line_Item_Id__c 
                                            FROM QuoteLineItem WHERE KTI_Quote_Line_Item_Id__c != NULL 
                                            AND KTI_Quote_Line_Item_Id__c IN:ktiQuoteLineItemIdSet ] ) {
                    
                    ktiQuoteLineItemIdwithKTSQuoteLineItemMap.put(qli1.KTI_Quote_Line_Item_Id__c, qli1);
                    
                }
            }

            system.debug('***ktiquoteIdSet ' + ktiquoteIdSet);
                
            if( ktiquoteIdSet != null && ktiquoteIdSet.size() > 0 ) {
                for( Quote q: [SELECT Id, KTI_Quote_Id__c FROM Quote WHERE KTI_Quote_Id__c != NULL AND KTI_Quote_Id__c IN:ktiquoteIdSet] ) {
                    system.debug('***quote ' + q);
                    ktiQuoteIdwithKTSQuoteIdMap.put(q.KTI_Quote_Id__c, q.Id);
                }
            }
            if( pricebookNameSet != null && pricebookNameSet.size() > 0 ) {
                for(PriceBook2 pb: [SELECT Id, Name FROM PriceBook2 WHERE Name IN:pricebookNameSet]) {
                    pricebookNamewithIdMap.put(pb.Name.toUpperCase(), pb.Id);
                }
            }  
            System.Debug('pricebookNamewithIdMap---->>>'+pricebookNamewithIdMap);              
            if( ktiProductIdSet != null && ktiProductIdSet.size() > 0 ) {
                for(Product2 prod :[SELECT Id, KTI_Product_Id__c FROM Product2 WHERE KTI_Product_Id__c != null AND KTI_Product_Id__c IN:ktiProductIdSet]) {
                    ktiProductIdwithKTSIdMap.put( prod.KTI_Product_Id__c, prod.Id);
                }    
            }
            System.debug('pricebookNameSet--->>>'+pricebookNameSet);
            System.debug('currencyisocodeSet--->>>'+currencyisocodeSet);
            System.debug('ktiProductIdSet--->>>'+ktiProductIdSet);
            if( ktiProductIdSet != null && ktiProductIdSet.size() > 0 && pricebookNameSet != null && pricebookNameSet.size() > 0 ) {
                for( PricebookEntry pribookEty : [ SELECT id, Name, CurrencyISOCode, Pricebook2Id, Product2Id, ProductCode, Pricebook2.Name, Product2.KTI_Product_Id__c 
                                                   FROM PricebookEntry 
                                                   WHERE Product2.KTI_Product_Id__c != NULL 
                                                   AND Product2.KTI_Product_Id__c != '' 
                                                   AND ( Pricebook2.Name IN:pricebookNameSet 
                                                       AND Product2.KTI_Product_Id__c IN:ktiProductIdSet
                                                       AND CurrencyISOCode IN :currencyisocodeSet) ]) {
                    pricebookNameProductIdISOCodewithPricebookEntryIdMap.put( pribookEty.Pricebook2.Name.toUpperCase()+pribookEty.Product2.KTI_Product_Id__c+pribookEty.CurrencyISOCode, pribookEty.Id );
                    System.debug(':::::pricebookEntry::::'+pricebookNameProductIdISOCodewithPricebookEntryIdMap);
                }
                
                Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
                Map<Integer, String> insertindexwithStrMap = new Map<Integer, String>();
                integer i = 0;
                System.debug('pricebookNameProductIdISOCodewithQuoteLineItemClassMap---->>>'+pricebookNameProductIdISOCodewithQuoteLineItemClassMap);
                for( String qliC1 :pricebookNameProductIdISOCodewithQuoteLineItemClassMap.keySet() ) {
                
                    if(!pricebookNameProductIdISOCodewithPricebookEntryIdMap.containsKey(qliC1) ) {
                        String tempktiProductId = pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).kti_ProductId.length() > 15 ? 
                                                  pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).kti_ProductId.subString(0,15) :
                                                  pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).kti_ProductId;
                        if( pricebookNamewithIdMap != null && ktiProductIdwithKTSIdMap != null &&
                            pricebookNamewithIdMap.size() > 0 && ktiProductIdwithKTSIdMap.size() > 0 &&
                            ktiProductIdwithKTSIdMap.containsKey( tempktiProductId) &&
                            pricebookNamewithIdMap.containsKey( pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).kti_pricebookName.toUpperCase()) ) {
                            
                           
                            
                            PricebookEntry pbeStd = new PricebookEntry( Pricebook2Id = standard.Id,CurrencyISOCode= pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).CurrencyIsoCode,
                                        product2Id = ktiProductIdwithKTSIdMap.get(tempktiProductId), UnitPrice = pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).UnitPrice != null ?
                                        pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).UnitPrice : 0 );
                            
                            insertPricebookEntryList.add(pbeStd);
                            
                            PricebookEntry pbe = new PricebookEntry( Pricebook2Id = pricebookNamewithIdMap.get(pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).kti_pricebookName.toUpperCase()),
                                        product2Id = ktiProductIdwithKTSIdMap.get(tempktiProductId), UnitPrice = pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).UnitPrice != null ?
                                        pricebookNameProductIdISOCodewithQuoteLineItemClassMap.get(qliC1).UnitPrice : 0,isactive = true);
                            
                            insertPricebookEntryList.add(pbe);
                            
                            insertindexwithStrMap.put(i, qliC1);
                            i++;
                        }
                    }
                }
                
                if( insertPricebookEntryList != null && insertPricebookEntryList.size() > 0 ) {
                System.Debug('insertPricebookEntryList----->>>>'+insertPricebookEntryList);
                insert insertPricebookEntryList;
                Integer pos = 0;
                    for(PricebookEntry pbe2 : insertPricebookEntryList) {
                        if(pbe2.Pricebook2Id != standard.Id) {
                            if( insertindexwithStrMap.containsKey(pos) != null ) {
                                pricebookNameProductIdISOCodewithPricebookEntryIdMap.put( insertindexwithStrMap.get(pos), pbe2.Id );
                                pos++;
                            }
                        }
                    }
                }
                System.Debug('pricebookNameProductIdISOCodewithPricebookEntryIdMap--->>>'+pricebookNameProductIdISOCodewithPricebookEntryIdMap);
                System.Debug('ktiQuoteIdwithKTSQuoteIdMap--->>>'+ ktiQuoteIdwithKTSQuoteIdMap);
                if( pricebookNameProductIdISOCodewithPricebookEntryIdMap != null && pricebookNameProductIdISOCodewithPricebookEntryIdMap .size() > 0 &&
                    ktiQuoteIdwithKTSQuoteIdMap != null && ktiQuoteIdwithKTSQuoteIdMap.size() > 0 ) {
                    for(QuoteLineItemClass qlicls:quoteLineItemClsList){
                        if( qlicls.kti_pricebookName != null && qlicls.kti_quoteId != null && ktiQuoteIdwithKTSQuoteIdMap.containsKey(qlicls.kti_quoteId) && 
                            pricebookNameProductIdISOCodewithPricebookEntryIdMap.containsKey(qlicls.kti_pricebookName.toUpperCase()+qlicls.kti_ProductId+qlicls.CurrencyIsoCode) ) {

                            if( ktiQuoteLineItemIdwithKTSQuoteLineItemMap.containsKey(qlicls.kti_quoteLineItemId)) {
                                QuoteLineItem qlineItem = new QuoteLineItem(id = ktiQuoteLineItemIdwithKTSQuoteLineItemMap.get(qlicls.kti_quoteLineItemId).Id);
                                //qlineItem.QuoteId = ktsQuoteIdwithKTIQuoteIdMap.get(qlicls.kts_quoteId);
                                //qlineItem.PricebookEntryId = pricebookNameProductIdwithPricebookEntryIdMap.get(qlicls.kts_pricebookName.toUpperCase()+qlicls.kts_ProductId);
                                qlineItem.Description = qlicls.Description;
                                qlineItem.UnitPrice = qlicls.UnitPrice != null ? qlicls.UnitPrice : 0;
                                qlineItem.Quantity = qlicls.Quantity != null ? qlicls.Quantity : 0;
                                qlineItem.KTI_Quote_Line_Item_Id__c = qlicls.kti_quoteLineItemId;
                                qlineItem.Updated_in_Source__c = TRUE;
                                System.debug(':::::QuoteLineItem::::'+qlineItem);
                                System.debug(':::::PricebookEntryId ::::'+qlineItem.PricebookEntryId );
                                System.debug(':::::qlineItem.QuoteId::::'+qlineItem.QuoteId );
                                System.debug(':::::qlicls.UnitPrice::::'+qlicls.UnitPrice );
                                System.debug(':::::qlicls.Quantity::::'+qlicls.Quantity );
                                
                                
                                updatequoteLineItemList.add(qlineItem);
                            } else {
                                QuoteLineItem qlineItem = new QuoteLineItem();
                                qlineItem.QuoteId = ktiQuoteIdwithKTSQuoteIdMap.get(qlicls.kti_quoteId);
                                qlineItem.PricebookEntryId = pricebookNameProductIdISOCodewithPricebookEntryIdMap.get(qlicls.kti_pricebookName.toUpperCase()+qlicls.kti_ProductId+qlicls.CurrencyIsoCode);
                                qlineItem.Description = qlicls.Description;
                                qlineItem.UnitPrice = qlicls.UnitPrice != null ? qlicls.UnitPrice : 0;
                                qlineItem.Quantity = qlicls.Quantity != null ? qlicls.Quantity : 0;
                                qlineItem.KTI_Quote_Line_Item_Id__c = qlicls.kti_quoteLineItemId;
                                System.debug(':::::QuoteLineItem::::'+qlineItem);
                                System.debug(':::::PricebookEntryId ::::'+qlineItem.PricebookEntryId );
                                System.debug(':::::qlineItem.QuoteId::::'+qlineItem.QuoteId );
                                System.debug(':::::qlicls.UnitPrice::::'+qlicls.UnitPrice );
                                System.debug(':::::qlicls.Quantity::::'+qlicls.Quantity );
                                
                                
                                insertquoteLineItemList.add(qlineItem);
                            }

                        }
                    }
                }
                system.debug('***insertquoteLineItemList ' + insertquoteLineItemList);
                if( insertquoteLineItemList != null && insertquoteLineItemList.size() > 0 ) {
                    insert insertquoteLineItemList;// KTS_Quote_Line_Item_Id__c
                }
                if( updatequoteLineItemList != null && updatequoteLineItemList.size() > 0 ) {
                    update updatequoteLineItemList;
                }
                List<responseClass> responseClassList = new List<responseClass>(); 
        
                for( QuoteLineItem q : insertquoteLineItemList ) {
                    responseClass rc = new responseClass();
                    rc.kti_QuoteLineItemId = q.KTI_Quote_Line_Item_Id__c;
                    rc.kts_QuoteLineItemId = q.Id;
                    responseClassList.add(rc);
                }
                /*for( QuoteLineItem q : updatequoteLineItemList) {
                    responseClass rc = new responseClass();
                    rc.kts_QuoteLineItemId = q.Id;
                    rc.kti_QuoteLineItemId = q.KTI_Quote_Line_Item_Id__c;
                    responseClassList.add(rc);
                }*/
                
                resToSend.isSuccess = TRUE;
                resToSend.responseResult = 'Success';
                resToSend.resClsList.addAll(responseClassList);
                
            } else {  
                resToSend.isSuccess = FALSE;
                resToSend.responseResult = 'KTI Product Id or KTI Price Book Name Blank';
            }
        } catch(Exception e) {
            System.debug('::::e:::Message:::'+e.getMessage());
            System.Debug('Inside catch');
            resToSend.isSuccess = FALSE;
            resToSend.responseResult = e.getMessage();
        
        }
        
        return JSON.serialize(resToSend);
    }        
}