trigger NoteEdit on Note (before delete, before update) {
	if (Trigger.isUpdate) {
		for (Note n : Trigger.new) {
			if (Datetime.now() > n.CreatedDate.addDays(14)) {
	            n.addError('Note cannot be modified after two weeks from created date.');
	        }
    	}
	} else { //isDelete
		for (Note n : Trigger.old) {
			if (Datetime.now() > n.CreatedDate.addDays(14)) {
	            n.addError('Note cannot be deleted after two weeks from created date.');
	        }
    	}
	}
}