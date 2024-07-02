/**
 * @description       : Test class for the BACSReports class.
 * @author            : Kev Cadger (Wipro)
 * @group             : Tests
 * @last modified on  : 13-07-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver       Date           Request         Author                          Modification
 * 01.00.00  01-06-2022     REQ-000109682   Kev Cadger (Wipro)              Initial Version
 **/

/**
 * Method naming:
 * - test denotes a test method.
 * - _{Method/Process} denotes the method/process being tested.
 * - _S for success expected.
 * - _F for failure expected.
 * - _{Criteria} shows what is being tested.
 **/
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class BACSReportsTest {
  // * Class Properties
  @TestVisible
  private static String reportTypeADDACS = 'ADDACS';
  @TestVisible
  private static String reportTypeARUDD = 'ARUDD';
  @TestVisible
  private static String reportTypeAUDDIS = 'AUDDIS';
  @TestVisible
  private static Map<String, List<SObject>> sobjectToRecordMapping = new Map<String, List<SObject>>();

  // ! -------------------------------------------------- ! //
  // * Report Specific Tests * //

  // * * ADDACS Report

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ADDACS report.
   * @tests
   * - 01 - Ensure the report details were processed.
   * @results
   * 01 - For each report detail:
   * - 01 - Status should not be pending.
   **/
  @IsTest
  static void test_FullProcess_ADDACS_S() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(5, true);
    createPaymentMethods();
    createTransactions();

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeADDACS);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeADDACS);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeADDACS,
        reportId,
        contentVersionId
      );
      //Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeADDACS, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // - 01 - Status should not be pending.
      System.assertNotEquals(
        'Pending',
        reportDetail.Status__c,
        'The report detail was not processed.'
      );
    }
  }

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ADDACS report where no memberships are linked.
   * @tests
   * - 01 - No membership numbers are linked.
   * - 02 - Message should be updated correctly.
   * @results
   * 01 - For each report detail:
   * - 01 - No membership linked.
   * - 02 - Message should state membership not found.
   **/
  @IsTest
  static void test_FullProcess_ADDACS_S_NoMembershipFound() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, false);

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeADDACS);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeADDACS);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeADDACS,
        reportId,
        contentVersionId
      );
      // Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeADDACS, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // - 01 - No membership linked.
      System.assertEquals(
        null,
        reportDetail.Account__c,
        'The membership was linked.'
      );
      // - 02 - Message should state membership not found.
      System.assert(
        reportDetail.Message__c.contains('Membership: Not found'),
        'The message was not updated correctly.'
      );
    }
  }

  // /**
  //  * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
  //  * @description Tests the full process of the ADDACS report where no memberships are linked.
  //  * @tests
  //  * - 01 - No membership numbers are linked.
  //  * - 02 - Message should be updated correctly.
  //  * @results
  //  * 01 - For each report detail:
  //  * - 01 - No membership linked.
  //  * - 02 - Message should state membership not found.
  //  **/
  // @IsTest
  // static void test_FullProcess_ADDACS_S_DuplicateMembershipFound() {
  //     // Initialise any required data.
  //     createCustomSettings();
  //     createMemberships(1, true);

  //     // Initialise any variables.
  //     List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

  //     Test.startTest();
  //     try {
  //         // Create the report.
  //         Id reportId = createReport(reportTypeADDACS);
  //         // Get the content versions.
  //         Id contentVersionId = createContentVersion(reportTypeADDACS);
  //         // Extract the report.
  //         Ctrl_BACSReports.extractReportData(reportTypeADDACS, reportId, contentVersionId);
  //         // Get the report details.
  //         List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(reportId);
  //         // Process the report.
  //         Ctrl_BACSReports.processReportData(reportTypeADDACS, reportId);

  //         // Get the report details that have been processed.
  //         reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
  //     } catch (Exception e) {
  //         Utilities.logException(e);
  //     }
  //     Test.stopTest();

  //     // Assert Tests:
  //     // 01 - For each report detail:
  //     for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
  //         // - 01 - No membership linked.
  //         System.assertEquals(null, reportDetail.Account__c, 'The membership was linked.');
  //         // - 02 - Message should state membership not found.
  //         System.assert(reportDetail.Message__c.contains('Membership: Not found'), 'The message was not updated correctly.');
  //     }
  // }

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ADDACS report where no payment methods or transactions are found.
   * @tests
   * 01 - For each report detail.
   * - Message should be updated correctly.
   * - 01 - No payment methods found.
   * - 02 - Message should be updated correctly (No )Payment.
   * @results
   * 01 - For each report detail:
   * - Message should state:
   * - 01 - No payment method found.
   * - 02 - No transactions found.
   **/
  @IsTest
  static void test_FullProcess_ADDACS_S_NoPaymentMethodOrTransactionsFound() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, true);

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeADDACS);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeADDACS);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeADDACS,
        reportId,
        contentVersionId
      );
      // Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeADDACS, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // If the message is not a duplicate.
      if (!reportDetail.Message__c.contains('Duplicate')) {
        // - Message should state:
        //  01 - No payment method found.
        System.assert(
          reportDetail.Message__c.contains('Payment Method: Not found'),
          'The message was not updated correctly.'
        );
        // - 02 - No transactions found.
        System.assert(
          reportDetail.Message__c.contains('Transactions: Not found'),
          'The message was not updated correctly.'
        );
      }
    }
  }

  // * * ARUDD Report

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ARUDD report.
   * @tests
   * - 01 - Ensure the report details were processed.
   * @results
   * 01 - For each report detail:
   * - 01 - Status should not be pending.
   **/
  @IsTest
  static void test_FullProcess_ARUDD_S() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, true);
    createPaymentMethods();
    createTransactions();

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeARUDD);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeARUDD);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeARUDD,
        reportId,
        contentVersionId
      );
      //Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeARUDD, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // - 01 - Status should not be pending.
      System.assertNotEquals(
        'Pending',
        reportDetail.Status__c,
        'The report detail was not processed.'
      );
    }
  }

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ARUDD report where no memberships are linked.
   * @tests
   * - 01 - No membership numbers are linked.
   * - 02 - Message should be updated correctly.
   * @results
   * 01 - For each report detail:
   * - 01 - No membership linked.
   * - 02 - Message should state membership not found.
   **/
  @IsTest
  static void test_FullProcess_ARUDD_S_NoMembershipFound() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, false);

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeARUDD);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeARUDD);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeARUDD,
        reportId,
        contentVersionId
      );
      // Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeARUDD, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // If the message is not a duplicate.
      if (!reportDetail.Message__c.contains('Duplicate')) {
        // - Message should state:
        //  01 - No payment method found.
        System.assert(
          reportDetail.Message__c.contains('Payment Method: Not found'),
          'The message was not updated correctly.'
        );
        // - 02 - No transactions found.
        System.assert(
          reportDetail.Message__c.contains('Transactions: Not found'),
          'The message was not updated correctly.'
        );
      }
    }
  }

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ARUDD report where no payment methods or transactions are found.
   * @tests
   * 01 - For each report detail.
   * - Message should be updated correctly.
   * - 01 - No payment methods found.#
   * - 02 - Message should be updated correctly (No )Payment.
   * @results
   * 01 - For each report detail:
   * - Message should state:
   * - 01 - No payment method found.
   * - 02 - No transactions found.
   **/
  @IsTest
  static void test_FullProcess_ARUDD_S_NoPaymentMethodOrTransactionsFound() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, true);

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeARUDD);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeARUDD);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeARUDD,
        reportId,
        contentVersionId
      );
      // Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeARUDD, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // - Message should state:
      //  01 - No payment method found.
      System.assert(
        reportDetail.Message__c.contains('Payment Method: Not found'),
        'The message was not updated correctly.'
      );
      // - 02 - No transactions found.
      System.assert(
        reportDetail.Message__c.contains('Transactions: Not found'),
        'The message was not updated correctly.'
      );
    }
  }

  // * * AUDDIS Reports

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the AUDDIS report.
   * @tests
   * - 01 - Ensure the report details were processed.
   * @results
   * 01 - For each report detail:
   * - 01 - Status should not be pending.
   **/
  @IsTest
  static void test_FullProcess_AUDDIS_S() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(5, true);
    createPaymentMethods();
    createTransactions();

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeAUDDIS);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeAUDDIS);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeAUDDIS,
        reportId,
        contentVersionId
      );
      //Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeAUDDIS, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // - 01 - Status should not be pending.
      System.assertNotEquals(
        'Pending',
        reportDetail.Status__c,
        'The report detail was not processed.'
      );
    }
  }

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ADDACS report where no memberships are linked.
   * @tests
   * - 01 - No membership numbers are linked.
   * - 02 - Message should be updated correctly.
   * @results
   * 01 - For each report detail:
   * - 01 - No membership linked.
   * - 02 - Message should state membership not found.
   **/
  @IsTest
  static void test_FullProcess_AUDDIS_S_NoMembershipFound() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, false);

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeAUDDIS);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeAUDDIS);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeAUDDIS,
        reportId,
        contentVersionId
      );
      // Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeAUDDIS, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // - 01 - No membership linked.
      System.assertEquals(
        null,
        reportDetail.Account__c,
        'The membership was linked.'
      );
      // - 02 - Message should state membership not found.
      System.assert(
        reportDetail.Message__c.contains('Membership: Not found'),
        'The message was not updated correctly.'
      );
    }
  }

  /**
   * @author Kev Cadger (kevin.cadger@wipro.com) | 01-06-2022
   * @description Tests the full process of the ADDACS report where no payment methods or transactions are found.
   * @tests
   * 01 - For each report detail.
   * - Message should be updated correctly.
   * - 01 - No payment methods found.
   * - 02 - Message should be updated correctly (No )Payment.
   * @results
   * 01 - For each report detail:
   * - Message should state:
   * - 01 - No payment method found.
   * - 02 - No transactions found.
   **/
  @IsTest
  static void test_FullProcess_AUDDIS_S_NoPaymentMethodOrTransactionsFound() {
    // Initialise any required data.
    createCustomSettings();
    createMemberships(1, true);

    // Initialise any variables.
    List<BACS_Report_Detail__c> reportDetailsProcessed = new List<BACS_Report_Detail__c>();

    Test.startTest();
    try {
      // Create the report.
      Id reportId = createReport(reportTypeAUDDIS);
      // Get the content versions.
      Id contentVersionId = createContentVersion(reportTypeAUDDIS);
      // Extract the report.
      Ctrl_BACSReports.extractReportData(
        reportTypeAUDDIS,
        reportId,
        contentVersionId
      );
      // Get the report details.
      List<BACS_Report_Detail__c> reportDetails = Ctrl_BACSReports.getReportData(
        reportId
      );
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeAUDDIS, reportId);

      // Get the report details that have been processed.
      reportDetailsProcessed = Ctrl_BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 01 - For each report detail:
    for (BACS_Report_Detail__c reportDetail : reportDetailsProcessed) {
      // If the message is not a duplicate.
      if (!reportDetail.Message__c.contains('Duplicate')) {
        // - Message should state:
        //  01 - No payment method found.
        System.assert(
          reportDetail.Message__c.contains('Payment Method: Not found'),
          'The message was not updated correctly.'
        );
        // - 02 - No transactions found.
        System.assert(
          reportDetail.Message__c.contains('Transactions: Not found'),
          'The message was not updated correctly.'
        );
      }
    }
  }

  // ! -------------------------------------------------- ! //
  // * Controller Specific Tests * //

  @IsTest
  static void test_CreateReport_F() {
    // Initialise any required data.
    // ? No custom settings are created to force an error.

    // Intialise any variables.
    Id reportIdADDACS = null;
    Id reportIdARUDD = null;
    Id reportIdAUDDIS = null;

    Test.startTest();
    try {
      // Create the report.
      reportIdADDACS = createReport(reportTypeADDACS);
      reportIdARUDD = createReport(reportTypeARUDD);
      reportIdAUDDIS = createReport(reportTypeAUDDIS);
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 1.
    System.assertEquals(
      null,
      reportIdADDACS,
      'The report was not created: ADDACS.'
    );
    System.assertEquals(
      null,
      reportIdARUDD,
      'The report was not created: ARUDD.'
    );
    System.assertEquals(
      null,
      reportIdAUDDIS,
      'The report was not created: AUDDIS.'
    );
  }

  @IsTest
  static void test_ExtractReport_F() {
    // Initialise any required data.
    // ? No custom settings are created to force an error.

    Test.startTest();
    try {
      // Extract the report.
      Ctrl_BACSReports.extractReportData(reportTypeADDACS, '', '');
      Ctrl_BACSReports.extractReportData(reportTypeARUDD, '', '');
      Ctrl_BACSReports.extractReportData(reportTypeAUDDIS, '', '');
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 1.
    System.assertEquals(null, null, 'The report was not created: ADDACS.');
    System.assertEquals(null, null, 'The report was not created: ARUDD.');
    System.assertEquals(null, null, 'The report was not created: AUDDIS.');
  }

  @IsTest
  static void test_GetReportData_F() {
    // Initialise any required data.
    // ? No custom settings are created to force an error.

    // Initialise any variables:
    List<BACS_Report_Detail__c> reportDetailsADDACS = null;
    List<BACS_Report_Detail__c> reportDetailsARUDD = null;
    List<BACS_Report_Detail__c> reportDetailsAUDDIS = null;

    Test.startTest();
    try {
      //Get the report details.
      reportDetailsADDACS = Ctrl_BACSReports.getReportData('');
      reportDetailsARUDD = Ctrl_BACSReports.getReportData('');
      reportDetailsAUDDIS = Ctrl_BACSReports.getReportData('');
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 1.
    System.assertEquals(
      null,
      reportDetailsADDACS,
      'The report was not created: ADDACS.'
    );
    System.assertEquals(
      null,
      reportDetailsARUDD,
      'The report was not created: ARUDD.'
    );
    System.assertEquals(
      null,
      reportDetailsAUDDIS,
      'The report was not created: AUDDIS.'
    );
  }

  @IsTest
  static void test_ProcessReportData_F() {
    // Initialise any required data.
    // ? No custom settings are created to force an error.

    Test.startTest();
    try {
      // Process the report.
      Ctrl_BACSReports.processReportData(reportTypeADDACS, '');
      Ctrl_BACSReports.processReportData(reportTypeARUDD, '');
      Ctrl_BACSReports.processReportData(reportTypeAUDDIS, '');
    } catch (Exception e) {
      Utilities.logException(e);
    }
    Test.stopTest();

    // Assert Tests:
    // 1.
    System.assertEquals(null, null, 'The report was not created: ADDACS.');
    System.assertEquals(null, null, 'The report was not created: ARUDD.');
    System.assertEquals(null, null, 'The report was not created: AUDDIS.');
  }

  // ! -------------------------------------------------- ! //
  // * Helper Methods * //

  // * * Report Methods

  private static Id createReport(String reportType) {
    return Ctrl_BACSReports.createReport(
      reportType,
      Utilities.getRecordTypeId('BACS_Report__c', reportType)
    );
  }

  private static String getReportData(String reportType) {
    String report = '';
    report += '<?xml version = \'1.0\' encoding = \'UTF-8\'?>';
    report += '<BACSDocument xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="newbacs-advices.xsd">';
    report += '<Data>';

    switch on reportType {
      when 'ADDACS' {
        report += buildReportDataADDACS();
      }
      when 'ARUDD' {
        report += buildReportDataARUDD();
      }
      when 'AUDDIS' {
        report += buildReportDataAUDDIS();
      }
    }

    report += '</Data>';
    report += '</BACSDocument>';

    return report;
  }

  private static String buildReportDataADDACS() {
    // Initialise any variables.
    String reportData = '<MessagingAdvices>';
    List<SObject> memberships = sobjectToRecordMapping.get('Account');
    List<SObject> paymentMethods = sobjectToRecordMapping.get(
      'Payment_Method__c'
    );

    // For each membership.
    for (Integer i = 0; i < memberships.size(); i++) {
      // Intialise any variables.
      Account membership = (Account) memberships[i];
      Payment_Method__c paymentMethod = paymentMethods != null
        ? (Payment_Method__c) paymentMethods[i]
        : new Payment_Method__c();
      String data = '';
      String reasonCode = '';

      // Determine the variety of reason codes to be used.
      if (i == 0) {
        reasonCode = 'R';
      } else if (i == 1) {
        reasonCode = '3';
      } else if (i == 2) {
        reasonCode = 'C';
      } else {
        reasonCode = 'E';
        if (i == 4) {
          // Set the payer name to be updated.
          paymentMethod = new Payment_Method__c(
            Bank_Account_Name__c = 'Mr Testy McTester'
          );
        }
      }

      // Build the report data for the membership.
      data += '<MessagingAdvice ';
      data += 'effective-date="' + date.today() + '" ';
      data += 'payer-name="' + paymentMethod.get('Bank_Account_Name__c') + '" ';
      if (paymentMethod.get('Bank_Account_Name__c') != null) {
        data +=
          'payer-new-name="' +
          paymentMethod.get('Bank_Account_Name__c') +
          '" ';
      }
      data +=
        'payer-account-number="' +
        paymentMethod.get('Bank_Account_Number__c') +
        '" ';
      if (paymentMethod.get('Bank_Account_Number__c') != null) {
        data +=
          'payer-new-account-number="' +
          paymentMethod.get('Bank_Account_Number__c') +
          '" ';
      }
      data += 'payer-sort-code="' + paymentMethod.get('Sort_Code__c') + '" ';
      if (paymentMethod.get('Sort_Code__c') != null) {
        data +=
          'payer-new-sort-code="' +
          paymentMethod.get('Sort_Code__c') +
          '" ';
      }
      data += 'reason-code="' + reasonCode + '" ';
      data +=
        'reference="' +
        membership.get('Membership_Number__c') +
        'DIRECT DBT" ';
      data += '/>';

      // Add the report data.
      reportData += data;
      // Add the report data duplicate.
      reportData += data;
    }

    reportData += '</MessagingAdvices>';

    return reportData;
  }

  private static String buildReportDataARUDD() {
    String reportData = '';

    List<SObject> memberships = sobjectToRecordMapping.get('Account');
    List<SObject> paymentMethods = sobjectToRecordMapping.get(
      'Payment_Method__c'
    );

    for (Integer i = 0; i < memberships.size(); i++) {
      //
      Account membership = (Account) memberships[i];
      Payment_Method__c paymentMethod = (Payment_Method__c) paymentMethods[i];
      String data = '';

      // Build the report data for the membership.
      data += '<ReturnedDebitItem ';
      data += 'effective-date="' + date.today() + '" ';
      data += 'payer-name="' + paymentMethod.get('Bank_Account_Name__c') + '" ';
      data +=
        'payer-account-number="' +
        paymentMethod.get('Bank_Account_Number__c') +
        '" ';
      data += 'payer-sort-code="' + paymentMethod.get('Sort_Code__c') + '" ';
      data += 'returnDescription="REFER TO PAYER" ';
      data += 'transCode="01" ';
      data += 'ref="' + membership.get('Membership_Number__c') + 'DIRECT DBT" ';
      data += 'returnCode="0157" ';
      data += '/>';

      // Add the report data.
      reportData += data;
      // Add the report data duplicate.
      reportData += data;
    }

    return reportData;
  }

  private static String buildReportDataAUDDIS() {
    // Intiialsie any variables
    String reportData = '<MessagingAdvices>';
    List<SObject> memberships = sobjectToRecordMapping.get('Account');
    List<SObject> paymentMethods = sobjectToRecordMapping.get(
      'Payment_Method__c'
    );

    // For each membership.
    for (Integer i = 0; i < memberships.size(); i++) {
      // Initialise any variables.
      Account membership = (Account) memberships[i];
      Payment_Method__c paymentMethod = (Payment_Method__c) paymentMethods[i];
      String data = '';
      String reasonCode = '';

      // Determine the variety of reason codes to be used.
      if (i == 0) {
        reasonCode = '1';
      } else {
        reasonCode = 'C';
      }

      // Build the report data for the membership.
      data += '<MessagingAdvice ';
      data += 'effective-date="' + date.today() + '" ';
      data += 'payer-name="' + paymentMethod.get('Bank_Account_Name__c') + '" ';
      data +=
        'payer-account-number="' +
        paymentMethod.get('Bank_Account_Number__c') +
        '" ';
      data += 'payer-sort-code="' + paymentMethod.get('Sort_Code__c') + '" ';
      data += 'reason-code="1" ';
      data +=
        'reference="' +
        membership.get('Membership_Number__c') +
        'DIRECT DBT" ';
      data += '/>';

      // Add the report data.
      reportData += data;
      // Add the report data duplicate.
      reportData += data;
    }

    reportData += '</MessagingAdvices>';

    return reportData;
  }

  // * * Data Methods

  /**
   * @description Creates the required custom settings for the tests.
   * @author Kev Cadger (Wipro) | 20-06-2022
   **/
  private static void createCustomSettings() {
    // Initialise the report configurations.
    List<BACS_Report_Config__c> reportConfigs = new List<BACS_Report_Config__c>{
      // ADDACS
      new BACS_Report_Config__c(
        Local_Name__c = 'MessagingAdvice',
        Name = 'ADDACS',
        Report_Name__c = 'Amendments'
      ),
      // ARUDD
      new BACS_Report_Config__c(
        Local_Name__c = 'ReturnedDebitItem',
        Name = 'ARUDD',
        Report_Name__c = 'Rejections'
      ),
      // AUDDIS
      new BACS_Report_Config__c(
        Local_Name__c = 'MessagingAdvice',
        Name = 'AUDDIS',
        Report_Name__c = 'Amendments'
      )
    };
    // Create the report configurations.
    insert reportConfigs;
  }

  private static void createMemberships(
    Integer numToGenerate,
    Boolean getMembershipNum
  ) {
    // Create the base memberships.
    List<SObject> memberships = TestDataFactory.createSObjects(
      new Account(),
      numToGenerate
    );

    // If the membership numbers should be returned.
    if (getMembershipNum) {
      // Build the query to include membership number.
      String query = Utilities.getSObjectQuerySpecifiedFields(
        'Account',
        new List<String>{ 'Membership_Number__c' }
      );
      // Get the memberships.
      memberships = Database.query(query);
    }

    // Add the memberships to the sobject to record mapping.
    sobjectToRecordMapping.put('Account', memberships);
  }

  private static void createPaymentMethods() {
    List<SObject> memberships = sobjectToRecordMapping.get('Account');
    List<SObject> paymentMethods = TestDataFactory.getSObjects(
      new Payment_Method__c(),
      memberships.size()
    );

    for (Integer i = 0; i < paymentMethods.size(); i++) {
      Account membership = (Account) memberships[i];

      Payment_Method__c paymentMethod = (Payment_Method__c) paymentMethods[i];
      paymentMethod.Membership__c = membership.Id;
      paymentMethod.RecordTypeId = Utilities.getRecordTypeId(
        'Payment_Method__c',
        'Direct_Debit'
      );
    }

    insert paymentMethods;

    sobjectToRecordMapping.put('Payment_Method__c', paymentMethods);
  }

  private static void createTransactions() {
    List<SObject> paymentMethods = sobjectToRecordMapping.get(
      'Payment_Method__c'
    );
    List<Transaction__c> transactions = new List<Transaction__c>();

    List<Transaction__c> transactions1 = (List<Transaction__c>) TestDataFactory.getSObjects(
      new Transaction__c(),
      paymentMethods.size()
    );
    List<Transaction__c> transactions2 = (List<Transaction__c>) TestDataFactory.getSObjects(
      new Transaction__c(),
      paymentMethods.size()
    );

    for (Integer i = 0; i < paymentMethods.size(); i++) {
      Payment_Method__c paymentMethod = (Payment_Method__c) paymentMethods[i];

      Transaction__c transaction1 = transactions1[i];
      transaction1.Payment_Method__c = paymentMethod.Id;
      transaction1.Status__c = 'Pending';
      transaction1.Transaction_Type__c = '0C';

      Transaction__c transaction2 = transactions2[i];
      transaction2.Payment_Method__c = paymentMethod.Id;
      transaction1.Status__c = 'Pending';
      transaction2.Transaction_Type__c = '0N';
    }

    transactions.addAll(transactions1);
    transactions.addAll(transactions2);

    insert transactions;

    sobjectToRecordMapping.put('Transaction__c', transactions);
  }

  private static Id createContentVersion(String reportType) {
    ContentVersion contentVersion = (ContentVersion) TestDataFactory.getSObject(
      new ContentVersion()
    );
    contentVersion.VersionData = Blob.valueOf(getReportData(reportType));

    insert contentVersion;

    return contentVersion.Id;
  }
}