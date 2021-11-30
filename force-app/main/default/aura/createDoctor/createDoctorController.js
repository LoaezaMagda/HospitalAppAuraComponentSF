({
    doInit : function(component, event, helper) {
         var recordId = component.get('v.recordId');
    },
    
    
    handleOnLoad : function(component, event, helper) {
          
    },
    
    handleOnSubmit : function(component, event, helper) {
        var appFromId = component.get("v.recordId");      
        var toastEvent = $A.get("e.force:showToast");
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
                  url: "/lightning/r/Doctor__c/"+ payload.id +"/view"
            });
            urlEvent.fire();
            component.set("v.reloadForm", false);
            component.set("v.reloadForm", true); 
    },
    
    cancelClick : function(c, e, h) {
        var urlEvent = $A.get("e.force:navigateToURL");
           urlEvent.setParams({
              url: "/lightning/o/Doctor__c/list?filterName=Recent"
           });
        urlEvent.fire();
    },
    
    handleOnError : function(c, e, h) {

    }
})