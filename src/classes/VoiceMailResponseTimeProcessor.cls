global class VoiceMailResponseTimeProcessor implements Schedulable{
	NewVoiceMediaCallHelper helper;
	
   global void execute(SchedulableContext ctx) {
   		helper = new NewVoiceMediaCallHelper();
   		helper.getResponseTimeForVoiceMail();

   		Datetime sysTime = System.now();
   		sysTime = sysTime.addMinutes(30);
        String day = string.valueOf(sysTime.day());
        String month = string.valueOf(sysTime.month());
        String hour = string.valueOf(sysTime.hour());
        String minute = string.valueOf(sysTime.minute() );        
        String second = string.valueOf(sysTime.second());
        String year = string.valueOf(sysTime.year());
        
        String strJobName = 'VoiceMailJob-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

        System.schedule(strJobName, strSchedule, new VoiceMailResponseTimeProcessor());

   }			
}