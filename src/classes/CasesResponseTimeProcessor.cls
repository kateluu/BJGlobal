global class CasesResponseTimeProcessor implements Schedulable{
	NewVoiceMediaCallHelper helper;
	
   global void execute(SchedulableContext ctx) {
   		helper = new NewVoiceMediaCallHelper();
   		helper.getResponseTimeForCases();
	}
	
}