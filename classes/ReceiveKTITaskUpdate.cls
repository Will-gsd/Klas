@RestResource(UrlMapping='/ReceiveKTITaskUpdate/')
global class ReceiveKTITaskUpdate{
    public class TaskClass{
        public String tskId;
        public String callDisposition;
        public String callType;
        public String description;
        public String activityDate;
        public String whoId;
        public String priority;
        public Integer recurrenceInterval;
        public String whatId;
        public String recurrenceRegeneratedType;
        public String status;
        public String subject;
        public String type;
    }
    
    @HttpPOST
    global static string postFormRegistration(){
        RestRequest req = RestContext.request;
        String jsonStr = req.requestBody.toString();
        // variables for what Id
        Set<String> ktiTaskIdSet = new Set<String>();
        Set<String> whatIdAccSet = new Set<String>();
        Set<String> whatIdOppSet = new Set<String>();
        Set<String> whatIdProdSet = new Set<String>();
        Set<String> whatIdAssetSet = new Set<String>();
        Set<String> whatIdCaseSet = new Set<String>();
        Set<String> whatIdQuoteSet = new Set<String>();
        Map<String,Task> KTIIdAndTaskMap = new Map<String,Task>();
        Map<String,Account> KTIIdAndAccountMap = new Map<String,Account>();
        Map<String,Opportunity> KTIIdAndOppMap = new Map<String,Opportunity>();
        Map<String,Product2> KTIIdAndProdMap = new Map<String,Product2>();
        Map<String,Asset> KTIIdAndAssetMap = new Map<String,Asset>();
        Map<String,Case> KTIIdAndCaseMap = new Map<String,Case>();
        Map<String,Quote> KTIIdAndQuoteMap = new Map<String,Quote>();       
        
        // varaibles for Who Id
        Set<String> whatIdLeadSet = new Set<String>();
        Set<String> whatIdContSet = new Set<String>();
        Map<String,Contact> KTIIdAndContactMap = new Map<String,Contact>();
        Map<String,Lead> KTIIdAndLeadMap = new Map<String,Lead>();
        
        try {
            List<TaskClass> taskClassList = (List<TaskClass>)JSON.deserialize(jsonStr, List<TaskClass>.class);
            List<Task> tskList = new List<Task>();
            System.Debug('<--taskClassList -->'+taskClassList);
            for ( TaskClass tskcls : taskClassList ) {
                if(tskcls.tskId != null) {
                    ktiTaskIdSet.add((tskcls.tskId).subString(0,15));
                    System.Debug('<--ktiTaskIdSet-->'+ktiTaskIdSet);
                }
                if(tskcls.whoId != null && (tskcls.whoId).subString(0,3).equals('003')) {
                    whatIdContSet.add((tskcls.whoId).subString(0,15));
                    System.Debug('<--whatIdContSet-->'+whatIdContSet);
                }
                if(tskcls.whoId != null && (tskcls.whoId).subString(0,3).equals('00Q')) {
                    whatIdLeadSet.add((tskcls.whoId).subString(0,15));
                    System.Debug('<--whatIdLeadSet-->'+whatIdLeadSet);
                } else {
                    
                    if(tskcls.whatId != null && (tskcls.whatId).subString(0,3).equals('001')) {
                        whatIdAccSet.add((tskcls.whatId).subString(0,15));
                    } else if(tskcls.whatId != null && (tskcls.whatId).subString(0,3).equals('006')) {
                        whatIdOppSet.add((tskcls.whatId).subString(0,15));
                    } else if(tskcls.whatId != null && (tskcls.whatId).subString(0,3).equals('01t')) {
                        whatIdProdSet.add((tskcls.whatId).subString(0,15));
                    } else if(tskcls.whatId != null && (tskcls.whatId).subString(0,3).equals('02i')) {
                        whatIdAssetSet.add(tskcls.whatId);
                    } else if(tskcls.whatId != null && (tskcls.whatId).subString(0,3).equals('500')) {
                        whatIdCaseSet.add((tskcls.whatId).subString(0,15));
                    } else if(tskcls.whatId != null && (tskcls.whatId).subString(0,3).equals('0Q0')) {
                        whatIdQuoteSet.add(tskcls.whatId);
                    }
                    System.Debug('<--whatIdAccSet-->'+whatIdAccSet);
                }
            }
            if( whatIdContSet != null && whatIdContSet.size() > 0 ) {
                for( Contact cont : [SELECT Id,KTS_Contact_Id__c,KTI_Contact_Id__c FROM Contact WHERE KTI_Contact_Id__c IN : whatIdContSet]){
                    KTIIdAndContactMap.put(cont.KTI_Contact_Id__c,cont);
                }
            }
            if( whatIdLeadSet != null && whatIdLeadSet.size() > 0 ) {
                for( Lead ld : [SELECT Id,KTS_Lead_Id__c,KTI_Lead_Id__c FROM Lead WHERE KTI_Lead_Id__c IN : whatIdLeadSet]){
                    KTIIdAndLeadMap.put(ld.KTI_Lead_Id__c,ld);
                }
            }
            system.debug('KTIIdAndLeadMap--->>>'+KTIIdAndLeadMap);
            if( ktiTaskIdSet != null && ktiTaskIdSet.size() > 0 ) {
                for( Task tsk : [SELECT Id,KTS_Task_Id__c,KTI_Task_Id__c FROM Task WHERE KTI_Task_Id__c IN : ktiTaskIdSet]){
                    KTIIdAndTaskMap.put(tsk.KTI_Task_Id__c,tsk);
                }
            }
            system.debug('<--KTIIdAndTaskMap-->'+KTIIdAndTaskMap);
            if( whatIdAccSet != null && whatIdAccSet.size() > 0 ) {
                for (Account acc : [SELECT Id,KTS_Id__c,KTI_Id__c FROM Account WHERE KTI_Id__c IN : whatIdAccSet] ) {
                    KTIIdAndAccountMap.put(acc.KTI_Id__c,acc);
                }
            }
            if( whatIdOppSet != null && whatIdOppSet.size() > 0 ) {
                for (Opportunity opp : [SELECT Id,KTS_Id__c,KTI_Id__c FROM Opportunity WHERE KTI_Id__c IN : whatIdOppSet] ) {
                    KTIIdAndOppMap.put(opp.KTI_Id__c,opp);
                }
            }
            if( whatIdProdSet != null && whatIdProdSet.size() > 0 ) {
                for (Product2 prod : [SELECT Id,KTS_Product_Id__c,KTI_Product_Id__c FROM Product2 WHERE KTI_Product_Id__c IN : whatIdProdSet] ) {
                    KTIIdAndProdMap.put(prod.KTI_Product_Id__c,prod);
                }
            }
            if( whatIdAssetSet != null && whatIdAssetSet.size() > 0 ) {
                for (Asset ast : [SELECT Id,KTI_Asset_Id__c FROM Asset WHERE KTI_Asset_Id__c IN : whatIdAssetSet] ) {
                    KTIIdAndAssetMap.put(ast.KTI_Asset_Id__c,ast);
                }
            }
            if( whatIdCaseSet != null && whatIdCaseSet.size() > 0 ) {
                for (Case cs : [SELECT Id,KTS_Case_Id__c,KTI_Case_Id__c FROM Case WHERE KTS_Case_Id__c IN : whatIdCaseSet] ) {
                    KTIIdAndCaseMap.put(cs.KTS_Case_Id__c,cs);
                }
            }
            if( whatIdQuoteSet != null && whatIdQuoteSet.size() > 0 ) {
                for (Quote qt : [SELECT Id,KTI_Quote_Id__c FROM Quote WHERE KTI_Quote_Id__c IN : whatIdQuoteSet] ) {
                    KTIIdAndQuoteMap.put(qt.KTI_Quote_Id__c,qt);
                }
            }
            System.Debug('<--KTIIdAndContactMap-->'+KTIIdAndContactMap);
            for ( TaskClass tskcls : taskClassList ) {
                Task tsk = new Task();
                if (KTIIdAndTaskMap.containsKey((tskcls.tskId).substring(0,15))) tsk.Id = KTIIdAndTaskMap.get((tskcls.tskId).substring(0,15)).Id;
                tsk.CallDisposition = tskcls.callDisposition;
                tsk.CallType = tskcls.callType;
                tsk.Description = tskcls.description;
                //tsk.ActivityDate = Date.ValueOf(tskcls.activityDate);
                tsk.ActivityDate = tskcls.activityDate != null ? Date.ValueOf(tskcls.activityDate): null;
                System.debug('<--tskcls.whoId-->'+tskcls.whoId);
                if(KTIIdAndContactMap.containsKey((tskcls.whoId).subString(0,15))) {
                    tsk.WhoId = KTIIdAndContactMap.get((tskcls.whoId).subString(0,15)).Id;
                    tsk.KTI_con_lead_Id__c = KTIIdAndContactMap.get((tskcls.whoId).subString(0,15)).KTI_Contact_Id__c;
                } else if (KTIIdAndLeadMap.containsKey((tskcls.whoId).subString(0,15))) {
                    tsk.WhoId = KTIIdAndLeadMap.get((tskcls.whoId).subString(0,15)).Id;
                    tsk.KTI_con_lead_Id__c = tskcls.whoId;
                    tsk.WhatId = null;
                    tsk.KTI_Account_Id__c = null;
                }
                tsk.Priority = tskcls.priority;
                tsk.RecurrenceInterval = tskcls.recurrenceInterval;
                System.debug(':::::::::tskcls.whatId::::::'+tskcls.whatId);
                System.debug(':::::::::KTIIdAndAccountMap::::::'+KTIIdAndAccountMap);
                if(KTIIdAndAccountMap != null && KTIIdAndAccountMap.size() > 0 && tskcls.whatId != null && KTIIdAndAccountMap.containsKey((tskcls.whatId).subString(0,15))) {
                    tsk.WhatId = KTIIdAndAccountMap.get((tskcls.whatId).subString(0,15)).Id;
                    tsk.KTI_Account_Id__c = KTIIdAndAccountMap.get((tskcls.whatId).subString(0,15)).KTI_Id__c;
                } else if(KTIIdAndOppMap != null && KTIIdAndOppMap.size() >0 && tskcls.whatId != null && KTIIdAndOppMap.containsKey((tskcls.whatId).subString(0,15))) {
                    tsk.WhatId = KTIIdAndOppMap.get((tskcls.whatId).subString(0,15)).Id;
                    tsk.KTI_Account_Id__c = KTIIdAndOppMap.get((tskcls.whatId).subString(0,15)).KTI_Id__c;
                } else if(KTIIdAndProdMap != null && KTIIdAndProdMap.size() > 0 && tskcls.whatId != null && KTIIdAndProdMap.containsKey((tskcls.whatId).subString(0,15))) {
                    tsk.WhatId = KTIIdAndProdMap.get((tskcls.whatId).subString(0,15)).Id;
                    tsk.KTI_Account_Id__c = KTIIdAndProdMap.get((tskcls.whatId).subString(0,15)).KTI_Product_Id__c;
                } else if(KTIIdAndAssetMap != null && KTIIdAndAssetMap.size() > 0 && tskcls.whatId != null && KTIIdAndAssetMap.containsKey(tskcls.whatId)) {
                    tsk.WhatId = KTIIdAndAssetMap.get(tskcls.whatId).Id;
                    tsk.KTI_Account_Id__c = KTIIdAndAssetMap.get(tskcls.whatId).KTI_Asset_Id__c;
                } else if(KTIIdAndCaseMap != null && KTIIdAndCaseMap.size() > 0 && tskcls.whatId != null && KTIIdAndCaseMap.containsKey((tskcls.whatId).subString(0,15))) {
                    tsk.WhatId = KTIIdAndCaseMap.get((tskcls.whatId).subString(0,15)).Id;
                    tsk.KTI_Account_Id__c = KTIIdAndCaseMap.get((tskcls.whatId).subString(0,15)).KTI_Case_Id__c;
                } else if(KTIIdAndQuoteMap != null && KTIIdAndQuoteMap.size() > 0 && tskcls.whatId != null && KTIIdAndQuoteMap.containsKey(tskcls.whatId)) {
                    tsk.WhatId = KTIIdAndQuoteMap.get(tskcls.whatId).Id;
                    tsk.KTI_Account_Id__c = KTIIdAndQuoteMap.get(tskcls.whatId).KTI_Quote_Id__c;
                }
                tsk.Status = tskcls.status;
                tsk.Subject = tskcls.subject;
                tsk.Type = tskcls.type;
                tsk.Updated_in_KTS__c = TRUE;
                tskList.add(tsk);
            }
            if( tskList != null && tskList.size() > 0 ){
                update tskList;
            }
        } catch(Exception ex) {
            System.Debug('Ex Error'+ex);
        }
        return null;
    }
}