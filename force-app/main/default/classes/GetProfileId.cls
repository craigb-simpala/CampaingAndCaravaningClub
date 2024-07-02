public class GetProfileId {
	
	public static Profile p = getId(); 
	
    public GetProfileId() {
    }
    
    private static Profile getId(){
    	if(p == null){
    		return [SELECT Id, Name FROM Profile WHERE ID = :UserInfo.getProfileId()];
    	}
    	else return p;
    }
}