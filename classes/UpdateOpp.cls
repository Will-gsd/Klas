@RestResource(UrlMapping='/updateOpportunity/')
global class UpdateOpp {
    public class KTSAndKTIId{
        public String ktsId;
        public String ktiId;
        public String ktiParentAccId;
        public String ktiOwner;
    }
    @HttpPOST
    global static string updateOppKTIId(){
    
        RestRequest req = RestContext.request;
        List<Opportunity> updateOppList = new List<Opportunity>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> oppKtsIdAndKtiIdMap = new Map<String,String>();
        Map<String,String> oppKtsIdAndKtiParentAccIdMap = new Map<String,String>();
        Map<String,String> oppKtsIdAndKtiOwnerMap = new Map<String,String>();
        
        for(KTSAndKTIId str : IdClsList) {
            oppKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
            if(str.ktiParentAccId != NULL) oppKtsIdAndKtiParentAccIdMap.put(str.ktsId,str.ktiParentAccId);
            if(str.ktiOwner != NULL) oppKtsIdAndKtiOwnerMap.put(str.ktsId,str.ktiOwner);
        }
        
        System.Debug('<----oppKtsIdAndKtiIdMap---->'+oppKtsIdAndKtiIdMap);
        if( oppKtsIdAndKtiIdMap != NULL && oppKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Opportunity opp : [SELECT Id, KTS_Id__c, KTI_Id__c,KTI_AccountId__c FROM Opportunity WHERE Id IN : oppKtsIdAndKtiIdMap.KeySet()]) {
                opp.KTI_Id__c = oppKtsIdAndKtiIdMap.get(opp.KTS_Id__c);
                if( oppKtsIdAndKtiParentAccIdMap.containsKey(opp.KTS_Id__c) ) opp.KTI_AccountId__c = oppKtsIdAndKtiParentAccIdMap.get(opp.KTS_Id__c);
                if( oppKtsIdAndKtiOwnerMap.containsKey(opp.KTS_Id__c) ) opp.KTI_Opportunity_Owner__c = oppKtsIdAndKtiOwnerMap.get(opp.KTS_Id__c);
                updateOppList.add(opp);
            }
            System.Debug('<----updateOppList---->'+updateOppList);

            if( updateOppList != NULL && updateOppList.Size() > 0 ) {
                update updateOppList;
            }
        }
        
        return NULL;
    }
}