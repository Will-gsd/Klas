trigger trg_ShareAccountToPartnerKTI on Account(before insert, after insert,after update,before update) {

    // Define connection id
    
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);
    List<Account> accountsToShare = new List<Account>();
    Set<Id> accIdToStopSharing = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    Set<String> accWithParentAccSet = new Set<String>();
    List<Account> accToAddParentList = new List<Account>();
    Map<Id,Id> ParentAccIdAndKTIIdMap = new Map<Id,Id>();
    Map<String,String> accKTIIdAndKTSIdMap = new Map<String,String>(); 
    //Set<Id> sharedAccountSet = new Set<Id>();
    
    //To update the KTI Parent Id Field when the Parent is changed here 
    Set<Id> accIdSetToChangeKTSAccId = new Set<Id>();
    List<Account> accToChangeKTSAccIdList = new List<Account>();
    Map<String,String> AccIdAndKTIIdMap = new Map<String,String>(); 
    
    // To Map the Parent Account for the Shared Account FROM KTI
    if( Trigger.IsBefore && Trigger.IsInsert ) {
        
        for( Account acc : Trigger.New ) {
            
            //Account With Parent Account
            if( acc.ConnectionReceivedId != null && acc.KTI_Parent_Id__c != NULL ) {
                
                //Id of the Account From the Shared Org
                accToAddParentList.add(acc);
                accWithParentAccSet.add(acc.KTI_Parent_Id__c.substring(0,15));
            }
        }
    } 
     
    // only share records created in this org, do not add Accounts received from another org.
    if( Trigger.isAfter && Trigger.isInsert ) {
        
        for ( Account newAccount : TRIGGER.new ) {
            
            if ( newAccount.ConnectionReceivedId == null && newAccount.Do_Not_Share__c != True ) {
                
                accountsToShare.add(newAccount);
            } 
            
            // To update the KTI org with the KTS Account ID , Parent Account ID and KTS Owner
            
            if( newAccount.ConnectionReceivedId != null && newAccount.KTS_Id__c != NULL && newAccount.KTI_Id__c != NULL ) {
                
                accKTIIdAndKTSIdMap.put(newAccount.KTI_Id__c.subString(0,15),newAccount.KTS_Id__c);
                
            }       
        }
        
         System.Debug('<---accKTIIdAndKTSIdMap--->'+accKTIIdAndKTSIdMap);
        
        if( accKTIIdAndKTSIdMap != NULL && accKTIIdAndKTSIdMap.Size() > 0 ) {
         Cls_SendResponseToKTI.updateAccountKTSIdToKTI(accKTIIdAndKTSIdMap);
         }
    }
    
    if( Trigger.isBefore && Trigger.isUpdate ){
        for( Account acc : Trigger.New ){
            System.Debug('---New acc---'+acc );
            System.Debug('---Old acc---'+Trigger.oldMap.get(acc.Id));
            if( (acc.ParentId != NULL && Trigger.oldMap.get(acc.Id).ParentId == NULL) || (acc.ParentId != NULL && Trigger.oldMap.get(acc.Id).ParentId != NULL && !acc.ParentId.equals(Trigger.oldMap.get(acc.Id).ParentId)) ) {
                
                accToChangeKTSAccIdList.add(acc);
                accIdSetToChangeKTSAccId.add(acc.ParentId);
            }
            if( (acc.KTI_Parent_Id__c != NULL && Trigger.oldMap.get(acc.Id).KTI_Parent_Id__c == NULL) || (acc.KTI_Parent_Id__c != NULL && Trigger.oldMap.get(acc.Id).KTI_Parent_Id__c != NULL && !acc.KTI_Parent_Id__c.equals(Trigger.oldMap.get(acc.Id).KTI_Parent_Id__c)) ){
                accToAddParentList.add(acc);
                accWithParentAccSet.add(acc.KTI_Parent_Id__c.substring(0,15));
            } 
            //When a parent is removed from the child Account
            if( Trigger.oldMap.get(acc.Id).KTI_Parent_Id__c != NULL && acc.KTI_Parent_Id__c == NULL ){
                
                acc.ParentId = null;
            }         
        }
    }
    System.Debug('---accToChangeKTSAccIdList---'+accToChangeKTSAccIdList);
    System.Debug('---accIdSetToChangeKTSAccId---'+accIdSetToChangeKTSAccId);
    
    if( accIdSetToChangeKTSAccId != NULL && accIdSetToChangeKTSAccId.size() >0 ){
        for(Account acc : [SELECT Id,KTI_Id__c FROM Account WHERE Id IN : accIdSetToChangeKTSAccId]){
            AccIdAndKTIIdMap.put(acc.Id,acc.KTI_Id__c);
        }
        
        for( Account acc : accToChangeKTSAccIdList ) {
            System.Debug('<--------------------------------------->'+acc);
            System.Debug('<--------------------------------------->'+AccIdAndKTIIdMap);
            acc.KTI_Parent_Id__c = AccIdAndKTIIdMap.get(acc.ParentId).substring(0,15);
        }
    }
    
    
    System.Debug('<---accWithParentAccSet--->'+accWithParentAccSet);
    
    if(accWithParentAccSet != null && accWithParentAccSet.size() > 0) {
        System.debug('-----------------------------------------------'+accWithParentAccSet);
       
        for(Account parentAcc : [SELECT Id,Name,KTI_Id__c FROM Account WHERE KTI_Id__c IN : accWithParentAccSet]) {
            
            ParentAccIdAndKTIIdMap.put(parentAcc.KTI_Id__c,parentAcc.Id);
        }
        
        System.Debug('<---ParentAccIdAndKTIIdMap--->'+ParentAccIdAndKTIIdMap);
        
        if(accToAddParentList != null && accToAddParentList.size() > 0 && ParentAccIdAndKTIIdMap != null && ParentAccIdAndKTIIdMap.size() > 0) {
        
            for( Account acc : accToAddParentList ){
                
                if(ParentAccIdAndKTIIdMap.get(acc.KTI_Parent_Id__c) != NULL ) {
                    
                    acc.ParentId = ParentAccIdAndKTIIdMap.get(acc.KTI_Parent_Id__c);
                }
            }
        }
    }
    if( Trigger.isAfter && Trigger.isUpdate ) {
    
        List<PartnerNetworkRecordConnection> toDelete = new List<PartnerNetworkRecordConnection>();
        
        for (Account newAccount : Trigger.new) {
        
            if ( newAccount.Do_Not_Share__c == True && Trigger.oldMap.get(newAccount.Id).Do_Not_Share__c == False ) {
      
                accIdToStopSharing.add(newAccount.Id);
            } else if ( newAccount.Do_Not_Share__c == False && Trigger.oldMap.get(newAccount.Id).Do_Not_Share__c == True /*&& newAccount.Do_Not_Share__c != True*/) {
                
                accountsToShare.add(newAccount);
            }   
        }
        
        if( accIdToStopSharing != null && accIdToStopSharing.Size() > 0 ) {
            
            for( PartnerNetworkRecordConnection recordConn : [SELECT Id, Status, ConnectionId, LocalRecordId, RelatedRecords FROM PartnerNetworkRecordConnection WHERE LocalRecordId IN :accIdToStopSharing]) {
                
                if( recordConn.Status.equalsignorecase('Sent') ) { //account is connected - outbound
                    
                    toDelete.add(recordConn);
                } 
            }
            
            
            Set<Id> localContactIds = new Set<Id>();
            
            for(Contact con : [SELECT Id ,Name FROM Contact WHERE AccountId IN : accIdToStopSharing]) {
                
                localContactIds.add(con.Id);
            }
            
            System.Debug('<::::::localContactIds::::::>'+localContactIds);
            
            if(localContactIds != null && localContactIds.size() > 0) {
            
                List<PartnerNetworkRecordConnection> relatedRecordsforAcc = [select Id, Status, ConnectionId, LocalRecordId, ParentRecordId from PartnerNetworkRecordConnection where LocalRecordId IN :localContactIds];
                
                System.Debug('<::::::relatedRecordsforAcc ::::::>'+relatedRecordsforAcc);
                
                if( relatedRecordsforAcc != null && relatedRecordsforAcc.Size() > 0 ){
                    
                    Delete relatedRecordsforAcc;
                }
            }
            
            if( toDelete != null && toDelete.Size() > 0 ) {
                
                Delete toDelete;
            }
        }
        
    }
    
    if ( accountsToShare != null && accountsToShare.size() > 0 ) {
    
        List<PartnerNetworkRecordConnection> AccountConnections =  new  List<PartnerNetworkRecordConnection>();        
        
        for ( Account newAccount : accountsToShare ) {
                
                PartnerNetworkRecordConnection newConnection = new PartnerNetworkRecordConnection(
                      ConnectionId = networkId,
                      LocalRecordId = newAccount.Id,
                      RelatedRecords = 'Contact,Opportunity',
                      SendClosedTasks = false,
                      SendOpenTasks = false,
                      SendEmails = false);
                       
                AccountConnections.add(newConnection);
        }
        
        System.Debug('<--AccountConnections-->'+AccountConnections);
        
        if(AccountConnections != null && AccountConnections.size() > 0) {
               
            insert AccountConnections;
        }
    }
}