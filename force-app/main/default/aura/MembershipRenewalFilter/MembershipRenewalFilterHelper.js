({
	callApex : function(component, event, apexMethod, params, callback) {
        console.log("callApex runs");
		let action = component.get("c." + apexMethod);
        
        if(params){
            action.setParams(params);
        }

        action.setCallback(this, (response) => {
            let state = response.getState();
			
            if(state === "SUCCESS"){
            	let responseValue = response.getReturnValue();
            	component.set("v.returnMsg", responseValue);
            	callback(responseValue);
        	}
        });
        
        $A.enqueueAction(action);
	},

    redirect : function(component, event){
        this.callApex(component, event, "doNonRenewalContinue", {recordId: recordId}, () => {

            // redirect to Renew Membership VFP
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/apex/RenewMembership?id="+recordId,
                "isredirect": "true"
            });
            urlEvent.fire();
        });
    }
})