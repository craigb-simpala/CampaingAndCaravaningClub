({
    /*
		createBACSRecord ()
		--
		Util method to create BACS record
    */
    createBACSRecord : function(component, apexMethod, methodParams, assignTo, callback){
        this.callApex_h(component, apexMethod, methodParams, assignTo, callback);
    },
    
	/*
        callApex_h ()
        --
        Utility method to queue Apex methods for run and handling the result
    */
    callApex_h : function(component, apexMethod, methodParams, assignTo, callback) {
        // Set the method to call
        let action = component.get("c." + apexMethod);

        // Set the parameters
        if (methodParams){
            action.setParams(methodParams);
        } 

        // Handle the callback
        action.setCallback(this, (response) => {
            let state = response.getState();
            
            let wasSuccess = state === "SUCCESS";
            
            if(wasSuccess) {
                // Assign the obtained value from Apex
                if(assignTo){
                    component.set("v." + assignTo, response.getReturnValue());
                }
                
            } else {
                // Display any errors that are returned
                this.handleErrors_h (response.getError(), apexMethod.toString());
            }

            // Return whether or not the execution was a success
            return callback(wasSuccess);
        });

        // Queue the action
        $A.enqueueAction (action);

    },

    /*
		handleErrors ()
		--
		Util method to display error messages returned from actions
    */
    handleErrors_h : function (errors, methodName) {
        for(let error of errors){
            console.log ("error: " + error.message + " from method: " + methodName);
        }	
    }
        
    
})