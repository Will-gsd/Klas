trigger OppUpdateAccountId on Opportunity (after insert, after update) {
    //System.debug('trigger OppUpdateAccountId: Trigger activated');
    // define connection id for KTI Org. 
    Id networkId = ConnectionHelper.getConnectionId('Klas Telecom'); 
    //System.debug('trigger OppUpdateAccountId: Did ConnectionHelper');
    // build the KTS local contact id to KTI contact map 
    Map<Id,Id> oppIdMap = new Map<Id,Id>(); 
    
    for (Opportunity newOpportunity : Trigger.new) { 
        //put this following line in before pushing to production (checks to make sure the opportunity was last modified by KTI SF instance)
        // i think we can do without the extra check on lastModifiedById.  it should be sufficient for us to just check to see if there is
        // a KTI_AccountId which means it is associated with an account on KTI's SF.  that's what is important.  Opportunities inserted/updated
        // from the parent will always have this populated due to the formula field.
        if (newOpportunity.KTI_AccountId__c != null && newOpportunity.KTI_AccountId__c != '' ) //&& newOpportunity.lastModifiedById == ConnectionHelper.getConnectionOwnerId('Klas Telecom')) 
        { 
            //System.debug('trigger OppUpdateAccountId: Did check to see if KTI_AccountId is not null and came from KTI');
            if (Trigger.isInsert
                || (Trigger.isUpdate
                   && (Trigger.oldMap.get(newOpportunity.Id).KTI_AccountId__c != newOpportunity.KTI_AccountId__c))) 
            { 
                oppIdMap.put(newOpportunity.Id, newOpportunity.KTI_AccountId__c);
                System.debug('trigger OppUpdateAccountId: newOpportunity.Id = ' + newOpportunity.Id + ', newOpportunity.KTI_AccountId__c = ' + newOpportunity.KTI_AccountId__c);
            }
        }
    }
    
    // call future method to link local Opportunity corresponding to KTI's Opportunity.AccountId.
    if (oppIdMap.size() > 0) { 
        System.debug('trigger OppUpdateAccountId: Call ExternalSharingHelper');
        ExternalSharingHelper.linkOpportunity(oppIdMap); 
    }
    
}