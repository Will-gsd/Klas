trigger ShareContactToPartner on Contact (after insert,before update) {
   
    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName); 
    Set<Id> localContactAccountSet = new Set<Id>();
    List<Contact> localContacts = new List<Contact>();
    Set<Id> sharedAccountSet = new Set<Id>();  
    Map<String,String> conKTIIdAndKTSIdMap = new Map<String,String>(); 
    
    //For before Update
    Set<Id> conIdSetToChangeKTSAccId = new Set<Id>();
    List<Contact> conToChangeKTSAccIdList = new List<Contact>(); 
    Set<String> conWithParentAccSet = new Set<String>();
    Map<String,Id> KTIIdAndParentAccIdMap = new Map<String,Id>();
    List<Contact> conToAddAccountList = new List<Contact>();
    Map<String,string> AccIdAndKTIIdMap = new Map<String,string>();

     
    // only share records created in this org, do not add contacts received from another org.
    if(Trigger.isAfter && Trigger.isInsert) {
    
        for (Contact newContact : TRIGGER.new) {
        
            if (newContact.ConnectionReceivedId == null && newContact.AccountId != null) {
                localContactAccountSet.add(newContact.AccountId);
                localContacts.add(newContact);
            }   
            
            if( newContact.ConnectionReceivedId != null && newContact.KTS_Contact_Id__c != NULL && newContact.KTI_Contact_Id__c!= NULL ) {
            
                conKTIIdAndKTSIdMap.put(newContact.KTI_Contact_Id__c,newContact.KTS_Contact_Id__c);  
            }   
        }
        
        System.Debug('<---conKTIIdAndKTSIdMap--->'+conKTIIdAndKTSIdMap);
        
        if(conKTIIdAndKTSIdMap != NULL && conKTIIdAndKTSIdMap.Size() > 0){
             
             Cls_SendResponseToKTI.updateContactKTSIdToKTI(conKTIIdAndKTSIdMap);
        }
        
        system.debug('***localContactAccountSet: ' + localContactAccountSet);
        if(localContactAccountSet != null && localContactAccountSet.size() > 0) {
            

            for(Account acc : [SELECT Id,Name,Do_Not_Share__c,Classified__c FROM Account WHERE Id IN : localContactAccountSet AND Do_Not_Share__c = False AND Classified__c = False]) {
                system.debug('***account id: ' + acc.id);
                system.debug('***account classified?: ' + acc.classified__c);
                system.debug('***account id: ' + acc.id);
                sharedAccountSet.add(acc.Id);
            }
            
            Map<Id,Id> accIdToRecordConnection = S2SUtils.accToSharedRecordId(sharedAccountSet);
            
            system.debug('***sharedAccountSet: ' + sharedAccountSet);
            if(sharedAccountSet != null && sharedAccountSet.size() > 0) {
                
                List<PartnerNetworkRecordConnection> contactConnections =  new  List<PartnerNetworkRecordConnection>();
    
                for(Contact newContact : localContacts) {
                    
                    if (accIdToRecordConnection.get(newContact.AccountId) != null && sharedAccountSet.contains(newContact.AccountId)) {
                        system.debug('***sharing contact with accountId: ' + newContact.AccountId);
                        PartnerNetworkRecordConnection newConnection =
                          new PartnerNetworkRecordConnection(
                              ConnectionId = networkId,
                              LocalRecordId = newContact.Id,
                              SendClosedTasks = false,
                              SendOpenTasks = false,
                              SendEmails = false,
                              ParentRecordId = newContact.AccountId);
                              
                        contactConnections.add(newConnection);
                    }
                }
                
                if(contactConnections != null && contactConnections.size() > 0 ) {
                    
                    database.insert(contactConnections);
                }
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
    
        for( Contact con : Trigger.New ){
            
            //To change the KTS Account Id when the Partner is updated here
            if( (con.AccountId != NULL && Trigger.oldMap.get(con.Id).AccountId == NULL) || (con.AccountId != NULL && Trigger.oldMap.get(con.Id).AccountId != NULL && !con.AccountId.equals(Trigger.oldMap.get(con.Id).AccountId )) ) {
                
                conToChangeKTSAccIdList.add(con);
                conIdSetToChangeKTSAccId.add(con.AccountId);
            }
            
            //To update the AccountId when the KTS Account Id changes
            if( (con.KTI_Account_Id__c != NULL && Trigger.oldMap.get(con.Id).KTI_Account_Id__c == NULL) || (con.KTI_Account_Id__c != NULL && Trigger.oldMap.get(con.Id).KTI_Account_Id__c != NULL && !con.KTI_Account_Id__c.equals(Trigger.oldMap.get(con.Id).KTI_Account_Id__c) )) {
                
                conToAddAccountList.add(con);
                conWithParentAccSet.add(con.KTI_Account_Id__c.substring(0,15));
            } 
            
            //To update the Contact Owner to the Other Org  
            if(con.OwnerId != NULL && Trigger.OldMap.get(con.Id).OwnerId != NULL && Trigger.OldMap.get(con.Id).OwnerId !=con.OwnerId ) {
                
                conKTIIdAndKTSIdMap.put(con.KTI_Contact_Id__c,con.KTS_Contact_Id__c);
            }       
        }
        
        if( conKTIIdAndKTSIdMap != NULL && conKTIIdAndKTSIdMap.Size() > 0 ) Cls_SendResponseToKTI.updateContactKTSIdToKTI(conKTIIdAndKTSIdMap);
        
        if( conIdSetToChangeKTSAccId != NULL && conIdSetToChangeKTSAccId.size() >0 ){
            
            for(Account acc : [SELECT Id,KTI_Id__c FROM Account WHERE Id IN : conIdSetToChangeKTSAccId]){
                
                AccIdAndKTIIdMap.put(acc.Id,acc.KTI_Id__c);
            }
            
            for( Contact con : conToChangeKTSAccIdList ) {
                
                con.KTI_Account_Id__c = AccIdAndKTIIdMap.get(con.AccountId).substring(0,15);
            }
        }
        System.Debug('<---conWithParentAccSet--->'+conWithParentAccSet);
        
        if(conWithParentAccSet != null && conWithParentAccSet.size() > 0) {
        
            for(Account parentAcc : [SELECT Id,KTI_Id__c FROM Account WHERE KTI_Id__c IN : conWithParentAccSet]) {
                
                KTIIdAndParentAccIdMap.put(parentAcc.KTI_Id__c,parentAcc.Id);
            }
            
            System.Debug('<---KTIIdAndParentAccIdMap--->'+KTIIdAndParentAccIdMap);
            
            if(conToAddAccountList != null && conToAddAccountList.size() > 0 && KTIIdAndParentAccIdMap != null && KTIIdAndParentAccIdMap.size() > 0) {
            
                for( Contact con : conToAddAccountList ){
                    
                    if(KTIIdAndParentAccIdMap.get(con.KTI_Account_Id__c) != NULL ) {
                        
                        con.AccountId = KTIIdAndParentAccIdMap.get(con.KTI_Account_Id__c);
                    }
                }
            }
        }
    }
}