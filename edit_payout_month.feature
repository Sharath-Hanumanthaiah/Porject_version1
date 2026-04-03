Feature: Should be able to edit payout month

  Scenario: Edit payout month
    Given I am logged in as "Adam"
    And I have "edit_payout_months" permissions
    And there is a "not_live" payout month
    And I am on the edit payout month screen
    And I select "Live" as the status
    When I Click the "Save" button
    Then the payout month should be "live" status