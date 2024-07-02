({
	doInit : function(component, event, helper){
		var recordId = component.get('v.recordId');
		helper.callApex_h(component,'buildXMLBody',{'recordId':recordId},'xml','Set request body',function(result){
            
    	});

        helper.callApex_h(component,'getAllowedPaymentTypes',{'recordId':recordId},'','',function(result){
            var options = [];
            for(var i=0;i<result.response.length;i++){
                options.push({'label':result.response[i],'value':result.response[i]});
            }
            component.set('v.paymentTypeOptions', options);
        });

        helper.callApex_h(component,'getEndpoint',undefined,'endpoint','Get verifone endpoint',function(result){

        });


	},

    next : function(component, event, helper) {
    	var paymentType = component.get('v.selectedPaymentType');
    	console.log('pt: ',paymentType);
    	component.set('v.screen', 'club-product');
    },

    back : function(component, event, helper){
    	component.set('v.screen','payment-type');
    },

    save : function(component, event, helper){
   		var recordId = component.get('v.recordId');
        var selectedPaymentType = component.get('v.selectedPaymentType');
    	var errors = '';
        var paymentDetails;

        if(selectedPaymentType == 'Direct Debit'){
            paymentDetails = [];
            var accountName = component.get('v.accountName');
            var accountNumber = component.get('v.accountNumber');
            var sortCode = component.get('v.sortCode');
            paymentDetails.push(accountName);
            paymentDetails.push(accountNumber);
            paymentDetails.push(sortCode);
            if(accountName.length==0){
                errors += 'Please enter an Account name! \n';
            }
            else if(accountName.length>18){
                errors += 'Account name too long! \n';
            }
            if(accountNumber.length==0){
                errors += 'Please enter an Account number! \n';
            }
            else if(accountNumber.length<8){
                errors += 'Account number too short! \n';
            }
            else if (accountNumber.length>10) {
                errors += 'Account number too long! \n';
            }

            if(sortCode.length==0){
                errors += 'Please enter a sort code! \n';
            }
            else if(sortCode.length!=6){
                errors += 'Sort code must be 6 digits! \n';
            }
        }

        if(errors==''){
            var save = component.get('c.saveNewMembershipBillingDetails');
            save.setParams({'recordId':recordId,'paymentMethod':selectedPaymentType,'paymentDetails':paymentDetails});
            save.setCallback(this, (res) => {
                location.reload();
            });
            $A.enqueueAction(save);  
        }
        
        component.set('v.errors', errors);
        
    	
    	console.log('details: ',accountName+' '+accountNumber+' '+sortCode);
    },

    callout : function(component, event, helper){
        var endpoint = component.get('v.endpoint');
        var xml = component.get('v.xml'); 
        let testContainer = component.find("testContainer");
        $A.util.removeClass(testContainer, "slds-hide");
        
        // Submit the form
        $('#paymentFrame').submit ();
    }
})