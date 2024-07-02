/**
 * @description       : BACS Reports Controller for the LWC.
 * @author            : Kev Cadger (Wipro)
 * @group             : BACS Reports
 * @last modified on  : 09-06-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver       Date           Request                 Author                          Modification
 * 01.00.00  16-05-2022     REQ-000109682           Kev Cadger (Wipro)              Initial Version
 **/
public without sharing class Ctrl_BACSReports {
  /**
   * @description Creates the BACS report for the file upload and details to link to.
   * @author Kev Cadger (Wipro) | 30-05-2022
   * @param String reportType The specified report type.
   * @param String recordTypeId The record type related to the report type.
   * @return String The id of the BACS report created.
   **/
  @AuraEnabled
  public static String createReport(String reportType, String recordTypeId) {
    try {
      return BACSReports.createReport(reportType, recordTypeId);
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Extracts the BACS report details for the specified report.
   * @author Kev Cadger (Wipro) | 30-05-2022
   * @param String reportType The specified report type.
   * @param String reportId The specified id of the report.
   * @param String contentVersionId the specified content version id to get the report details.
   **/
  @AuraEnabled
  public static void extractReportData(
    String reportType,
    String reportId,
    String contentVersionId
  ) {
    try {
      BACSReports.Extract extractClass = new BACSReports.Extract(reportType);
      extractClass.extractData(reportId, contentVersionId);
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Fetches the BACS report details for the specified report.
   * @author Kev Cadger (Wipro) | 30-05-2022
   * @param String reportId The specified id of the report.
   * @return List<BACS_Report_Detail__c> The report details linked to the specified report.
   **/
  @AuraEnabled
  public static List<BACS_Report_Detail__c> getReportData(String reportId) {
    try {
      return BACSReports.getReportData(reportId);
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Processes the BACS report details for the specified report.
   * @author Kev Cadger (Wipro) | 30-05-2022
   * @param String reportType The specified report type.
   * @param String reportId The specified id of the report.
   **/
  @AuraEnabled
  public static void processReportData(String reportType, String reportId) {
    try {
      BACSReports.Process processClass = new BACSReports.Process(
        reportType,
        BACSReports.getReportDataUnprocessed(reportId)
      );
      processClass.processData();
    } catch (Exception e) {
      Utilities.logException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }
}