trigger ShareProductToPartner on Product2 (after insert, after update, before update) {
   
    // Define connection id
    Id networkId = ConnectionHelper.getConnectionId(System.Label.ConnectionName);
    
    List<Product2> localProduct = new List<Product2>();
    
    // To update the KTS Product Id in the KTI Product Record.
    Map<Id,Id> productKTIIdAndKTSIdMap = new Map<Id,Id>();
    if (Trigger.IsAfter && Trigger.IsInsert){
        // only share records created in this org, do not add contacts received from another org.
        for ( Product2 newProduct : TRIGGER.new ) {
        
            if ( newProduct.ConnectionReceivedId == null ) {
                
                localProduct.add(newProduct);
            } 
            
            if( newProduct.ConnectionReceivedId != null && newProduct.KTS_Product_Id__c != NULL && newProduct.KTI_Product_Id__c!= NULL ) productKTIIdAndKTSIdMap.put(newProduct.KTI_Product_Id__c,newProduct.KTS_Product_Id__c);       
        }
            
        if (localProduct != NULL && localProduct.size() > 0) {
        
            List<PartnerNetworkRecordConnection> ProductConnections =  new  List<PartnerNetworkRecordConnection>();

            for (Product2 newProduct : localProduct) {

                PartnerNetworkRecordConnection newConnection =
                  new PartnerNetworkRecordConnection(
                      ConnectionId = networkId,
                      LocalRecordId = newProduct.Id,
                      SendClosedTasks = false,
                      SendOpenTasks = false,
                      SendEmails = false);
                      
                ProductConnections.add(newConnection);
            }
            
            if (ProductConnections != NULL && ProductConnections.size() > 0 ) {
                   insert ProductConnections;
            }
        }
    }
    
    System.Debug('<---productKTIIdAndKTSIdMap--->'+productKTIIdAndKTSIdMap);
    if( productKTIIdAndKTSIdMap != NULL && productKTIIdAndKTSIdMap.Size() > 0 ) Cls_SendResponseToKTI.updateProductKTSIdToKTI(productKTIIdAndKTSIdMap);


    /* These are the unused Pricebook Entry update triggers that would automatically take the price from the standard cross org price field and set it to the standard pricebook
        and defualt cross org pricebook. 

    //before update -   // query to see if there is a pricebook2entry for this product in the pricebook where "standard price book" is checked.
    if(Trigger.IsBefore && Trigger.IsUpdate){
        Set <Id> sprodids = new Set <Id>(); 
        pricebook2 spb = [SELECT Id FROM pricebook2 WHERE IsStandard = true ];
        
        for (Product2 sprod : Trigger.new){
            
            if(sprod.Standard_Cross_Org_Price__c != null ){
            sprodids.add(sprod.id);
                     
            } 

        }


        //anytime a product2 is updated where ConnectionReceivedId != null and the "Standard Cross-Org Price" field != null,
        List <pricebookentry> spbes = [SELECT Id, Product2Id, Pricebook2Id FROM pricebookentry WHERE Product2Id in :sprodids AND pricebook2Id = :spb.id ];
        Map <Id, PricebookEntry> spbeMap = new Map <Id, PricebookEntry>();
        for(PricebookEntry spbe : spbes){
            spbeMap.put(spbe.Product2Id, spbe);

        }


        //Declare a new empty list of pricebook entries called updatePricebookEntries
        List <pricebookentry> updateStandardPricebookEntries = new List<pricebookentry>();
        for (Product2 sprod : Trigger.new){
            //Check if there is a pricebookentry corresponding to this product
            if(sprod.Standard_Cross_Org_Price__c != null){
                if(spbeMap.get(sprod.id) != null ){
                    //If so, update the pbe and then add it to the list you declared above
                    spbeMap.get(sprod.id).UnitPrice = sprod.Standard_Cross_Org_Price__c;
                    updateStandardPricebookEntries.add(spbeMap.get(sprod.id));

                }else{
                    //If not, create a new pricebookentry and fill out the pricebook2id and the product2id fields and any other required fields.
                    //Then add it to the same list
                    PricebookEntry snpbe = new PricebookEntry();
                    snpbe.Product2Id = sprod.id;
                    snpbe.Pricebook2Id = spb.id;
                    snpbe.UnitPrice = sprod.Standard_Cross_Org_Price__c;
                    updateStandardPricebookEntries.add(snpbe);
                }
            }
        }
        if(updateStandardPricebookEntries.size() > 0){


            upsert updateStandardPricebookEntries;
        }
    }

    

    //After update -   // query to see if there is a pricebook2entry for this product in the pricebook where "Standard Cross-Org Pricebook" is checked.

    if( Trigger.IsAfter && Trigger.IsUpdate ) {
        system.debug('***' + 'Standard_Cross_Org_Price__c');
        Set <Id> prodids = new Set <Id>(); 
        pricebook2 pb = [SELECT Id FROM pricebook2 WHERE Standard_Cross_Org_Pricebook__c = true ];
        
        for (Product2 prod : Trigger.new){
            
            if(prod.Standard_Cross_Org_Price__c != null ){
            prodids.add(prod.id);
                     
            } 

        }


        //anytime a product2 is updated where ConnectionReceivedId != null and the "Standard Cross-Org Price" field != null,
        List <pricebookentry> pbes = [SELECT Id, Product2Id, Pricebook2Id FROM pricebookentry WHERE Product2Id in :prodids AND pricebook2Id = :pb.id ];
        Map <Id, PricebookEntry> pbeMap = new Map <Id, PricebookEntry>();
        for(PricebookEntry pbe : pbes){
            pbeMap.put(pbe.Product2Id, pbe);

        }


        //Declare a new empty list of pricebook entries called updatePricebookEntries
        List <pricebookentry> updatePricebookEntries = new List<pricebookentry>();
        for (Product2 prod : Trigger.new){
            //Check if there is a pricebookentry corresponding to this product
            if(prod.Standard_Cross_Org_Price__c != null){
                if(pbeMap.get(prod.id) != null ){
                    //If so, update the pbe and then add it to the list you declared above
                    pbeMap.get(prod.id).UnitPrice = prod.Standard_Cross_Org_Price__c;
                    updatePricebookEntries.add(pbeMap.get(prod.id));

                }else{
                    //If not, create a new pricebookentry and fill out the pricebook2id and the product2id fields and any other required fields.
                    //Then add it to the same list
                    PricebookEntry npbe = new PricebookEntry();
                    npbe.Product2Id = prod.id;
                    npbe.Pricebook2Id = pb.id;
                    npbe.UnitPrice = prod.Standard_Cross_Org_Price__c;
                    updatePricebookEntries.add(npbe);
                }
            }
        }

        //If the list contains any entries, upsert it
        if(updatePricebookEntries.size() > 0){


            upsert updatePricebookEntries;
        }
    } */
}