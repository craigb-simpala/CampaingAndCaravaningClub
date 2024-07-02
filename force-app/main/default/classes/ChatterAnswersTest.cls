/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ChatterAnswersTest {

    static testMethod void myUnitTest() {

        User[] user = [SELECT Id, Firstname, Lastname from User WHERE Name = 'Sandyx Sys-Admin'];
        if (user.size() == 0) { return; }
        String firstName = user[0].FirstName; 
        String lastName = user[0].LastName; 
        String userId = user[0].Id;
        ChatterAnswers accountId = new ChatterAnswers();
        String accId = accountId.createAccount(firstName, lastName, userId);
        Account acct = [SELECT name, ownerId from Account where Id =: accId];
        System.assertEquals(firstName + ' ' + lastName, acct.name);
        System.assertEquals(userId, acct.ownerId);

  }
}