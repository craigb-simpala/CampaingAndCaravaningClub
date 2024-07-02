({
    createARUDDRecord : function(component, event, helper) {
        
        // create BACS record
        helper.createBACSRecord(component, "createBACSReport", {reportType: "ARUDD"}, "BACSRecordId", (wasSuccess) => {
            console.log("BACS record creation successful: " + wasSuccess);
            component.set("v.updateResult", '');
            component.set("v.reportType", "ARUDD");
        });
        
    },
            
    createADDACSRecord : function(component, event, helper) {
        
        // create BACS record
        helper.createBACSRecord(component, "createBACSReport", {reportType: "ADDACS"}, "BACSRecordId", (wasSuccess) => {
            console.log("BACS record creation successful: " + wasSuccess);
            component.set("v.updateResult", '');
            component.set("v.reportType", "ADDACS");
        });
        
    },
           
    createAUDDISRecord : function(component, event, helper) {
        
        // create BACS record
        helper.createBACSRecord(component, "createBACSReport", {reportType: "AUDDIS"}, "BACSRecordId", (wasSuccess) => {
            console.log("BACS record creation successful: " + wasSuccess);
            component.set("v.updateResult", '');
            component.set("v.reportType", "AUDDIS");
        });
        
    },
    
	updateRejectedTransactions_c : function(component, event, helper) {
        helper.callApex_h(component, "updateRejectedTransactions", 
            {
                BACSRecordId: component.get("v.BACSRecordId"),
                reportType: component.get("v.reportType")
            }, 
            "updateResult", (wasSuccess) => {
            
            console.log("XML document upload successful: " + wasSuccess);
            component.set("v.BACSRecordId", "null");
            
            // show toast to alert user of successful upload
            var uploadedFiles = event.getParam("files");
            var fileName = uploadedFiles[0].name;
            var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
            	"type": "success",
                "title": "Success!",
                "message": "File "+fileName+" uploaded successfully."
        	});
        	toastEvent.fire();
        });   
	}
})