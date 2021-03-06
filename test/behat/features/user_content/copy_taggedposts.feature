@javascript @core @core_artefact
Feature: Mahara users can allow their tagged blogs tags to be copied
    As a mahara user
    I need to copy a tagged blog block

 Background:
  Given the following "users" exist:
    | username | password | email | firstname | lastname | institution | authname | role |
    | UserA | Kupuhipa1 | UserA@example.org | Angela | User | mahara | internal | member |
    | UserB | Kupuhipa1 | UserB@example.org | Bob | User | mahara | internal | member |

  And the following "pages" exist:
    | title | description | ownertype | ownername |
    | Page UserA_01 | Page 01 | user | UserA |

  And the following "journalposts" exist:
    | owner | ownertype | title | entry | blog | tags | draft |
    | UserA | user | Entry one | This is journal entry one | | blog,one | 0 |
    | UserA | user | Entry two | This is journal entry two | | blog,two | 0 |
    | UserB | user | UserB entry | This is a journal entry for UserB | | blog,one | 0 |

 Scenario: Create blogs
  Given I log in as "UserA" with password "Kupuhipa1"
  # Add a taggedblogs block to a page
  And I choose "Pages and collections" in "Portfolio" from main menu
  And I click on "Page UserA_01" panel menu
  And I click on "Edit" in "Page UserA_01" panel menu
  And I expand "Journals" node in the "blocktype sidebar" property
  And I follow "Tagged journal entries" in the "blocktype sidebar" property
  And I press "Add"
  And I fill in select2 input "instconf_tagselect" with "blog" and select "blog"
  And I fill in select2 input "instconf_tagselect" with "one" and select "one"
  And I fill in select2 input "instconf_tagselect" with "-two" and select "two"
  And I select "Others will get a copy of the block configuration" from "Block copy permission"
  And I press "Save"
  And I scroll to the id "main-nav"
  And I follow "Share" in the "Toolbar buttons" property
  And I follow "Advanced options"
  And I enable the switch "Allow copying"
  And I select "Public" from "accesslist[0][searchtype]"
  And I press "Save"

  # Copy the page as same user
  And I choose "Pages and collections" in "Portfolio" from main menu
  And I follow "Page UserA_01"
  And I follow "Copy"
  And I press "Save"
  Then I should see "Journal entries with tags \"blog\", \"one\" but not tag \"two\""
  And I should see "Entry one"

  # Copy the page as another user
  And I log out
  Given I log in as "UserB" with password "Kupuhipa1"
  And I scroll to the id "view"
  And I follow "Page UserA_01"
  And I scroll to the base of id "copyview-button"
  And I follow "Copy"
  And I press "Save"
  Then I should see "Journal entries with tags \"blog\", \"one\" but not tag \"two\""
  And I should see "UserB entry"
