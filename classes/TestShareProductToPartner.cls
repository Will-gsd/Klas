@isTest
public Class TestShareProductToPartner {
    public Static testMethod Void testShareProduct2Method() {
        Product2 pro = new Product2(Name = 'Test Prod',ProductCode = 'Pro -1',Family = 'Product', Standard_Cross_Org_Price__c = 1);

        Insert pro;

        Id pricebookid = Test.getstandardPricebookId();

        PriceBookEntry standardPrice = new PricebookEntry(
        PriceBook2id = pricebookid, Product2Id = pro.id, UnitPrice = 1, IsActive = true);

        insert standardPrice;

        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true, Standard_Cross_Org_Pricebook__c = true);
        insert customPB;

        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = pro.Id,
            UnitPrice = 1, IsActive = true);
        insert customPrice;
    }
}