trigger ShareOpportunityToPartner on Opportunity (before insert,after insert,before update) {
   
    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);
     
    Set<Id> localOpportunityAccountSet = new Set<Id>();
    List<Opportunity> localOpportunity = new List<Opportunity>();
    Set<Id> sharedAccountSet = new Set<Id>(); 
    Map<String,String> oppKTIIdAndKTSIdMap = new Map<String,String>(); 
    
    //For before Update
    Set<Id> oppIdSetToChangeKTSAccId = new Set<Id>();
    List<Opportunity> oppToChangeKTSAccIdList = new List<Opportunity>(); 
    Set<String> oppWithParentAccSet = new Set<String>();
    Map<Id,Id> KTIIdAndParentAccIdMap = new Map<Id,Id>();
    List<Opportunity> oppToAddAccountList = new List<Opportunity>();
    Map<String,string> AccIdAndKTIIdMap = new Map<String,string>();
    
     
    if(Trigger.isInsert && Trigger.isBefore) {
    
        Map<String, Id> pbNameIdMap = new Map<String, Id>();
        Set<String> PBNameSet = new Set<String>();
        
        for (Opportunity opp : trigger.new) {
        
            if (opp.KTI_Price_Book_Name__c != NULL) {
                
                PBNameSet.add(opp.KTI_Price_Book_Name__c);
            }
        }
        System.debug('PBNameSet : ' + PBNameSet);
        
        if (PBNameSet != NULL && PBNameSet.size() > 0) {
            
            for (Pricebook2 pb2 : [SELECT Id, Name, isActive 
                                   FROM Pricebook2 
                                   WHERE Name IN :PBNameSet
                                   AND isActive = TRUE
                                  ]) {
                pbNameIdMap.put(pb2.Name, pb2.Id);    
            }
            System.debug('pbNameIdMap : ' + pbNameIdMap);
            
            if (pbNameIdMap != NULL && pbNameIdMap.size() > 0) {
            
                for (Opportunity opp : trigger.new) {
                
                    if (opp.KTI_Price_Book_Name__c != NULL && pbNameIdMap.containsKey(opp.KTI_Price_Book_Name__c) && pbNameIdMap.get(opp.KTI_Price_Book_Name__c) != NULL) {
                        
                        opp.pricebook2Id = pbNameIdMap.get(opp.KTI_Price_Book_Name__c);
                    }
                }
            } // End if pbNameIdMap
                    
        } // End if PBNameSet
        
    } // End if trigger beforeInsert
     
    // only share records created in this org, do not add Opportunities received from another org.
    if(Trigger.isAfter && Trigger.isInsert) {
    
        for (Opportunity newOpportunity : TRIGGER.new) {
        
            if (newOpportunity.ConnectionReceivedId == null && newOpportunity.AccountId != null) {
            
                localOpportunityAccountSet.add(newOpportunity.AccountId);
                localOpportunity.add(newOpportunity);
            }
             //To update the shared KTI ID to the Source Org
            if( newOpportunity.ConnectionReceivedId != null && newOpportunity.KTS_Id__c != NULL && newOpportunity.KTI_Id__c != NULL ) {
                
                oppKTIIdAndKTSIdMap.put(newOpportunity.KTI_Id__c.substring(0,15),newOpportunity.KTS_Id__c);
            }        
        }
        System.Debug('<---oppKTIIdAndKTSIdMap--->'+oppKTIIdAndKTSIdMap);
        if( oppKTIIdAndKTSIdMap != NULL && oppKTIIdAndKTSIdMap.Size() > 0 ) Cls_SendResponseToKTI.updateOpportunityKTSIdToKTI(oppKTIIdAndKTSIdMap);
        
        if (localOpportunityAccountSet != NULL && localOpportunityAccountSet.size() > 0) {
        
            List<PartnerNetworkRecordConnection> OpportunityConnections =  new  List<PartnerNetworkRecordConnection>();
            
            for(PartnerNetworkRecordConnection pnrc : [SELECT ConnectionId,LocalRecordId,PartnerRecordId FROM PartnerNetworkRecordConnection WHERE LocalRecordId IN : localOpportunityAccountSet]){
            
                sharedAccountSet.add(pnrc.LocalRecordId);
            }
        
            Map<Id,Id> accIdToRecordConnection = S2SUtils.accToSharedRecordId(sharedAccountSet);

            for (Opportunity newOpportunity : localOpportunity) {
                
                if (accIdToRecordConnection.get(newOpportunity.AccountId) != null) {
                    if (sharedAccountSet != NULL && sharedAccountSet.size() > 0 && sharedAccountSet.contains(newOpportunity.AccountId)) {
        
                        PartnerNetworkRecordConnection newConnection =
                          new PartnerNetworkRecordConnection(
                              ConnectionId = networkId,
                              LocalRecordId = newOpportunity.Id,
                              RelatedRecords = 'OpportunityLineItem',
                              SendClosedTasks = false,
                              SendOpenTasks = false,
                              SendEmails = false,
                              ParentRecordId = newOpportunity.AccountId
                          );
                              
                        OpportunityConnections.add(newConnection);
                    }
                }
            }
            
            if (OpportunityConnections != NULL && OpportunityConnections.size() > 0 ) {
                   
                   insert OpportunityConnections;
                   System.debug('-----OpportunityConnections--->>>'+OpportunityConnections);
            }
            
        }
    }// End of After Insert
     if( Trigger.IsBefore && Trigger.IsUpdate ) {
        
        for( Opportunity opp : Trigger.New ){
            
            //To change the KTS Account Id when the Partner is updated here
            if( (opp.AccountId != NULL && Trigger.oldMap.get(opp.Id).AccountId == NULL) || (opp.AccountId != NULL && Trigger.oldMap.get(opp.Id).AccountId != NULL && !opp.AccountId.equals(Trigger.oldMap.get(opp.Id).AccountId )) ) {
                
                oppToChangeKTSAccIdList.add(opp);
                oppIdSetToChangeKTSAccId.add(opp.AccountId);
            }
            
            //To update the AccountId when the KTS Account Id changes
            if( (opp.KTI_AccountId__c != NULL && Trigger.oldMap.get(opp.Id).KTI_AccountId__c == NULL) || (opp.KTI_AccountId__c != NULL && Trigger.oldMap.get(opp.Id).KTI_AccountId__c != NULL && !opp.KTI_AccountId__c.equals(Trigger.oldMap.get(opp.Id).KTI_AccountId__c) )) {
                
                oppToAddAccountList.add(opp);
                oppWithParentAccSet.add(opp.KTI_AccountId__c.substring(0,15));
            } 
            
            //To update the shared KTI ID to the Source Org
            if( opp.OwnerId != NULL && Trigger.oldMap.get(opp.Id).OwnerId != NULL && Trigger.oldMap.get(opp.Id).OwnerId != opp.OwnerId ) {
                
                oppKTIIdAndKTSIdMap.put(opp.KTI_Id__c.substring(0,15),opp.KTS_Id__c);
            }  
            Set <Id> oIds = new Set <Id>();
            for (Id oId : Trigger.newMap.keyset()){
                //if the ownerId of the new lead does not equal the id of the old lead
                if (Trigger.oldMap.get(oId).OwnerId != Trigger.newMap.get(oId).OwnerId ){
                    //add the opp's id to a set
        
                    oIds.add(oId);
              
                }
      
            }

            //if the set is not empty
            if(oIds.size() > 0){
            //pass the set to the future method
            S2SUtils.updateRecords(oIds, 'Opportunity'); 

            }

        }
        
        System.Debug('<---oppKTIIdAndKTSIdMap--->'+oppKTIIdAndKTSIdMap);
        if( oppKTIIdAndKTSIdMap != NULL && oppKTIIdAndKTSIdMap.Size() > 0 ) Cls_SendResponseToKTI.updateOpportunityKTSIdToKTI(oppKTIIdAndKTSIdMap);
        
        if( oppIdSetToChangeKTSAccId != NULL && oppIdSetToChangeKTSAccId.size() >0 ){
            
            for(Account acc : [SELECT Id,KTI_Id__c FROM Account WHERE Id IN : oppIdSetToChangeKTSAccId]){
                
                AccIdAndKTIIdMap.put(acc.Id,acc.KTI_Id__c);
            }
            
            for( Opportunity op : oppToChangeKTSAccIdList ) {
                
                op.KTI_AccountId__c = AccIdAndKTIIdMap.get(op.AccountId).substring(0,15);
            }
        }
        System.Debug('<---oppWithParentAccSet--->'+oppWithParentAccSet);
        
        if(oppWithParentAccSet != null && oppWithParentAccSet.size() > 0) {
        
            for(Account parentAcc : [SELECT Id,KTI_Id__c FROM Account WHERE KTI_Id__c IN : oppWithParentAccSet]) {
                
                KTIIdAndParentAccIdMap.put(parentAcc.KTI_Id__c,parentAcc.Id);
            }
            
            System.Debug('<---KTIIdAndParentAccIdMap--->'+KTIIdAndParentAccIdMap);
            
            if(oppToAddAccountList != null && oppToAddAccountList.size() > 0 && KTIIdAndParentAccIdMap != null && KTIIdAndParentAccIdMap.size() > 0) {
            
                for( Opportunity opp : oppToAddAccountList ){
                    
                    if(KTIIdAndParentAccIdMap.get(opp.KTI_AccountId__c) != NULL ) {
                        
                        opp.AccountId = KTIIdAndParentAccIdMap.get(opp.KTI_AccountId__c);
                    }
                }
            }
        }
    }
}