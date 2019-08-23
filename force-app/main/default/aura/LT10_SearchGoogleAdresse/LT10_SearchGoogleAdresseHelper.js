({
	callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {        
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                //console.log(response.getReturnValue());
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    resetAddress : function(component){
		component.set("v.city", null);	 
		component.set("v.country", null);
		component.set("v.latitude", null);	 
		component.set("v.postalCode", null);
		component.set("v.street", null);
		component.set("v.latitude", null);	 
		component.set("v.longitude", null);
    }
})