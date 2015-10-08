trigger Case_trg_S2S_Sharing on Case (after insert ,before Insert, before update) {
    
     // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName); 
    Set<Id> localCaseAccountIdSet = new Set<Id>();
    Set<Id> sharedAccountSet = new Set<Id>();
    List<Case> localCase = new List<Case>();
    Map<String,String> caseKTIIdAndKTSIdMap = new Map<String,String>();
    
    /*Variables to map the parent case*/
    Set<String> caseWithParentCaseSet = new Set<String>();
    List<Case> caseToAddParentList = new List<Case>();
    Map<String,Id> KTIIdAndParentCaseIdMap = new Map<String,Id>();
    
    /*Variables to map the Contact*/ 
    Set<String> localCaseContactIdSet = new Set<String>();
    List<Case> caseToAddContactList = new List<Case>();
    Map<Id,Id> KTIIdAndParentContactIdMap = new Map<Id,Id>();
    
    if( trigger.isBefore && trigger.isInsert ) {
    
        for(Case newCase : trigger.new) {
            System.Debug('<--new case-->'+newcase);
            System.debug(':::newCase.ConnectionReceivedId:::'+newCase.ConnectionReceivedId);
            if( newCase.ConnectionReceivedId != null ) {
                
                if(newCase.KTI_Contact_Id__c != null) {
                        
                    localCaseContactIdSet.add(newCase.KTI_Contact_Id__c);
                    caseToAddContactList.add(newCase);
                }
                if(newCase.KTI_Parent_Case_Id__c != null) {
                    
                    caseToAddParentList.add(newCase);
                    caseWithParentCaseSet.add(newCase.KTI_Parent_Case_Id__c);
                }
            }
        }
        System.Debug('<--localCaseContactIdSet-->'+localCaseContactIdSet);
        System.Debug('<--caseWithParentCaseSet-->'+caseWithParentCaseSet);
    }
       
    if(trigger.isInsert && trigger.isAfter) {
        
        for(Case newCase : trigger.new) {
            
            if (newCase.ConnectionReceivedId == null ) {
                
                if(newCase.AccountId != null) {
                    
                    localCaseAccountIdSet.add(newCase.AccountId);
                    localCase.add(newCase);
                }
            }  
            
            /*if (newCase.ConnectionReceivedId != null ) {
                
                if(newCase.KTI_Contact_Id__c != null) {
                
                    localCaseContactIdSet.add(newCase.KTI_Contact_Id__c);
                    caseToAddContactList.add(newCase);
                }
                    
                if(newCase.KTI_Parent_Case_Id__c != null) {
                    
                    caseToAddParentList.add(newCase);
                    caseWithParentCaseSet.add(newCase.KTI_Parent_Case_Id__c);
                }
            }*/
            
            if(newCase.ConnectionReceivedId != null && newCase.KTS_Case_Id__c != NULL && newCase.KTI_Case_Id__c!= NULL ) {
            
                 caseKTIIdAndKTSIdMap.put(newCase.KTI_Case_Id__c, newCase.KTS_Case_Id__c);  
            } 
        }
        
        if(caseKTIIdAndKTSIdMap != NULL && caseKTIIdAndKTSIdMap.Size() > 0){
             
             Cls_SendResponseToKTI.updateCaseKTSIdToKTI(caseKTIIdAndKTSIdMap);
        } 
        
        if(localCaseAccountIdSet != null && localCaseAccountIdSet.size() > 0) {
            
            for(Account acc : [SELECT Id, Name, Do_Not_Share__c FROM Account WHERE Id IN : localCaseAccountIdSet AND Do_Not_Share__c = False]) {
                
                sharedAccountSet.add(acc.Id);
            } 
            
            if(sharedAccountSet != null && sharedAccountSet.size() > 0) {   
            
                List<PartnerNetworkRecordConnection> caseConnections =  new  List<PartnerNetworkRecordConnection>();
                
                 for(Case newCase : localCase) {
                    
                    if(sharedAccountSet.contains(newCase.AccountId)) {
    
                        PartnerNetworkRecordConnection newConnection =
                          new PartnerNetworkRecordConnection(
                              ConnectionId = networkId,
                              LocalRecordId = newCase.Id,
                              SendClosedTasks = false,
                              SendOpenTasks = false,
                              SendEmails = false,
                              ParentRecordId = newCase.AccountId);
                              
                        caseConnections.add(newConnection);
                    }
                }
                
                if(caseConnections != null && caseConnections.size() > 0 ) {
                    
                    database.insert(caseConnections);
                }    
            }
        }          
    } // End of After Insert
    
    if(trigger.isBefore && trigger.isUpdate) {
        //Variables to change the KTI Acc Id
        List<Case> caseToChangeKTSAccIdList = new List<Case>(); 
        Set<Id> caseIdSetToChangeKTSAccId = new Set<Id>();
        //Var to change the KTI Case Id
        List<Case> caseToChangeKTIcaseIdList = new List<Case>(); 
        Set<Id> caseIdSetToChangeKTICaseId = new Set<Id>();
        Map<String,string> caseIdAndKTIIdMap = new Map<String,string>();
        
        List<Case> caseToAddAccountList = new List<Case>();
        Set<String> caseWithParentAccSet = new Set<String>();
        Map<String,string> AccIdAndKTIIdMap = new Map<String,string>();
        Map<String,Id> KTIIdAndParentAccIdMap = new Map<String,Id>();
        
        for(Case newCase : trigger.new) {
            
            //To change the KTS Account Id when the Partner is updated here
            if( (newCase.AccountId != NULL && Trigger.oldMap.get(newCase.Id).AccountId == NULL) || (newCase.AccountId != NULL && Trigger.oldMap.get(newCase.Id).AccountId != NULL && !newCase.AccountId.equals(Trigger.oldMap.get(newCase.Id).AccountId )) ) {
                
                caseToChangeKTSAccIdList.add(newCase);
                caseIdSetToChangeKTSAccId.add(newCase.AccountId);
            }
            
            //To update the AccountId when the KTS Account Id changes
            if( (newCase.KTI_Account_Id__c != NULL && Trigger.oldMap.get(newCase.Id).KTI_Account_Id__c == NULL) || (newCase.KTI_Account_Id__c != NULL && Trigger.oldMap.get(newCase.Id).KTI_Account_Id__c != NULL && !newCase.KTI_Account_Id__c.equals(Trigger.oldMap.get(newCase.Id).KTI_Account_Id__c) )) {
                
                caseToAddAccountList.add(newCase);
                caseWithParentAccSet.add(newCase.KTI_Account_Id__c.substring(0,15));
            } 
            
            //To update the case Owner to the Other Org  
            if(newCase.OwnerId != NULL && Trigger.OldMap.get(newCase.Id).OwnerId != NULL && Trigger.OldMap.get(newCase.Id).OwnerId !=newCase.OwnerId ) {
                
                caseKTIIdAndKTSIdMap.put(newCase.KTI_Case_Id__c,newCase.KTS_Case_Id__c);
            } 
            
            if( (newCase.ParentId != NULL && Trigger.oldMap.get(newCase.Id).ParentId == NULL) || (newCase.ParentId != NULL && Trigger.oldMap.get(newCase.Id).ParentId != NULL && !newCase.ParentId.equals(Trigger.oldMap.get(newCase.Id).ParentId)) ) {
                
                caseToChangeKTIcaseIdList.add(newCase);
                caseIdSetToChangeKTICaseId.add(newCase.ParentId);
            }
            
            //To update the parent case
            if( (newCase.KTI_Parent_Case_Id__c != NULL && Trigger.oldMap.get(newCase.Id).KTI_Parent_Case_Id__c == NULL) || (newCase.KTI_Parent_Case_Id__c != NULL && Trigger.oldMap.get(newCase.Id).KTI_Parent_Case_Id__c != NULL && !newCase.KTI_Parent_Case_Id__c.equals(Trigger.oldMap.get(newCase.Id).KTI_Parent_Case_Id__c)) ){
                caseToAddParentList.add(newCase);
                caseWithParentCaseSet.add(newCase.KTI_Parent_Case_Id__c.substring(0,15));
            }
                  
        }
        
        if( caseKTIIdAndKTSIdMap != NULL && caseKTIIdAndKTSIdMap.Size() > 0 ) {
        
            Cls_SendResponseToKTI.updateCaseKTSIdToKTI(caseKTIIdAndKTSIdMap);
        }
        
        if(caseIdSetToChangeKTSAccId != NULL && caseIdSetToChangeKTSAccId.size() > 0){
            
            for(Account acc : [SELECT Id,KTI_Id__c FROM Account WHERE Id IN : caseIdSetToChangeKTSAccId]){
                
                AccIdAndKTIIdMap.put(acc.Id,acc.KTI_Id__c);
            }
            
            for( Case cas : caseToChangeKTSAccIdList ) {
                
                cas.KTI_Account_Id__c = AccIdAndKTIIdMap.get(cas.AccountId).substring(0,15);
            }
        }
        // to update the KTI Parent Case Id
        if(caseIdSetToChangeKTICaseId != NULL && caseIdSetToChangeKTICaseId.size() > 0){
            
            for(Case caseRec : [SELECT Id,KTI_Case_Id__c FROM Case WHERE Id IN : caseIdSetToChangeKTICaseId]){
                
                caseIdAndKTIIdMap.put(caseRec.Id,caseRec.KTI_Case_Id__c );
            }
            
            for( Case cas : caseToChangeKTIcaseIdList ) {
                
                cas.KTI_Parent_Case_Id__c = caseIdAndKTIIdMap.get(cas.ParentId).substring(0,15);
            }
        }
        
        if(caseWithParentAccSet != null && caseWithParentAccSet.size() > 0) {
            
            for(Account parentAcc : [SELECT Id, KTI_Id__c FROM Account WHERE KTI_Id__c IN : caseWithParentAccSet]) {
                
                KTIIdAndParentAccIdMap.put(parentAcc.KTI_Id__c,parentAcc.Id);
            }
            
            if(caseToAddAccountList != null && caseToAddAccountList.size() > 0 && KTIIdAndParentAccIdMap != null && KTIIdAndParentAccIdMap.size() > 0) {
            
                for( Case cas : caseToAddAccountList ){
                    
                    if(KTIIdAndParentAccIdMap.get(cas.KTI_Account_Id__c) != NULL ) {
                        
                        cas.AccountId = KTIIdAndParentAccIdMap.get(cas.KTI_Account_Id__c);
                    }
                }
            }    
        }
    } // End of Before Update
    
    System.Debug('<---caseWithParentCaseSet--->'+caseWithParentCaseSet);
    
    if(caseWithParentCaseSet != null && caseWithParentCaseSet.size() > 0) {
        System.debug('-----------------------------------------------'+caseWithParentCaseSet);
       
        for(Case parentCase : [SELECT Id,KTI_Case_Id__c FROM Case WHERE KTI_Case_Id__c IN : caseWithParentCaseSet]) {
            
            KTIIdAndParentCaseIdMap.put(parentCase.KTI_Case_Id__c,parentCase.Id);
        }
        
        System.Debug('<---KTIIdAndParentCaseIdMap--->'+KTIIdAndParentCaseIdMap);
        
        if(caseToAddParentList != null && caseToAddParentList.size() > 0 && KTIIdAndParentCaseIdMap != null && KTIIdAndParentCaseIdMap.size() > 0) {
        
            for( Case cas : caseToAddParentList){
                
                if(KTIIdAndParentCaseIdMap.get(cas.KTI_Parent_Case_Id__c) != NULL ) {
                    cas.ParentId = KTIIdAndParentCaseIdMap.get(cas.KTI_Parent_Case_Id__c);
                }
            }
        }
    }
    
    if(localCaseContactIdSet != null && localCaseContactIdSet.size() > 0) {
        System.debug('-----------------------------------------------'+localCaseContactIdSet);
       
        for(Contact con : [SELECT Id,KTI_Contact_Id__c FROM Contact WHERE KTI_Contact_Id__c IN : localCaseContactIdSet]) {
            
            KTIIdAndParentContactIdMap.put(con.KTI_Contact_Id__c,con.Id);
        }
        
        System.Debug('<---KTIIdAndParentContactIdMap--->'+KTIIdAndParentContactIdMap);
        
        if(caseToAddContactList != null && caseToAddContactList.size() > 0 && KTIIdAndParentContactIdMap != null && KTIIdAndParentContactIdMap.size() > 0) {
        
            for( Case cas : caseToAddContactList ){
                
                if(KTIIdAndParentContactIdMap.containsKey(cas.KTI_Contact_Id__c)) {
                    
                    cas.ContactId = KTIIdAndParentContactIdMap.get(cas.KTI_Contact_Id__c);
                }
            }
        }
    }
}