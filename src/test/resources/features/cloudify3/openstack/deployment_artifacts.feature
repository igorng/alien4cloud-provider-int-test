Feature: Usage of deployment artifacts with cloudify 3
  # Tested features with this scenario:
  #   - Deployment artifact as a file and directory for nodes and relationships
  #   - Override deployment artifact in Alien
  Scenario: Usage of deployment artifacts with cloudify 3
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I upload the local archive "csars/artifact-test"
    And I upload the local archive "topologies/artifact_test.yaml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
    # And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin id "alien-cloudify-3-orchestrator:1.1.0-SM8-SNAPSHOT" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to the OpenStack's jenkins management server for orchestrator with name "Mount doom orchestrator"
    And I enable the orchestrator "Mount doom orchestrator"
    And I create a location named "Thark location" and infrastructure type "openstack" to the orchestrator "Mount doom orchestrator"
    And I create a resource of type "alien.nodes.openstack.Flavor" named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "2" for the resource named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.nodes.openstack.Image" named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "02ddfcbb-9534-44d7-974d-5cfd36dfbcab" for the resource named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I autogenerate the on-demand resources for the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.nodes.openstack.PublicNetwork" named "Internet" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property complexe "floating_network_name" to "net-pub" of "floatingip" for the resource named "Internet" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a new application with name "artifact-test-cfy3" and description "Artifact test with CFY 3" based on the template with name "artifact_test"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    And I update the node template "Artifacts"'s artifact "to_be_overridden" with file at path "src/test/resources/data/toOverride.txt"

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    When I download the remote file "/home/ubuntu/toBeOverridden.txt" from the node "Compute" with the keypair "keys/cfy3.pem" and user "ubuntu"
    Then The downloaded file should have the same content as the local file "data/toOverride.txt"
    When I download the remote file "/home/ubuntu/toBePreserved.txt" from the node "Compute" with the keypair "keys/cfy3.pem" and user "ubuntu"
    Then The downloaded file should have the same content as the local file "csars/artifact-test/toBePreserved.txt"
