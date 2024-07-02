@RestResource(urlMapping='/Payment/*')
global class PaymentRest {

        global class Error{
            global integer id;
            global String Message;
        }

        global class Result{
            global String status;
            global List<Error> Errors;
            global String MemNumber;
            global Date renewalDate;
        }

        global class Payment{
            global String PaymentType;
            global string SortCode;
            global string AccountNumber;
            global string PayeeName;
            global string AuthCode;
            global string token;
        }

    @HttpPost
    global static Result paymentDetails(Payment payment){
        RestRequest req = RestContext.request;
        String ref = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Result res = new Result();

        PaymentSuccessController ps = new PaymentSuccessController();
        
        if(ref.startswith('006')){
            Lead l = new Lead(Company =ref,lastname=ref);
            ref=l.id;
        }
        if(ref !=null && (ref.startswith('00Q')) )
        {
            
            Lead theLead = [select id,company,name from Lead where id = :ref];
                    
            ps.ref = ref;
            
            if(theLead.company.startswith('006') && payment.PaymentType=='Direct Debit'){
                ps.skipDDpay=true;
            }
            
            
            theLead.Payment_Method__c=payment.PaymentType;
            theLead.Bank_Account_Number__c = payment.AccountNumber;
            if(payment.SortCode!=null)theLead.Sort_Code__c = payment.SortCode.replaceAll('[^0-9]', '');
            theLead.Bank_Account_Name__c = payment.PayeeName;
            ps.acode=payment.AuthCode;
            ps.tokenid=payment.token;
            ps.result='Success';
            update theLead;
            system.debug(ps.acode);        
            system.debug(ps.result);        
            system.debug(ps.tokenid);        
            system.debug(ps.ref); 
        
            PageReference p = ps.ConvertLead();
            system.debug(p);
            system.debug(p.getUrl());
            id Accid = p.getUrl().removeStart('/');
            Account a =[select id,hybrid_membership_number__c,renewal_date__c from Account where id=:accid];
            res.MemNumber = a.hybrid_membership_number__c;
            res.RenewalDate = a.renewal_date__c;
        }      
        return res; 
        
    }

}