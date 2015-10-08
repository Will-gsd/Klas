trigger FeedItemTrigger on FeedItem (after insert) 
{
	List<FeedItem> records = Trigger.isDelete ? Trigger.old : Trigger.new;
    
    if (Trigger.isAfter == true)
    {
        if (Trigger.isInsert == true)
        {
            S2SUtils.createConnectedPostRecord(records);
        }
    } 
}