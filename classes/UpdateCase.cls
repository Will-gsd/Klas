@RestResource(UrlMapping='/updateCase/')
global class UpdateCase {
    public class KTSAndKTIId{
        public String ktsId;
        public String ktiId;
        public String ktiParentAccId;
        public String ktiOwner;
        public String ktiParentCaseId;
        public String ktiCaseContactId;
    }
    @HttpPOST
    global static string updateCaseKTIId(){
    
        RestRequest req = RestContext.request;
        List<Case> updateCaseList = new List<Case>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> caseKtsIdAndKtiIdMap = new Map<String,String>();
        Map<String,String> caseKtsIdAndKtiParentAccIdMap = new Map<String,String>();
        Map<String,String> caseKtsIdAndKtiOwnerMap = new Map<String,String>();
        Map<String,String> caseKtsIdAndKtiParentCaseIdMap = new Map<String,String>();
        Map<String,String> caseKtsIdAndKtiContactIdMap = new Map<String,String>();
        
        for(KTSAndKTIId str : IdClsList) {
            caseKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
            if(str.ktiParentAccId != NULL) caseKtsIdAndKtiParentAccIdMap.put(str.ktsId,str.ktiParentAccId);
            if(str.ktiOwner != NULL) caseKtsIdAndKtiOwnerMap.put(str.ktsId,str.ktiOwner);
            if(str.ktiParentCaseId != NULL) caseKtsIdAndKtiParentCaseIdMap.put(str.ktsId,str.ktiParentCaseId);
            if(str.ktiCaseContactId != NULL) caseKtsIdAndKtiContactIdMap.put(str.ktsId,str.ktiCaseContactId);
        }
        
        System.Debug('<----caseKtsIdAndKtiIdMap---->'+caseKtsIdAndKtiIdMap);
        if( caseKtsIdAndKtiIdMap != NULL && caseKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Case cs : [SELECT Id,KTS_Case_Id__c,KTI_Case_Id__c FROM Case WHERE Id IN : caseKtsIdAndKtiIdMap.KeySet()]) {
               
                cs.KTI_Case_Id__c = caseKtsIdAndKtiIdMap.get(cs.KTS_Case_Id__c);
                if( caseKtsIdAndKtiParentAccIdMap.containsKey(cs.KTS_Case_Id__c) ) cs.KTI_Account_Id__c = caseKtsIdAndKtiParentAccIdMap.get(cs.KTS_Case_Id__c);
                if( caseKtsIdAndKtiOwnerMap.containsKey(cs.KTS_Case_Id__c) ) cs.KTI_Case_Owner_Id__c = caseKtsIdAndKtiOwnerMap.get(cs.KTS_Case_Id__c);
                if( caseKtsIdAndKtiParentCaseIdMap.containsKey(cs.KTS_Case_Id__c)) cs.KTI_Parent_Case_Id__c = caseKtsIdAndKtiParentCaseIdMap.get(cs.KTS_Case_Id__c);
                if( caseKtsIdAndKtiContactIdMap.containsKey(cs.KTS_Case_Id__c)) cs.KTI_Contact_Id__c = caseKtsIdAndKtiContactIdMap.get(cs.KTS_Case_Id__c);

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