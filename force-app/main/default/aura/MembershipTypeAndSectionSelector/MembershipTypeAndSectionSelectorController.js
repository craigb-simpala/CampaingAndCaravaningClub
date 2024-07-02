({  

    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var selectedType;
        var result  = {};
        console.log('recordId: ' + recordId)

        helper.callApex_h(component,'getSelectedMembershipType',{'recordId':recordId},'selectedMembershipType','Get Membership Type of Record', function(result){
            console.log('here!')
            if (result.wasSuccess === true) {
                selectedType = result.response.Name;
                helper.callApex_h(component,'getMembershipTypes',null,'membershipTypes','Get Membership Types', function(innerResult){
                    if (innerResult.wasSuccess === true) {
                        var names = [];
                        for(var i =0;i<innerResult.response.length;i++){
                            var name = innerResult.response[i].Name;
                            names.push({'name':name,'price':innerResult.response[i].Price_for_Initial_Picklist__c});
                            if(selectedType==name){
                                component.set('v.sectionsAllowed', innerResult.response[i].Sections_Allowed__c);
                            }
                        }
                        component.set('v.membershipTypeNames', names);
                    }
                    else{
                        console.log('ERROR PROCESSING MEMBERSHIP TYPES');
                    }
                });
            }
            else{
                console.log('ERROR PROCESSING SELECTED MEMBERSHIP TYPE',selectedType);
            }

        });

        var sectionsResult = {}
        helper.callApex_h(component,'getSections',{'recordId':recordId},'sections','Get All Sections', function(result){
            if (result.wasSuccess === false) {
                console.log('ERROR RETRIEVING SECTIONS');
            }
        });

    },

    next : function(component, event, helper) {
        component.set('v.errors', '');
        component.set('v.membershipTypeIsSelected', true);

    },

    back : function(component, event, helper) {
        component.set('v.errors', '');
        component.set('v.membershipTypeIsSelected', false);

    },

    save : function(component, event, helper) {
        console.log('component: ' + component);
        console.log('selectedType: ' + selectedType)

        var recordId = component.get('v.recordId');
        var selectedType = component.get('v.selectedMembershipType');
        var sectionsAllowed = component.get('v.sectionsAllowed');
        var sections = component.get('v.sections');
        var save = component.get('c.saveChanges');
        var params;
        if(sectionsAllowed==true){
            params = {'recordId':recordId,'sections':sections,'membershipType':selectedType.Name};
        }
        else{
            params = {'recordId':recordId,'sections':null,'membershipType':selectedType.Name};
            
        }
        save.setParams(params);
        save.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                location.reload();
            }
            else{
                var errorMsg = response.getError()[0].message;
                component.set('v.errors', 'ERROR: '+errorMsg);
            }
        });
        $A.enqueueAction(save);

    },

    getSectionsAllowed: function(component, event, helper) {
        console.log('component: ' + component);

        var membershipTypes = component.get('v.membershipTypes');
        var selected = component.get('v.selectedMembershipType');
        for(var i =0;i<membershipTypes.length;i++){
            var string = JSON.stringify(membershipTypes[i]);
            var json = JSON.parse(string);
            if(selected.Name==json.Name){
                component.set('v.sectionsAllowed', json.Sections_Allowed__c);
            }
            
        }
    }


})