Feature: Windows with cloudify 3
  # Tested features with this scenario:
  #   - Instantiation of windows vm with block storage and network
  #   - Execute batch script
  Scenario: Usage of windows with cloudify 3
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I checkout the git archive from url "https://github.com/alien4cloud/samples.git" branch "master"
    And I upload the git archive "alien4cloud-extended-types/alien-base-types-1.0-SNAPSHOT"
    And I upload the git archive "samples/helloWindows"
    And I upload the local archive "topologies/windows.yaml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
#    And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to the OpenStack's jenkins management server for orchestrator with name "Mount doom orchestrator"
    And I enable the orchestrator "Mount doom orchestrator"
    And I create a location named "Thark location" and infrastructure type "openstack" to the orchestrator "Mount doom orchestrator"

    And I create a resource of type "alien.nodes.openstack.WindowsCompute" named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "image" to "53e6ef20-a087-44d1-9bdb-5c7f4bffad5b" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "flavor" to "3" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "key_pair" to "a4c-manager" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the complex property "server" to """{"security_groups": ["openbar"]}""" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a resource of type "alien.nodes.openstack.PrivateNetwork" named "PrivateNetwork" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "cidr" to "192.168.1.0/24" for the resource named "PrivateNetwork" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "gateway_ip" to "192.168.1.1" for the resource named "PrivateNetwork" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a resource of type "alien.nodes.openstack.PublicNetwork" named "Internet" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the complex property "floatingip" to """{"floating_network_name": "net-pub"}""" for the resource named "Internet" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a new application with name "windows" and description "Windows with CFY 3" based on the template with name "windows"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    When I substitute on the current application the node "PublicNetwork" with the location resource "Mount doom orchestrator"/"Thark location"/"Internet"
    When I substitute on the current application the node "PrivateNetwork" with the location resource "Mount doom orchestrator"/"Thark location"/"PrivateNetwork"

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 40 minutes