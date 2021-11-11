global class callSendEmailAppoitmentBatch implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        sendEmailAppoitmentBatch app = new sendEmailAppoitmentBatch();
		Database.executeBatch(app);
    }	
    
}