@isTest
public class TestUpdateAccount {
    static testMethod void leadAccountMethod() {
              
        Account acc = new Account(Name = 'Test Account',AccountSource = 'New Customer',Organization_Name__c= 'Test');
        Insert acc;
           
        List<UpdateAccount.KTSAndKTIId> accClsList = new List<UpdateAccount.KTSAndKTIId>();
        UpdateAccount.KTSAndKTIId accCls = new UpdateAccount.KTSAndKTIId();
        accCls.ktsId = acc.Id;
        accCls.ktiId = '001M05r0h0acqGn' ;
        
        accClsList.add(accCls);
        
        String JsonMsg=JSON.serialize(accClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateAccount';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateAccount.updateAccountKTIId();

    }
}