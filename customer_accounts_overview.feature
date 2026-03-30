Feature: Customer Accounts Overview

  Background:
    Given I am logged in as "Adam"
    And I have "view_customer_accounts" permissions

  Scenario: Should show grouped commission transactions belongs to customer
    Given there are some commission transactions belonging to different customers
    When I am on the customer accounts overview screen for "ET"
    Then I should see "Provider" on the page
    And I should see "291" on the page
    And I should see "36.0" on the page

  Scenario: Paginate to 50 records
    Given There are more than 50 commission_transaction records belonging to "ET"
    When I am on the customer accounts overview screen for "ET"
    Then the table should have 52 rows

  Scenario: Account Number Search
    Given there are some commission transactions belonging to different customers
    And I am on the customer accounts overview screen for "ET"
    And I search for "666" account number
    When I Click the "Search" button
    Then I should see "666" on the page
    Then I should see "55.0" on the page

  Scenario: Provider Search
    Given there are some commission transactions belonging to different customers
    And I am on the customer accounts overview screen for "ET"
    And I search for "Verizon" provider
    When I Click the "Search" button
    Then I should see "70.0" on the page
    And I should see "Verizon" on the page

  Scenario: Provider Search & account number search
    Given there are some commission transactions belonging to different customers
    And I am on the customer accounts overview screen for "ET"
    And I search for "Verizon" provider
    And I search for "666" account number
    When I Click the "Search" button
    Then I should see "666" on the page
    And I should see "30.0" on the page

  Scenario: Paid on or after search
    Given there are some commission transactions belonging to different customers
    And I am on the customer accounts overview screen for "ET"
    And I search for "January", "2015" in paid on or after
    When I Click the "Search" button
    Then I should see "abc123" on the page
    And I should see "CenturyLink" on the page
    And I should see "777" on the page
    And I should see "15.0" on the page

