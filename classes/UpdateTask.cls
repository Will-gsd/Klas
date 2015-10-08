@RestResource(UrlMapping='/updateTask/')
global class UpdateTask {
    
    public class KTSAndKTIId{
        public String ktsId;
        public String ktiId;
        public String ktiParentAccId;
        public String ktiOwner;
        public String ktiParentCaseId;
        public String ktiCaseContactId;
    }
    
    @HttpPOST
    global static string updateTaskKTIId(){
    
        RestRequest req = RestContext.request;
        List<Task> updateCaseList = new List<Task>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> taskKtsIdAndKtiIdMap = new Map<String,String>();
        Map<String,String> taskKtsIdAndKtiParentAccIdMap = new Map<String,String>();
        Map<String,String> taskKtsIdAndKtiOwnerMap = new Map<String,String>();
        Map<String,String> taskKtsIdAndKtiParentCaseIdMap = new Map<String,String>();
        Map<String,String> taskKtsIdAndKtiContactIdMap = new Map<String,String>();
        
        for(KTSAndKTIId str : IdClsList) {
            
            taskKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
            if(str.ktiParentAccId != NULL) taskKtsIdAndKtiParentAccIdMap.put(str.ktsId,str.ktiParentAccId);
            if(str.ktiOwner != NULL) taskKtsIdAndKtiOwnerMap.put(str.ktsId,str.ktiOwner);
            if(str.ktiCaseContactId != NULL) taskKtsIdAndKtiContactIdMap.put(str.ktsId,str.ktiCaseContactId);
        }
        
        System.Debug('<----taskKtsIdAndKtiIdMap---->'+taskKtsIdAndKtiIdMap);
        if( taskKtsIdAndKtiIdMap != NULL && taskKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Task cs : [SELECT Id, KTS_Task_Id__c, KTI_Task_Id__c FROM Task WHERE Id IN : taskKtsIdAndKtiIdMap.KeySet()]) {
               
                cs.KTI_Task_Id__c = taskKtsIdAndKtiIdMap.get(cs.KTS_Task_Id__c);
                if( taskKtsIdAndKtiParentAccIdMap.containsKey(cs.KTS_Task_Id__c) ) cs.KTI_Account_Id__c = taskKtsIdAndKtiParentAccIdMap.get(cs.KTS_Task_Id__c);
                if( taskKtsIdAndKtiContactIdMap.containsKey(cs.KTS_Task_Id__c) ) cs.KTI_con_lead_Id__c = taskKtsIdAndKtiContactIdMap.get(cs.KTS_Task_Id__c);
                cs.Updated_in_KTS__c = TRUE;
                updateCaseList.add(cs);
            }
            System.Debug('<----updateCaseList---->'+updateCaseList);

            if( updateCaseList != NULL && updateCaseList.Size() > 0 ) {
                update updateCaseList;
            }
        }
        
        return NULL;
    }
}