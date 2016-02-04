Feature: Deploy wordpress with cloudify 3 on a byon (nodes are on openstack)
  # Tested features with this scenario:
  #   - Deployment of wordpress on a byon
  #   - the pool-service csar

  Scenario: Wordpress byon
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
    And I upload the git archive "samples/host-pool-service"
    And I upload the git archive "samples/topology-host-pool-service"

    # Cloudify 3 plugin
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
#    And I upload a plugin "alien4cloud-cloudify3-provider" from "../a4c-cdfy3"
#    And I upload a plugin from "../alien4cloud-cloudify3-provider"

	### DEPLOY the POOL-SERVICE
    # Orchestrator and location
    And I create an orchestrator named "cdfy3-openstack" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "cdfy3-openstack"
    And I update cloudify 3 manager's url to value defined in environment variable "OPENSTACK_CLOUDIFY3_MANAGER_URL" for orchestrator with name "cdfy3-openstack"
    And I enable the orchestrator "cdfy3-openstack"
    And I create a location named "loc-openstack" and infrastructure type "openstack" to the orchestrator "cdfy3-openstack"
    And I create a resource of type "alien.nodes.openstack.Flavor" named "Small" related to the location "cdfy3-openstack"/"loc-openstack"
    And I update the property "id" to "6" for the resource named "Small" related to the location "cdfy3-openstack"/"loc-openstack"
    And I create a resource of type "alien.nodes.openstack.Image" named "Ubuntu" related to the location "cdfy3-openstack"/"loc-openstack"
    And I update the property "id" to "02ddfcbb-9534-44d7-974d-5cfd36dfbcab" for the resource named "Ubuntu" related to the location "cdfy3-openstack"/"loc-openstack"
    And I autogenerate the on-demand resources for the location "cdfy3-openstack"/"loc-openstack"
    And I create a resource of type "alien.nodes.openstack.PublicNetwork" named "Internet" related to the location "cdfy3-openstack"/"loc-openstack"
    And I update the complex property "floatingip" to """{"floating_network_name": "net-pub"}""" for the resource named "Internet" related to the location "cdfy3-openstack"/"loc-openstack"
    And I update the complex property "server" to """{"security_groups": ["openbar"]}""" for the resource named "Small_Ubuntu" related to the location "cdfy3-openstack"/"loc-openstack"


    ##prepare the pool-configuration
    And I create 2 instances of the openstack compute with options
    	| name | byon-linux |
    	|imageRef| 02ddfcbb-9534-44d7-974d-5cfd36dfbcab |
    	|flavorRef| 2 |
    	|keyPairName| a4c-manager |
    	|floatingIpPool| net-pub |
    And I generate an "unix" pool configuration with the created instances

    ## create and deloy the pool service
    And I create a new application with name "alien-pool-service" and description "pool service application" based on the template with name "host-pool-service-template"
    And I update the node template "HostPoolService"'s artifact "pool_config" with file at path "target/tmp/config.tar.gz"
    And I Set a unique location policy to "cdfy3-openstack"/"loc-openstack" for all nodes

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    And The URL which is defined in attribute "endpoint" of the node "HostPoolService" suffixed by "hosts" should work
    And I save the attribute "endpoint" of the node "HostPoolService" as "pool_endpoint"


	 ## BYON WORDPRESS
	 # Orchestrator and location
	 And I create an orchestrator named "cdfy3-byon" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
	 And I get configuration for orchestrator "cdfy3-byon"
	 And I update cloudify 3 manager's url to value defined in environment variable "OPENSTACK_CLOUDIFY3_MANAGER_URL" for orchestrator with name "cdfy3-byon"
	 And I enable the orchestrator "cdfy3-byon"
	 And I create a location named "loc-byon" and infrastructure type "byon" to the orchestrator "cdfy3-byon"
	 And I create a resource of type "alien.cloudify.byon.nodes.Compute" named "Small_Ubuntu" related to the location "cdfy3-byon"/"loc-byon"
	 And I update the property "host_pool_service_endpoint" to the saved attribute "pool_endpoint" for the resource named "Small_Ubuntu" related to the location "cdfy3-byon"/"loc-byon"

    # Wordpress Application
    And I create a new application with name "wordpress-cfy3" and description "Wordpress with CFY 3 Byon" based on the template with name "wordpress-template"
    And I Set a unique location policy to "cdfy3-byon"/"loc-byon" for all nodes
    And I set the following inputs properties
      | os_arch | x86_64 |
      | os_type | linux  |

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    And The URL which is defined in attribute "wordpress_url" of the node "wordpress" should work
