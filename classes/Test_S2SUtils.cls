/*
	Purpose: - Test class for S2SUtils

	Created By: Aaron Pettitt (GSD Consulting)

	Revision Log:  
	 	v1.0 - (AP 08/15/2015) -- created
*/
@isTest(SeeAllData = true)
private class Test_S2SUtils {
	Static List<FeedItem> posts;
	Static List<FeedComment> comments;
	Static List<Chatter_Connected_Post__c> connectedPosts;


	@isTest static void test_createConnectedPostRecord() {
		setupTestData();
		S2SUtils.createConnectedPostRecord(posts);
		List<Chatter_Connected_Post__c> chatterConnectedPosts = [Select Id, Originating_Record_Id__c from Chatter_Connected_Post__c where Originating_Record_Id__c =: posts[0].Id];
		System.assertEquals(2, chatterConnectedPosts.size());
	}
	
	@isTest static void test_createConnectedPostCommentRecord() {
		setupTestData();
		S2SUtils.createConnectedPostCommentRecord(comments);
		List<Chatter_Connected_Post__c> chatterConnectedPosts = [Select Id, Originating_Record_Id__c from Chatter_Connected_Post__c where Originating_Record_Id__c =: comments[0].Id];
		System.assertEquals(2, chatterConnectedPosts.size());
	}

	@isTest static void test_createLocalFeedItemOrComment() {
		setupTestData();
		S2SUtils.createLocalFeedItemOrComment(connectedPosts);
	}
	
	@isTest static void test_getConnectionOwnerId() {
		PartnerNetworkConnection partnerConnection = [SELECT ConnectionName, Id FROM PartnerNetworkConnection  WHERE ConnectionStatus = 'Accepted' Limit 1];
		S2SUtils.getConnectionOwnerId(partnerConnection.ConnectionName);
	}

	//setup the test chatter post
	static void setupTestData(){
		User user = [Select Name, Id from User Limit 1];
      	//create the chatter post
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    	messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    	ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    	textSegment.text = 'Test Chatter Post ';
    	messageInput.messageSegments.add(textSegment);

        ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();
        mention.Id = UserInfo.getUserId();
        messageInput.messageSegments.add(mention);
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    	input.body = messageInput;
    	input.subjectId = UserInfo.getUserId();

    	ConnectApi.FeedElement post = ConnectApi.ChatterFeeds.postFeedElement(null, input, null);
    	posts = [Select Body, CommentCount, ConnectionId, ContentData, ContentDescription, ContentFileName, ContentSize,
    	ContentType, InsertedById, LinkUrl, ParentId, RelatedRecordId, Title, Type, CreatedById
    	From FeedItem 
    	Where Id =: post.Id];

    	//create chatter comment
    	ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
		messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		messageInput.messageSegments.add(textSegment);
		messageInput.messageSegments.add(mention);
		commentInput.body = messageInput;

    	ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, posts[0].Id, commentInput, null);
    	comments = [select CommentBody, CommentType, CreatedById, CreatedDate, FeedItemId, Id, InsertedById, IsDeleted, ParentId, RelatedRecordId 
    	from FeedComment
    	Where Id =: commentRep.Id];


    	//create chatter connected post record
    	connectedPosts = new List<Chatter_Connected_Post__c>();
    	Chatter_Connected_Post__c connectedPost = new Chatter_Connected_Post__c();
    	connectedPost.Body__c = 'Test other org post';
    	connectedPost.Originating_Record_Id__c = 'testoriginatingid';
    	connectedPost.ParentId_in_Originating_Org__c = '00560000001FbK8AAK';
    	connectedPost.Mentions_CSV__c = '@' + user.Name +  '%%%' + user.Id;
    	connectedPost.Originating_Record_Id__c = '0D5g000000NIA7yCAH';
    	connectedPost.Originating_FeedItem_Id__c = '0D5M000000JBUIkKAP';
    	connectedPosts.add(connectedPost);
    	insert connectedPosts;
	}
	
}