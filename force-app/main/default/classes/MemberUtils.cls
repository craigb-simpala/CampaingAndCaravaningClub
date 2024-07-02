public class MemberUtils {
    // public MemberUtils() {

    // }

    public static void setAgeConcession(List<Contact> contactList)
    {
        for(contact item:contactList)
        {
            item.Age_Concession__c = true;
        }
    update contactList;
    }
}