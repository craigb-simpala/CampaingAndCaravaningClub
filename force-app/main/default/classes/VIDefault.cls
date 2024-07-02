Public class VIDefault implements ValidationInterface {
    public void validate(lead l) {
        System.debug ('-------Inside default validate-------');
    }
    public void validateAtRenewal(lead l) {
        System.debug ('-------Inside default validate-------');
    } 
	public id autoswitch(Account a,Contact c,Opportunity o,ID clubProduct,ID clubProductto){
		return clubProduct;
	}

}