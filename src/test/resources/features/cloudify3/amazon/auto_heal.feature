Feature: Monitoring and Auto healing
  # Tested features with this scenario:
  #   - auto healing

  Scenario: Auto healing withoud scaling
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/samples.git" branch "master"
    And I upload the git archive "samples/apache"
    And I upload the local archive "topologies/apache.yml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
#    And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to value defined in environment variable "AWS_CLOUDIFY3_MANAGER_URL" for orchestrator with name "Mount doom orchestrator"
    And I enable the orchestrator "Mount doom orchestrator"
    And I create a location named "Thark location" and infrastructure type "amazon" to the orchestrator "Mount doom orchestrator"
    And I create a resource of type "alien.cloudify.aws.nodes.InstanceType" named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "t2.small" for the resource named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.cloudify.aws.nodes.Image" named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "ami-47a23a30" for the resource named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I autogenerate the on-demand resources for the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.nodes.aws.PublicNetwork" named "Internet" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a new application with name "apache-autoheal-test" and description "Apache for autoheal test" based on the template with name "apache"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    And I set the following inputs properties
      | monitoring_interval_inMinute | 1 |

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
#    And The URL which is defined in attribute "url" of the node "Apache" should work

    # autoheal test
    When I delete one instance of the amazon compute node "Compute"
    And I wait for 120 seconds before continuing the test
    Then The node "Compute" should contain 1 instance(s) not started
    And all nodes instances must be in "started" state after 15 minutes
    And I wait for 5 seconds before continuing the test
    