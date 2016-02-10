Feature: Apache load balancer + tomcat
  # Tested features with this scenario:
  #   - Floating IP
  #   - Topology's output
  #   - concat function
  #   - get_operation_output function
  #   - Scale up/down : not implemented on cfy 3 at moment
  #   - Custom command
  #   - Deployment of tomcat and apache load balancer
  Scenario: Apache load balancer + tomcat
    Given I am authenticated with "ADMIN" role

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I upload the git archive "alien4cloud-extended-types/alien-base-types-1.0-SNAPSHOT"
    And I upload the git archive "alien4cloud-extended-types/alien-extended-storage-types-1.0-SNAPSHOT"
    And I checkout the git archive from url "https://github.com/alien4cloud/samples.git" branch "master"
    And I upload the git archive "samples/apache-load-balancer"
    And I upload the git archive "samples/tomcat-war"
    And I upload the git archive "samples/topology-load-balancer-tomcat"

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

    And I create a new application with name "load-balancer-cfy3" and description "Apache load balancer with CFY 3" based on the template with name "apache-load-balancer"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    And I set the following inputs properties
      | os_arch | x86_64 |
      | os_type | linux  |

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to Fastconnect !"
    And I should wait for 30 seconds before continuing the test

    When I trigger on the node template "War" the custom command "update_war_file" of the interface "custom" for application "load-balancer-cfy3" with parameters:
      | WAR_URL | https://github.com/alien4cloud/alien4cloud-provider-int-test/raw/develop/src/test/resources/data/helloWorld.war |
    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to testDeployArtifactOverriddenTest !"

    # Scale up/down part
    When I scale up the node "WebServer" by adding 1 instance(s)
    Then I should receive a RestResponse with no error
    And The node "War" should contain 2 instance(s) after at maximum 15 minutes
    # Test that it's load balanced !! And so we can sometimes get web page from the overidden one, sometimes from the original
    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to testDeployArtifactOverriddenTest !" and "Welcome to Fastconnect !"
    When I scale down the node "WebServer" by removing 1 instance(s)
    Then I should receive a RestResponse with no error
    And The node "War" should contain 1 instance(s) after at maximum 15 minutes
#  For the moment there are synchronization problem we disable this test for the moment
#    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to testDeployArtifactOverriddenTest !" or "Welcome to Fastconnect !"
#    And I should wait for 30 seconds before continuing the test