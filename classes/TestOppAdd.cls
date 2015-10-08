@isTest(SeeAllData=true)
public class TestOppAdd 
{
    public static testMethod void myOppAddTest()
    {
        Id networkId = ConnectionHelper.getConnectionId('Klas Telecom'); 
		// create an acct simulating an account on the parent SF
        //Account acctKTI = new Account();
        //acctKTI.Name = 'KTI Test Account';
        //acctKTI.AccountSource = 'Other';
        
        //insert acctKTI;
        
        // create a new account, simulating an account shared to us from the parent
        /*Account acctKTS = new Account();
        acctKTS.Name = 'KTS Test Account';
        acctKTS.AccountSource = 'Other';
        acctKTS.KTI_Id__c = '0011100000cVHEI';
        
		insert acctKTS;
                
        acctKTS = [SELECT KTS_Id__c FROM Account WHERE Id = :acctKTS.Id];
        */
    	//System.assertEquals(null, acct.Most_Recently_Created_Opportunity_Name__c);
        
        // create a new opporutnity, simulating an opp shared to us from parent linked to above account
        Organization org = [select Id, IsSandbox from Organization limit 1];
        Opportunity op = new Opportunity();
        op.Name = 'Test Opportunity';
        op.Type = 'Existing Business';
        op.KTI_AccountId__c = '';
        // use 0011100000c9POr on sandbox
        // use 00160000011NnpW on production
        if(org.IsSandbox){
            op.KTI_AccountId__c = '0011100000c9POr';
        }
        else{
            op.KTI_AccountId__c = '00160000011NnpW';
        }
        //op.KTI_Id__c =        '00611000007BFbh';
        op.StageName ='Prospecting';
        op.CloseDate = Date.parse('11/01/2014');
        //op.KTS_AccountId__c = '';

        //Account acctKTS = [SELECT Id, KTI_Id__c FROM Account WHERE KTI_Id__c=:op.KTI_AccountId__c];
        
        Test.startTest();
        insert op;
        Test.stopTest();
        
        Opportunity op2 = [SELECT Id, AccountId FROM Opportunity WHERE Id=:op.Id];
        System.debug('op2.AccountId = ' + op2.AccountId);
        //System.assertEquals(op2.AccountId, acctKTS.Id);

        
    }

}