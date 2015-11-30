Feature: Deploy wordpress with cloudify 3
  # Tested features with this scenario:
  #   - Network
  #   - Clean up block storage if deletable_blockstorage is set
  #   - Deployment of wordpress
  Scenario: Wordpress
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I upload the git archive "alien4cloud-extended-types/alien-base-types-1.0-SNAPSHOT"
    And I upload the git archive "alien4cloud-extended-types/alien-extended-storage-types-1.0-SNAPSHOT"
    And I checkout the git archive from url "https://github.com/alien4cloud/samples.git" branch "master"
    And I upload the git archive "samples/apache"
    And I upload the git archive "samples/mysql"
    And I upload the git archive "samples/php"
    And I upload the git archive "samples/wordpress"
    And I upload the git archive "samples/topology-wordpress"

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
    And I create a resource of type "alien.nodes.openstack.PrivateNetwork" named "PrivateNetwork" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "cidr" to "192.168.1.0/24" for the resource named "PrivateNetwork" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "gateway_ip" to "192.168.1.1" for the resource named "PrivateNetwork" related to the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.nodes.openstack.PublicNetwork" named "Internet" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property complexe "floating_network_name" to "net-pub" of "floatingip" for the resource named "Internet" related to the location "Mount doom orchestrator"/"Thark location"

    # Application CFY 3
    And I create a new application with name "wordpress-cfy3" and description "Wordpress with CFY 3" based on the template with name "wordpress-template"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    And I add a node template "DbStorage" related to the "alien.nodes.ConfigurableBlockStorage:1.0-SNAPSHOT" node type
    And I update the node template "DbStorage"'s property "location" to "/var/mysql"
    And I update the node template "DbStorage"'s property "device" to "/dev/vdb"
    And I update the node template "DbStorage"'s property "file_system" to "ext4"
    And I update the node template "mysql"'s property "storage_path" to "/var/mysql"
    And I add a relationship of type "tosca.relationships.AttachTo" defined in archive "tosca-normative-types" version "1.0.0.wd06-SNAPSHOT" with source "DbStorage" and target "computeDb" for requirement "attachment" of type "tosca.capabilities.Attachment" and target capability "attach"
    And I add a node template "internet" related to the "tosca.nodes.Network:1.0.0.wd06-SNAPSHOT" node type
    And I add a relationship of type "tosca.relationships.Network" defined in archive "tosca-normative-types" version "1.0.0.wd06-SNAPSHOT" with source "computeWww" and target "internet" for requirement "network" of type "tosca.capabilities.Connectivity" and target capability "connection"
    And I add a node template "privateNetwork" related to the "tosca.nodes.Network:1.0.0.wd06-SNAPSHOT" node type
    And I add a relationship of type "tosca.relationships.Network" defined in archive "tosca-normative-types" version "1.0.0.wd06-SNAPSHOT" with source "computeDb" and target "privateNetwork" for requirement "network" of type "tosca.capabilities.Connectivity" and target capability "connection"
    And I add a relationship of type "tosca.relationships.Network" defined in archive "tosca-normative-types" version "1.0.0.wd06-SNAPSHOT" with source "computeWww" and target "privateNetwork" for requirement "network" of type "tosca.capabilities.Connectivity" and target capability "connection"
    When I substitute on the current application the node "internet" with the location resource "Mount doom orchestrator"/"Thark location"/"Internet"
    When I substitute on the current application the node "privateNetwork" with the location resource "Mount doom orchestrator"/"Thark location"/"PrivateNetwork"
    And I set the following inputs properties
      | os_arch | x86_64 |
      | os_type | linux |

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    And The URL which is defined in attribute "wordpress_url" of the node "wordpress" should work