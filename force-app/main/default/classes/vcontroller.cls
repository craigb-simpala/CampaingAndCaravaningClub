public with sharing class vcontroller{
    
         public ApexPages.StandardController stdCntrlr {get; set;}
            public vcontroller(ApexPages.StandardController controller) {
            if (!Test.isRunningTest())
            {
                controller.addFields(new List<String>{'Membership_Code__c'});
            }
            stdCntrlr = controller;
            this.lea = (Lead) controller.getRecord();
        }
        
        public lead lea {get;set;}
        
        public pagereference validate(){
            //l = [select id,name,membership_code__c from lead where id='00Q26000002zCFo'];
            Type t;
            t = Type.forName('VI'+lea.membership_code__c);
            if(t==null)t = Type.forName('VIDefault');
            ValidationInterface v = (ValidationInterface)t.newInstance();
            v.validate(lea);
            system.debug(lea);
            return null;
            
        }

}