@RestResource(UrlMapping='/updateContact/')
global class UpdateContact {
    public class KTSAndKTIId{
        public String ktsId;
        public String ktiId;
        public String ktiParentAccId;
        public String ktiOwner;
    }
    @HttpPOST
    global static string updateContactKTIId(){
    
        RestRequest req = RestContext.request;
        List<Contact> updateContactList = new List<Contact>();
        String jsonStr = req.requestBody.toString();
        List<KTSAndKTIId> IdClsList = (List<KTSAndKTIId>)JSON.deserialize(jsonStr, List<KTSAndKTIId>.class);
        Map<String,String> conKtsIdAndKtiIdMap = new Map<String,String>();
        Map<String,String> conKtsIdAndKtiParentAccIdMap = new Map<String,String>();
        Map<String,String> conKtsIdAndKtiOwnerMap = new Map<String,String>();
        
        for(KTSAndKTIId str : IdClsList) {
            conKtsIdAndKtiIdMap.put(str.ktsId,str.ktiId);
            if(str.ktiParentAccId != NULL) conKtsIdAndKtiParentAccIdMap.put(str.ktsId,str.ktiParentAccId);
            if(str.ktiOwner != NULL) conKtsIdAndKtiOwnerMap.put(str.ktsId,str.ktiOwner);
        }
        
        System.Debug('<----conKtsIdAndKtiIdMap---->'+conKtsIdAndKtiIdMap);
        if( conKtsIdAndKtiIdMap != NULL && conKtsIdAndKtiIdMap.Size() > 0 ) {
        
            for(Contact con : [SELECT Id,Name,KTS_Contact_Id__c,KTI_Contact_Id__c FROM Contact WHERE Id IN : conKtsIdAndKtiIdMap.KeySet()]) {
                con.KTI_Contact_Id__c = conKtsIdAndKtiIdMap.get(con.KTS_Contact_Id__c);
                if( conKtsIdAndKtiParentAccIdMap.containsKey(con.KTS_Contact_Id__c) ) con.KTI_Account_Id__c = conKtsIdAndKtiParentAccIdMap.get(con.KTS_Contact_Id__c);
                if( conKtsIdAndKtiOwnerMap.containsKey(con.KTS_Contact_Id__c) ) con.KTI_Contact_Owner__c = conKtsIdAndKtiOwnerMap.get(con.KTS_Contact_Id__c);
                updateContactList.add(con);
            }
            System.Debug('<----updateContactList---->'+updateContactList);

            if( updateContactList != NULL && updateContactList.Size() > 0 ) {
                update updateContactList;
            }
        }
        
        return NULL;
    }
}