Feature: Block storage
  # Tested bug with this scenario:
  #   - Empty parameter when calling a custom param should be resolved into an empty string instead of 'None'
  Scenario: Empty parameter for a custom command
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
	And I upload the local archive "csars/ALIEN-1190-test"
	And I upload the local archive "topologies/empty_parameter_custom_command.yml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
    
#    And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to value defined in environment variable "OPENSTACK_CLOUDIFY3_MANAGER_URL" for orchestrator with name "Mount doom orchestrator"
    And I enable the orchestrator "Mount doom orchestrator"
    And I create a location named "Thark location" and infrastructure type "openstack" to the orchestrator "Mount doom orchestrator"
    And I create a resource of type "alien.nodes.openstack.Flavor" named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "2" for the resource named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.nodes.openstack.Image" named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "02ddfcbb-9534-44d7-974d-5cfd36dfbcab" for the resource named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I autogenerate the on-demand resources for the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.nodes.openstack.PublicNetwork" named "Internet" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the complex property "floatingip" to """{"floating_network_name": "net-pub"}""" for the resource named "Internet" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the complex property "server" to """{"security_groups": ["openbar"]}""" for the resource named "Small_Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a new application with name "ALIEN-1190-test" and description "Test of empty parameter in custom command" based on the template with name "ALIEN-1190-template"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    
    When I trigger on the node template "customComp" the custom command "update" of the interface "custom" for application "ALIEN-1190-test"
    Then I should receive a RestResponse with no error
	And I wait for 30 seconds before continuing the test
    And I download the remote file "/home/ubuntu/customCommande.log" from the node "Compute" with the keypair "keys/openstack/alien.pem" and user "ubuntu"
    Then The downloaded file should have the same content as the local file "data/ALIEN-1190_customCommande.log"
    