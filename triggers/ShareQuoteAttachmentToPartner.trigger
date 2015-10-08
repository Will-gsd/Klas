trigger ShareQuoteAttachmentToPartner on Attachment (after insert) {
    Set<Id> attIdSet = new Set<Id>();
    if( Trigger.isInsert) {
        
        for(Attachment att:Trigger.new) {
            String parentIdStr = att.ParentId;
            System.debug('::::::'+parentIdStr);
            if(parentIdStr.startsWith(Quote.sobjectType.getDescribe().getKeyPrefix()) && !AssetClass.helperFlagForQuoteAttach ) {
                attIdSet.add(att.Id);
            }
            System.debug('::attIdset:::'+attIdSet);
        }
        if( attIdSet != null && attIdSet.size() > 0 ) {
            System.debug('::attIdset:::'+attIdSet);
            QuoteAttachmentExternalSharing.sendQuoteAttach(attIdSet); 
        }
    }
}