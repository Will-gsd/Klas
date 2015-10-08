trigger shareAssetToPartner on Asset (After Insert,After Update) {
    Set<Id> assetIdSet = new Set<Id>();
    Map<Id,Id> contactIdAndAccountIdMap=new Map<Id,Id>();
    Set<Id> contactIdSet=new Set<Id>();
    Set<Id> accountIdSet=new Set<Id>();
    Set<Id> totalAccountIdSet = new Set<Id>();
    Set<Id> sharedAccountIdSet=new Set<Id>();
    Set<Id> sharedAssetIdSet=new Set<Id>();
    
    if ( Trigger.IsAfter &&( Trigger.IsInsert || Trigger.IsUpdate) ) {
        
        for(Asset newAsset : Trigger.New) {
            // assetIdAndAccountIdMap.put(newAsset.Id,newAsset.AccountId);
            if(newAsset.AccountId != NULL) {
                accountIdSet.add(newAsset.AccountId);
            }
            // assetIdAndContactIdMap.put(newAsset.Id,newAsset.ContactId);
            if(newAsset.ContactId != NULL) {
                contactIdSet.add(newAsset.ContactId);
            }
            // assetIdAndOpportunityIdMap.put(newAsset.Id,newAsset.Opportunity__c);
           
        }
        
        for(Contact contact:[Select Id,AccountId From Contact Where Id IN :contactIdSet AND AccountId != NULL]) {
            contactIdAndAccountIdMap.put(contact.Id,contact.AccountId); 
               
        }
        
        if(accountIdSet != NULL && accountIdSet.size() > 0) {
            totalAccountIdSet.addAll(accountIdSet);
        }
        if(contactIdAndAccountIdMap != NULL && contactIdAndAccountIdMap.size() > 0) {
            totalAccountIdSet.addAll(contactIdAndAccountIdMap.values());
        }
        
        if(totalAccountIdSet != NULL && totalAccountIdSet.size() > 0) {
            for(Account account:[Select Id,Do_Not_Share__c From Account Where Id IN :totalAccountIdSet AND Do_Not_Share__c=false]) {
                sharedAccountIdSet.add(account.Id); 
            }
        }
        for ( Asset newAsset : Trigger.New ) {
            if(newAsset.AccountId != NULL){
                if(sharedAccountIdSet.contains(newAsset.AccountId)) {
                    sharedAssetIdSet.add(newAsset.Id);    
                }
            }else if(newAsset.ContactId != NULL){
                if(sharedAccountIdSet.contains(contactIdAndAccountIdMap.get(newAsset.ContactId))) {
                    sharedAssetIdSet.add(newAsset.Id);    
                }
            }
        }
        if(sharedAssetIdSet != NULL && sharedAssetIdSet.size() > 0) {
            for ( Asset newAsset : Trigger.New ) {
                if(sharedAssetIdSet.contains(newAsset.Id)) {
                    if((Trigger.IsInsert && newAsset.KTI_Asset_Id__c == NULL ) || ( Trigger.IsUpdate &&  !AssetClass.processedIdSet.contains(newAsset.Id) && Trigger.oldmap.get(newAsset.Id).KTI_Asset_Id__c == newAsset.KTI_Asset_Id__c) && newAsset.Updated_in_Source__c == FALSE) { 
                        assetIdSet.add(newAsset.Id);
                        AssetClass.processedIdSet.add(newAsset.Id);
                        
                    }
                
                    if ( Trigger.IsUpdate && Trigger.OldMap.get(newAsset.Id).Updated_in_Source__c == FALSE && newAsset.Updated_in_Source__c) {
                        
                        AssetClass.processedIdSet.add(newAsset.Id);
                    }
               }
            }
                
            if (assetIdSet != NULL && assetIdSet.size() > 0) {
                System.debug('------------------------------------------------------'+assetIdSet);
                AssetExternalSharing.linkAsset(assetIdSet);
            }
        }
    }
}