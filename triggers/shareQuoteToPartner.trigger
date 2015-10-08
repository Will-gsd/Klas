trigger shareQuoteToPartner on Quote (After Insert,After Update) {

    Set<Id> quoteIdSet = new Set<Id>();
    Set<Id> oppIdSet = new Set<Id>();
    Set<Id> sharedOppIdSet = new Set<Id>();
    
    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName); 
    
    if ( Trigger.IsAfter &&( Trigger.IsInsert || Trigger.IsUpdate) ) {
        
        // TO COLLECT THE OPPORTUNITY ID 
        for (Quote newQuo : Trigger.New ) {
            oppIdSet.add(newQuo.OpportunityId);
        }
        
        // TO CHECK THE OPPORTUNITY SHARED OR NOT         
        for (PartnerNetworkRecordConnection oppSharingRecord :  [SELECT Status, LocalRecordId, ConnectionId                                 
                                                                 FROM PartnerNetworkRecordConnection              
                                                                 WHERE LocalRecordId IN :oppIdSet AND ConnectionId = :networkId ]) {
                                              
           if (oppSharingRecord.status.equalsignorecase('Sent')|| oppSharingRecord.status.equalsignorecase('Received')) {
               sharedOppIdSet.add(oppSharingRecord.LocalRecordId);
           }              
        }
        
        for ( Quote newQuote : Trigger.New ) {
            
            // ONLY ALLOW SHARED OPPORTUNITY 
            if (sharedOppIdSet.contains(newQuote.OpportunityId)) {
            
                if( (Trigger.IsInsert && newQuote.KTI_Quote_Id__c == null) || ( Trigger.IsUpdate &&  !AssetClass.processedIdSet.contains(newQuote.Id) && Trigger.oldmap.get(newQuote.Id).KTI_Quote_Id__c == newQuote.KTI_Quote_Id__c) && newQuote.Updated_in_Source__c == FALSE && newQuote.KTI_Quote_Id__c != NULL && !AssetClass.helperFlag) { 
                    quoteIdSet.Add(newQuote.Id);
                    AssetClass.processedIdSet.add(newQuote.Id);
                }
            
                if ( Trigger.IsUpdate && Trigger.OldMap.get(newQuote.Id).Updated_in_Source__c == FALSE && newQuote.Updated_in_Source__c) {
                    
                    AssetClass.processedIdSet.add(newQuote.Id);
                }
            }
        }
            
        if (quoteIdSet != NULL && quoteIdSet.size() > 0) {
        
            QuoteExternalSharing.linkQuote(quoteIdSet);
        }
    }
    
}