Feature: Base by Providers Report

  Background:
    Given I am logged in as "Adam"
    And I have "view_base_by_providers_report" permissions
    And there are some Request Types
    And there are some transactions

  Scenario: Search by payout month and type
    Given I am on the base by providers report page
    And I select "January 2015" from the "q_payout_month_id_eq" dropdown
    And I select "Residual" from the "q_commission_upload_generic_type_eq_any" dropdown
    And I Click the "Search" button
    Then I should see "Provider" on the page
    And I should see "Second Provider" on the page
    And I should see "$500.00" on the page
    And I should see "$1,000.00" on the page
