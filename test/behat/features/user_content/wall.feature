@javascript @core @blocktype @blocktype_wall
Feature: The wall block should send out notifications
    In order to make it easier for the wall owner to know about new wall posts
    So they can respond to those new wall posts

Background:
    Given the following "users" exist:
     | username | password | email | firstname | lastname | institution | authname | role |
     | UserA | Kupuhipa1 | UserA@example.org | Angela | User | mahara | internal | member |
     | UserB | Kupuhipa1 | UserB@example.org | Bob | User | mahara | internal | member |

Scenario: Wall post notifications
The wall post must generate a notification (Bug 547333)
    Given I log in as "UserB" with password "Kupuhipa1"
    And I choose "Find people" in "Groups" from main menu
    And I follow "Angela User"
    And I scroll to the base of id "wall-wrap"
    And I set the field "Post" to "Hello"
    And I press "Post"
    And I log out
    And I log in as "UserA" with password "Kupuhipa1"
    And I choose "mail" from user menu by id
    When I click on "New post on your wall"
    Then I should see "Hello"
    When I follow "View whole wall"
    Then I should see "Angela User: Wall"
    And I should see "Bob User"
    And I should see "Hello"
