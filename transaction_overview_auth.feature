Feature: Transaction Overview Auth

  Scenario: Can only view if you have view_commission_transactions permission
    Given I am logged in as "Sally"
    And I have "" permissions
    When I am on the commission transaction overview screen
    Then I should see content "Not Authorized"

  Scenario: Can't see non live trans if you dont have the permission
    Given I am logged in as "Sally"
    And I have "view_commission_transactions,view_gross_commissions" permissions
    And there is a non live commission transaction
    When I am on the commission transaction overview screen
    Then I should see following table
      | Payout Date | Customer | Account # | Type | Provider | Usage | Gross | Sales Amount | Split | Split Amount | OR | OR Amount |
