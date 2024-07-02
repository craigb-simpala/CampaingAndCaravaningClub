({
    doInit : function(component, event, helper) {
    	var addressText = component.get('v.inputAddresses');
    	addressText = addressText.trimRight();
    	var addresses = addressText.split('\n');
    	component.set('v.addresses', addresses);
    },

    save : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var selectedAddress = component.get('v.selectedAddress');
        var params = {'recordId':recordId,'address':selectedAddress};
        var setAddress = component.get('c.setAddress');
        setAddress.setParams(params);
        setAddress.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                location.reload();
            }
            else{
                var errorMsg = response.getError()[0].message;
                component.set('v.errors', 'Error: '+errorMsg);

            }
        });
        $A.enqueueAction(setAddress);
    }
})