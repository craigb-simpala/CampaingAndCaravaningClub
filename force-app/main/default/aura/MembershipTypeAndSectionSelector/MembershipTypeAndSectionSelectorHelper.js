({
    callApex_h: function(component, apexMethod, methodParams, assignTo, methodName, callback) {
      console.log('here!!')

      // Set the method to call
      var action = component.get('c.'+apexMethod);

      // Set the parameters
      if(methodParams) {
          action.setParams(methodParams);
      }
      // Handle the callback
      action.setCallback(this, (res) => {
          var wasSuccess = res.getState() === 'SUCCESS';
          var response = res.getReturnValue();

          if(wasSuccess) {
              // Assign the obtained value from Apex
              component.set('v.' + assignTo, response);
          } else {
              // Display any errors that are returned
              this.handleErrors_h(response.getError(), methodName);
          }

          // Return whether or not the execution was a success
          return callback({
              'wasSuccess': wasSuccess,
              'response': response
          });

      });

      // Queue the action
      $A.enqueueAction(action);

  },
	  /*
	      handleErrors ()
	      --
	      Util method to display error messages returned from actions
	*/
	  handleErrors_h: function(errors, methodName) {
	      for (var i = errors.length - 1; i >= 0; i--)
	          console.log('error from method : ' + methodName + ' - ' + errors[i].message);
	  } 
})