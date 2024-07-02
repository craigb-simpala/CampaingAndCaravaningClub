({
	getRecords : function(component, event, apexMethod, attrToSet) {
		var action = component.get("c." + apexMethod);
		
		// Set parameters.
		action.setParams({
			"surname" : component.get("v.surname"),
			"postcode" : component.get("v.postcode"),
			"email" : component.get("v.email")
		});

		// Set callback.
		action.setCallback(this, function(response) {
			var state = response.getState();
			console.log(state);
			
			// If successful, set the returned records to the specified attribute.
			if (state === "SUCCESS") {
				var records = response.getReturnValue();
				records.forEach(function(record) {
					record.linkName = '/' + record.Id;
				})
				component.set("v." + attrToSet, records);
			}
		});

		// Enqueue action.
		$A.enqueueAction(action);
	}
})