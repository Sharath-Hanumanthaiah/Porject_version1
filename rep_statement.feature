Feature: Rep Statement

  Background:
    Given I am logged in as "Adam"
    And I have "view_rep_commission,view_rep_commission_basic" permissions

  Scenario: Should only see commission transactions for selected rep and payout month
    Given there are transactions for a rep statement
    And I am on the rep commission statement
    And I select a month year and rep
    When I Click the "Search" button
    Then I should see following table
      | Type     | # Transactions | Provider | Usage | Sales Commissions |
      |          | 5              | Totals   | $0.00 | $0.00             |
      | Bonus    | 3              |          |       |                   |
      | Residual | 1              |          |       |                   |
      | Upfront  | 1              |          |       |                   |

  Scenario: if change url params for invalid user should see not authorized
    Given there are transactions for a rep statement
    And I change the user id in the url
    Then I should see "Not Authorized" on the page

  Scenario: if change url params for invalid payout month should see not authorized
    Given there are transactions for a rep statement
    And I change the payout month id in the url
    Then I should see "Not Authorized" on the page
