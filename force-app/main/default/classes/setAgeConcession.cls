public class setAgeConcession implements Schedulable
{
    public void execute(SchedulableContext ctx)
    {
        List<Contact> membersToUpdate = [Select id, Age_Concession__c, Age__c,Membership_Status__c 
        FROM Contact where Age__c = 60 AND Membership_Status__c = 'Paid' AND Age_Concession__c = false limit 10];
        MemberUtils.setAgeConcession(membersToUpdate);
    }
}