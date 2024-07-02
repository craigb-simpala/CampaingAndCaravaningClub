({
    /*
        afterScriptsLoaded_c
        --
        On load of external resources
    */
    afterScriptsLoaded_c : function (component, event, helper) {
        $(() => {
            console.log ('LOADED JQUERY');
        });
    },

    /*
        init_c
        --
        On load of the DOM
    */
    init_c : function (component, event, helper) {
        console.log ('RUNNING INIT_C');
        helper.callApex_h (component, 'returnSalesWrapper_a', {recordId: component.get ('v.recordId')}, 'salesWrapper', 'init_c', (res) => {});
    },

    /*
		handleDirectDebitClick_c ()
		--
		Run on click of the Direct Debit button
	*/
    handleDirectDebitClick_c : function (component, event, helper) {
        const accountName = component.find("accountName").get("v.value");
        const accountNumber = component.find("accountNumber").get("v.value");
        const sortCode = component.find("sortCode").get("v.value");
        
        const params = {
            recordId: component.get ('v.recordId'),
            "accountName": accountName,
            "accountNumber": accountNumber,
            "sortCode": sortCode
        };
        console.log (params);
        
        helper.callApex_h (component, 'autoConvertDirectDebit_a', params, 'convertStatus', 'handleDirectDebitClick_c', (res) => {
            
            if (res.response == '0') return;
            helper.redirect(component, event, res.response);
        });
    },
          
    
    /*
        handleCashChequeClick_c ()
        --
        On click of the Cash/Cheque button
    */
    handleCashChequeClick_c : function(component, event, helper){
        const params = {
            recordId: component.get ('v.recordId'),
            paymentMethod: "Cash/Cheque"
        }
       
    	helper.callApex_h (component, 'autoConvertCashCheque_a', params, 'convertStatus', 'handleCashChequeClick_c', (res) => {
        	if (res.response == '0') return;
            helper.redirect(component, event, res.response);
        });
        
    },

    /*
        submitForm_c ()
        --
        On click of the select button, submit the html form
    */
    submitForm_c : function (component, event, helper) {
        const params = {
            recordId: component.get ('v.recordId'),
            paymentMethod: "Debit/Credit Card"
        }

        helper.callApex_h (component, 'updateLead_a', params, 'convertStatus', 'submitForm_c', (res) => {
            if (res.response == '0') return;

            // Show the iframe the form will be displayed in
            $('#formContainer').show (1000, () => {
                $('#nonjava').submit ();
            });
            $('#formSubmitButton').hide (1000);
        });
    }
})