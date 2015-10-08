global class ChatterIntegrationBatch implements Database.Batchable<sObject>, Schedulable {
    
    global ChatterIntegrationBatch()
    {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(GetQueryLocatorString());
    }

    private String GetQueryLocatorString()
    {
        String query = 'Select Id, Batch_Process__c, Body__c, Destination_FeedItem_Id__c, Mentions_CSV__c, Originating_FeedItem_Id__c, ConnectionReceivedId, ' +
                       'Originating_Record_Id__c, Other_Org_User_Id__c, ParentId_in_Destination_Org__c, ParentId_in_Originating_Org__c, Parent_Org_User__c, Parent_Org_User_Id__c ' +
                       'FROM Chatter_Connected_Post__c WHERE Batch_Process__c = false ORDER BY CreatedDate DESC LIMIT 25';
        
        /*
        if(Test.isRunningTest())
        {
            query += ' LIMIT 200';
        }
        */
        
        system.debug('#### ChatterIntegrationBatch - GetQueryLocatorString: ' + query);

        return query;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Chatter_Connected_Post__c> ccpList = (List<Chatter_Connected_Post__c>)scope;
        S2SUtils.createLocalFeedItemOrComment(ccpList);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.scheduleBatch(new ChatterIntegrationBatch(), 'Chatter Integration', 5);
    }

    global void execute(SchedulableContext SC) 
    {
        ID batchprocessid = Database.executeBatch(new ChatterIntegrationBatch());
    }
    
    public static void schedule()
    {
        schedule(null);
    }
    
    public static void schedule(string jobSchedule)
    {
        if(jobSchedule == null || jobSchedule.trim().length() == 0)
        {
            jobSchedule = '0 0 1 * * ?'; //1 AM Daily
        }
        
        if (Test.isRunningTest()) 
        {
            System.schedule('ChatterIntegrationBatch Nightly' + String.valueOf(Math.random()), jobSchedule, new ChatterIntegrationBatch());
        }
        else
        {
            System.schedule('ChatterIntegrationBatch Nightly', jobSchedule, new ChatterIntegrationBatch());
        }
    }
    
}