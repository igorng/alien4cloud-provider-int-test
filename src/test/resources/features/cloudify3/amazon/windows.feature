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
    And I upload the local archive "topologies/windows_amazon.yaml"

    # Cloudify 3
    And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
#    And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to value defined in environment variable "AWS_CLOUDIFY3_MANAGER_URL" for orchestrator with name "Mount doom orchestrator"
    And I enable the orchestrator "Mount doom orchestrator"
    And I create a location named "Thark location" and infrastructure type "amazon" to the orchestrator "Mount doom orchestrator"

    And I create a resource of type "alien.cloudify.aws.nodes.WindowsCompute" named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "image_id" to "ami-4b80bf3c" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "instance_type" to "m3.medium" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "key_pair" to the environment variable "AWS_KEY_NAME" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "user" to "cloudify" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "password" to "Cl@ud1fy234!" for the resource named "MediumWindows" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a resource of type "alien.nodes.aws.PublicNetwork" named "Internet" related to the location "Mount doom orchestrator"/"Thark location"

    And I create a new application with name "windows" and description "Windows with CFY 3" based on the template with name "windows"
    And I Set a unique location policy to "Mount doom orchestrator"/"Thark location" for all nodes
    When I substitute on the current application the node "PublicNetwork" with the location resource "Mount doom orchestrator"/"Thark location"/"Internet"

    When I deploy it
    Then I should receive a RestResponse with no error
    And The application's deployment must succeed after 40 minutes