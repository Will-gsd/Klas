trigger task_Trg_S2S_Shareing on Task (before insert, after insert, before update,after update) {

    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);

    /*Variables to map the Contact for case*/
    Set<String> taskContactIdSet = new Set<String>();
    Set<String> taskLeadIdSet = new Set<String>();
    List<task> taskToAddWhoIdList = new List<task>();
    
    //Var to change the KTI con Lead Id
    List<task> taskToChangeKTSContOrleadIdList = new List<task>(); 
    Set<Id> taskIdSetToChangeKTSContId = new Set<Id>();
    Set<Id> taskIdSetToChangeKTSLeadId = new Set<Id>();

    Map<String,String> taskKTIIdAndKTSIdMap = new Map<String,String>();

    if( Trigger.isBefore && Trigger.isInsert) {
        
        for(Task newTaskRec : Trigger.New) {
        
            if(newTaskRec.ConnectionReceivedId != null) {
            
                if(newTaskRec.KTI_con_lead_Id__c != null) {
                    
                    if((newTaskRec.KTI_con_lead_Id__c).subString(0,3).equals('003')) {
                        taskContactIdSet.add(newTaskRec.KTI_con_lead_Id__c); 
                    }
                    taskToAddWhoIdList.add(newTaskRec);
                    
                    if((newTaskRec.KTI_con_lead_Id__c).subString(0,3).equals('00Q')) {
                        taskLeadIdSet.add(newTaskRec.KTI_con_lead_Id__c);
                    }
                }
            }
        }
    }
    
    if(trigger.isAfter && Trigger.isInsert) {
        List<Task> taskRecList = new List<Task>();
        
        
        for(task newTaskRec : trigger.new) {
            
            if(newTaskRec.ConnectionReceivedId == null) {
                
                taskRecList.add(newTaskRec);
            } 
            
            if(newTaskRec.ConnectionReceivedId != null && newTaskRec.KTI_Task_Id__c != NULL && newTaskRec.KTS_Task_Id__c!= NULL) {
            
                taskKTIIdAndKTSIdMap.put(newTaskRec.KTI_Task_Id__c,newTaskRec.KTS_Task_Id__c);
            }       
        }
        
        if(taskKTIIdAndKTSIdMap != NULL && taskKTIIdAndKTSIdMap.Size() > 0) { 
        
            Cls_SendResponseToKTI.updateTaskKTSIdToKTI(taskKTIIdAndKTSIdMap);
        }
        
        if(taskRecList != null && taskRecList.size() > 0) {
        
            List<PartnerNetworkRecordConnection> caseConnections =  new  List<PartnerNetworkRecordConnection>();
            
            for (Task newCase : taskRecList) {
                string parntId;
                if(newCase.WhatId != null) {
                    parntId = newCase.WhatId;
                    system.debug('IF'+parntId);
                } else {
                    parntId = newCase.WhoId;
                    system.debug('Else'+parntId);
                }
                PartnerNetworkRecordConnection newConnection =
                    new PartnerNetworkRecordConnection(
                        ConnectionId = networkId,
                        LocalRecordId = newCase.Id,
                        SendClosedTasks = false,
                        SendOpenTasks = false,
                        SendEmails = false,
                        ParentRecordId = parntId);
                      
                caseConnections.add(newConnection);    
            }
            
            if(caseConnections != null && caseConnections.size() > 0) {
               try{
                    database.insert(caseConnections);
                }catch(Exception e){
                    system.debug('***DID NOT SHARE: ' + e);
                    system.debug('***Error message: ' + e.getMessage());
                }
            }
        }
    }

    /*
        // Define connection id
        Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName); 
        Set<Id> caseAccountIdSet = new Set<Id>(); 
        Set<Id> sharedAccountSet = new Set<Id>();
        List<Task> taskRecList = new List<Task>();
        Set<Id> taskIdWithWhoIdSet = new Set<Id>();  
        
        for(Task newCaseRec : trigger.new) {
            
             System.debug('::::newCaseRec:::::'+newCaseRec);
             System.debug('::::newCaseRec.ConnectionReceivedId:::::'+newCaseRec.ConnectionReceivedId);
             System.debug('::::newCaseRec.WhatId :::::'+newCaseRec.WhatId );
             //System.debug('::::String.valueOf(newCaseRec.WhatId).subString(0,3):::::'+String.valueOf(newCaseRec.WhatId).subString(0,3));
             if(newCaseRec.ConnectionReceivedId == null && newCaseRec.WhatId != null && (String.valueOf(newCaseRec.WhatId)).subString(0,3).equals('001') ) {
                 
                 caseAccountIdSet.add(newCaseRec.WhatId);     
                 taskRecList.add(newCaseRec);   
             } else if ( newCaseRec.ConnectionReceivedId == null && newCaseRec.WhoId != null && ( (String.valueOf(newCaseRec.WhoId)).subString(0,3).equals('00Q') || (String.valueOf(newCaseRec.WhoId)).subString(0,3).equals('003') )  ) {
                 
                 taskIdWithWhoIdSet.add(newCaseRec.WhoId);
                 taskRecList.add(newCaseRec);
             }
             System.debug('::::caseAccountIdSet:::::'+caseAccountIdSet);
             System.debug('::::taskRecList:::::'+taskRecList);
    
             
             if(newCaseRec.ConnectionReceivedId != null && newCaseRec.KTS_Task_Id__c != NULL && newCaseRec.KTI_Task_Id__c != NULL ) {
            
                 taskKTIIdAndKTSIdMap.put(newCaseRec.KTI_Task_Id__c, newCaseRec.KTS_Task_Id__c);  
             }   
             System.debug('::::taskKTIIdAndKTSIdMap:::::'+taskKTIIdAndKTSIdMap);
             
        }
            
        if(taskKTIIdAndKTSIdMap != NULL && taskKTIIdAndKTSIdMap.Size() > 0){
             
             Cls_SendResponseToKTI.updateTaskKTSIdToKTI(taskKTIIdAndKTSIdMap);
        } 
            
        if( (caseAccountIdSet != null && caseAccountIdSet.size() > 0) || (taskIdWithWhoIdSet != null && taskIdWithWhoIdSet.size() > 0 ) )  {
            
            for(Account acc : [SELECT Id, Name, Do_Not_Share__c FROM Account WHERE Id IN : caseAccountIdSet AND Do_Not_Share__c = False]) {
                
                sharedAccountSet.add(acc.Id);
            } 
            System.debug(':::::sharedAccountSet::::'+sharedAccountSet);
    
            if( (sharedAccountSet != null && sharedAccountSet.size() > 0) || (taskIdWithWhoIdSet != null && taskIdWithWhoIdSet.size() > 0 ) ) {   
            
                List<PartnerNetworkRecordConnection> taskConnections =  new  List<PartnerNetworkRecordConnection>();
                
                 for(Task newCase : taskRecList) {
                    Id parntId;
                    
                    if(sharedAccountSet.contains(newCase.WhatId)) {
                        
                        parntId = newCase.WhatId;
                    } else if (taskIdWithWhoIdSet.contains(newcase.WhoId)) {
                       
                        parntId = newcase.WhoId;
                    }
                        PartnerNetworkRecordConnection newConnection =
                          new PartnerNetworkRecordConnection(
                              ConnectionId = networkId,
                              LocalRecordId = newCase.Id,
                              SendClosedTasks = false,
                              SendOpenTasks = false,
                              SendEmails = false,
                              ParentRecordId = parntId);
                        taskConnections.add(newConnection); 
                }
                
                if(taskConnections != null && taskConnections.size() > 0 ) {
                    system.debug('***newConnectioN: ' + taskConnections[0]);
                    database.insert(taskConnections);
                }    
            }
            
        }
    }
    */
    if(trigger.isBefore && trigger.isUpdate) {
    
        //Variables to change the KTI Acc Id
        List<Task> taskToChangeKTIAccIdList = new List<task>(); 
        
        Map<String,string> taskIdAndKTIIdMap = new Map<String,string>();
        
        //List<task> taskToAddAccountList = new List<task>();
        //Set<String> taskWithParentAccSet = new Set<String>();
        //Map<String,string> AccIdAndKTIIdMap = new Map<String,string>();
        //Map<String,Id> KTIIdAndParentAccIdMap = new Map<String,Id>();
        
        Set<Id> whatIdAccSet = new Set<Id>(); 
        Set<Id> whatIdOppSet = new Set<Id>();
        Set<Id> whatIdProdSet = new Set<Id>();
        Set<Id> whatIdAssetSet = new Set<Id>();
        Set<Id> whatIdCaseSet = new Set<Id>();
        Set<Id> whatIdQuoteSet = new Set<Id>();
        
        Map<Id,Account> IdAndAccountMap = new Map<Id,Account>();
        Map<Id,Opportunity> IdAndOppMap = new Map<Id,Opportunity>();
        Map<Id,Product2> IdAndProdMap = new Map<Id,Product2>();
        Map<Id,Asset> IdAndAssetMap = new Map<Id,Asset>();
        Map<Id,Case> IdAndCaseMap = new Map<Id,Case>();
        Map<Id,Quote> IdAndQuoteMap = new Map<Id,Quote>();
        
        for(task newtask : trigger.new) {
        
            if((newtask.KTI_con_lead_Id__c != NULL && Trigger.oldMap.get(newtask.Id).KTI_con_lead_Id__c == NULL) || (newtask.KTI_con_lead_Id__c != null && Trigger.oldMap.get(newtask.Id).KTI_con_lead_Id__c != NULL && !newtask.KTI_con_lead_Id__c.equals(Trigger.oldMap.get(newtask.Id).KTI_con_lead_Id__c) ) ) {
                    
                if((newtask.KTI_con_lead_Id__c).subString(0,3).equals('003')) {
                    taskContactIdSet.add(newtask.KTI_con_lead_Id__c); 
                }
                taskToAddWhoIdList.add(newtask);
                
                if((newtask.KTI_con_lead_Id__c).subString(0,3).equals('00Q')) {
                    taskLeadIdSet.add(newtask.KTI_con_lead_Id__c);
                }
            }    
            if( (newtask.WhoId != NULL && Trigger.oldMap.get(newtask.Id).WhoId == NULL) || (newtask.WhoId != NULL && Trigger.oldMap.get(newtask.Id).WhoId != NULL && !newtask.WhoId.equals(Trigger.oldMap.get(newtask.Id).WhoId)) ) {
                
                taskToChangeKTSContOrleadIdList.add(newtask);
                
                if((String.valueOf(newtask.WhoId)).subString(0,3).equals('003')) {
                    taskIdSetToChangeKTSContId.add(newtask.WhoId); 
                }
                if((String.valueOf(newtask.WhoId)).subString(0,3).equals('00Q')) {
                    taskIdSetToChangeKTSLeadId.add(newtask.WhoId);
                }
            } 
            
            /*//To update the task Owner to the Other Org  
            if(newtask.OwnerId != NULL && Trigger.OldMap.get(newtask.Id).OwnerId != NULL && Trigger.OldMap.get(newtask.Id).OwnerId != newtask.OwnerId ) {
                
                taskKTIIdAndKTSIdMap.put(newtask.KTI_task_Id__c,newtask.KTS_task_Id__c);
            } 
            System.debug(':::taskKTIIdAndKTSIdMap:::'+taskKTIIdAndKTSIdMap);
            */
            if( (newtask.WhatId != NULL && Trigger.oldMap.get(newtask.Id).WhatId == NULL) || (newtask.WhatId != NULL && Trigger.oldMap.get(newtask.Id).WhatId != NULL && !newtask.WhatId.equals(Trigger.oldMap.get(newtask.Id).WhatId)) ) {
                
                taskToChangeKTIAccIdList.add(newtask);
                if(newtask.whatId != null && (string.ValueOf(newtask.whatId)).subString(0,3).equals('001')) {
                    whatIdAccSet.add((newtask.whatId));
                } else if(newtask.whatId != null && (string.ValueOf(newtask.whatId)).subString(0,3).equals('006')) {
                    whatIdOppSet.add((newtask.whatId));
                } else if(newtask.whatId != null && (string.ValueOf(newtask.whatId)).subString(0,3).equals('01t')) {
                    whatIdProdSet.add((newtask.whatId));
                } else if(newtask.whatId != null && (string.ValueOf(newtask.whatId)).subString(0,3).equals('02i')) {
                    whatIdAssetSet.add(newtask.whatId);
                } else if(newtask.whatId != null && (string.ValueOf(newtask.whatId)).subString(0,3).equals('500')) {
                    whatIdCaseSet.add((newtask.whatId));
                } else if(newtask.whatId != null && (string.ValueOf(newtask.whatId)).subString(0,3).equals('0Q0')) {
                    whatIdQuoteSet.add(newtask.whatId);
                }
            } 
            System.debug(':::taskToChangeKTIAccIdList:::'+taskToChangeKTIAccIdList);
                          
        }
        
        if( taskKTIIdAndKTSIdMap != NULL && taskKTIIdAndKTSIdMap.Size() > 0 ) {
        
            Cls_SendResponseToKTI.updatetaskKTSIdToKTI(taskKTIIdAndKTSIdMap);
        }
        
        if(taskToChangeKTIAccIdList != NULL && taskToChangeKTIAccIdList.size() > 0){
            
            if( whatIdAccSet != null && whatIdAccSet.size() > 0 ) {
                for(Account acc : [SELECT Id,KTI_Id__c FROM Account WHERE Id IN : whatIdAccSet]){
                    IdAndAccountMap.put(acc.Id,acc);
                }
            }
            if( whatIdOppSet != null && whatIdOppSet.size() > 0 ) {
                for (Opportunity opp : [SELECT Id,KTS_Id__c,KTI_Id__c FROM Opportunity WHERE Id IN : whatIdOppSet] ) {
                    IdAndOppMap.put(opp.Id,opp);
                }
            }
            if( whatIdProdSet != null && whatIdProdSet.size() > 0 ) {
                for (Product2 prod : [SELECT Id,KTS_Product_Id__c,KTI_Product_Id__c FROM Product2 WHERE Id IN : whatIdProdSet] ) {
                    IdAndProdMap.put(prod.Id,prod);
                }
            }
            if( whatIdAssetSet != null && whatIdAssetSet.size() > 0 ) {
                for (Asset ast : [SELECT Id,KTI_Asset_Id__c FROM Asset WHERE Id IN : whatIdAssetSet] ) {
                    IdAndAssetMap.put(ast.Id,ast);
                }
            }
            if( whatIdCaseSet != null && whatIdCaseSet.size() > 0 ) {
                for (Case cs : [SELECT Id,KTS_Case_Id__c,KTI_Case_Id__c FROM Case WHERE Id IN : whatIdCaseSet] ) {
                    IdAndCaseMap.put(cs.Id,cs);
                }
            }
            if( whatIdQuoteSet != null && whatIdQuoteSet.size() > 0 ) {
                for (Quote qt : [SELECT Id,KTI_Quote_Id__c FROM Quote WHERE Id IN : whatIdQuoteSet] ) {
                    IdAndQuoteMap.put(qt.Id,qt);
                }
            }
            for( task tas : taskToChangeKTIAccIdList) {
                
                if(IdAndAccountMap != null && IdAndAccountMap.size() > 0 && IdAndAccountMap.containsKey(tas.whatId)) {
                    tas.KTI_Account_Id__c = IdAndAccountMap.get(tas.whatId).KTI_Id__c;
                } else if(IdAndOppMap != null && IdAndOppMap.size() >0 && IdAndOppMap.containsKey(tas.whatId)) {
                    tas.KTI_Account_Id__c = IdAndOppMap.get(tas.whatId).KTI_Id__c;
                } else if(IdAndProdMap != null && IdAndProdMap.size() > 0 && IdAndProdMap.containsKey(tas.whatId)) {
                    tas.KTI_Account_Id__c = IdAndProdMap.get(tas.whatId).KTI_Product_Id__c;
                } else if(IdAndAssetMap != null && IdAndAssetMap.size() > 0 && IdAndAssetMap.containsKey(tas.whatId)) {
                    tas.KTI_Account_Id__c = IdAndAssetMap.get(tas.whatId).KTI_Asset_Id__c;
                } else if(IdAndCaseMap != null && IdAndCaseMap.size() > 0 && IdAndCaseMap.containsKey(tas.whatId)) {
                    tas.KTI_Account_Id__c = IdAndCaseMap.get(tas.whatId).KTI_Case_Id__c;
                } else if(IdAndQuoteMap != null && IdAndQuoteMap.size() > 0 && IdAndQuoteMap.containsKey(tas.whatId)) {
                    tas.KTI_Account_Id__c = IdAndQuoteMap.get(tas.whatId).KTI_Quote_Id__c;
                }
            }
        }
    }
    if( ( taskContactIdSet != null && taskContactIdSet.size() > 0 ) || ( taskLeadIdSet != null && taskLeadIdSet.size() > 0 ) ) {
        System.debug('-----------------------------------------------'+taskContactIdSet+'::::'+taskLeadIdSet);
        Map<String,Id> KTIIdAndContactIdMap = new Map<String,Id>(); 
        Map<String,Id> KTIIdAndLeadIdMap = new Map<String,Id>();        
       
        for(Contact con : [SELECT Id,KTI_Contact_Id__c FROM Contact WHERE KTI_Contact_Id__c IN : taskContactIdSet]) {
            
            KTIIdAndContactIdMap.put(con.KTI_Contact_Id__c,con.Id);
        }
        for(Lead ld : [SELECT Id,KTI_Lead_Id__c FROM Lead WHERE KTI_Lead_Id__c IN : taskLeadIdSet]) {
            
            KTIIdAndLeadIdMap.put(ld.KTI_Lead_Id__c,ld.Id);
        }

        System.Debug('<---KTIIdAndContactIdMap--->'+KTIIdAndContactIdMap);
        
        if(taskToAddWhoIdList != null && taskToAddWhoIdList.size() > 0 && KTIIdAndContactIdMap != null && KTIIdAndContactIdMap.size() > 0) {
        
            for( Task tas : taskToAddWhoIdList){
                
                if(KTIIdAndContactIdMap.containsKey(tas.KTI_con_lead_Id__c)) {
                    
                    tas.WhoId = KTIIdAndContactIdMap.get(tas.KTI_con_lead_Id__c);
                } else if(KTIIdAndLeadIdMap.containsKey(tas.KTI_con_lead_Id__c)) {
                    
                    tas.WhoId = KTIIdAndLeadIdMap.get(tas.KTI_con_lead_Id__c);
                }

            }
        }
    }
    
    /*if(taskLeadIdSet != null && taskLeadIdSet.size() > 0) {
        System.debug('-----------------------------------------------'+taskLeadIdSet);
        Map<String,Id> KTIIdAndLeadIdMap = new Map<String,Id>();        
        for(Lead ld : [SELECT Id,KTI_Lead_Id__c FROM Lead WHERE KTI_Lead_Id__c IN : taskLeadIdSet]) {
            
            KTIIdAndLeadIdMap.put(ld.KTI_Lead_Id__c,ld.Id);
        }
        
        System.Debug('<---KTIIdAndLeadIdMap--->'+KTIIdAndLeadIdMap);
        
        if(taskToAddWhoIdList != null && taskToAddWhoIdList.size() > 0 && KTIIdAndLeadIdMap != null && KTIIdAndLeadIdMap.size() > 0) {
        
            for( Task tas : taskToAddWhoIdList){
                
                if(KTIIdAndLeadIdMap.containsKey(tas.KTI_con_lead_Id__c)) {
                    
                    tas.WhoId = KTIIdAndLeadIdMap.get(tas.KTI_con_lead_Id__c);
                }
            }
        }
    }*/
    
    // To update the KTI Con or Lead Id when the WhoId Changes
    if( (taskIdSetToChangeKTSContId != null && taskIdSetToChangeKTSContId.size() > 0) || (taskIdSetToChangeKTSLeadId != null && taskIdSetToChangeKTSLeadId.size() > 0) ) {
        
        Map<String,String> ContactIdAndKTIIdMap = new Map<String,String>();  
        Map<String,String> LeadIdAndKTIIdMap = new Map<String,String>();
              
        for(Contact con : [SELECT Id,KTI_Contact_Id__c FROM Contact WHERE Id IN : taskIdSetToChangeKTSContId]) {
            
            ContactIdAndKTIIdMap.put(con.Id,con.KTI_Contact_Id__c);
        }
        for(Lead ld : [SELECT Id,KTI_Lead_Id__c FROM Lead WHERE Id IN : taskIdSetToChangeKTSLeadId]) {
            
            LeadIdAndKTIIdMap.put(ld.Id,ld.KTI_Lead_Id__c);
        }
        System.Debug('<---ContactIdAndKTIIdMap--->'+ContactIdAndKTIIdMap);
        System.Debug('<---LeadIdAndKTIIdMap--->'+LeadIdAndKTIIdMap);

        if(taskToChangeKTSContOrleadIdList != null && taskToChangeKTSContOrleadIdList.size() > 0 /*&& ContactIdAndKTIIdMap != null && ContactIdAndKTIIdMap.size() > 0*/) {
        
            for( Task tas : taskToChangeKTSContOrleadIdList){
                
                if(ContactIdAndKTIIdMap.containsKey(tas.WhoId)) {
                    if(ContactIdAndKTIIdMap.get(tas.WhoId) != null) tas.KTI_con_lead_Id__c = ContactIdAndKTIIdMap.get(tas.WhoId).substring(0,15);
                } else if(LeadIdAndKTIIdMap.containsKey(tas.WhoId)) {
                    if(LeadIdAndKTIIdMap.get(tas.WhoId) != null) tas.KTI_con_lead_Id__c = LeadIdAndKTIIdMap.get(tas.WhoId).substring(0,15);
                }
            }
        }
    }
    if( trigger.IsAfter && Trigger.IsUpdate){
        Set<Id> taskIdSet = new Set<Id>();
        Set<Id> sharedTaskIdSet = new Set<Id>();
        Set<Id> taskIdSetNotToUpdate = new Set<Id>();
        for(Task tsk : Trigger.New){
            if(trigger.oldmap.get(tsk.Id).whatId == tsk.WhatId) {
                sharedTaskIdSet.add(tsk.Id);
            }
        }
        if( sharedTaskIdSet != null && sharedTaskIdSet.size() > 0 ) {
            for(PartnerNetworkRecordConnection conRec : [SELECT Id,LocalRecordId FROM PartnerNetworkRecordConnection WHERE LocalRecordId IN : sharedTaskIdSet AND (Status = 'Sent' OR Status ='Received')]){
                taskIdSetNotToUpdate.add(conRec.LocalRecordId);
            }
        }
        System.debug('<-taskIdSetNotToUpdate->'+taskIdSetNotToUpdate);
        for(Task tk : Trigger.New) {
            System.debug('<---tk--->'+tk);
            System.debug('<---tk old map--->'+trigger.oldMap.get(tk.Id));
            System.debug('<---AssetClass.processedIdSet--->'+AssetClass.processedIdSet);
            
            if ( Trigger.IsUpdate && Trigger.OldMap.get(tk.Id).Updated_in_KTS__c == FALSE && tk.Updated_in_KTS__c) {
                    
                    AssetClass.processedIdSet.add(tk.Id);
            }
            if( /*(tk.ConnectionReceivedId == NULL) && (tk.ConnectionSentId == null) */ !taskIdSetNotToUpdate.contains(tk.Id) && tk.LastModifiedById != '005F0000003aYETIA2' &&  !AssetClass.processedIdSet.contains(tk.Id) && !(trigger.oldMap.get(tk.Id).Updated_In_KTS__c  && tk.Updated_In_KTS__c == False) ) {
                taskIdSet.add(tk.Id);
                AssetClass.processedIdSet.add(tk.Id);
            }
        }
        if ( taskIdSet != null && taskIdSet.size() > 0 ) {
            TaskExternalUpdate.linkTask(taskIdSet);
        }
    }
}