@RestResource(UrlMapping='/updateLead/')
global class UpdateLead {
    public class KTSAndKTIId{
        public String ktsId;
        public String ktiId;
    }
    @HttpPOST
    global static string updateLeadKTIId(){
    
        RestRequest req = RestContext.request;
        List<Lead> updateLeadList = new List<Lead>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> leadKtsIdAndKtiIdMap = new Map<String,String>();
        
        for(KTSAndKTIId str : IdClsList) {
            leadKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
        }
        
        System.Debug('<----leadKtsIdAndKtiIdMap---->'+leadKtsIdAndKtiIdMap);
        if( leadKtsIdAndKtiIdMap != NULL && leadKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Lead ld : [SELECT Id, KTS_Lead_Id__c, KTI_Lead_Id__c FROM Lead WHERE Id IN : leadKtsIdAndKtiIdMap.KeySet()]) {
                ld.KTI_Lead_Id__c = leadKtsIdAndKtiIdMap.get(ld.Id);
                updateLeadList.add(ld);
            }
            System.Debug('<----updateLeadList---->'+updateLeadList);

            if( updateLeadList != NULL && updateLeadList.Size() > 0 ) {
                update updateLeadList;
            }
        }
        
        return NULL;
    }
}