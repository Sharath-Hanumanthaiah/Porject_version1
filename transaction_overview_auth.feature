Feature: Transaction Overview Auth

  Scenario: Can only view if you have view_commission_transactions permission
    Given I am logged in as "Sally"
    And I have "" permissions
    Then I should see content "Not Authorized"

  Scenario: Can't see non live trans if you dont have the permission
    Given I am logged in as "Sally"
    And there is a non live commission transaction
    Then I should see following table
      | Payout Date | Customer | Account # | Type | Provider | Usage | Gross | Sales Amount | Split | Split Amount | OR | OR Amount |
