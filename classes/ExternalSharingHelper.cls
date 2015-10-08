public class ExternalSharingHelper {
    @future 
    
    public static void linkOpportunity(Map<Id,Id> oppIdMap) 
    {
        Set<Id> KTIOppIdSet = new Set<Id>(); 
        for (Id KTIOppId : oppIdMap.values()) 
        {
            System.debug('linkOpportunity: KTIOppId = ' + KTIOppId);
            KTIOppIdSet.add(KTIOppId); 
        } 
        
        Map<Id,Id> oppMap = new Map<Id,Id>(); 
        System.debug('ExternalSharingHelper.linkOpportunity: Map created');
        
        for (PartnerNetworkRecordConnection opportunityConnection : 
            [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
             FROM PartnerNetworkRecordConnection 
             WHERE PartnerRecordId in :KTIOppIdSet]) 
        { 
            System.debug('Found match in KTIOppIdSet');
            if ( opportunityConnection.Status == 'Sent' || opportunityConnection.Status == 'Received') 
            {
                oppMap.put(opportunityConnection.PartnerRecordId, opportunityConnection.LocalRecordId); 
                System.debug('linkOpportunity: opportunityConnection.PartnerRecordId = ' + opportunityConnection.PartnerRecordId + ',opportunityConnection.LocalRecordId = ' + opportunityConnection.LocalRecordId);
            } 
        } 
        
        List<Opportunity> localOppList = new List<Opportunity>();
        
        for (Id oppId : oppIdMap.keySet()) { 
            Opportunity oppForUpdate = new Opportunity(id=oppId); 
            oppForUpdate.AccountId  =  oppMap.get(oppIdMap.get(oppId));
            System.debug('oppForUpdate.AccountId = ' + oppForUpdate.AccountId);
            localOppList.add(oppForUpdate);                                                          
        }
        System.Debug('localOppList:::'+localOppList);
        database.update(localOppList);         
    }
}