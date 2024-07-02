public class sectionSelectWrapper {

	public club_product__c s {get; set;}
	public Decimal price {get; set;}
	public Boolean selected {get; set;}
	public List<Price__c> prices {get;set;}
 
	public sectionSelectWrapper(club_product__c sec) {
		this.s = sec;
		this.selected = false;
	}

	public sectionSelectWrapper(club_product__c sec,Decimal price) {
		system.debug('creating a sectionSelectWrapper: ' + sec);
		this.s = sec;
		this.price = price;
		this.selected = false;
	}
	
	public sectionSelectWrapper(club_product__c sec, List<Price__c> prices){
		this.s = sec;
		this.prices = prices;
		this.selected = false;
	}
	
	public sectionSelectWrapper(club_product__c sec, List<Price__c> prices, boolean sel){
		this.s = sec;
		this.prices = prices;
		this.selected = sel;
	}

	public sectionSelectWrapper(club_product__c sec,boolean sel) {
		this.s = sec;
		this.selected = sel;
	}

	public sectionSelectWrapper(club_product__c sec,Decimal price,boolean sel) {
		this.s = sec;
		this.price = price;
		this.selected = sel;
	}
}