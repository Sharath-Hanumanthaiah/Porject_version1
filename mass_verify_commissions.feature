Feature: Mass Verify Commissions

  Background:
    Given I am logged in as "Adam"
    And I have "view_mass_verify_commissions" permissions

  Scenario:
    Given there are some commission transactions to mass verify
    And I am on the mass verify commissions page
    When I upload the "mass_verify_commissions.csv" file
    Then I should see following table
      | Account Number | Last Paid Cycle Date |
      | 12345          | 02/01/2015           |
      | 67890          | 02/01/2015           |
      | abcde          | 02/01/2015           |
      | notpaid        | 02/01/2015           |
