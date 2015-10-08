public class TaskExternalUpdate {
    public class TaskClass{
        public String tskId;
        public String callDisposition;
        public String callType;
        public String description;
        public String activityDate;
        public String whoId;
        public String priority;
        public Integer recurrenceInterval;
        public String whatId;
        public String recurrenceRegeneratedType;
        public String status;
        public String subject;
        public String type;
    }
    @future(callout=true)
    public static void linkTask(Set<Id> taskIdSet) {
        List<TaskClass> taskClassList = new List<TaskClass>();
        for(Task tsk : [Select Id,CallDisposition,CallType,Description,ActivityDate,whoId,Priority,RecurrenceInterval,WhatId,RecurrenceRegeneratedType,Status,Subject,Type FROM Task WHERE Id IN : taskIdSet]){
            
            TaskClass TskClInst = new TaskClass();
            TskClInst.tskId = tsk.Id;
            TskClInst.callDisposition = tsk.CallDisposition;
            TskClInst.callType = tsk.CallType;
            TskClInst.description = tsk.Description;
            TskClInst.activityDate= string.ValueOf(tsk.ActivityDate);
            TskClInst.whoId = tsk.WhoId;
            TskClInst.whatId = tsk.whatId;
            TskClInst.priority = tsk.Priority;
            TskClInst.recurrenceInterval = tsk.RecurrenceInterval;
            TskClInst.status = tsk.Status;
            TskClInst.subject = tsk.Subject;
            TskClInst.type = tsk.Type;
            
            taskClassList.add(TskClInst);
        }
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(System.label.EndPointUrl+'/services/apexrest/ReceiveTaskUpdate/');
        hreq.setMethod('POST');
        System.debug('::::::'+JSON.serialize(taskClassList));
        hreq.setHeader('Content-Type', 'application/json'); 
        
        hreq.setBody(JSON.serialize(taskClassList));
        HttpResponse hres = h.send(hreq);
    }
}