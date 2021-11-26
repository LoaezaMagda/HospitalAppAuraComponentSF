public with sharing class AppointmentAuraController {
    public static String currentProfile;
    
	@AuraEnabled
    public static sObject getCurrentUser() {
        currentProfile = getProfile().Name;
        Boolean hasPermission = FeatureManagement.checkPermission('is_Hospital_Admin');
        
        if(currentProfile == 'Doctors'){
            Doctor__c currentDoc = new Doctor__c();
            currentDoc = [SELECT Id,Name FROM Doctor__c WHERE User__c =: UserInfo.getUserId() Limit 1];
            return currentDoc;
        }else if(currentProfile == 'Patients'){
            Patients__c currentPat = new Patients__c();
            currentPat = [SELECT Id,Name FROM Patients__c WHERE User__c =: UserInfo.getUserId() Limit 1];
            return currentPat;
        }else if(hasPermission) {
            User currentUser = new User();
            currentUser = [SELECT Name FROM User WHERE Id =: UserInfo.getUserId() Limit 1];
            return currentUser;
        } else {
            return null;
        }
    }
    
    
   @AuraEnabled
    public static Profile getProfile(){
      try {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        return profile;
      } catch(Exception e) {
        throw new AuraHandledException(e.getMessage()); 
      }
    }

}