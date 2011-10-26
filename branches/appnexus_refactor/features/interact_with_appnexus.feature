Feature:
  In order to interact with apnexus effeciently, code wise,
  software engineers will need
  a module which exposes the apnexus API

  Scenario: authenticate with displaywords domain
    When I request a new appnexus agent
    Then the appnexus agent should be authenticated
