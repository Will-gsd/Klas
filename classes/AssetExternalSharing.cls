public class AssetExternalSharing {
    public class AssetClass{
      
        public String asstId;
        public String assetName;
        public String assetDescription;
        public String assetStatus;
        public String assetInstallDate;
        public String asstAccountId;
        public String asstContactId;
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
        public String ktsProductId;
        public String KTI_Asset_Id;
        public String asstOpportunity;
        //public String KTS_Asset_Id;
      
    }
    
    public class responseClass {
        public string kti_assetId;
        public String kts_assetId;
    }
    
    public class ResponseToSend {
        public Boolean isSuccess;
        public String responseResult;
        List<ResponseClass> resClsList = new List<ResponseClass>();
    }
    
    //public static List<Asset> assetList = new List<Asset>();
    @future(callout=true)
    public static void linkAsset(Set<Id> assetIdSet) {
    
        List<AssetClass> assetList = new List<AssetClass>();
        if ( assetIdSet != NULL && assetIdSet.Size() > 0 ) { 
           for(Asset newAsset : [SELECT Id, Name, Description, Status, AccountId, contactId,KTI_Asset_Id__c, Product2Id, InstallDate, purchaseDate, serialNumber, UsageEndDate, Customer_Employee_Name__c, Quantity, Price, KTACable__c, KTAC_End__c, KTAC_Start__c, NO_KTAC__c, IsCompetitorProduct, Warranty_End__c, Warranty_Start__c, Serial_Short__c, KTAC_Price_old__c, Opportunity__c FROM Asset WHERE Id IN : assetIdSet]) {
               AssetClass ac = new AssetClass();
               ac.asstId = newAsset.Id;
               ac.assetName = newAsset.Name;
               ac.assetDescription = newAsset.Description;
               ac.assetStatus = newAsset.Status;
               ac.asstAccountId = newAsset.AccountId;
               ac.asstcontactId = newAsset.ContactId;
               ac.asstOpportunity = newAsset.Opportunity__c;
               ac.assetInstallDate = newAsset.InstallDate != NULL ? String.ValueOf(newAsset.InstallDate) : NULL;
               ac.purchaseDate = newAsset.PurchaseDate != NULL ? String.ValueOf(newAsset.PurchaseDate) : NULL;
               ac.serialNumber = newAsset.SerialNumber;
               ac.usageEndDate = newAsset.UsageEndDate != NULL ? String.ValueOf(newAsset.UsageEndDate) : NULL;
               ac.Customer_Employee_Name = newAsset.Customer_Employee_Name__c;
               ac.KTACable = newAsset.KTACable__c;
               ac.KTAC_End = newAsset.KTAC_End__c != NULL ? String.ValueOf(newAsset.KTAC_End__c) : NULL;
               ac.KTAC_Start = newAsset.KTAC_Start__c != NULL ? String.ValueOf(newAsset.KTAC_Start__c) : NULL;
               ac.NO_KTAC = newAsset.NO_KTAC__c;
               ac.IsCompetitorProd = newAsset.IsCompetitorProduct;
               ac.Warranty_End = newAsset.Warranty_End__c != NULL ? String.ValueOf(newAsset.Warranty_End__c) : NULL;
               ac.Warranty_Start = newAsset.Warranty_Start__c != NULL ? String.ValueOf(newAsset.Warranty_Start__c) : NULL;
               ac.assetQuantity = newAsset.Quantity;
               ac.KTAC_Price_old = newAsset.KTAC_Price_old__c;
               ac.Serial_Short = newAsset.Serial_Short__c;
               ac.Price = newAsset.Price;
               ac.ktsProductId = newAsset.Product2Id;
               ac.KTI_Asset_Id=newAsset.KTI_Asset_Id__c;
               //ac.Product_Line = newAsset.Product_Line__c;
               //ac.KTAC_Price = newAsset.KTAC_Price__c;
               //ac.Warranty_Status = newAsset.Warranty_Status__c ;
               

               assetList.add(ac);
           }
        }
       
        System.Debug('<----assetList---->'+assetList);
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl +'/services/apexrest/receiveAsset/');
        //hreq.setEndpoint('https://cs17.salesforce.com/services/apexrest/receiveAsset/');
        //hreq.setHeader('Authorization','Bearer 00Dg0000003NtmR!AQ0AQNWUf4QbeQRhfAoofhnc9dcw_sYeM.98duCcuA8tLwaRaINCdOyGQDkYqMp46Q3fSYBtsnVhDNQPCO1xuY9QBB78JCO7');
        hreq.setMethod('POST');
        System.debug('::::::'+JSON.serialize(assetList));
        hreq.setHeader('Content-Type', 'application/json'); 
        
        hreq.setBody(JSON.serialize(assetList));
        HttpResponse hres = h.send(hreq);
        
        if(hres.getStatus() == 'OK' && hres.getStatusCode() == 200) {
            System.debug(':::::'+hres.getbody());
            String jsonStr = hres.getBody().unescapeJava();
            System.debug(':::::jsonStr '+jsonStr);
            String jsonStr1 = jsonStr.unescapeCsv();
            system.debug(':::::jsonStr1 '+jsonStr1 );
            //List<responseClass> responeClsList = (List<responseClass>)JSON.deserialize(jsonStr1 , List<responseClass>.class);
            ResponseToSend res = (ResponseToSend)JSON.deserialize(jsonStr1 , ResponseToSend.class);
            
            List<Asset> updateAssetList = new List<Asset>();
            Map<String,String> assetKtsandKtiIdMap = new Map<String,String>();
            
            if ( res != null && res.isSuccess == TRUE && res.responseResult == 'Success' ) {
        
                for ( responseClass assetcls : res.resClsList ) {
                    
                    assetKtsandKtiIdMap.put(assetcls.kts_assetId,assetcls.kti_assetId);
                }
                for( Asset ast : [SELECT Id,Name,KTI_Asset_Id__c FROM Asset WHERE Id IN : assetKtsandKtiIdMap.Keyset()] ) {
                    
                    if(ast.KTI_Asset_Id__c != assetKtsandKtiIdMap.get(ast.Id) ) {
                        
                        Asset a = new asset();
                        a.Id = ast.Id;
                        a.KTI_Asset_Id__c = assetKtsandKtiIdMap.get(ast.Id);
                        a.Updated_in_Source__c = TRUE;
                        updateAssetList.add(a);
                    }
                }
                if ( updateAssetList != NULL && updateAssetList.Size() > 0 ) {
                    update updateAssetList;
                }
                System.debug(':::updateAssetList::'+updateAssetList);
            }
        
        }else{
            System.debug(':::::Failure:::::'+hres.getBody());
        }
    }
}