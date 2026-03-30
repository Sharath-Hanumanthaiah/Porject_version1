Feature: Agent Single Account Lookup


  Background:
    Given I am logged in as "Sally"
    And I have "view_single_account_lookup" permissions

  Scenario: For agent users, strip any dashes and search for exact account number matches
    Given there is a commission transaction with an account number of "1234567890"
    When I do a single account lookup for "123-456-789-0"
    Then I should see "YES" on the page. 

  Scenario: Show NO when the stripped account number doesn't exactly match any existing transactions
    Given there is a commission transaction with an account number of "1234567890"
    When I do a single account lookup for "123-¬456-789-0-abcdefghijk"
    Then I should see "NO" on the page
