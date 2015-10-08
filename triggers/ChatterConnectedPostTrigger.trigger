trigger ChatterConnectedPostTrigger on Chatter_Connected_Post__c (after insert) 
{
	List<Chatter_Connected_Post__c> records = Trigger.isDelete ? Trigger.old : Trigger.new;
    
    if (Trigger.isAfter == true)
    {
        if (Trigger.isInsert == true)
        {
            //S2SUtils.createLocalFeedItemOrComment(records);
        }
    } 
}