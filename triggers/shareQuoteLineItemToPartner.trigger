trigger shareQuoteLineItemToPartner on QuoteLineItem (after insert, after update) {

    Set<Id> quoteLineItemIdSet = new Set<Id>();
    Set<Id> quoteIdSet = new Set<Id>();
    Set<Id> oppIdSet = new Set<Id>();
    Set<Id> sharedQuoteIdSet = new Set<Id>();
    
    Set<Id> productIdSet = new Set<Id>();
    Set<Id> sharedProductIdSet = new Set<Id>();
    
    Map<Id, Id> opportunityIdAndCorrespondingQuoteIdMap = new Map<Id, Id>();
    
    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);
    
    if ( Trigger.IsAfter &&( Trigger.IsInsert || Trigger.IsUpdate) ) {
        
        // TO COLLECT THE QUOTE ID 
        for (QuoteLineItem QLI : Trigger.New) {
            
            quoteIdSet.add(QLI.QuoteId);
            productIdSet.add(QLI.Product2Id);
        }
        
        system.debug ('::quoteIdSet::' +quoteIdSet);
        // TO COLLECT THE OPPORTUNITY ID 
        for (Quote qu : [SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIdSet ]) {
        
            opportunityIdAndCorrespondingQuoteIdMap.put (qu.OpportunityId, qu.Id);
        }
        system.debug ('::opportunityIdAndCorrespondingQuoteIdMap::' +opportunityIdAndCorrespondingQuoteIdMap);
        
        // TO CHECK THE OPPORTUNITY SHARED OR NOT          
        if (opportunityIdAndCorrespondingQuoteIdMap != NULL && opportunityIdAndCorrespondingQuoteIdMap.size() > 0) {  
             
            for (PartnerNetworkRecordConnection oppSharingRecord :  [SELECT Status, LocalRecordId, ConnectionId                                 
                                                                     FROM PartnerNetworkRecordConnection              
                                                                     WHERE LocalRecordId IN :opportunityIdAndCorrespondingQuoteIdMap.keyset() AND ConnectionId = :networkId ]) {
                                                  
               if (oppSharingRecord.status.equalsignorecase('Sent')|| oppSharingRecord.status.equalsignorecase('Received')) {
               
                   if (opportunityIdAndCorrespondingQuoteIdMap.containsKey(oppSharingRecord.LocalRecordId) && opportunityIdAndCorrespondingQuoteIdMap.get(oppSharingRecord.LocalRecordId) != NULL) {
                       sharedQuoteIdSet.add(opportunityIdAndCorrespondingQuoteIdMap.get(oppSharingRecord.LocalRecordId));
                   }
               }              
            }
        }
                
        // TO CHECK THE PRODUCT SHARED OR NOT 
        for (PartnerNetworkRecordConnection productRecord :  [SELECT Status, LocalRecordId, ConnectionId                                 
                                                                 FROM PartnerNetworkRecordConnection              
                                                                 WHERE LocalRecordId IN :productIdSet AND ConnectionId = :networkId ]) {
            
            if (productRecord.status.equalsignorecase('Sent')|| productRecord.status.equalsignorecase('Received')) {
                sharedProductIdSet.add(productRecord.LocalRecordId); 
            }                                                            
        }                                                            
        system.debug ('::sharedQuoteIdSet::' +sharedQuoteIdSet);
        system.debug ('::sharedProductIdSet::' +sharedProductIdSet);
        system.debug ('::AssetClass.processedIdSet::' +AssetClass.processedIdSet);
        Map<Id,Id> quoteIdAndKTIquoteIdMap = new Map<Id,Id>();
        for(Quote qt : [SELECT Id,KTI_Quote_Id__c FROM Quote WHERE Id IN: sharedQuoteIdSet]){
            quoteIdAndKTIquoteIdMap.put(qt.Id,qt.KTI_Quote_Id__c);
        }
        for ( QuoteLineItem newQLI : Trigger.New ) {
        
            // ONLY ALLOW SHARED QUOTE FROM OPPORTUNITY AS WELL AS NEED TO CHECK PRODUCT SHARED OR NOT 
            if (sharedQuoteIdSet.contains(newQLI.QuoteId) && sharedProductIdSet.contains(newQLI.Product2Id)) {
                
                // Static variable To avoid calling the Quote Update when a QuoteLineItem is created
                AssetClass.helperFlag = True;        
            
                if( (Trigger.IsInsert && newQLI.KTI_Quote_Line_Item_Id__c == null && quoteIdAndKTIquoteIdMap != null && quoteIdAndKTIquoteIdMap.size()>0 && quoteIdAndKTIquoteIdMap.containsKey(newQLI.QuoteId) && quoteIdAndKTIquoteIdMap.get(newQLI.QuoteId) != null ) || ( Trigger.IsUpdate &&  !AssetClass.processedIdSet.contains(newQLI.Id) && Trigger.oldmap.get(newQLI.Id).KTI_Quote_Line_Item_Id__c == newQLI.KTI_Quote_Line_Item_Id__c) && newQLI.Updated_in_Source__c == FALSE&& newQLI.KTI_Quote_Line_Item_Id__c!= NULL) { 
                    quoteLineItemIdSet.Add(newQLI.Id);
                    AssetClass.processedIdSet.add(newQLI.Id);
                    
                }
                System.Debug('AssetClass.helperFlag::::'+AssetClass.helperFlag);
                if ( Trigger.IsUpdate && Trigger.OldMap.get(newQLI.Id).Updated_in_Source__c == FALSE && newQLI.Updated_in_Source__c) {
                    
                    AssetClass.processedIdSet.add(newQLI.Id);
                }
            }
        }
            
        if (quoteLineItemIdSet != NULL && quoteLineItemIdSet.size() > 0) {
            System.debug('::::::'+quoteLineItemIdSet );
            QuoteLineItemExternalSharing.doPost( quoteLineItemIdSet );
        }
    }
}