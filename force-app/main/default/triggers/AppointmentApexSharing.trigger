trigger AppointmentApexSharing on Appointment__c (after insert, after update) {
    
    if(!AppointmentTriggerHandler.isFirstTime) {
        return ;
    }
    AppointmentTriggerHandler.isFirstTime = false;
    
        if(trigger.isUpdate && trigger.isAfter) {
           for(Appointment__c item : trigger.new) {
                 Appointment__c oldApp = Trigger.oldMap.get(item.id);
                 if(oldApp.Patient__c != item.Patient__c) {
                    item.addError('Patient cannot be change');
                 }else if(oldApp.Doctor__c != item.Doctor__c ) {
                    item.addError('Doctor cannot be change');
                 }else if(oldApp.Status__c == 'cancelled' || oldApp.Status__c == 'confirmed' ) {
                    item.addError('Status cannot be change');
                 }
                }
         }
    
        if(trigger.isInsert) {
            Profile profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() Limit 1];
            Boolean hasPermission = FeatureManagement.checkPermission('is_Hospital_Admin');
            //List<Appointment__c> appList = new List<Appointment__c>();
            //appList = [SELECT Id,Patient__r.User__c, Doctor__r.User__c FROM Appointment__c WHERE Id IN: Trigger.new];
            Map<Id,Appointment__c> appMap = new Map<Id,Appointment__c>([SELECT Id,Patient__r.User__c, Doctor__r.User__c, Doctor__r.User__r.Email,Patient__r.User__r.Email FROM Appointment__c WHERE Id IN: Trigger.new]);
            List<Appointment__Share> appSrh = new List<Appointment__Share>();
            List<Appointment__c> app = new List<Appointment__c>();
            Appointment__Share doctorShr;
            Appointment__Share patientShr;
                for(Appointment__c item : trigger.new) {
                    Appointment__c appToUpdate = new Appointment__c();
                    appToUpdate.Doctor_Email__c = appMap.get(item.Id).Doctor__r.User__r.Email;
                    appToUpdate.Patient_Email__c = appMap.get(item.Id).Patient__r.User__r.Email;
                    appToUpdate.Id = item.Id;
                    app.add(appToUpdate);
                    
                    doctorShr = new Appointment__Share();
                    patientShr = new Appointment__Share();
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
                    }else if(hasPermission){
                        System.debug('HAS PERMISSION' + hasPermission);
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
            
            insert appSrh;
            update app;
        
        }
}