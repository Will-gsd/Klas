trigger TaskTrigger on Task (before update) 
{
    List<Task> records = trigger.isDelete ? trigger.old : trigger.new;
    
    if(trigger.isBefore == true)
    {
        if(trigger.isUpdate == true)
        {
            S2SUtils.updateExternalAssignmentId(records, trigger.oldMap);    
        }
    }
}