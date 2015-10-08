@isTest(seeAllData=True)
public class TestUpdateContact {
    static testMethod void contactUpdateMethod() {
        List<Account> accList=[Select Id, KTI_Id__c From Account Where ConnectionReceivedId != NULL And Do_Not_Share__c=False];
        Contact con = new Contact(LastName = 'Test Contact',AccountId=accList.get(0).Id);
        Insert con;
        List<Contact> conList=[Select Id,KTI_Account_Id__c From Contact Where AccountId != NULL ];
        conList.get(0).KTI_Account_Id__c=accList.get(0). KTI_Id__c; 
        conList.get(0).AccountId=accList.get(0).Id;
        update conList; 
        List<UpdateContact.KTSAndKTIId> conClsList = new List<UpdateContact.KTSAndKTIId>();
        UpdateContact.KTSAndKTIId conCls = new UpdateContact.KTSAndKTIId();
        conCls.ktsId = con.Id;
        conCls.ktiId = '003M05r0h0acqGn' ;
        
        conClsList.add(conCls);
        
        String JsonMsg=JSON.serialize(conClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateContact.updateContactKTIId();

    }
}