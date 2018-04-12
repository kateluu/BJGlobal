@istest
private class BlogHomeControllerTest {
	static testMethod void TestController()
	{
		Blog_Post__c post=new Blog_Post__c(Content__c='Unit Test Blog Post', Status__c='Published');
		insert post;
		BlogHomeController ctrl=new BlogHomeController();
		
		ctrl.comname='Unit Tester'; 
		ctrl.combody='Unit Test Comment Body';
		ctrl.comblogid=post.id;
		ctrl.addComment();
	}
}