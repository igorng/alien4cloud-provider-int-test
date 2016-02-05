Feature: Test scaling with linux compute + public network + volume with cloudify 3

  Scenario: Scale with volumes
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I upload the git archive "alien4cloud-extended-types/alien-extended-storage-types-1.0-SNAPSHOT"
    And I upload the local archive "topologies/scale_storage.yml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
#    And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to value defined in environment variable "OPENSTACK_CLOUDIFY3_MANAGER_URL" for orchestrator with name "Mount doom orchestrator"
    And I update "openstack" location import param for orchestrator with name "Mount doom orchestrator" using "http://www.getcloudify.org/spec/cloudify/3.3/types.yaml,openstack-plugin.yaml,http://www.getcloudify.org/spec/diamond-plugin/1.3/plugin.yaml"
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
    And I create a resource of type "alien.cloudify.openstack.nodes.Volume" named "SmallBlock" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "size" to "1 gib" for the resource named "SmallBlock" related to the location "Mount doom orchestrator"/"Thark location"

    # Application
    And I create a new application with name "scale_with_storage" and description "Scale with storage" based on the template with name "scale_storage"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    And I wait for 30 seconds before continuing the test
    And I should have a volume on OpenStack with id defined in property "volume_id" of the node "BlockStorage" for "scale_with_storage"
    And I should have a volume on OpenStack with id defined in property "volume_id" of the node "BlockStorage3" for "scale_with_storage"

    # Scale
    When I scale up the node "Compute" by adding 1 instance(s)
    Then I should receive a RestResponse with no error
    And The node "Compute" should contain 2 instance(s) after at maximum 15 minutes
    When I wait for 30 seconds before continuing the test
    And I should have volumes on OpenStack with ids defined in property "volume_id" of the node "BlockStorage" for "scale_with_storage"

    # upload data
    When I upload the local file "data/block_storage_test_file.txt" to the node "Compute" instance 0 remote path "/mnt/test/block_storage_test_file.txt" with the keypair "keys/openstack/alien.pem" and user "ubuntu"
    When I upload the local file "data/block_storage_test_file.txt" to the node "Compute" instance 1 remote path "/mnt/test/block_storage_test_file.txt" with the keypair "keys/openstack/alien.pem" and user "ubuntu"
    When I undeploy it
    Then I should receive a RestResponse with no error
    # change default instances and redeploy
    Given I update the node template "Compute"'s capability "scalable" of type "tosca.capabilities.Scalable"'s property "default_instances" to "2"
    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes

    # check that the volumes have been reused
    When I download the remote file "/mnt/test/block_storage_test_file.txt" from the node "Compute" instance 0 with the keypair "keys/openstack/alien.pem" and user "ubuntu"
    Then The downloaded file should have the same content as the local file "data/block_storage_test_file.txt"
    When I download the remote file "/mnt/test/block_storage_test_file.txt" from the node "Compute" instance 1 with the keypair "keys/openstack/alien.pem" and user "ubuntu"
    Then The downloaded file should have the same content as the local file "data/block_storage_test_file.txt"
    When I undeploy it
    Then I should have volumes on OpenStack with ids defined in property "volume_id" of the node "BlockStorage" for "scale_with_storage"
    Then I should have volumes on OpenStack with ids defined in property "volume_id" of the node "BlockStorage3" for "scale_with_storage"
    And I delete volumes on OpenStack with ids defined in property "volume_id" of the node "BlockStorage" for "scale_with_storage"
    And I delete volumes on OpenStack with ids defined in property "volume_id" of the node "BlockStorage3" for "scale_with_storage"