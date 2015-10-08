@RestResource(UrlMapping='/updateAsset/')
global class UpdateAssets {
    public class AssetClass{
      
        public String asstId;
        public String assetName;
        public String assetDescription;
        public String assetStatus;
        public String assetInstallDate;
        public String asstAccountId;
        public String asstContactId;
        public String asstOpportunity;
        //public String productCode;
        //public String productDescription;
        //public String productFamily;
        public String purchaseDate;
        public String serialNumber;
        public String usageEndDate;
        public String Customer_Employee_Name;
        public Boolean KTACable;
        public String KTAC_End;
        public String KTAC_End_Month;
        public Boolean KTAC_End_Ended;
        public String KTAC_Start;
        public String KTAC_Status;
        public String Product_Line;
        public String Warranty_End;
        public String Warranty_Start;
        public String Warranty_Status;
        public Boolean NO_KTAC;
        public Boolean IsCompetitorProd;
        public Double assetQuantity;
        public Double Price;
        public Double KTAC_Price;
        public Double KTAC_Price_old;
        public Double Serial_Short;
        public String KTS_Asset_Id;
        public String ktsAccountId;
        public String product2Id;
        public String KTI_Asset_Id;
    }
    public class ResponseClass {
        public string kti_assetId;
        public String kts_assetId;
    }
    public class ResponseToSend {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }
    
    @HttpPOST
    global static string postFormRegistration(){
        RestRequest req = RestContext.request;
         ResponseToSend resToSend = new ResponseToSend();
        List<Asset> updateAssetList = new List<Asset>();
        System.debug(':::toString::::'+req.requestBody.toString());
        
        String jsonStr = req.requestBody.toString();
        Set<String> ktiAssetIdSet=new Set<String>();
        Set<String> ktiAccountIdSet=new Set<String>();
        Set<String> ktiProductIdSet=new Set<String>();
        Set<String> ktiContactIdSet=new Set<String>();
        Set<String> ktiOpportunityIdSet=new Set<String>();
        Map<Id,Id> localAccIdAndKTSIdMap = new Map<Id,Id>();
        Map<Id,Id> localConIdAndKTSIdMap=new Map<Id,Id>();
       // Map<Id,Id> localProIdAndKTSIdMap=new Map<Id,Id>();
        Map<Id,Id> localProdIdAndKTSIdMap=new Map<Id,Id>();
        Map<Id,Id> localOppIdAndKTSIdMap=new Map<Id,Id>();
        Set<Id> updateAssetIdSet=new Set<Id>();
        
        Map<String,String> assetIdSetAndAccountIdMap = new Map<String,String>();
        //System.degug('::::jsonStr:::'+jsonStr);
        Set<String> ktsAssetIdSet = new Set<String>();
        
        List<AssetClass> assetClsList = (List<AssetClass>)JSON.deserialize(jsonStr, List<AssetClass>.class);
        System.debug('<------------------------------------------>'+assetClsList);
        for ( AssetClass assetcls : assetClsList ) {
            if( assetcls.KTS_Asset_Id != null ) {
                ktsAssetIdSet.add(assetcls.KTS_Asset_Id);
                
            } 
            if(assetcls.asstId != null) {
                ktiAssetIdSet.add(assetcls.asstId);
            } 
            
            if(assetcls.asstAccountId != NULL && assetcls.asstAccountId.length() > 15) {
                ktiAccountIdSet.add(assetcls.asstAccountId.subString(0,15));   
                System.debug('<------------------------------------------------>'+assetcls.asstAccountId.subString(0,15));
            } else if(assetcls.asstAccountId != NULL && assetcls.asstAccountId.length() == 15) {
                ktiAccountIdSet.add(assetcls.asstAccountId);   
            }
            if(assetcls.asstContactId != NULL && assetcls.asstContactId.length() >15) {
                ktiContactIdSet.add(assetcls.asstContactId.subString(0,15));
            } else if(assetcls.asstContactId != NULL && assetcls.asstContactId.length() == 15) {
                ktiContactIdSet.add(assetcls.asstContactId);
            }
            if(assetcls.asstOpportunity != NULL && assetcls.asstOpportunity.length() >15) {
                ktiOpportunityIdSet.add(assetcls.asstOpportunity.subString(0,15));
                System.debug(':::newbie::::'+assetcls.asstOpportunity.subString(0,15));
            } else if(assetcls.asstOpportunity != NULL && assetcls.asstOpportunity.length() == 15) {
                ktiOpportunityIdSet.add(assetcls.asstOpportunity);
            }
            if(assetcls.product2Id != NULL && assetcls.product2Id.length() > 15 ) {
                ktiProductIdSet.add(assetcls.product2Id.subString(0,15));
            } else if(assetcls.product2Id != NULL && assetcls.product2Id.length() == 15) {
                ktiProductIdSet.add(assetcls.product2Id);
            }
            

        }
        
        
        if( ktIAccountIdSet != NULL && ktIAccountIdSet.Size() > 0 ) {
            System.debug('<----------------ktIAccountIdSet----------------------------------->'+ktIAccountIdSet);
                for( Account acc : [SELECT Id,Name,KTI_Id__c FROM Account WHERE KTI_Id__c IN :ktiAccountIdSet]) {
                    
                    localAccIdAndKTSIdMap.put(acc.KTI_Id__c,acc.Id);
                }
            }
            
            if( ktiContactIdSet != NULL && ktiContactIdSet.Size() > 0 ) {
                for( Contact con : [SELECT Id,Name,KTI_Contact_Id__c FROM Contact WHERE KTI_Contact_Id__c IN : ktiContactIdSet ]) {
                    
                    localConIdAndKTSIdMap.put(con.KTI_Contact_Id__c,con.Id);
                }
            }
            
            if( ktiProductIdSet != NULL && ktiProductIdSet.Size() > 0 ) {
                System.debug('<----------------ktIProduct-----ID------------------------------>'+ktiProductIdSet);
                for( Product2 prod : [SELECT Id,Name,KTI_Product_Id__c FROM Product2 WHERE KTI_Product_Id__c IN :ktiProductIdSet ]) {
                    
                    localProdIdAndKTSIdMap.put(prod.KTI_Product_Id__c,prod.Id);
                }
            }
            
            if( ktiAssetIdSet != NULL && ktiAssetIdSet.Size() > 0 ) {
                for( Asset ast : [SELECT Id,Name,KTI_Asset_Id__c FROM Asset WHERE KTI_Asset_Id__c IN :ktiAssetIdSet ]) {
                    
                    updateAssetIdSet.add(ast.KTI_Asset_Id__c);
                }
            }

            if( ktiOpportunityIdSet != NULL && ktiOpportunityIdSet.Size() > 0 ) {
                 System.debug('***'+ktiContactIdSet);
                for( Opportunity opp : [SELECT Id,Name,KTI_Id__c FROM Opportunity WHERE KTI_Id__c IN : ktiOpportunityIdSet ]) {
                   
                    localOppIdAndKTSIdMap.put(opp.KTI_Id__c,opp.Id);
                }
            }

            
        for ( AssetClass assetcls : assetClsList ) {
           // if( assetcls.KTS_Asset_Id != null ) {
                ktsAssetIdSet.add(assetcls.KTS_Asset_Id);
                Asset assetToUpdate = new Asset();
                if ( updateAssetIdSet != NULL && updateAssetIdSet.Size() > 0 && updateAssetIdSet.Contains(assetcls.asstId)) {
                    assetToUpdate.Updated_in_Source__c = TRUE;
                }
                if(localAccIdAndKTSIdMap.containsKey(assetcls.asstAccountId)) {
                    assetToUpdate.AccountId= localAccIdAndKTSIdMap.get(assetcls.asstAccountId);   
                }
                if(localConIdAndKTSIdMap.containsKey(assetcls.asstContactId)) {
                    assetToUpdate.ContactId = localConIdAndKTSIdMap.get(assetcls.asstContactId);   
                }
                if(localProdIdAndKTSIdMap.containsKey(assetcls.product2Id)) {
                     assetToUpdate.Product2Id = localProdIdAndKTSIdMap.get(assetcls.product2Id);   
                }
                if(localOppIdAndKTSIdMap.containsKey(assetcls.asstOpportunity)) {
                     assetToUpdate.Opportunity__c = localOppIdAndKTSIdMap.get(assetcls.asstOpportunity);   
                }
                //assetIdSetAndAccountIdMap.put(assetcls.KTS_Asset_Id,);
               //  Asset assetToUpdate = new Asset();
               //  assetToUpdate.Id = assetcls.KTS_Asset_Id;
                assetToUpdate.Name = assetcls.assetName;
                assetToUpdate.Description = assetcls.assetDescription;
                assetToUpdate.KTI_Asset_Id__c = assetcls.asstId;
                assetToUpdate.Status = assetcls.assetStatus;
                assetToUpdate.InstallDate = assetcls.assetInstallDate != NULL ? Date.ValueOf(assetcls.assetInstallDate) : NULL;
                assetToUpdate.purchaseDate = assetcls.purchaseDate != NULL ? Date.ValueOf(assetcls.purchaseDate) : NULL;
                //assetToUpdate.AccountId = assetcls.ktsAccountId;
                //assetToUpdate.ContactId = assetcls.asstContactId;
                assetToUpdate.serialNumber = assetcls.serialNumber;  
                assetToUpdate.usageEndDate = assetcls.usageEndDate != NULL ? Date.ValueOf(assetcls.usageEndDate) : NULL;               
                assetToUpdate.Customer_Employee_Name__c = assetcls.Customer_Employee_Name;
                assetToUpdate.KTACable__c = assetcls.KTACable != NULL ? assetcls.KTACable : FALSE;
                assetToUpdate.KTAC_End__c = assetcls.KTAC_End != NULL ? Date.ValueOf(assetcls.KTAC_End) : NULL;
                assetToUpdate.KTAC_Start__c = assetcls.KTAC_Start != NULL ? Date.ValueOf(assetcls.KTAC_Start) : NULL;
                assetToUpdate.NO_KTAC__c = assetcls.NO_KTAC != NULL ? assetcls.NO_KTAC : FALSE;
                assetToUpdate.IsCompetitorProduct = assetcls.IsCompetitorProd != NULL ? assetcls.IsCompetitorProd : FALSE;
                assetToUpdate.Warranty_End__c = assetcls.Warranty_End != NULL ? Date.ValueOf(assetcls.Warranty_End) : NULL;
                assetToUpdate.Warranty_Start__c = assetcls.Warranty_Start != NULL ? Date.ValueOf(assetcls.Warranty_Start) : NULL;
                assetToUpdate.KTAC_Price_old__c = assetcls.KTAC_Price_old;
                assetToUpdate.Serial_Short__c = assetcls.Serial_Short;
                assetToUpdate.Quantity = assetcls.assetQuantity;
                assetToUpdate.Price = assetcls.Price;
                assetToUpdate.Updated_in_Source__c = TRUE;
                updateAssetList .add(assetToUpdate);
          //  }
            
        }
        System.debug(':::ktsAssetIdSet:::::'+ktsAssetIdSet);
        
        
        if(updateAssetList != null && updateAssetList .size() > 0 ) {
            upsert updateAssetList KTI_Asset_Id__c;
        }
        List<responseClass> responseClassList = new List<responseClass>(); 
            
        for( Asset a : updateAssetList ) {
            responseClass rc = new responseClass();
            rc.kts_assetId = a.Id;
            rc.kti_assetId = a.KTI_Asset_Id__c;
            responseClassList.add(rc);
        }
        
        resToSend.isSuccess = TRUE;
        resToSend.responseResult = 'Success';
        resToSend.resClsList.addAll(responseClassList);
        return JSON.serialize(resToSend);
    }
}