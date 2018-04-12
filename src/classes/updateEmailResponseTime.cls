global class updateEmailResponseTime {
	
	public Task[] tasks = new List<Task>();
	public Task[] update_tasks = new List<Task>();
	public Map<String, Integer> monthsMap = new Map<String, Integer>{
  		'Jan' => 1,
  		'Feb' => 2,
 	    'Mar' => 3,
   		'Apr' => 4,
    	'May' => 5,
   		'Jun' => 6,
    	'Jul' => 7,
     	'Aug' => 8,
     	'Sep' => 9,
      	'Oct' => 10,
      	'Nov' => 11,
      	'Dec' => 12
	};
	global updateEmailResponseTime(){
		tasks = [select Id, email_Received_date__c, Description, subject from task where createddate = Last_n_Days:7
 						and Subject like '→ Email: Re:%' and email_Received_date__c = null];
	
		
		for(Task task: tasks){
	  	  	try{
		        //system.debug(task.Description);
		        String comments = task.Description;
		        //system.debug(comments);
		        String substring = '> wrote:';
		        Integer result = comments.IndexOf(substring);
		        //system.debug(result);
		        comments = comments.substring(0, result);
		        //system.debug(comments);
		        comments = comments.substring(0, comments.lastIndexOf(','));
		        //system.debug(comments);
		        String rec_time = comments.substring(comments.lastIndexOf('at')+3, comments.length());
		        //system.debug(rec_time);
		        String year = comments.substring(comments.lastIndexOf(',')+2, comments.lastIndexOf(',')+6);
		        //system.debug(year);  
		        comments = comments.substring(0, comments.lastIndexOf(','));
		        String rec_date = comments.substring(comments.lastIndexOf(',')+2, comments.length());
		        ////system.debug(rec_date);
		        String[] parts = rec_date.split(' ');
		        String month = parts[0];
		        String day = parts[1];
		        //system.debug(month);
		       // system.debug(day);
		        String date_format = day+'/'+ monthsMap.get(month) +'/'+year+' '+rec_time;
		        //system.debug(date_format);
		        Datetime dt = DateTime.parse(date_format);
		        //system.debug(dt);
		        task.email_Received_date__c = dt;
		        
		        if(dt.hour() >= 17 && dt.hour()<=23){
		        	task.Email_Received_Date_Business_Hour__c = DateTime.newInstance(dt.year(), dt.month(), dt.day()+1, 8, 0, 0);
		        }else if(dt.hour() >= 0 &&  dt.hour()<8){
		        	task.Email_Received_Date_Business_Hour__c = DateTime.newInstance(dt.year(), dt.month(), dt.day(), 8, 0, 0);
		        }else{
		        	task.Email_Received_Date_Business_Hour__c = dt;
		        }
		        
		        update_tasks.add(task);
	        }catch(Exception e){
	        	system.debug(e.getMessage());
	    	}
		}
		system.debug(update_tasks.size());
		update(update_tasks);
	}
}