@RestResource(UrlMapping='/receiveKTIOpportunityLineItem/') 
global class ReceiveKTIOpportunityLineItem {
    public class OpportunityLineItemClass {
        public String kti_opportunityLineItemId;
        public String kti_opportunityId;
        public String CurrencyIsoCode;
        public String Description;
        public Decimal ListPrice;
        public String pricebookEntryId;
        public Decimal Quantity;
        public Decimal TotalPrice;
        public Decimal UnitPrice;
        
        public String kti_ProductId;
        public String kti_pricebookId;
        public String kti_pricebookName;
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
    @HttpPOST
    global static string postOpportunityLineItemUpsert(){
        Set<String> ktiProductIdSet = new Set<String>();
        Set<String> pricebookNameSet = new Set<String>();
        Set<String> ktioppIdSet = new Set<String>();
        Set<String> ktiOpportunityLineItemIdSet = new Set<String>();
        Set<String> currencyisocodeSet = new Set<String>();

        Map<String,Id> pricebookNameProductIdISOCodewithPricebookEntryIdMap = new Map<String, Id>();
        Map<String,OpportunityLineItemClass> pricebookNameProductIdISOCodewithOppLineItemClassMap = new Map<String, OpportunityLineItemClass>();
        Map<String, Id> pricebookNamewithIdMap = new Map<String, Id>();
        Map<String, Id> ktiProductIdwithKTSIdMap = new Map<String, Id>();
        Map<String, Id> ktiOppIdwithKTSOppIdMap = new Map<String, Id>();
        Map<String, OpportunityLineItem> ktiOppLineItemIdwithKTSOppLineItemMap = new Map<String, OpportunityLineItem>();
        
        List<PricebookEntry> insertPricebookEntryList = new List<PricebookEntry>();
        List<OpportunityLineItem> insertOppLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> updateOppLineItemList = new List<OpportunityLineItem>();
        
        RestRequest req = RestContext.request;
        ResponseMsgClass resToSend = new ResponseMsgClass();
        
        //System.debug(':::toString::::'+req.requestBody.toString());
        if(req != null && req.requestBody != null){
            System.debug(':::toString::::'+req.requestBody.toString());    
            String jsonStr = req.requestBody.toString();
            try {
                List<OpportunityLineItemClass> oppLineItemClsList = (List<OpportunityLineItemClass>)JSON.deserialize(jsonStr, List<OpportunityLineItemClass>.class);
                
                for ( OpportunityLineItemClass oplicls : oppLineItemClsList ) {
                
                    if( oplicls.kti_ProductId != NULL && oplicls.kti_ProductId != '' && oplicls.kti_pricebookName != NULL && oplicls.kti_pricebookName != '' ) {
                        String productIdStrTemp = oplicls.kti_ProductId.length() > 15 ? oplicls.kti_ProductId.substring(0,15) : oplicls.kti_ProductId; 
                        currencyisocodeSet.add(oplicls.CurrencyIsoCode);
                        ktiProductIdSet.add(productIdStrTemp);
                        ktiOpportunityLineItemIdSet.add(oplicls.kti_opportunityLineItemId);
                        
                        pricebookNameSet.add(oplicls.kti_pricebookName);
                        ktioppIdSet.add(oplicls.kti_opportunityId);
                        pricebookNameProductIdISOCodewithOppLineItemClassMap.put(oplicls.kti_pricebookName.toUpperCase()+productIdStrTemp+oplicls.CurrencyIsoCode, oplicls);
                    }
                }
                if( ktiOpportunityLineItemIdSet != null && ktiOpportunityLineItemIdSet.size() > 0 ) {
                    for( OpportunityLineItem opli1 :[  SELECT ID, KTI_Opportunity_Line_Item_Id__c 
                                                FROM OpportunityLineItem WHERE KTI_Opportunity_Line_Item_Id__c != NULL 
                                                AND KTI_Opportunity_Line_Item_Id__c IN :ktiOpportunityLineItemIdSet ] ) {
                        
                        ktiOppLineItemIdwithKTSOppLineItemMap.put(opli1.KTI_Opportunity_Line_Item_Id__c, opli1);
                        
                    }
                }
                
                if( ktioppIdSet != null && ktioppIdSet.size() > 0 ) {
                    for( Opportunity  opp: [SELECT Id, KTI_Id__c, CurrencyIsoCode FROM Opportunity WHERE KTI_Id__c != NULL AND KTI_Id__c IN :ktioppIdSet] ) {
                        ktiOppIdwithKTSOppIdMap.put(opp.KTI_Id__c, opp.Id);
                    }
                }
                
                
                if( pricebookNameSet != null && pricebookNameSet.size() > 0 ) {
                    for(PriceBook2 pb: [SELECT Id, Name FROM PriceBook2 WHERE Name IN :pricebookNameSet]) {
                        pricebookNamewithIdMap.put(pb.Name.toUpperCase(), pb.Id);
                    }
                }                
                if( ktiProductIdSet != null && ktiProductIdSet.size() > 0 ) {
                    for(Product2 prod :[SELECT Id, KTI_Product_Id__c FROM Product2 WHERE KTI_Product_Id__c != null AND KTI_Product_Id__c IN:ktiProductIdSet]) {
                        ktiProductIdwithKTSIdMap.put( prod.KTI_Product_Id__c, prod.Id);
                    }    
                }
                if( ktiProductIdSet != null && ktiProductIdSet.size() > 0 && pricebookNameSet != null && pricebookNameSet.size() > 0 ) {
                    for( PricebookEntry pribookEty : [ SELECT id, Name, CurrencyISOCode, Pricebook2Id, Product2Id, ProductCode, Pricebook2.Name, Product2.KTI_Product_Id__c 
                                                       FROM PricebookEntry 
                                                       WHERE Product2.KTI_Product_Id__c != NULL 
                                                       AND Product2.KTI_Product_Id__c != '' 
                                                       AND ( Pricebook2.Name IN :pricebookNameSet 
                                                             AND Product2.KTI_Product_Id__c IN :ktiProductIdSet
                                                             AND CurrencyISOCode IN :currencyisocodeSet) ]) {
           
                        pricebookNameProductIdISOCodewithPricebookEntryIdMap.put( pribookEty.Pricebook2.Name.toUpperCase()+pribookEty.Product2.KTI_Product_Id__c+pribookEty.CurrencyISOCode, pribookEty.Id );
                    }
                    
                    System.debug('pricebookNameProductIdISOCodewithPricebookEntryIdMap : ' + pricebookNameProductIdISOCodewithPricebookEntryIdMap);
                    
                    Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
                    Map<Integer, String> insertindexwithStrMap = new Map<Integer, String>();
                    integer i = 0;
                    for( String opliC1 :pricebookNameProductIdISOCodewithOppLineItemClassMap.keySet() ) {
                        if(!pricebookNameProductIdISOCodewithPricebookEntryIdMap.containsKey(opliC1) ) {
                            String tempktsProductId = pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).kti_ProductId.length() > 15 ? 
                                                      pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).kti_ProductId.subString(0,15) :
                                                      pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).kti_ProductId;
                            if( pricebookNamewithIdMap != null && ktiProductIdwithKTSIdMap != null &&
                                pricebookNamewithIdMap.size() > 0 && ktiProductIdwithKTSIdMap.size() > 0 &&
                                ktiProductIdwithKTSIdMap.containsKey( tempktsProductId) &&
                                pricebookNamewithIdMap.containsKey( pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).kti_pricebookName.toUpperCase()) ) {
                                
                                    PricebookEntry pbeStd = new PricebookEntry( Pricebook2Id = standard.Id, CurrencyISOCode= pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).CurrencyIsoCode,
                                                product2Id = ktiProductIdwithKTSIdMap.get(tempktsProductId), UnitPrice = pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).UnitPrice != null ?
                                                pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).UnitPrice : 0 );
                                    insertPricebookEntryList.add(pbeStd);                                
                                    
                                    PricebookEntry pbe = new PricebookEntry( Pricebook2Id = pricebookNamewithIdMap.get(pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).kti_pricebookName.toUpperCase()),
                                                CurrencyISOCode= pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).CurrencyIsoCode,
                                                product2Id = ktiProductIdwithKTSIdMap.get(tempktsProductId), UnitPrice = pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).UnitPrice != null ?
                                                pricebookNameProductIdISOCodewithOppLineItemClassMap.get(opliC1).UnitPrice : 0, isActive=TRUE );
                                    
                                    insertPricebookEntryList.add(pbe);
                                    
                                    insertindexwithStrMap.put(i, opliC1);
                                    i++;
                                }
                            
                        }
                    }
                    System.debug('insertPricebookEntryList : ' + insertPricebookEntryList);
                    System.debug('insertindexwithStrMap : ' + insertindexwithStrMap);
                    if( insertPricebookEntryList != null && insertPricebookEntryList.size() > 0 ) {
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
                    System.debug('pricebookNameProductIdISOCodewithPricebookEntryIdMap: ' + pricebookNameProductIdISOCodewithPricebookEntryIdMap);
                    if( pricebookNameProductIdISOCodewithPricebookEntryIdMap != null && pricebookNameProductIdISOCodewithPricebookEntryIdMap.size() > 0 &&
                        
                        ktiOppIdwithKTSOppIdMap != null && ktiOppIdwithKTSOppIdMap.size() > 0 ) {
                        
                        for(OpportunityLineItemClass oplicls : oppLineItemClsList){
                            
                            if( oplicls.kti_pricebookName != null && oplicls.kti_opportunityId != null && ktiOppIdwithKTSOppIdMap.containsKey(oplicls.kti_opportunityId) && 
                                
                                pricebookNameProductIdISOCodewithPricebookEntryIdMap.containsKey(oplicls.kti_pricebookName.toUpperCase()+oplicls.kti_ProductId+oplicls.CurrencyIsoCode) ) {

                                OpportunityLineItem opli;
                                
                                if( ktiOppLineItemIdwithKTSOppLineItemMap.containsKey(oplicls.kti_opportunityLineItemId)) {
                                    
                                    opli = new OpportunityLineItem(id = ktiOppLineItemIdwithKTSOppLineItemMap.get(oplicls.kti_opportunityLineItemId).Id);
                                    opli.Description = oplicls.Description;
                                    opli.UnitPrice = oplicls.UnitPrice != null ? oplicls.UnitPrice : 0;
                                    opli.Quantity = oplicls.Quantity != null ? oplicls.Quantity : 0;
                                    opli.KTI_Opportunity_Line_Item_Id__c = oplicls.kti_opportunityLineItemId;
                                    opli.Updated_in_Source__c = TRUE;
                                    
                                    System.debug(':::::OpportunityLineItem::::'+opli);
                                    System.debug(':::::PricebookEntryId ::::'+opli.PricebookEntryId );
                                    System.debug(':::::opli.OpportunityId::::'+opli.OpportunityId);
                                    System.debug(':::::oplicls.UnitPrice::::'+oplicls.UnitPrice );
                                    System.debug(':::::oplicls.Quantity::::'+oplicls.Quantity );
                                    
                                    updateOppLineItemList.add(opli);
                                    
                                } else {
                                
                                    opli = new OpportunityLineItem();
                                    opli.OpportunityId = ktiOppIdwithKTSOppIdMap.get(oplicls.kti_opportunityId);
                                    opli.PricebookEntryId = pricebookNameProductIdISOCodewithPricebookEntryIdMap.get(oplicls.kti_pricebookName.toUpperCase()+oplicls.kti_ProductId+oplicls.CurrencyIsoCode);
                                    opli.Description = oplicls.Description;
                                    opli.UnitPrice = oplicls.UnitPrice != null ? oplicls.UnitPrice : 0;
                                    opli.Quantity = oplicls.Quantity != null ? oplicls.Quantity : 0;
                                    opli.KTI_Opportunity_Line_Item_Id__c = oplicls.kti_opportunityLineItemId;
                                    
                                    System.debug(':::::OpportunityLineItem::::'+opli);
                                    System.debug(':::::PricebookEntryId ::::'+opli.PricebookEntryId );
                                    System.debug(':::::opli.OpportunityId::::'+opli.OpportunityId);
                                    System.debug(':::::oplicls.UnitPrice::::'+oplicls.UnitPrice );
                                    System.debug(':::::oplicls.Quantity::::'+oplicls.Quantity );                                    
                                    
                                    insertOppLineItemList.add(opli);
                                }

                            }
                        }
                    }
                    if( insertOppLineItemList != null && insertOppLineItemList.size() > 0 ) {
                        insert insertOppLineItemList;
                    }
                    if( updateOppLineItemList != null && updateOppLineItemList.size() > 0 ) {
                        update updateOppLineItemList;
                    }
                    List<responseClass> responseClassList = new List<responseClass>(); 
            
                    for( OpportunityLineItem opli2 : insertOppLineItemList ) {
                        responseClass rc = new responseClass();
                        rc.kts_OpportunityLineItemId = opli2.Id;
                        rc.kti_opportunityLineItemId = opli2.KTI_Opportunity_Line_Item_Id__c;
                        responseClassList.add(rc);
                    }
                    /*for( OpportunityLineItem opli3 : updateOppLineItemList) {
                        responseClass rc = new responseClass();
                        rc.kts_OpportunityLineItemId = opli3.Id;
                        rc.kti_opportunityLineItemId = opli3.KTI_Opportunity_Line_Item_Id__c;
                        responseClassList.add(rc);
                    }*/
                    
                    resToSend.isSuccess = TRUE;
                    resToSend.responseResult = 'Success';
                    resToSend.resClsList.addAll(responseClassList);
                    
                } else {  
                    resToSend.isSuccess = FALSE;
                    resToSend.responseResult = 'KTS Product Id or KTS Price Book Name Blank';
                }
            } catch(Exception e) {
                System.debug('::::e:::Message:::'+e.getMessage());
                System.Debug('Inside catch');
                resToSend.isSuccess = FALSE;
                resToSend.responseResult = e.getMessage();
            
            }
        }        
        return JSON.serialize(resToSend);
    }
        
}