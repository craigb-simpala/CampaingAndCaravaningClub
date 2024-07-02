({
	
	// Initialise table columns.
	doInit : function(component, event, helper) {
		component.set('v.leadColumns', [
			{label: 'Last Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: {fieldName: 'LastName'}, target: '_blank'}},
			{label: 'Street', fieldName: 'Street', type: 'text'},
			{label: 'City', fieldName: 'City', type: 'text'},
			{label: 'Postcode', fieldName: 'PostalCode', type: 'text'},
			{label: 'Email', fieldName: 'Email', type: 'email'}
			]);

		component.set('v.accountColumns', [
			{label: 'Membership Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: {fieldName: 'Name'}, target: '_blank'}},
			{label: 'Street', fieldName: 'BillingStreet', type: 'text'},
			{label: 'City', fieldName: 'BillingCity', type: 'text'},
			{label: 'Postcode', fieldName: 'BillingPostalCode', type: 'text'},
			{label: 'Membership Number', fieldName: 'Hybrid_Membership_Number__c', type: 'text'},
			{label: 'Membership Status', fieldName: 'Membership_Status__c', type: 'text'},
			{label: 'Email', fieldName: 'Email__c', type: 'email'}
			]);
	},

	// Populate tables with records mathing the provided search criteria.
	search : function(component, event, helper) {

		helper.getRecords(component, event, "findLeads", "leadData");
		helper.getRecords(component, event, "findAccounts", "accountData");

	},

	// Create new lead record with provided details.
	callCreateLead : function(component, event, helper) {
		var action = component.get("c.createLead");
		
		// Set parameters.
		action.setParams({
			"surname" : component.get("v.surname"),
			"postcode" : component.get("v.postcode"),
			"email" : component.get("v.email")
		});

		// Set callback.
		action.setCallback(this, function(response) {
			var state = response.getState();

			// If successful, navigate to newly created record.
			if (state === 'SUCCESS') {
				console.log('Record created successfully.');
				var record = response.getReturnValue();
				var navEvent = $A.get("e.force:navigateToSObject");
				navEvent.setParams({
					"recordId": record.Id
				});
				navEvent.fire();
			
			// If unsuccessful, display error message.
			} else {
				console.log('Record creation failed with state: ' + state);
				var errors = response.getError();
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Whoops!",
					"message": errors[0].message,
					"type": "error",
					"mode": "sticky"
				});
				toastEvent.fire();
			}
		});

		// Enqueue action.
		$A.enqueueAction(action);
	}
})