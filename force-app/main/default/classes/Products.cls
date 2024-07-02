@RestResource(urlMapping='/Products/*')
global class  Products {

        global class Error{
            global integer id;
            global String Message;
        }

        global class Price {
            Global String PaymentType;
            global Date StartDate;
            global Date EndDate;
            global Decimal Price;
            global Decimal JoiningFee;
            global String PriceDescription;
            global String PricePrompt;
            global boolean ShowinWeb;
            global String PriceDetail;
        }
        global class Result{
            global String status;
            global List<Error> Errors;
            global List<MProductPrice> Memberships;
            global List<ProductPrice> Associate;
            global List<ProductPrice> Sections;
        }
        
        global virtual class ProductPrice {
            global String ProductId;
            global String ProductName;
            global String ProductDetail;
            global String Description;
            global String ProductPrompt;
            global List<Price> Prices;
        }
        
        global class MProductPrice extends ProductPrice{
            global boolean ShowInNewMembershipPicklist;
            global boolean OverseasMembership;
            global boolean SectionsAllowed;
            global boolean AssociateAllowed;
            global boolean PartnerAllowed;
            //global boolean CashPaymentAllowed;
            //global boolean CardPaymentAllowed;
            //global boolean DDPaymentAllowed;
        }
        
    
    @HttpGet
    global static Result getProductPriceDetails(){

        RestRequest req = RestContext.request;
        Date theDate;
        String ds = req.params.get('PriceDate');
        List<Error> Errors = new List<Error>();
        Result res = new Result();

        if(ds!=null){
            try{
                theDate = date.valueof(ds);
            }
            catch(exception ex){
                Error e = new error();
                e.message = 'Invalid date';
                e.id=1;
                Errors.add(e);
            }
        }
        else{
            Error e = new error();
            e.message = 'No Date supplied';
            e.id=2;
            Errors.add(e);
        }
        
        if(Errors.size()==0){
            List<MProductPrice> ppm = new List<MProductPrice>();
            List<ProductPrice> pps = new List<ProductPrice>();
            List<ProductPrice> ppa = new List<ProductPrice>();
    
            List<Club_Product__c> cplist = [Select Id, Name, RecordType.Name, 
                                            Product_Detail__c, Membership__c, Show_in_New_Membership_Picklist__c, 
                                            Product_Type__c, Active__c, Visible_to_Admin_Users_Only__c, 
                                            Product_Description__c, Sections_Allowed__c, 
                                            Associate_Allowed__c, PartnerAllowed__c, 
                                            //DD_Payment_Allowed__c, Card_Payment_Allowed__c, 
                                            //Cash_Payment_Allowed__c,
                                            isOverseas__c,
                                            website_product_prompt__c, 
                                            (Select Id, 
                                                    Name, Product__c, Price__c, 
                                                    Start_Date__c, End_Date__c, 
                                                    Change_Fee__c, Joining_Fee__c,
                                                    Payment_Type__c,Price_Description__c,
                                                    Price_Prompt__c,Show_in_Web__c,
                                                    Price_Detail__c
                                                    from Prices__r 
                                                    where ((start_date__c =null or start_date__c <= :theDate) and (End_Date__c=null or End_Date__c >= :theDate))
                                                    order by start_date__c desc) from Club_Product__c
                                            order by RecordType.Name,Name];
    
            for(Club_Product__c cp:cplist){
                List<Price> pl = new List<Price>();
                ProductPrice p = new ProductPrice();
                MProductPrice m = new MProductPrice();
                p.ProductId = cp.Id;
                m.ProductId = cp.Id;
                p.ProductName = cp.Name;
                m.ProductName = cp.Name;
                p.ProductDetail = cp.Product_Detail__c;
                m.ProductDetail = cp.Product_Detail__c;
                p.Description = cp.Product_Description__c;
                m.Description = cp.Product_Description__c;
                p.ProductPrompt = cp.website_product_prompt__c;
                m.ProductPrompt = cp.website_product_prompt__c;
                for(Price__c price:cp.Prices__r){
                    Price pr = new Price();
                    pr.PaymentType = price.Payment_Type__c;
                    pr.PriceDescription =  price.Price_Description__c;
                    pr.PricePrompt = price.Price_Prompt__c;
                    pr.ShowinWeb = price.Show_in_Web__c;
                    pr.PriceDetail = price.Price_Detail__c;
                    pr.EndDate = price.End_Date__c;
                    pr.StartDate = price.Start_Date__c;
                    pr.Price = price.Price__c;
                    pr.JoiningFee = price.Joining_Fee__c;
                    pl.add(pr);
                }
                p.Prices = pl;
                m.Prices = pl;
                if(cp.RecordType.Name=='Associate Membership')ppa.add(p);
                if(cp.RecordType.Name=='Section')pps.add(p);
                if(cp.RecordType.Name=='Membership Code'){
                    m.ShowInNewMembershipPicklist = cp.Show_in_New_Membership_Picklist__c;
                    m.OverseasMembership = cp.isOverseas__c;
                    m.AssociateAllowed = cp.Associate_Allowed__c;
                    //m.CardPaymentAllowed = cp.Card_Payment_Allowed__c;
                    //m.CashPaymentAllowed = cp.Cash_Payment_Allowed__c;
                    //m.DDPaymentAllowed = cp.DD_Payment_Allowed__c;
                    m.PartnerAllowed = cp.PartnerAllowed__c;
                    m.SectionsAllowed = cp.Sections_Allowed__c;
                    ppm.add(m);
                }
            }
    
            res.Memberships = ppm;
            res.Associate = ppa;
            res.Sections = pps;
        }
        res.Errors = Errors;
        return res;     
    }

}