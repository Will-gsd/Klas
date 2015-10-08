public class S2SUtils 
{
  public static Set<Id> pauseUpdatesForParentOrFeed;
    
    public static void createConnectedPostRecord(List<FeedItem> records)
    {
        List<Chatter_Connected_Post__c> toInsert = new List<Chatter_Connected_Post__c>();
        
        //make sure this record has not been synched yet
        Set<Id> existingConnections = getExistingConnections(records);
        
        for (FeedItem fi : records)
        {
            List<String> mentionIds = new List<String>();
            ConnectApi.FeedElement fe = ConnectApi.ChatterFeeds.getFeedElement(null, fi.Id);
            for (ConnectApi.MessageSegment messageSegment : fe.body.messageSegments)
            {
                if (messageSegment instanceof ConnectApi.MentionSegment)
                {
                    ConnectApi.MentionSegment ms = (ConnectApi.MentionSegment) messageSegment;
                    //mentionIds.add('@' + ms.name + '%%%' + ms.record.id.substring(0,15));
                    mentionIds.add('@' + ms.name + '%%%' + ms.record.id);
                }
            }
            
            System.debug('#### S2SUtils - createConnectedPostRecord - chatter mentions: ' + mentionIds);
            System.debug('#### S2SUtils - createConnectedPostRecord - pauseUpdatesForParentOrFeed: ' + pauseUpdatesForParentOrFeed);
            
            System.debug('#### S2SUtils - createConnectedPostRecord - fi.ParentId: ' + fi.ParentId);
            if (pauseUpdatesForParentOrFeed == null || !pauseUpdatesForParentOrFeed.contains(fi.ParentId))
            {
                Chatter_Connected_Post__c ccp = new Chatter_Connected_Post__c
                (
                    Parent_Org_User_Id__c = fi.CreatedById,
                    ParentId_in_Originating_Org__c = fi.ParentId,
                    Originating_Record_Id__c = fi.Id,
                    Body__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' says: ' + fi.Body
                );
                
                if (mentionIds.size() > 0)
                {
                    String m = '';
                    for (String s : mentionIds)
                    {
                        m += s + ',';
                    }
                    
                    if (m.right(1) == ',')
                    {
                        m = m.substring(0, m.length() - 1);
                    }
                    
                    ccp.Mentions_CSV__c = m;
                }
                
                System.debug('#### S2SUtils - createConnectedPostRecord - fi record: ' + fi);
                toInsert.add(ccp);
            }
        }
        
        if (toInsert.size() > 0)
        {
          try
            {
                System.debug('#### S2SUtils - createConnectedPostRecord - inserting CCP record: ' + toInsert);
              insert toInsert;
                syncRecords(toInsert);
            }
            catch (Exception e)
            {
                System.debug('#### S2SUtils - createConnectedPostRecord - error inserting CCP record: ' + e);
            }
        }
    }
    
    public static void createConnectedPostCommentRecord(List<FeedComment> records)
    {
        List<Chatter_Connected_Post__c> toInsert = new List<Chatter_Connected_Post__c>();
        
        //make sure this record has not been synched yet
        Set<Id> existingConnections = getExistingConnections(records);
        
        for (FeedComment fc : records)
        {
            List<String> mentionIds = new List<String>();
            ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment(null, fc.Id);
            for (ConnectApi.MessageSegment messageSegment : comment.body.messageSegments)
            {
                if (messageSegment instanceof ConnectApi.MentionSegment)
                {
                    ConnectApi.MentionSegment ms = (ConnectApi.MentionSegment) messageSegment;
                    //mentionIds.add('@' + ms.name + '%%%' + ms.record.id.substring(0,15));
                    mentionIds.add('@' + ms.name + '%%%' + ms.record.id);
                }
            }
            
            System.debug('#### S2SUtils - createConnectedPostCommentRecord - fc.Id: ' + fc.Id);
            
            System.debug('#### S2SUtils - createConnectedPostRecord - chatter comment mentions: : ' + mentionIds);
            System.debug('#### S2SUtils - createConnectedPostRecord - pauseUpdatesForParentOrFeed: ' + pauseUpdatesForParentOrFeed);
            System.debug('#### S2SUtils - createConnectedPostRecord - fc.FeedItemId: ' + fc.FeedItemId);
            
            if (pauseUpdatesForParentOrFeed == null
                || !pauseUpdatesForParentOrFeed.contains(fc.FeedItemId))
            {
                Chatter_Connected_Post__c ccp = new Chatter_Connected_Post__c
                (
                    Parent_Org_User_Id__c = fc.CreatedById,
                    ParentId_in_Originating_Org__c = fc.ParentId,
                    Originating_FeedItem_Id__c = fc.FeedItemId,
                    Originating_Record_Id__c = fc.Id,
                    Body__c = fc.CommentBody
                );
                
                if (mentionIds.size() > 0)
                {
                    String m = '';
                    for (String s : mentionIds)
                    {
                        m += s + ',';
                    }
                    
                    if (m.right(1) == ',')
                    {
                        m = m.substring(0, m.length() - 1);
                    }
                    
                    ccp.Mentions_CSV__c = m;
                }
                
                System.debug('#### S2SUtils - createConnectedPostCommentRecord - fc record: ' + fc);
                toInsert.add(ccp);
            }
        }
        
        if (toInsert.size() > 0)
        {
          try
            {
                System.debug('#### S2SUtils - createConnectedPostCommentRecord - inserting CCP comment record: ' + toInsert);
              insert toInsert;
                syncRecords(toInsert);
            }
            catch (Exception e)
            {
                System.debug('#### S2SUtils - createConnectedPostCommentRecord - error inserting CCP comment record: ' + e);
            }
        }
    }
    
    public static void syncRecords(List<Chatter_Connected_Post__c> records)
    {
        System.debug('#### S2SUtils - syncRecords - creating sync records: ' + records);
        Id networkId = getConnectionId('Klas Telecom');  
        List<PartnerNetworkRecordConnection> toShare = new List<PartnerNetworkRecordConnection>();
        
        for (Chatter_Connected_Post__c ccp : records) 
        {
            System.debug('#### S2SUtils - syncRecords - ccp.ConnectionReceivedId: ' + ccp.ConnectionReceivedId);
            if (ccp.ConnectionReceivedId == null) 
            {     
                PartnerNetworkRecordConnection pnrc = new PartnerNetworkRecordConnection
                ( 
                        ConnectionId = networkId, 
                        LocalRecordId = ccp.Id
                ); 
                
                System.debug('#### S2SUtils - syncRecords - no existing connection, creating new one: ' + pnrc);
                toShare.add(pnrc); 
            }         
        } 
      
        if (toShare.size() > 0 ) 
        { 
            try
            {
                System.debug('#### S2SUtils - syncRecords - inserting PartnerNetworkRecordConnection records: ' + toShare);
              database.insert(toShare);
            }
            catch (Exception e)
            {
                System.debug('#### S2SUtils - syncRecords - error inserting new PartnerNetworkRecordConnection records: ' + e);
            }
        } 
    }
    
    public static void createLocalFeedItemOrComment(List<Chatter_Connected_Post__c> records)
    {
        Id networkId = getConnectionId('Klas Telecom');
        Map<Id, Id> localParentMap = new Map<Id, Id>();
        Map<Id, Id> localFeedItemMap = new Map<Id, Id>();
        Map<Id, Map<String, Id>> initialMentions = new Map<Id,  Map<String, Id>>();
        Map<Id, Id> localMentions = new Map<Id, Id>();
        List<Chatter_Connected_Post__c> feedItemsToProcess = new List<Chatter_Connected_Post__c>();
        List<Chatter_Connected_Post__c> feedCommentsToProcess = new List<Chatter_Connected_Post__c>();
        List<Chatter_Connected_Post__c> toProcess = new List<Chatter_Connected_Post__c>();
        
        pauseUpdatesForParentOrFeed = new Set<Id>();
        
        for (Chatter_Connected_Post__c ccp : records)
        {
            if ((ccp.ConnectionReceivedId == networkId || test.isRunningTest()) && !String.isBlank(ccp.ParentId_in_Originating_Org__c))
            {
                if (String.isBlank(ccp.Originating_FeedItem_Id__c))
                {
                    System.debug('#### S2SUtils - createLocalFeedItemOrComment - feeditem to process: ' + ccp);
                    feedItemsToProcess.add(ccp);
                }
                else
                {
                    System.debug('#### S2SUtils - createLocalFeedItemOrComment - feedcomment to process: ' + ccp);
                    feedCommentsToProcess.add(ccp);
                    localFeedItemMap.put(ccp.Originating_FeedItem_Id__c, null);
                }
                
                if (!String.isBlank(ccp.Mentions_CSV__c))
                {
                    Map<String, Id> innerMap = new Map<String, Id>();
                    //split by comma, then %%%
                    for (String s1 : ccp.Mentions_CSV__c.split(','))
                    {
                        List<String> pieces = s1.split('%%%');
                        System.debug('#### S2SUtils - createLocalFeedItemOrComment - pieces: ' + pieces);
                        if (pieces.size() == 2 && pieces[1] != null && pieces[1] != '')
                        {
                            innerMap.put(pieces[0], pieces[1]);
                            localMentions.put(pieces[1], null);
                        }
                    }
                    initialMentions.put(ccp.Id, innerMap);
                }
                
                localParentMap.put(ccp.ParentId_in_Originating_Org__c, null);
            }
        }
        
        if (localParentMap.size() == 0 
            && (feedItemsToProcess.size() == 0 || feedCommentsToProcess.size() == 0))
        {
            return;
        }
        
        for (PartnerNetworkRecordConnection p : [SELECT
                                                    Id,
                                                    Status,
                                                     ConnectionId,
                                                    PartnerRecordId,
                                                     LocalRecordId
                                                 FROM
                                                     PartnerNetworkRecordConnection
                                                 WHERE
                                                     PartnerRecordId = : localParentMap.keySet()])
        {
            localParentMap.put(p.PartnerRecordId, p.LocalRecordId);
        }
        
        if (localMentions.size() > 0)
        {
            for (User u : [SELECT Id, Other_Org_18_Digit_Id__c FROM User WHERE Other_Org_18_Digit_Id__c = : localMentions.keySet()])
            {
                localMentions.put(u.Other_Org_18_Digit_Id__c, u.Id);
            }
            System.debug('#### S2SUtils - createLocalFeedItemOrComment - localMentions: ' + localMentions);
        }
        
        //process feeditems first in case records came in at the same time
        Map<Id, ConnectApi.FeedElement> destinationFIMap = new Map<Id, ConnectApi.FeedElement>();
        for (Chatter_Connected_Post__c ccp : feedItemsToProcess)
        {
            if (localParentMap.containsKey(ccp.ParentId_in_Originating_Org__c)
                && !String.isBlank(localParentMap.get(ccp.ParentId_in_Originating_Org__c)))
            {
                String body = ccp.Body__c.unescapeHtml4();
                if (initialMentions.containsKey(ccp.Id))
                {
                    for (String x : initialMentions.get(ccp.Id).keySet())
                    {
                        if (localMentions.containsKey(initialMentions.get(ccp.Id).get(x)))
                        {
                            String replacement = '{' + localMentions.get(initialMentions.get(ccp.Id).get(x)) + '}';
                          body = body.replaceAll(x, replacement);
                            System.debug('#### S2SUtils - createLocalFeedItemOrComment - body after: ' + body);
                        }
                    }  
                }
                
                pauseUpdatesForParentOrFeed.add(localParentMap.get(ccp.ParentId_in_Originating_Org__c));
                ConnectApi.FeedElement fe = ConnectApiHelper.postFeedItemWithMentions(null, localParentMap.get(ccp.ParentId_in_Originating_Org__c), body);
                destinationFIMap.put(ccp.Id, fe);
            }
        }
        
        if (destinationFIMap.size() > 0)
        {
            //insert destinationFIMap.values();
            
            //add new destination feed item Ids to CCP records -- only do this for feed item
            List<Chatter_Connected_Post__c> ccpToUpdate = new List<Chatter_Connected_Post__c>();
            for (Chatter_Connected_Post__c ccp : feedItemsToProcess)
            {
                if (destinationFIMap.containsKey(ccp.Id)
                    && (destinationFIMap.get(ccp.Id).id != null 
                        || destinationFIMap.get(ccp.Id).parent != null))
                {
                    Chatter_Connected_Post__c ccp2 = new Chatter_Connected_Post__c(Id = ccp.Id);
                    ccp2.Destination_FeedItem_Id__c = destinationFIMap.get(ccp.Id).Id;
                    ccp2.ParentId_in_Destination_Org__c = destinationFIMap.get(ccp.Id).parent.id;
                    ccp2.Batch_Process__c = true;
                    ccpToUpdate.add(ccp2);
                }
            }
            
            if (ccpToUpdate.size() > 0)
            {
                update ccpToUpdate;
            }
        }
        
        //process feedcomments -- need to find feeditem locally    
        for (Chatter_Connected_Post__c ccp : [SELECT
                                                 Id,
                                                 Originating_Record_Id__c,
                                                  Destination_FeedItem_Id__c
                                              FROM
                                                 Chatter_Connected_Post__c
                                              WHERE
                                                 Originating_Record_Id__c = : localFeedItemMap.keySet()])
        {
            localFeedItemMap.put(ccp.Originating_Record_Id__c, ccp.Destination_FeedItem_Id__c);
        }
        
        List<FeedComment> FCtoInsert = new List<FeedComment>();
        List<Chatter_Connected_Post__c> ccpCommentToUpdate = new List<Chatter_Connected_Post__c>();
        for (Chatter_Connected_Post__c ccp : feedCommentsToProcess)
        {
            if (localFeedItemMap.containsKey(ccp.Originating_FeedItem_Id__c)
                && !String.isBlank(localFeedItemMap.get(ccp.Originating_FeedItem_Id__c)))
            {
                String body = ccp.Body__c != null ? ccp.Body__c.unescapeHtml4() : '';
                if (initialMentions.containsKey(ccp.Id))
                {
                    for (String x : initialMentions.get(ccp.Id).keySet())
                    {
                        if (localMentions.containsKey(initialMentions.get(ccp.Id).get(x)))
                        {
                            String replacement = '{' + localMentions.get(initialMentions.get(ccp.Id).get(x)) + '}';
                          body = body.replaceAll(x, replacement);
                            System.debug('#### S2SUtils - createLocalFeedItemOrComment - comment body after: ' + body);
                        }
                    }  
                }
                
                pauseUpdatesForParentOrFeed.add(localFeedItemMap.get(ccp.Originating_FeedItem_Id__c));
                if(!test.isRunningTest()){
                    ConnectApi.Comment fe = ConnectApiHelper.postCommentWithMentions(null, localFeedItemMap.get(ccp.Originating_FeedItem_Id__c), body);
                }
                Chatter_Connected_Post__c ccp2 = new Chatter_Connected_Post__c(Id = ccp.Id);
                ccp2.Batch_Process__c = true;
                if(ccp2.Body__c != null && ccp2.Body__c != '') ccpCommentToUpdate.add(ccp2);
            }
        }
        
        if (ccpCommentToUpdate.size() > 0)
        {
            update ccpCommentToUpdate;
        }
        
        pauseUpdatesForParentOrFeed = new Set<Id>();
    }
    
    /*public static List<String> getPostPieces(String body, Map<String, Id> innerMap)
    {
        List<String> pieces = new List<String>();
        for (String x : innerMap.keySet())
        {
            body.replaceAll(x, '%%%' + innerMap.get(x) + '%%%');
        }
        
        //pieces = body.split('(%%%[\da-zA-Z])\w+%%%');
        System.debug('#### S2SUtils - getPostPieces - pieces: ' + pieces);
        
        return pieces;
    }*/
    
    public static Set<Id> getExistingConnections(List<SObject> records)
    {
        Set<Id> recordIds = new Set<Id>();
        for (SObject sobj : records)
        {
            recordIds.add(sobj.Id);
        }
        
        Set<Id> existingConnections = new Set<Id>();
        for (Chatter_Connected_Post__c ccp : [SELECT
                                                  Id,
                                                  Originating_Record_Id__c
                                              FROM
                                                  Chatter_Connected_Post__c
                                              WHERE
                                                  Originating_Record_Id__c = : recordIds])
        {
            existingConnections.add(ccp.Originating_Record_Id__c);
        }
        
        return existingConnections;
    }
    
    public static Id getConnectionId(String connectionName) 
    {  
      List<PartnerNetworkConnection> partnerNetConList = [SELECT 
                                                              Id 
                                                            FROM 
                                                              PartnerNetworkConnection 
                                                            WHERE 
                                                              ConnectionStatus = 'Accepted' 
                                                            AND 
                                                              ConnectionName = : connectionName];
        
        if (partnerNetConList.size() != 0) 
        {
            return partnerNetConList.get(0).Id;
        }
        
        return null;
    }
    
    public static Id getConnectionOwnerId(String connectionName) 
    { 
        List<PartnerNetworkConnection> partnerNetConList = [SELECT 
                                                              CreatedById 
                                                            FROM 
                                                              PartnerNetworkConnection 
                                                            WHERE 
                                                              ConnectionStatus = 'Accepted' 
                                                            AND 
                                                              ConnectionName = : connectionName];
        
        if (partnerNetConList.size() != 0) 
        {
            return partnerNetConList.get(0).createdById;
        }
        
        return null;
    }
    
    public static void updateExternalAssignmentId(List<SObject> records, Map<Id, SObject> oldMap)
    {
        Boolean isUpdate = (oldMap != null);
        Id connectionUser = S2SSettings__c.getOrgDefaults().Connection_User_Id__c;
        List<SObject> toUpdate = new List<SObject>();
        
        for (SObject obj : records)
        {
            if (isUpdate
                && UserInfo.getUserId() == connectionUser
                && obj.get('External_Owner_Id_Local_Record__c') != null
                && obj.get('External_Owner_Id_Local_Record__c') != ''
                && (obj.get('External_Owner_Id_Local_Record__c') != oldMap.get((Id) obj.get('Id')).get('External_Owner_Id_Local_Record__c')))
                //&& oldMap.get((Id) obj.get('Id')).get('LastModifiedById') == connectionUser)
            {
                System.debug('#### S2SUtils - updateExternalAssignmentId - update by connection user for: ' + obj);
                System.debug('#### S2SUtils - updateExternalAssignmentId - External_Owner_Id_Local_Record__c: ' + obj.get('External_Owner_Id_Local_Record__c'));
                obj.put('OwnerId', obj.get('External_Owner_Id_Local_Record__c'));
                //toUpdate.add(obj);
            }
        }
        /*
        if (toUpdate.size() > 0)
        {
            try
            {
                System.debug('#### S2SUtils - updateExternalAssignmentId - updating: ' + toUpdate);
                update toUpdate;
            }
      catch (Exception e)
            {
                System.debug('#### S2SUtils - updateExternalAssignmentId - error updating records: ' + toUpdate);
            }
        }
    */
    }
    
    public static Map<Id,Id> accToSharedRecordId(Set<Id> accIds){
        Map<Id,Id> accIdToRecordConnection = new Map<Id,Id>();
        for(PartnerNetworkRecordConnection connection: [SELECT Id,LocalRecordId FROM PartnerNetworkRecordConnection 
                                                        WHERE LocalRecordId IN :accIds
                                                        AND Status = 'Sent']){
            accIdToRecordConnection.put(connection.LocalRecordId,connection.Id);
        }
        return accIdToRecordConnection;
    }
    @future
    public static void updateRecords(Set<Id> recordIds, String objName){
        String query = 'SELECT id FROM ' + objName + ' WHERE Id IN :recordIds';
        List<SObject> records = Database.query(query);
        update records;
    }
}