@isTest
public class TestUpdateLead {
    static testMethod void leadUpdateMethod() {
              
        
        Lead newld = new Lead(LastName = 'Test Lead',Company = 'Test',Status = 'Open');
        Insert newld;
           
        List<UpdateLead.KTSAndKTIId> leadClsList = new List<UpdateLead.KTSAndKTIId>();
        UpdateLead.KTSAndKTIId leadCls = new UpdateLead.KTSAndKTIId();
        leadCls.ktsId = newld.Id;
        leadCls.ktiId = '00QM05r0h0acqGn' ;
        
        leadClsList.add(leadCls);
        
        String JsonMsg=JSON.serialize(leadClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateLead';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateLead.updateLeadKTIId();

    }
}