public class sendEmailAppoitmentBatch implements Database.Batchable<SObject> , Database.Stateful {
    
    EmailTemplate tempToReminder = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName =: 'Recordatorio_Cita' LIMIT 1];
    EmailTemplate tempToConfirm = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName =: 'Confirm_appointment_patient' LIMIT 1];
    
    Date afterToday = Date.today() + 1;
    Date currentDay = Date.today();
    String cancelled = 'cancelled';
    
    List<Appointment__c> appToReminder= new List<Appointment__c>();
	List<Appointment__c> appToConfirm = new List<Appointment__c>();
    
	public Database.QueryLocator start(Database.BatchableContext bc) {//Doctorr__r.Name,Patientt__r.Name
 		return database.getQueryLocator('SELECT Id,Name,Time__c,Patient__r.User__c, Doctor__r.Name,Patient__r.Name,Status__c,Doctor_Email__c,Patient_Email__c,Date__c FROM Appointment__c WHERE Date__c >=:currentDay AND Date__c <=:afterToday AND Status__c !=: cancelled');
    
    }
    //todas las que han sido confirmadas el dia de hoy y que la fecha sea > today()
    //todas donde la fecha sea today+1 y el status null 
    //Todas donde la fecha se today y el status null
    
    public void execute(Database.BatchableContext bc, List<Appointment__c> records) {           
        for(Appointment__c app : records) {
            if((app.Date__c == Date.today()) && app.Status__c == null){ 
                //update status to cancelled if appoitment date equals today
                app.Status__c = 'cancelled';
            }
            else if(Date.today() == (app.Date__c -1) && app.Status__c == null ){
               //add to list appoitments needs to be confirm
               appToConfirm.add(app);
            }else if(Date.today() == (app.Date__c - 1) && app.Status__c == 'confirmed') {
                //add to list appoitments needs to be reminder
               appToReminder.add(app);
            }
            
        }
        update records ;

    }

    public void finish(Database.BatchableContext bc) {
        //send emails
		sendEmail(tempToReminder,appToReminder);
        sendEmail(tempToConfirm,appToConfirm);
    }
    
    private static void sendEmail(EmailTemplate temp, List<Appointment__c> records) {
       
        List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        String urldomain = URL.getSalesforceBaseUrl().toExternalForm();
        
        for(Appointment__c app : records) {
            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
            //toAddresses = new List<String>();
			//toAddresses.add(app.Patient_Email__c);
            //if(app.Status__c!= null && app.Status__c == 'confirmed'){
             //  toAddresses.add(app.Doctor_Email__c); 
            //}
            
            singleMail.setTargetObjectId(app.Patient__r.User__c);
            //singleMail.setToAddresses(toAddresses);
            String subject = temp.Subject;
        	
            String htmlBody = temp.HtmlValue;
            htmlBody = htmlBody.replace('{!Appointment__c.Name}', app.Name);
            htmlBody = htmlBody.replace('{!Appointment__c.Doctor__c.Name}', app.Doctor__r.Name);
            htmlBody = htmlBody.replace('{!Appointment__c.Patient__c.Name}', app.Patient__r.Name);
            htmlBody = htmlBody.replace('{!Appointment__c.Time__c}', String.valueOf(app.Time__c));
            htmlBody = htmlBody.replace('{!Appointment__c.Date__c}', String.valueOf(app.Date__c));
            htmlBody = htmlBody.replace('{!Appointment__c.Link}', urldomain +'/apex/createAppoitment?id='+app.id);
            if(app.Status__c != null) {
                 htmlBody = htmlBody.replace('{!Appointment__c.Status__c}', app.Status__c);
            }else {
                 htmlBody = htmlBody.replace('{!Appointment__c.Status__c}', '');
            }
           
            htmlBody = htmlBody.replace('{!Appointment__c.Id}',app.Id);
            singleMail.setSubject(subject);
            singleMail.setHtmlBody(htmlBody);
            singleMail.saveAsActivity = false;
            mail.add(singleMail);
        }
        
       Messaging.sendEmail(mail);
    }
    
}