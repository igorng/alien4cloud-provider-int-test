Feature: Deploy samples with cloudify 2

  Scenario: Tomcat
    Given I am authenticated with "ADMIN" role
    And I have already created a cloud image with name "Ubuntu Trusty", architecture "x86_64", type "linux", distribution "Ubuntu" and version "14.04.1"

    # Archives
    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    And I checkout the git archive from url "https://github.com/alien4cloud/alien4cloud-extended-types.git" branch "master"
    And I upload the git archive "alien4cloud-extended-types/alien-base-types-1.0-SNAPSHOT"
    And I upload the git archive "alien4cloud-extended-types/alien-extended-storage-types-1.0-SNAPSHOT"
    And I checkout the git archive from url "https://github.com/alien4cloud/samples.git" branch "master"
    And I upload the git archive "samples/tomcat-war"
    And I upload the git archive "samples/topology-tomcatWar"

    # Cloudify 2
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify2-provider"
    And I create a cloud with name "Cloudify 2" from cloudify 2 PaaS provider
#    And I update cloudify 2 manager's url to "https://129.185.67.39:8100" with login "Superuser" and password "Superuser" for cloud with name "Cloudify 2"
    And I update cloudify 2 manager's url to "http://129.185.67.97:8100" for cloud with name "Cloudify 2"
    And I enable the cloud "Cloudify 2"
    And I add the cloud image "Ubuntu Trusty" to the cloud "Cloudify 2" and match it to paaS image "RegionOne/c3fcd822-0693-4fac-b8bb-c0f268225800"
    And I add the flavor with name "small", number of CPUs 2, disk size 34359738368 and memory size 2147483648 to the cloud "Cloudify 2" and match it to paaS flavor "RegionOne/2"

    # Application CFY 2
    And I create a new application with name "tomcat-cfy2" and description "Tomcat with CFY 2" based on the template with name "tomcat-war-0.1.0-SNAPSHOT"
    And I assign the cloud with name "Cloudify 2" for the application
    And I set the input property "os_arch" of the topology to "x86_64"
    And I set the input property "os_type" of the topology to "linux"
    And I give deployment properties:
      | deletable_blockstorage          | true |
      | disable_self_healing            | true |
      | events_lease_inHour             | 2    |
      | startDetection_timeout_inSecond | 600  |
    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 10 minutes
    And The URL which is defined in attribute "application_url" of the node "War" should work and the html should contain "Fastconnect"