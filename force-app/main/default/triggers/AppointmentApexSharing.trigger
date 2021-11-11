trigger AppointmentApexSharing on Appointment__c (after insert, after update) {

    if(trigger.isUpdate && trigger.isAfter) {
          	for(Appointment__c item : trigger.new) {
                Appointment__c oldApp = Trigger.oldMap.get(item.id);
                if(oldApp.Patient__c != item.Patient__c) {
                    item.addError('Patient can not change');
                }else if(oldApp.Doctor__c != item.Doctor__c ) {
                    item.addError('Doctor can not change');
                }else if(oldApp.Status__c == 'cancelled' || oldApp.Status__c == 'confirmed' ) {
                    item.addError('Status can not change');
                }
         	}
        

        
    }
    
    if(trigger.isInsert && trigger.isUpdate) {
        Profile profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() Limit 1];
        List<Appointment__c> appList = new List<Appointment__c>();
        appList = [SELECT Id,Patient__r.User__c, Doctor__r.User__c FROM Appointment__c WHERE Id IN: Trigger.new];
        Map<Id,Appointment__c> appMap = new Map<Id,Appointment__c>([SELECT Id,Patient__r.User__c, Doctor__r.User__c FROM Appointment__c WHERE Id IN: Trigger.new]);
        List<Appointment__Share> appSrh = new List<Appointment__Share>();
        Appointment__Share doctorShr;
        Appointment__Share patientShr;
            for(Appointment__c item : trigger.new) {
                doctorShr = new Appointment__Share();
                patientShr = new Appointment__Share();
                //aqui debo compartir si el doctor esta logueado mapear el del paciente
                //doctorShr.UserOrGroupId = appMap.get(item.Id).Patient__r.User__c;
                //doctorShr.UserOrGroupId = appMap.get(item.Id).Doctor__r.User__c;
                if(profileName.Name == 'Patients') {
                    doctorShr.ParentId = item.Id;
                    doctorShr.UserOrGroupId = appMap.get(item.Id).Doctor__r.User__c;
                    doctorShr.AccessLevel = 'edit';
                    //System.debug('patient id' + trigger.newMap.get(item.Id).Doctor__r.User__c );
                    //recordShr.UserOrGroupId = trigger.newMap.get(item.Id).Doctor__r.User__c;
                    appSrh.add(doctorShr);
                }else if(profileName.Name == 'Doctors') {
                    patientShr.ParentId = item.Id;                    
                    patientShr.UserOrGroupId = appMap.get(item.Id).Patient__r.User__c;
                    patientShr.AccessLevel = 'edit';
                    appSrh.add(patientShr);
                    //recordShr.UserOrGroupId = trigger.newMap.get(item.Id).Patient__r.User__c;
                }else if(profileName.Name == 'System Administrator'){
                     doctorShr.ParentId = item.Id;
                     patientShr.ParentId = item.Id;
                     doctorShr.UserOrGroupId = appMap.get(item.Id).Doctor__r.User__c;
                     patientShr.UserOrGroupId = appMap.get(item.Id).Patient__r.User__c;
                     doctorShr.AccessLevel = 'edit';
                     patientShr.AccessLevel = 'edit';
                	 appSrh.add(doctorShr);
                     appSrh.add(patientShr);
                }
            }
                        
       
        
        //System.debug('LIST' + appSrh);
        insert appSrh;

        /*Database.SaveResult[] lsr = Database.insert(appSrh);
        
        // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                               &&  err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.
                    trigger.newMap.get(appSrh[i].ParentId).
                      addError(
                       'Unable to grant sharing access due to following exception: '
                       + err.getMessage());
                }
            }
            i++;
        }   */
    }
}