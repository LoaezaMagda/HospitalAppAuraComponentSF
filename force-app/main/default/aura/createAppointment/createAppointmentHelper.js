({
		getObjectInfo : function(component) {
            var action = component.get("c.getCurrentUser");
            console.log('ACTION' + action);
            var self = this;
            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();
                console.log('state' + state)
                if (component.isValid() && state === "SUCCESS") {
                    var result = actionResult.getReturnValue();
                    component.set("v.user", result);
                    console.log('RESULT' + result)
                }
            });
            $A.enqueueAction(action);
		},
    
        showNotice : function(component,event) {
            component.find('notifyId').showNotice({
                "variant": "error",
                "header": "An Internal Server has occured!",
                "message": "There was a problem updating the Date it only can be from monday to friday.",
                closeCallback: function() 
                {
                    $A.get('e.force:refreshView').fire();
                }
            });
        }
})