Feature: Reuse block storage with cloudify 3

  Scenario: Reuse of block storage should work
    Given I am authenticated with "ADMIN" role
    And I have already created a cloud image with name "Ubuntu Trusty", architecture "x86_64", type "linux", distribution "Ubuntu" and version "14.04.1"

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I upload the git archive "alien4cloud-extended-types/alien-base-types-1.0-SNAPSHOT"
    And I upload the git archive "alien4cloud-extended-types/alien-extended-storage-types-1.0-SNAPSHOT"
    And I upload the local archive "topologies/block_storage.yaml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
    And I create a cloud with name "Cloudify 3" from cloudify 3 PaaS provider
    And I update cloudify 3 manager's url to "http://129.185.67.110:8100" for cloud with name "Cloudify 3"
    And I enable the cloud "Cloudify 3"
    And I add the cloud image "Ubuntu Trusty" to the cloud "Cloudify 3" and match it to paaS image "02ddfcbb-9534-44d7-974d-5cfd36dfbcab"
    And I add the flavor with name "small", number of CPUs 2, disk size 34359738368 and memory size 2147483648 to the cloud "Cloudify 3" and match it to paaS flavor "2"
    And I add the storage with id "SmallBlock" and device "/dev/vdb" and size 1073741824 to the cloud "Cloudify 3"
    And I add the public network with name "public" to the cloud "Cloudify 3" and match it to paaS network "net-pub"

    And I create a new application with name "block-storage-cfy3" and description "Block Storage with CFY 3" based on the template with name "block_storage"
    And I add a node template "internet" related to the "tosca.nodes.Network:1.0.0.wd03-SNAPSHOT" node type
    And I add a relationship of type "tosca.relationships.Network" defined in archive "tosca-normative-types" version "1.0.0.wd03-SNAPSHOT" with source "Compute" and target "internet" for requirement "network" of type "tosca.capabilities.Connectivity" and target capability "connection"
    And I assign the cloud with name "Cloudify 3" for the application

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 10 minutes

    When I upload the local file "data/block_storage_test_file.txt" to the node "Compute"'s remote path "/var/myTestVolume/block_storage_test_file.txt" with the keypair "keys/cfy3.pem" and user "ubuntu"
    And I re-deploy the application
    Then The application's deployment must succeed after 10 minutes

    When I download the remote file "/var/myTestVolume/block_storage_test_file.txt" from the node "Compute" with the keypair "keys/cfy3.pem" and user "ubuntu"
    Then The downloaded file should have the same content as the local file "data/block_storage_test_file.txt"