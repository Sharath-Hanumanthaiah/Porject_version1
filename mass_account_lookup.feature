Feature: Mass Account Lookup

  Background:
    Given I am logged in as "Adam"
    And I have "view_mass_account_lookup" permissions

  Scenario:
    Given there are some commission transactions for CenturyLink
    And I am on the mass account lookup page
    When I upload the "mass_account_lookup.csv" file
    Then I should see following table
    | Account Number | Found? | Last Transaction Date |
    | 12345          | Yes    | 02/01/2015            |
    | 67890          | Yes    | 02/01/2015            |
    | abcde          | No     |                       |
  
