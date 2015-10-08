@RestResource(UrlMapping='/updateAccount/')
global class UpdateAccount {
    public class KTSAndKTIId{
        public String ktsId;
        public String ktiId;
        public String ktiParentAccId;
        public String ktiOwner;
    }
    @HttpPOST
    global static string updateAccountKTIId(){
    
        RestRequest req = RestContext.request;
        List<Account> updateAccountList = new List<Account>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> accKtsIdAndKtiIdMap = new Map<String,String>();
        Map<String,String> accKtsIdAndKtiParentAccIdMap = new Map<String,String>();
        Map<String,String> accKtsIdAndKtiAccOwnerMap = new Map<String,String>();
        
        System.Debug('IdClsList----'+IdClsList);
        for(KTSAndKTIId str : IdClsList) {
           
            accKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
            if(str.ktiParentAccId != NULL) accKtsIdAndKtiParentAccIdMap.put(str.ktsId,str.ktiParentAccId);
            if(str.ktiOwner != NULL) accKtsIdAndKtiAccOwnerMap.put(str.ktsId,str.ktiOwner);
        }
        
        System.Debug('<----accKtsIdAndKtiIdMap---->'+accKtsIdAndKtiIdMap);
        System.Debug('<----accKtsIdAndKtiParentAccIdMap---->'+accKtsIdAndKtiParentAccIdMap);
        
        if( accKtsIdAndKtiIdMap != NULL && accKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Account acc : [SELECT Id,Name,KTS_Id__c,KTI_Id__c,KTI_Parent_Id__c FROM Account WHERE Id IN : accKtsIdAndKtiIdMap.KeySet()]) {
                
                acc.KTI_Id__c = accKtsIdAndKtiIdMap.get(acc.KTS_Id__c);
                if( accKtsIdAndKtiParentAccIdMap.containsKey(acc.KTS_Id__c) ) acc.KTI_Parent_Id__c = accKtsIdAndKtiParentAccIdMap.get(acc.KTS_Id__c);
                if( accKtsIdAndKtiAccOwnerMap.containsKey(acc.KTS_Id__c) ) acc.KTI_Account_Owner__c = accKtsIdAndKtiAccOwnerMap.get(acc.KTS_Id__c);
                
                updateAccountList.add(acc);
            }
            System.Debug('<----updateAccountList---->'+updateAccountList);

            if( updateAccountList != NULL && updateAccountList.Size() > 0 ) {
                
                update updateAccountList;
            }
        }
        
        return NULL;
    }
}