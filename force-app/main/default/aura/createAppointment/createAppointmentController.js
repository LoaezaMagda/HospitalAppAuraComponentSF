({
    doInit : function(component, event, helper) { 
        var recordId = component.get('v.recordId');
		var profileName;
        
        helper.getObjectInfo(component);
        var action = component.get("c.getProfile");
        
        action.setCallback(this, function(response) {
          var state = response.getState();
          if(state == "SUCCESS" && component.isValid()){
            var result = response.getReturnValue();
            component.set("v.profile", result);
            profileName = result.Name;
				var  x = component.find("sts");
              if(recordId == undefined && profileName == 'Patients') {
                  component.set('v.doctorDisabled',false);    
              }else if(recordId != undefined && profileName == 'Patients'){
                  component.set('v.doctorDisabled',true);
              }else if(recordId == undefined && profileName == 'Doctors'){
                  component.set('v.patientDisabled',false);
              }else if(recordId != undefined && profileName == 'Doctors'){
                  component.set('v.patientDisabled',true);
              }              
           }else{
             console.error("fail:" + response.getError()[0].message); 
            }
        });
        $A.enqueueAction(action);

    },
    handleOnLoad : function(component, event, helper) {
          
    },
      
    handleOnSubmit : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var appFromId = component.get("v.idapp");      
        
        if(appFromId != undefined && appFromId != '') {
            toastEvent.setParams({
                "title": "Success!",
                "message": "The record has been updated successfully."
            });
            toastEvent.fire();            
        }else {
                toastEvent.setParams({
                "title": "Success!",
                "message": "The record has been saved successfully."
                });
                toastEvent.fire();
        }

    },
      
    handleOnSuccess : function(component, event, helper) {
           var payload = event.getParams().response;
            var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  url: "/lightning/r/Appointment__c/"+ payload.id +"/view"
            });
            urlEvent.fire();
            component.set("v.reloadForm", false);
            component.set("v.reloadForm", true); 
        
    },
      
    handleOnError : function(component, event, helper) {
        
		component.set("v.showErrors",true);
        component.set("v.errorMessage",'Error Was occurred');
    },
    
    validateDate : function(c, e, h) {
       var  dateField = c.find("date").get("v.value");  
       var dayFromDate = $A.localizationService.formatDate(dateField, "EEEE");
       var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
       var dateSelected = $A.localizationService.formatDate(dateField, "YYYY-MM-DD");
       if(dayFromDate == 'Sunday' || dayFromDate == 'Saturday') {
          c.set("v.showErrors",true);
          c.set("v.errorMessage",'Date ' + dateField + ' invalid, Days only can be from Monday to Friday');         
       	  c.set('v.isDisabled',true);
       }
       else if(dateSelected < today ){
          c.set("v.showErrors",true);
          c.set("v.errorMessage",'Date ' + dateField + ' invalid, Date cannot be less than today');         
       	  c.set('v.isDisabled',true);
       }
       else {
          c.set("v.showErrors",false);
          c.set('v.isDisabled',false);
       }
	},
    
    validateTime : function(c, e, h) {
        var timeField = c.find("time").get("v.value");  
        if(timeField >= '08:00:00' && timeField <= '20:00:00.000') {
            c.set("v.showErrors",false);
            c.set('v.isDisabled',false);
        }else{
          c.set("v.showErrors",true);
          c.set("v.errorMessage",'Time ' + timeField + ' invalid, Available time from 8:00 to 20:00 hours'); 
       	  c.set('v.isDisabled',true);
        }
	},
    cancelClick : function(c, e, h) {
        var urlEvent = $A.get("e.force:navigateToURL");
           urlEvent.setParams({
              url: "/lightning/o/Appointment__c/list?filterName=Recent"
           });
        urlEvent.fire();
    }
})