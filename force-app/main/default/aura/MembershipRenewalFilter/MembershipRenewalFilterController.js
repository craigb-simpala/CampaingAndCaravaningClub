({
    init : function(component, event, helper) {
        
    },

	filterMembership : function(component, event, helper) {
        console.log("filterMembership runs");
        helper.callApex(component, event, "doFilterMembership", {recordId: component.get("v.recordId")}, (responseValue) => {
            
            // set attr to reveal continue button
            console.log('responseValue '+responseValue);
            if(responseValue && responseValue.includes("Non-Renewer")){
            	component.set("v.showBatchContinueButton", true);
                component.set("v.showContinueButton", false);
                                console.log('1');

        	}
            else{
                console.log('2');
                component.set("v.showContinueButton", true);
                component.set("v.showBatchContinueButton", false);
            }
        });
	},
    
    nonRenewalContinue : function(component, event, helper){
        console.log("continue runs");
        let recordId = component.get("v.recordId");
        helper.callApex(component, event, "doNonRenewalContinue", {recordId: recordId}, () => {

            // redirect to Renew Membership VFP
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            	"url": "/apex/RenewMembership?id="+recordId,
            	"isredirect": "true"
            });
            urlEvent.fire();
        });
    },

    renewalContinue : function(component, event, helper){
        let recordId = component.get("v.recordId");
        console.log('record id: '+recordId);
        helper.callApex(component, event, "redirect", {}, () => {

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