trigger ShareLeadToPartner on Lead ( after insert, before update ) {

    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);
     
   // Set<Id> localLeadAccountSet = new Set<Id>();
    List<Lead> localLead = new List<Lead>();
    Map<Id,Id> leadKTIIdAndKTSIdMap = new Map<Id,Id>();
    //Set<Id> sharedAccountSet = new Set<Id>();   
     
    // only share records created in this org, do not add contacts received from another org.
    if( Trigger.IsAfter && Trigger.IsInsert ) {
    
        for ( Lead newLead : TRIGGER.new ) {
        
            if ( newLead.ConnectionReceivedId == null ) {
            
                localLead.add(newLead);
            }   
             if( newLead.ConnectionReceivedId != null && newLead.KTS_Lead_Id__c != NULL && newLead.KTI_Lead_Id__c!= NULL ) leadKTIIdAndKTSIdMap.put(newLead.KTI_Lead_Id__c,newLead.KTS_Lead_Id__c);        
        } 
           
        if ( localLead!= NULL && localLead.size() > 0 ) {
        
            List<PartnerNetworkRecordConnection> LeadConnections =  new  List<PartnerNetworkRecordConnection>();
    
            for ( Lead newLead : localLead ) {
    
                PartnerNetworkRecordConnection newConnection =
                  new PartnerNetworkRecordConnection(
                      ConnectionId = networkId,
                      LocalRecordId = newLead.Id,
                      SendClosedTasks = false,
                      SendOpenTasks = false,
                      SendEmails = false);
                      
                LeadConnections.add(newConnection);
            }
            
            if ( LeadConnections != NULL && LeadConnections.size() > 0 ) {
                   insert LeadConnections;
            }
        }
        System.Debug('<---leadKTIIdAndKTSIdMap--->'+leadKTIIdAndKTSIdMap);
        if( leadKTIIdAndKTSIdMap != NULL && leadKTIIdAndKTSIdMap.Size() > 0 ) Cls_SendResponseToKTI.updateLeadKTSToKTI(leadKTIIdAndKTSIdMap);
    }
    //if the trigger is before and update
    if (Trigger.IsBefore && Trigger.IsUpdate){
      //iterate over each id in the trigger set
      Set <Id> lIds = new Set <Id>();
      for (Id lid : Trigger.newMap.keyset()){
        //if the ownerId of the new lead does not equal the id of the old lead
        if( Trigger.oldMap.get(lid).OwnerId != Trigger.newMap.get(lid).OwnerId ){
          //add the lead's id to a set
        
          lIds.add(lid);
              
        }
      
      }

      //if the set is not empty
      if(lIds.size() > 0){
      //pass the set to the future method
      S2SUtils.updateRecords(lids, 'Lead'); 

      }
          
    }
}