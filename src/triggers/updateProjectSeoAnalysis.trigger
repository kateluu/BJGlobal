trigger updateProjectSeoAnalysis on Report_SEO_Analysis__c (after insert) {
	for(Report_SEO_Analysis__c report : trigger.new) {
		try {
			Id projectId = report.Project__c;
			SFDC_Projects__c project = [SELECT Id,Last_SEO_Analysis__c FROM SFDC_Projects__c WHERE Id=:projectId];
			Datetime dt = System.now();
			Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
			project.Last_SEO_Analysis__c = d;
			update project;
		} catch(Exception e) {
			general.sendAdminEmail('updateProjectSeoAnalysis','updateProjectSeoAnalysis Error Exception :'+e.getMessage());
		}
	}
}