({
    /*
        callApex_h ()
        --
        Util method to call an Apex function and assign the response
    */
    callApex_h: function (component, apexMethod, methodParams, assignTo, methodName, callback) {

        console.log ('Running Apex method: \'' + apexMethod + '\' from Javascript method: \'' + methodName + '\' with params: \'' + methodParams + '\'');

        // Set the method to call
        var action = component.get ('c.' + apexMethod);

        // Set the parameters
        if (methodParams) {action.setParams (methodParams);}

        // Handle the callback
        action.setCallback (this, (res) => {
            var wasSuccess;
            var response;

            if (res.getState () === 'SUCCESS') {
                // Assign the obtained value from Apex
                component.set ('v.' + assignTo, res.getReturnValue ());
                wasSuccess = true;
                response = res.getReturnValue ();
            } else {
                // Display any errors that are returned
                this.handleErrors_h (response.getError (), methodName);
                wasSuccess = false;
            }

            // Return whether or not the execution was a success
            return callback ({'wasSuccess': wasSuccess, 'response': response});

        });

        // Queue the action
        $A.enqueueAction (action);

    },
        
    /*
        redirect ()
        --
        Redirect to newly created Account
    */
    redirect : function(component, event, accountId){
        // Redirect the user to the new Account, created from the conversion process
        var redirectObject = $A.get ('e.force:navigateToURL');
        redirectObject.setParams ({
            'url': '/' + accountId,
            'isredirect': 'true'
        });
            
       redirectObject.fire ();
    },
    /*
        handleErrors_h ()
        --
        Util method to display error messages returned from actions
    */
    handleErrors_h: function (errors, methodName) {
        for (var i = errors.length - 1; i >= 0; i--)
            console.log ('error from method : ' + methodName + ' - ' + errors[i].message);
    }
})