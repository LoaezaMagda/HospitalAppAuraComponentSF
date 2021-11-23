public with sharing class AppointmentAuraController {
    
    public static String currentProfile;
    
	@AuraEnabled
    public static sObject getCurrentUser() {
        currentProfile = getProfileName().Name;
        if(currentProfile == 'Doctors'){
            Doctor__c currentDoc = new Doctor__c();
            currentDoc = [SELECT Id,Name, User__r.Email FROM Doctor__c WHERE User__c =: UserInfo.getUserId() Limit 1];
            return currentDoc;
        }else if(currentProfile == 'Patients'){
            Patients__c currentPat = new Patients__c();
            currentPat = [SELECT Id,Name,User__r.Email FROM Patients__c WHERE User__c =: UserInfo.getUserId() Limit 1];
            return currentPat;
        }else if(currentProfile == 'Admin Test' || currentProfile == 'System Administrator'){
            User currentUser = new User();
            currentUser = [SELECT Name FROM User WHERE Id =: UserInfo.getUserId() Limit 1];
            return currentUser;
        }else{
            return null;
        }
    }
    
    
    
    /*@AuraEnabled
    public static ProfileInfo getProfileInfo(){
      try{
        ProfileInfo info = new ProfileInfo();
        info.Name = getProfileInfo().Name;
        return info;
      }catch(Exception e){
         throw new AuraHandledException(e.getMessage()); 
      }
     
    } */
   @AuraEnabled
    public static Profile getProfileName(){
      try{
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
        return profile;
      }catch(Exception e){
        throw new AuraHandledException(e.getMessage()); 
      }
    }

    
   /* public class ProfileInfo{
      @AuraEnabled
      public String Id {get;set;}
      @AuraEnabled
      public String Name {get;set;}
    }*/
}