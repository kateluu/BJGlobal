public with sharing class NoteAndAttachmentForProjectController {
	private SFDC_Projects__c project {get; set;}
	public List<rowData> nas;
	
	public class rowData {
		public String dType {get;set;}
		public Id id {get;set;}
		public String Title{get;set;}
		public String ParentName{get;set;}
		public Datetime LastModifiedDate{get;set;}
		public String CreatedByName{get;set;}
		
		public rowData(String dType, Id id, String title, String ParentName, Datetime LastModifiedDate, String CreatedByName) {
			this.dType = dType;
			this.id = id;
			this.Title = title;
			this.ParentName = ParentName;
			this.LastModifiedDate = LastModifiedDate;
			this.CreatedByName = CreatedByName;
		}
	} 
	
	public NoteAndAttachmentForProjectController(ApexPages.StandardController controller) {
		this.project = (SFDC_Projects__c)controller.getRecord();
	}
	
	public List<rowData> getNas() {
		nas = new List<rowData>();
		SFDC_Projects__c project = [select id, Account__c from SFDC_Projects__c where id = :project.id];
		if(project.Account__c == null) return null;
		for(Note n : [select Id, Title, Parent.Name, LastModifiedDate, CreatedBy.Name from Note where ParentId = :project.Account__c]) {
			nas.add(new rowData('Note', n.Id, n.Title, n.Parent.name, n.LastModifiedDate, n.CreatedBy.Name));
		}
		for(Attachment att : [select Id, Name, Parent.Name, LastModifiedDate, CreatedBy.Name from Attachment where ParentId = :project.Account__c]) {
			nas.add(new rowData('Attachment', att.Id, att.Name, att.Parent.name, att.LastModifiedDate, att.CreatedBy.Name));
		}
		
		system.debug(nas);
		return nas;
	}
	
	public static testMethod void coverageTest() {
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		
		Note n = new Note();
		n.ParentId = acc.id;
		n.title = 'aa';
		insert n;
		
		Attachment att = new Attachment();
		att.parentId = acc.id;
		att.name = 'ds';
		Blob b = Blob.valueof('fdsa'); 
		att.body = b;
		insert att;
		
		SFDC_Projects__c p = new SFDC_Projects__c();
    	p.account__c = acc.id;
    	p.name = 'name';
    	p.Sold_by__c = 'ss';
    	p.Phone_Number__c = '123456789';
    	p.Email__c = 'fdas@jlkdfs.com';
    	insert p;
    	    	
    	ApexPages.standardController sc = new ApexPages.standardController(p);
		NoteAndAttachmentForProjectController con = new NoteAndAttachmentForProjectController(sc);
		List<rowData> l = con.getNas();
		
	}
	
}