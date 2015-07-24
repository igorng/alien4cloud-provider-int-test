Feature: Apache load balancer + tomcat
  # Tested features with this scenario:
  #   - Floating IP
  #   - Topology's output
  #   - concat function
  #   - get_operation_output function
  #   - Scale up/down
  #   - Custom command
  #   - Deployment of tomcat and apache load balancer
  Scenario: Apache load balancer + tomcat
    Given I am authenticated with "ADMIN" role
    And I have already created a cloud image with name "Ubuntu Trusty", architecture "x86_64", type "linux", distribution "Ubuntu" and version "14.04.1"

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
    And I create a cloud with name "Cloudify 3" from cloudify 3 PaaS provider
    And I update cloudify 3 manager's url to the OpenStack's jenkins management server for cloud with name "Cloudify 3"
    And I enable the cloud "Cloudify 3"
    And I add the cloud image "Ubuntu Trusty" to the cloud "Cloudify 3" and match it to paaS image "02ddfcbb-9534-44d7-974d-5cfd36dfbcab"
    And I add the flavor with name "small", number of CPUs 2, disk size 34359738368 and memory size 2147483648 to the cloud "Cloudify 3" and match it to paaS flavor "2"
    And I add the public network with name "public" to the cloud "Cloudify 3" and match it to paaS network "net-pub"

    And I create a new application with name "load-balancer-cfy3" and description "Apache load balancer with CFY 3" based on the template with name "apache-load-balancer"
    And I assign the cloud with name "Cloudify 3" for the application
    And I set the input property "os_arch" of the topology to "x86_64"
    And I set the input property "os_type" of the topology to "linux"

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 15 minutes
    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to Fastconnect !"

    When I trigger on the node template "War" the custom command "update_war_file" of the interface "custom" for application "load-balancer-cfy3" with parameters:
      | WAR_URL | https://github.com/alien4cloud/alien4cloud-provider-int-test/raw/develop/src/test/resources/data/helloWorld.war |
    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to testDeployArtifactOverriddenTest !"

    When I scale up the node "WebServer" by adding 1 instance(s)
    Then I should receive a RestResponse with no error
    And The node "War" should contain 2 instance(s) after at maximum 15 minutes
    # Test that it's load balanced !! And so we can sometimes get web page from the overidden one, sometimes from the original
    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to testDeployArtifactOverriddenTest !" and "Welcome to Fastconnect !"
    When I scale down the node "WebServer" by removing 1 instance(s)
    Then I should receive a RestResponse with no error
    And The node "War" should contain 1 instance(s) after at maximum 15 minutes
  # For the moment there are synchronization problem we disable this test for the moment
#    And The URL which is defined in attribute "load_balancer_url" of the node "ApacheLoadBalancer" should work and the html should contain "Welcome to testDeployArtifactOverriddenTest !" or "Welcome to Fastconnect !"
#    And I should wait for 30 seconds before continuing the test