/*
	Purpose: - Test class for QuoteLineItemExternalSharing

	Created By: Aaron Pettitt (GSD Consulting)

	Revision Log:  
	 	v1.0 - (AP 08/10/2015) -- created
*/

@isTest
private class Test_QuoteLineItemExternalSharing {
	
	@isTest(SeeAllData = TRUE) static void test_Post() {
		/* setup data */
		Opportunity opportunity;
        Contact contact;
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Testing Product 1', ProductCode = 'tp1', Family = 'Others', IsActive = true));
        products.add(new Product2(Name = 'Testing Product 2', ProductCode = 'tp2', Family = 'Others', IsActive = true));
        products.add(new Product2(Name = 'Testing Product 3', ProductCode = 'tp3', Family = 'Others', IsActive = true));
        insert products;

		Pricebook2 priceBook = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];

		PriceBook2 priceBook2 = new PriceBook2(Name = 'Test',IsActive = TRUE);
        Insert priceBook2;

        PricebookEntry priceBookEntry1 = new PricebookEntry(Pricebook2Id = priceBook.Id, product2Id = products[0].Id, UnitPrice = 100, isactive = true);
        Insert priceBookEntry1;
        
        PricebookEntry priceBookEntry2 = new PricebookEntry(Pricebook2Id = priceBook2.Id, product2Id = products[0].Id, UnitPrice = 100, isactive = true);
        Insert priceBookEntry2;
        
        List<Account> sharedAcc = [SELECT Id, Name, KTI_Id__c, connectionReceivedId FROM Account WHERE KTI_Id__c != NULL];

        if ( sharedAcc != NULL && sharedAcc.Size() > 0 ) {
            contact = new Contact(LastName = 'Test Con',AccountId=sharedAcc[0].Id,KTI_Contact_Id__c = '003M00k000cAxBZAAA');
            insert contact;
        }
        if ( sharedAcc != NULL && sharedAcc.Size() > 0 ) {
            opportunity = new Opportunity(Name = 'opp1',StageName= 'closed',CloseDate = System.today()+30,AccountId=sharedAcc[0].Id,KTI_ID__c = '006M00m000CKBbA');
            insert opportunity;
        }
		Quote quote = new Quote(Name = 'Test Quote 1', Email='TestContact@test.com', OpportunityId = opportunity.Id, Pricebook2Id = priceBook.Id);
		insert quote;

		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
		quoteLineItems.add(new QuoteLineItem(Product2Id = products[0].Id, QuoteId = quote.Id, Quantity = 1, PricebookEntryId = priceBookEntry1.Id, UnitPrice = 100));
		quoteLineItems.add(new QuoteLineItem(Product2Id = products[1].Id, QuoteId = quote.Id, Quantity = 2, PricebookEntryId = priceBookEntry1.Id, UnitPrice = 100));
		quoteLineItems.add(new QuoteLineItem(Product2Id = products[2].Id, QuoteId = quote.Id, Quantity = 3, PricebookEntryId = priceBookEntry1.Id, UnitPrice = 100));
		insert quoteLineItems;

		Set<Id> quoteLineItemIdSet = new Set<Id>();
		for(QuoteLineItem quoteLineItem : quoteLineItems){
			quoteLineItemIdSet.add(quoteLineItem.Id);
		}

		//start the actual test
		Test.setMock(HttpCalloutMock.class, new HttpResponseForAsset());
		test.startTest();

		QuoteLineItemExternalSharing.doPost(quoteLineItemIdSet);

		test.stopTest();

		quoteLineItems = [Select Id, Updated_in_Source__c from QuoteLineItem where Id IN : quoteLineItems];
		for(QuoteLineItem quoteLineItem : quoteLineItems){
			system.assertEquals(false, quoteLineItem.Updated_in_Source__c);
		}
	}

	//mock callout class for the callout to receivequotelineitem
	public class HttpResponseForAsset implements HttpCalloutMock {
        List<QuoteLineItem> qtList = [SELECT Id,KTI_Quote_Line_Item_Id__c FROM QuoteLineItem LIMIT 5];
        
        //System.Debug(qteList);
        String TestJSONContent = '"{\"responseResult\":\"Success\",\"resClsList\":[{\"kti_QuoteLineItemId\":\"987654rf243\",\"kts_QuoteLineItemId\":\"'+qtList[0].Id+'\"}],\"isSuccess\":true}"';
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(TestJSONContent);
            res.setStatus('Ok');
            return res;
        }
    }

}