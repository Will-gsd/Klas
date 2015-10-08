@isTest
public Class TestUpdateOpp {
    static testMethod void oppUpdateMethod() {
        
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',StageName='Prospecting',CloseDate=System.TODAY());
        Insert newOpp;
           
        List<UpdateOpp.KTSAndKTIId> oppClsList = new List<UpdateOpp.KTSAndKTIId>();
        UpdateOpp.KTSAndKTIId oppCls = new UpdateOpp.KTSAndKTIId();
        oppCls.ktsId = newOpp.Id;
        oppCls.ktiId = '00QM05r0h0acqGn' ;
        
        oppClsList.add(oppCls);
        
        String JsonMsg=JSON.serialize(oppClsList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/UpdateOpportunity';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateOpp.updateOppKTIId(); 

    }
}