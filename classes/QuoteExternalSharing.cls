public Class QuoteExternalSharing { 
    public Class QuoteClass {
        public String accountId;
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
        public String currencyIsoCode;
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
    
    
    @future(callout=true)
    public static void linkQuote(Set<Id> quoteIdSet) {
        List<QuoteClass> quoteClassList = new List<QuoteClass>();
        Set<Id> quoteIdToInsertQLISet = new Set<Id>();        
        if( quoteIdSet != NULL && quoteIdSet.Size() > 0 ) {
            for( Quote qte : [SELECT Id,AccountId,AdditionalCity,AdditionalCountry,AdditionalLatitude,AdditionalLongitude,AdditionalPostalCode,AdditionalState,AdditionalStreet,AdditionalName,
                BillingCity,BillingCountry,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStreet,BillingName,ContactId,ContractId,CurrencyIsoCode,Description,Discount,Email,ExpirationDate,Fax,GrandTotal,OpportunityId,Phone,Name,QuoteNumber,
                QuoteToCity,QuoteToCountry,QuoteToLatitude,QuoteToLongitude,QuoteToPostalCode,QuoteToState,QuoteToStreet,QuoteToName,ShippingHandling,ShippingName,Status,IsSyncing,Tax,Additional_Information__c,Contract_Organization__c,Contract_POC__c,
                ShippingCity,ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Pricebook2.Name FROM Quote WHERE Id IN : quoteIdSet]) {
                QuoteClass qteCls = new QuoteClass();
                qteCls.accountId = qte.accountId;
                qteCls.additionalCity = qte.AdditionalCity;
                qteCls.additionalCountry = qte.AdditionalCountry;
                qteCls.additionalLatitude = String.ValueOf(qte.AdditionalLatitude);
                qteCls.additionalLongitude = String.ValueOf(qte.AdditionalLongitude);
                qteCls.additionalPostalCode = qte.AdditionalPostalCode;
                qteCls.additionalState= qte.AdditionalState;
                qteCls.additionalStreet = qte.AdditionalStreet;
                qteCls.additionalName = qte.AdditionalName;
                qteCls.billingCity = qte.BillingCity;
                qteCls.billingCountry = qte.BillingCountry;
                qteCls.billingLatitude = String.ValueOf(qte.BillingLatitude);
                qteCls.billingLongitude = String.ValueOf(qte.BillingLongitude);
                qteCls.billingPostalCode = qte.BillingPostalCode;
                qteCls.billingState= qte.BillingState;
                qteCls.billingStreet = qte.BillingStreet;
                qteCls.billingName = qte.BillingName;
                qteCls.contactId = qte.ContactId;
                qteCls.contractId = qte.ContractId;
                qteCls.currencyIsoCode = qte.CurrencyIsoCode;
                qteCls.description = qte.Description;
                //qteCls.discount = qte.Discount;
                qteCls.email = qte.Email;
                qteCls.expirationDate = qte.ExpirationDate != NULL ? string.ValueOf(qte.ExpirationDate ) : NULL;
                qteCls.fax = qte.Fax;
                //qteCls.grandTotal = qte.GrandTotal;
                qteCls.opportunityId = qte.OpportunityId;
                qteCls.phone = qte.Phone;
                qteCls.name = qte.Name;
                //qteCls.quoteNumber = qte.QuoteNumber;
                qteCls.quoteToCity = qte.QuoteToCity;
                qteCls.quoteToCountry = qte.QuoteToCountry;
                qteCls.quoteToLatitude = String.ValueOf(qte.QuoteToLatitude);
                qteCls.quoteToLongitude = String.ValueOf(qte.QuoteToLongitude);
                qteCls.quoteToPostalCode = qte.QuoteToPostalCode;
                qteCls.quoteToState= qte.QuoteToState;
                qteCls.quoteToStreet = qte.QuoteToStreet;
                qteCls.quoteToName = qte.QuoteToName;
                qteCls.shippingHandling = qte.ShippingHandling;
                qteCls.shippingCity = qte.ShippingCity;
                qteCls.shippingCountry = qte.ShippingCountry;
                qteCls.shippingLatitude = String.ValueOf(qte.ShippingLatitude);
                qteCls.shippingLongitude = String.ValueOf(qte.ShippingLongitude);
                qteCls.shippingPostalCode = qte.ShippingPostalCode;
                qteCls.shippingState= qte.ShippingState;
                qteCls.shippingStreet = qte.ShippingStreet;                
                qteCls.shippingName= qte.ShippingName;
                qteCls.status = qte.Status;
                //qteCls.isSyncing= qte.IsSyncing;
                qteCls.tax = qte.Tax;
                qteCls.additional_Information = qte.Additional_Information__c;
                qteCls.contract_Organization = qte.Contract_Organization__c;
                qteCls.contract_POC = qte.Contract_POC__c;
                qteCls.kts_Quote_Id = qte.Id;
                qteCls.priceBookName = qte.Pricebook2 != NULL ? qte.Pricebook2.Name:null;
                
                quoteClassList.add(qteCls);
            }
        }
        
        System.Debug('<----quoteClassList---->'+quoteClassList);
        
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/receiveQuote/');
        hreq.setMethod('POST');
        
        System.debug('::::::'+JSON.serialize(quoteClassList));
        
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setBody(JSON.serialize(quoteClassList));
        HttpResponse hres = h.send(hreq);
        System.debug(':::::'+hres.getbody());
        
        if(hres.getStatus() == 'OK' && hres.getStatusCode() == 200) {
            
            String jsonStr = hres.getBody().unescapeJava();
            System.debug(':::::jsonStr '+jsonStr);
            String jsonStr1 = jsonStr.unescapeCsv();
            system.debug(':::::jsonStr1 '+jsonStr1 );
            ResponseToSend res = (ResponseToSend)JSON.deserialize(jsonStr1 , ResponseToSend.class);
            
            List<Quote> updateQuoteList = new List<Quote>();
            Map<String,String> quoteKtsandKtiIdMap = new Map<String,String>();
            
            if ( res != null && res.isSuccess == TRUE && res.responseResult == 'Success' ) {
        
                for ( responseClass assetcls : res.resClsList ) {
                    
                    quoteKtsandKtiIdMap.put(assetcls.kts_QuoteId,assetcls.kti_QuoteId);
                }
                System.Debug('quoteKtsandKtiIdMap::::'+quoteKtsandKtiIdMap);
                for( Quote qt : [SELECT Id,Name,KTI_Quote_Id__c FROM Quote WHERE Id IN : quoteKtsandKtiIdMap.Keyset()] ) {
                    
                    if(qt.KTI_Quote_Id__c != quoteKtsandKtiIdMap.get(qt.Id) ) {
                        
                        Quote q = new Quote();
                        q.Id = qt.Id;
                        quoteIdToInsertQLISet.add(qt.Id);
                        q.KTI_Quote_Id__c = quoteKtsandKtiIdMap.get(q.Id);
                        q.Updated_in_Source__c = TRUE;
                        updateQuoteList.add(q);
                    }
                }
                system.Debug('::::updateQuoteList'+updateQuoteList);
                if ( updateQuoteList != NULL && updateQuoteList.Size() > 0 ) {
                    update updateQuoteList;
                    
                    // To insert the quote Line Item to other org when the Corresponding quote has the Opportunity Line Items
                    if( quoteIdToInsertQLISet != null && quoteIdToInsertQLISet.size() > 0 ){
                        String s = '0 ';
                        Datetime d = system.now();
                        System.debug('----d--->>'+d);
                        String minutes = '';
                        String hrs = '';
                        
                        if(d.minute()==58) {
                         
                         minutes = '00';
                         hrs = String.valueOf(d.hour() + 1);
                         
                        }else if(d.minute()==59) {
                         
                         minutes = '01';
                         hrs = String.valueOf(d.hour() + 1);
                        }else {
                        
                         minutes = String.valueOf(d.minute() + 2);
                         hrs = String.valueOf(d.hour());
                        }
                        
                        //String s1 = '10 '+ minutes+' '+hrs+' '+d.day()+' '+d.month()+' ?';  
                        String s1 = '10 '+ minutes+' '+hrs+' '+d.day()+' '+d.month()+' ? '+d.year();
                        System.debug('-----s----->>>'+s1);
                        System.Debug('quoteIdToInsertQLISet::::'+quoteIdToInsertQLISet);
                        String jobName = 'Create CP User' + System.now();
                        SchedulerToInsertQLI schQLI = new SchedulerToInsertQLI(quoteIdToInsertQLISet);
                        List<CronTrigger> jobList = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType 
                                 FROM CronTrigger WHERE CronJobDetail.Name =: jobName ];
                        if( jobList != Null && jobList.size() > 0 ) {
                            System.Debug('Alredy scheduled');
                        } else {
                            String jobID = system.schedule('Create CP User' + System.now(), s1, schQLI);
                        }
                    }
                }
                System.debug(':::updateQuoteList::'+updateQuoteList);
            }
        
        }else{
            System.debug(':::::Failure:::::'+hres.getBody());
        }
    }
    
    /*public static void toInsertQuoteLineItem(Set<Id> quoteIdToInQLISet) {
        
        Set<Id> qLIIDSet = new Set<Id>();
        for (QuoteLineItem ql : [SELECT Id FROM QuoteLineItem WHERE QuoteId IN :quoteIdToInQLISet]) {
            qLIIDSet.add(ql.Id);
        }
        System.Debug('qLIIDSet::::'+qLIIDSet);
        if( qLIIDSet != null && qLIIDSet.size() > 0 ) {
           
            QuoteLineItemExternalSharing.doPost( qLIIDSet);
        }
    }*/
}