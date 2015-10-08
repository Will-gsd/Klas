/*
To Insert the QuoteLineItem when a quote is created
*/
global class SchedulerToInsertQLI Implements Schedulable{
    
    //Set<Id> qutIdSet = new Set<Id>();
    Set<Id> quoteLineItemIdSet = new Set<Id>();
    global SchedulerToInsertQLI (Set<Id> QuotIdSet){
        for(QuoteLineItem qli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId IN : QuotIdSet]) {
            quoteLineItemIdSet.add(qli.Id);
        }
    }
    global void execute(SchedulableContext sc){
        
        QuoteLineItemExternalSharing.doPost( quoteLineItemIdSet );
    }
}