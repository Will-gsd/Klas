trigger FeedCommentTrigger on FeedComment (after insert) 
{
	List<FeedComment> records = Trigger.isDelete ? Trigger.old : Trigger.new;
    
    if (Trigger.isAfter == true)
    {
        if (Trigger.isInsert == true)
        {
            S2SUtils.createConnectedPostCommentRecord(records);
        }
    } 
}