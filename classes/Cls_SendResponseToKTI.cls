public class Cls_SendResponseToKTI {
    
    public class KTSAndKTIId{
        
        public String ktsId;
        public String ktiId;
        public String ktsParentAccId;
        public String ktsOwner;
        public String ktsParentCaseId;
        public String ktsCaseContactId;
    }
    
    @future(callout=true)
    public static void updateAccountKTSIdToKTI(Map<String,String> accKtiIdAndKtsIdMap) {
    
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        
        System.Debug('---accKtiIdAndKtsIdMap---'+accKtiIdAndKtsIdMap);
        for( Account acc : [SELECT Id,KTS_Id__c,KTI_Id__c,Parent_Id__c,KTS_Account_Owner__c FROM Account WHERE KTI_Id__c IN :accKtiIdAndKtsIdMap.KeySet()] ) {
           
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktsId = acc.KTS_Id__c;
           IdMapInstance.ktiId = acc.KTI_Id__c;
           IdMapInstance.ktsParentAccId = acc.Parent_Id__c;
           IdMapInstance.ktsOwner = acc.KTS_Account_Owner__c;
           
           IdMapInstanceList.add(IdMapInstance);
        }
        
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTIAccount/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
    
    @future(callout=true)
    public static void updateProductKTSIdToKTI(Map<Id,Id> productKtiIdAndKtsIdMap) {
    
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        for( Id idValue : productKtiIdAndKtsIdMap.KeySet() ) {
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktiId = idValue;
           IdMapInstance.ktsId = productKtiIdAndKtsIdMap.get(idValue);
           
           IdMapInstanceList.add(IdMapInstance);
        }
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTIProduct/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
    @future(callout=true)
    public static void updateLeadKTSToKTI(Map<Id,Id> leadKtiIdAndKtsIdMap) {
        
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        for( Id idValue : leadKtiIdAndKtsIdMap.KeySet() ) {
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktiId = idValue;
           IdMapInstance.ktsId = leadKtiIdAndKtsIdMap.get(idValue);
           
           IdMapInstanceList.add(IdMapInstance);
        }    
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTILead/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
    @future(callout=true)
    public static void updateContactKTSIdToKTI(Map<String,String> contactKtiIdAndKtsIdMap) {
        
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        
        //for( Id idValue : contactKtiIdAndKtsIdMap.KeySet() ) {
        for( Contact con : [SELECT Id,KTS_Contact_Id__c,KTI_Contact_Id__c,KTS_Account_Id__c,Owner.Name FROM Contact WHERE KTI_Contact_Id__c IN :contactKtiIdAndKtsIdMap.KeySet()] ) {
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktiId = con.KTI_Contact_Id__c;
           IdMapInstance.ktsId = con.KTS_Contact_Id__c;
           IdMapInstance.ktsParentAccId = con.KTS_Account_Id__c;
           IdMapInstance.ktsOwner = con.Owner.Name;
           
           IdMapInstanceList.add(IdMapInstance);
        }    
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTIContact/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
    @future(callout=true)
    public static void updateOpportunityKTSIdToKTI(Map<String,String> oppKtiIdAndKtsIdMap) {
    
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        
        System.Debug('---oppKtiIdAndKtsIdMap---'+oppKtiIdAndKtsIdMap);
        for( Opportunity opp : [SELECT Id,KTS_Id__c,KTI_Id__c,KTS_AccountId__c,KTS_Opportunity_Owner__c FROM Opportunity WHERE KTI_Id__c IN :oppKtiIdAndKtsIdMap.KeySet()] ) {
           
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktsId = opp.KTS_Id__c;
           IdMapInstance.ktiId = opp.KTI_Id__c;
           IdMapInstance.ktsParentAccId = opp.KTS_AccountId__c;
           IdMapInstance.ktsOwner = opp.KTS_Opportunity_Owner__c;
           
           IdMapInstanceList.add(IdMapInstance);
        }
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTIOpportunity/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
    
    @future(callout=true)
    public static void updateCaseKTSIdToKTI(Map<String,String> caseKtiIdAndKtsIdMap) {
        
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        
        //for( Id idValue : contactKtiIdAndKtsIdMap.KeySet() ) {
        for( Case caseRec : [SELECT Id, KTS_Case_Id__c, KTI_Case_Id__c, KTS_Account_Id__c, Owner.Name,KTS_Parent_Case_Id__c,KTS_Contact_Id__c FROM Case WHERE KTI_Case_Id__c IN :caseKtiIdAndKtsIdMap.KeySet()] ) {
           
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktiId = caseRec.KTI_Case_Id__c;
           IdMapInstance.ktsId = caseRec.KTS_Case_Id__c;
           IdMapInstance.ktsParentAccId = caseRec.KTS_Account_Id__c;
           IdMapInstance.ktsOwner = caseRec.Owner.Name;
           IdMapInstance.ktsParentCaseId = caseRec.KTS_Parent_Case_Id__c;
           IdMapInstance.ktsCaseContactId = caseRec.KTS_Contact_Id__c;
           
           IdMapInstanceList.add(IdMapInstance);
        }    
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTICase/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
    
    @future(callout=true)
    public static void updateTaskKTSIdToKTI(Map<String,String> taskKtiIdAndKtsIdMap) {
        
        List<KTSAndKTIId> IdMapInstanceList = new List<KTSAndKTIId>();
        
        //for( Id idValue : contactKtiIdAndKtsIdMap.KeySet() ) {
        for( Task caseRec : [SELECT Id, KTS_Task_Id__c, KTI_Task_Id__c, KTS_Account_Id__c, Owner.Name,KTS_con_lead_Id__c FROM Task WHERE KTI_Task_Id__c IN :taskKtiIdAndKtsIdMap.KeySet()] ) {
           
           KTSAndKTIId IdMapInstance = new KTSAndKTIId();
           IdMapInstance.ktiId = caseRec.KTI_Task_Id__c;
           IdMapInstance.ktsId = caseRec.KTS_Task_Id__c;
           IdMapInstance.ktsParentAccId = caseRec.KTS_Account_Id__c;
           IdMapInstance.ktsOwner = caseRec.Owner.Name;
           IdMapInstance.ktsCaseContactId = caseRec.KTS_con_lead_Id__c;
           IdMapInstanceList.add(IdMapInstance);
        }    
        System.Debug('<----IdMapInstanceList---->'+IdMapInstanceList);
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/updateKTITask/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(IdMapInstanceList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(IdMapInstanceList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
    }
}