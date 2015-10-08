@RestResource(UrlMapping='/updateQuote/')
global class UpdateQuote {
    public class QuoteClass{
        //public String accountId;
        public String additionalCity;
        public String additionalCountry;
        public String additionalLatitude;
        public String additionalLongitude;
        public String additionalPostalCode;
        public String additionalState;
        public String additionalStreet;
        public String additionalName;
        public String billingCity;
        public String billingCountry;
        public String billingLatitude;
        public String billingLongitude;
        public String billingPostalCode;
        public String billingState;
        public String billingStreet;
        public String billingName;
        public String contactId;
        public String contractId;
        public String description;
        //public Double discount;
        public String email;
        public String expirationDate;
        public String fax;
        //public Double grandTotal;
        public String opportunityId;
        public String phone;
        public String name;
        //public String quoteNumber;
        public String quoteToCity;
        public String quoteToCountry;
        public String quoteToLatitude;
        public String quoteToLongitude;
        public String quoteToPostalCode;
        public String quoteToState;
        public String quoteToStreet;
        public String quoteToName;
        public Double shippingHandling;
        public String shippingCity;
        public String shippingCountry;
        public String shippingLatitude;
        public String shippingLongitude;
        public String shippingPostalCode;
        public String shippingState;
        public String shippingStreet;
        public String shippingName;
        public String status;
        //public Boolean isSyncing;
        public Double tax;
        public String additional_Information;
        public String contract_Organization;
        public String contract_POC;
        public String kts_Quote_Id;
        public String kti_Quote_Id;
        public String pricebookName;
        
    }
    public class responseClass {
        public string kti_QuoteId;
        public String kts_QuoteId;
    }
    
    public class ResponseToSend {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }
    @HttpPOST
    global static string postQuoteLink(){
    
        Set<String> ktiQuoteIdSet = new Set<String>();
        Set<String> ktiOpportunityIdSet = new Set<String>();
        Set<String> ktiContactIdSet = new Set<String>();
        Set<String> updateQuoteIdSet = new Set<String>();
        Set<String> pricebookNameSet = new Set<String>();
        //Map<Id,Id> localAccIdAndKTSIdMap = new Map<Id,Id>();
        Map<Id,Id> localOppIdAndKTSIdMap = new Map<Id,Id>();
        Map<Id,Id> localConIdAndKTSIdMap = new Map<Id,Id>();
        Map<String, Id> pricebookNamewithIdMap = new Map<String, Id>();
        RestRequest req = RestContext.request;
        List<responseClass> responseClassList;
        ResponseToSend resToSend = new ResponseToSend();
        System.debug(':::toString::::'+req.requestBody.toString());
        
        String jsonStr = req.requestBody.toString();
        
         try {
            List<QuoteClass> quoteClsList = (List<QuoteClass>)JSON.deserialize(jsonStr, List<QuoteClass>.class);
            System.Debug('<----quoteClsList---->'+quoteClsList);
            
            for( QuoteClass qC : quoteClsList ) {
                if( qC.kti_Quote_Id != null ) {
                    ktiQuoteIdSet.add(qC.kti_Quote_Id);
                }
                if( qC.opportunityId != null && qC.opportunityId.length() > 15) {
                    ktiOpportunityIdSet.add(qC.opportunityId.subString(0,15));
                } else if(qC.opportunityId != null && qC.opportunityId.length() == 15){
                    ktiOpportunityIdSet.add(qC.opportunityId);
                }
                if( qC.contactId != null && qC.contactId.length() > 15 ) {
                    ktiContactIdSet.add(qC.contactId.subString(0,15));
                }
                if( qC.pricebookName != null ) {
                    pricebookNameSet.add(qC.pricebookName);
                }
            }
            
            System.Debug('ktiContactIdSet:::'+ktiContactIdSet);
            if( ktiQuoteIdSet != NULL && ktiQuoteIdSet.Size() > 0 ) {
                for( Quote qt : [SELECT Id,Name,KTI_Quote_Id__c FROM Quote WHERE KTI_Quote_Id__c IN :ktiQuoteIdSet]) {
                    
                    updateQuoteIdSet.add(qt.KTI_Quote_Id__c);
                }
            }
            
            if( ktiOpportunityIdSet != NULL && ktiOpportunityIdSet.Size() > 0 ) {
                for( Opportunity opp : [SELECT Id,Name,KTI_Id__c FROM Opportunity WHERE KTI_Id__c IN :ktiOpportunityIdSet ]) {
                    
                    localOppIdAndKTSIdMap.put(opp.KTI_Id__c,opp.Id);
                }
            }
            if( ktiContactIdSet != NULL && ktiContactIdSet.Size() > 0 ) {
                for( Contact con : [SELECT Id,Name,KTI_Contact_Id__c FROM Contact WHERE KTI_Contact_Id__c IN :ktiContactIdSet]) {
                    
                    localConIdAndKTSIdMap.put(con.KTI_Contact_Id__c,con.Id);
                }
            }
            // To assign the PrieBook 
            if( pricebookNameSet != null && pricebookNameSet.size() > 0 ) {
                for(PriceBook2 pb: [SELECT Id, Name FROM PriceBook2 WHERE Name IN:pricebookNameSet]) {
                    pricebookNamewithIdMap.put(pb.Name.toUpperCase(), pb.Id);
                }
            }
              
            System.Debug('localConIdAndKTSIdMap::::'+localConIdAndKTSIdMap);
            List<Quote> quoteList = new List<Quote>();
            
            for( QuoteClass qC : quoteClsList ) {
                Quote qte = new Quote();
                //qte.AccountId = localAccIdAndKTIIdMap.get(qte.AccountId);
                if ( updateQuoteIdSet != NULL && updateQuoteIdSet.Size() > 0 && updateQuoteIdSet.Contains(qC.kti_Quote_Id)) {
                    qte.Updated_in_Source__c = TRUE;
                }
                qte.additionalCity = qC.AdditionalCity;
                qte.additionalCountry = qC.AdditionalCountry;
                qte.additionalLatitude = qC.AdditionalLatitude != NULL ? Decimal.ValueOf(qC.AdditionalLatitude) : NULL;
                qte.additionalLongitude = qC.AdditionalLongitude  != NULL ? Decimal.ValueOf(qC.AdditionalLongitude ) : NULL;
                qte.additionalPostalCode = qC.AdditionalPostalCode;
                qte.additionalState= qC.AdditionalState;
                qte.additionalStreet = qC.AdditionalStreet;
                qte.AdditionalName = qC.AdditionalName;
                qte.billingCity = qC.BillingCity;
                qte.billingCountry = qC.BillingCountry;
                qte.billingLatitude = qC.BillingLatitude != NULL ? Decimal.ValueOf(qC.BillingLatitude) : NULL;
                qte.billingLongitude = qC.BillingLongitude != NULL ? Decimal.ValueOf(qC.BillingLongitude) : NULL;
                qte.billingPostalCode = qC.BillingPostalCode;
                qte.billingState= qC.BillingState;
                qte.billingStreet = qC.BillingStreet;
                qte.BillingName = qC.BillingName;
                qte.ContactId = localConIdAndKTSIdMap.get(qC.ContactId);
                qte.ContractId = qC.ContractId;
                qte.Description = qC.Description;
                //qte.Discount = qC.Discount;
                qte.Email = qC.email;
                qte.ExpirationDate = qC.ExpirationDate != NULL ? Date.ValueOf(qC.ExpirationDate ) : NULL;
                qte.Fax = qC.Fax;
                //qte.GrandTotal = qC.GrandTotal;
                qte.OpportunityId = localOppIdAndKTSIdMap.get(qC.OpportunityId);
                qte.Phone = qC.Phone;
                qte.Name = qC.Name;
                //qte.QuoteNumber = qC.QuoteNumber;
                qte.QuoteToCity = qC.QuoteToCity;
                qte.QuoteToCountry = qC.QuoteToCountry;
                qte.QuoteToLatitude = qC.QuoteToLatitude != NULL ? Decimal.ValueOf(qC.QuoteToLatitude) : NULL;
                qte.QuoteToLongitude = qC.QuoteToLongitude != NULL ? Decimal.ValueOf(qC.QuoteToLongitude) : NULL;
                qte.QuoteToPostalCode = qC.QuoteToPostalCode;
                qte.QuoteToState= qC.QuoteToState;
                qte.QuoteToStreet = qC.QuoteToStreet;
                qte.QuoteToName = qC.QuoteToName;
                qte.ShippingHandling = qC.ShippingHandling;
                qte.ShippingCity = qC.ShippingCity;
                qte.ShippingCountry = qC.ShippingCountry;
                qte.ShippingLatitude = qC.ShippingLatitude != NULL ? Decimal.ValueOf(qC.ShippingLatitude) : NULL;
                qte.ShippingLongitude = qC.ShippingLongitude != NULL ? Decimal.ValueOf(qC.ShippingLongitude) : NULL;
                qte.ShippingPostalCode = qC.ShippingPostalCode;
                qte.ShippingState= qC.ShippingState;
                qte.ShippingStreet = qC.ShippingStreet;
                qte.ShippingName= qC.shippingName;
                qte.Status = qC.status;
                //qte.IsSyncing= qC.isSyncing;
                qte.Tax = qC.tax;
                qte.Additional_Information__c = qC.additional_Information;
                qte.Contract_Organization__c = qC.contract_Organization;
                qte.Contract_POC__c = qC.contract_POC;
                qte.KTI_Quote_Id__c = qC.kti_Quote_Id;
                if(qC.priceBookName != null) {
                    qte.PriceBook2Id = pricebookNamewithIdMap.get(qC.priceBookName.toUpperCase());
                }
                
                quoteList.add(qte);
            }
            
            System.Debug('<--quoteList-->'+quoteList);
            if( quoteList != NULL && quoteList.Size() > 0 ) {
                upsert quoteList KTI_Quote_Id__c;
            } 
            responseClassList = new List<responseClass>();
            for( Quote q : quoteList ) {
            
                if(q.Updated_in_Source__c != TRUE) { // form the response class only for Insert
                    responseClass rc = new responseClass();
                    rc.kts_QuoteId = q.Id;
                    rc.kti_QuoteId = q.KTI_Quote_Id__c;
                    responseClassList.add(rc);
                }
            }
            
            resToSend.isSuccess = TRUE;
            resToSend.responseResult = 'Success';
            resToSend.resClsList.addAll(responseClassList);
            System.Debug('resToSend::::'+resToSend);
        } Catch (Exception e) {
            System.Debug('Inside catch');
            resToSend.isSuccess = FALSE;
            resToSend.responseResult = e.getMessage();
        }
        return JSON.serialize(resToSend);
    }
}