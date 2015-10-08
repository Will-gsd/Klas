trigger ShareOpportunityLineItemToPartner on OpportunityLineItem (after insert, after update) {

    Map<Id, Set<Id>> oppIdAndOpliIdSetMap = new Map<Id, Set<Id>>();
    
    Set<Id> opliIdSet  = new Set<Id>();
    Set<Id> sharedOppIdSet = new Set<Id>();
    
    Set<Id> prodIdSet = new Set<Id>();
    Set<Id> sharedProdIdSet = new Set<Id>();
    
    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);
    
    if ( Trigger.IsAfter &&( Trigger.IsInsert || Trigger.IsUpdate) ) {
    
        // TO FORM THE MAP OF OPPORTUNITY ID AS KEY AND OPLI ID SET AS VALUE 
        for (OpportunityLineItem opli : trigger.new) {
            if (oppIdAndOpliIdSetMap.get(opli.OpportunityId) == NULL) {
                oppIdAndOpliIdSetMap.put(opli.OpportunityId, new Set<Id>());
            }
            oppIdAndOpliIdSetMap.get(opli.OpportunityId).add(opli.OpportunityId);
            prodIdSet.add(opli.Product2Id);
        }
        System.debug('oppIdAndOpliIdSetMap : ' + oppIdAndOpliIdSetMap);
        System.debug('prodIdSet : ' + prodIdSet);
        
        // TO CHECK THE OPPORTUNITY SHARED OR NOT          
        if (oppIdAndOpliIdSetMap != NULL && oppIdAndOpliIdSetMap.size() > 0) {  
             
            for (PartnerNetworkRecordConnection oppSharingRecord :  [SELECT Status, LocalRecordId, ConnectionId                                 
                                                                     FROM PartnerNetworkRecordConnection              
                                                                     WHERE LocalRecordId IN :oppIdAndOpliIdSetMap.keyset() AND ConnectionId = :networkId ]) {
                                                  
               if (oppSharingRecord.status.equalsignorecase('Sent')|| oppSharingRecord.status.equalsignorecase('Received') || Test.isRunningTest()) {
               
                   if (oppIdAndOpliIdSetMap.containsKey(oppSharingRecord.LocalRecordId) && oppIdAndOpliIdSetMap.get(oppSharingRecord.LocalRecordId) != NULL) {
                       sharedOppIdSet.add(oppSharingRecord.LocalRecordId);
                   }
               }              
            }
        } // End if oppIdAndOpliIdSetMap
        System.debug('sharedOppIdSet : ' + sharedOppIdSet);
        
        // TO CHECK THE PRODUCT SHARED OR NOT 
        if (prodIdSet != NULL && prodIdSet.size() > 0) {
            for (PartnerNetworkRecordConnection productRecord :  [SELECT Status, LocalRecordId, ConnectionId                                 
                                                                     FROM PartnerNetworkRecordConnection              
                                                                     WHERE LocalRecordId IN :prodIdSet AND ConnectionId = :networkId ]) {
                
                if (productRecord.status.equalsignorecase('Sent')|| productRecord.status.equalsignorecase('Received') ) {
                    sharedProdIdSet.add(productRecord.LocalRecordId); 
                }                                                            
            }
        } // End if prodIdSet
        System.debug('sharedProdIdSet : ' + sharedProdIdSet);        
        
        for ( OpportunityLineItem newOPLI : Trigger.New ) {
            
            // SHARE OPLI TO KTI SYSTEM ONLY IF BOTH OPPORTUNITY AND PRODUCT IS SHARED
            if (sharedOppIdSet.contains(newOPLI.OpportunityId) && sharedProdIdSet.contains(newOPLI.Product2Id)) {
                
                if( (Trigger.IsInsert && newOPLI.Updated_in_Source__c == FALSE && newOPLI.KTI_Opportunity_Line_Item_Id__c == null ) || ( Trigger.IsUpdate &&  !AssetClass.processedIdSet.contains(newOPLI.Id) && Trigger.oldmap.get(newOPLI.Id).KTI_Opportunity_Line_Item_Id__c == newOPLI.KTI_Opportunity_Line_Item_Id__c && newOPLI.Updated_in_Source__c != True)) { 
                
                    opliIdSet.Add(newOPLI.Id);
                    AssetClass.processedIdSet.add(newOPLI.Id);
                }
                System.debug(':::AssetClass.ProcessedId:::'+AssetClass.processedIdSet);
                if ( Trigger.IsUpdate && Trigger.OldMap.get(newOPLI.Id).Updated_in_Source__c == FALSE && newOPLI.Updated_in_Source__c) {
            
                    AssetClass.processedIdSet.add(newOPLI.Id);
                }
            }
        } // End for trigger.new 
        
        if (opliIdSet != NULL && opliIdSet.size() > 0) {
            System.debug('::::::'+opliIdSet );
            OpportunityLineItemExternalSharing.doPost( opliIdSet );
        }
    }
}