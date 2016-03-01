Feature: Deploy wordpress with cloudify 3
  # Tested features with this scenario:
  #   - Deployment of N computes
  Scenario: Compute Long Run on Amazon
    Given I am authenticated with "ADMIN" role

    And I checkout the git archive from url "https://github.com/alien4cloud/tosca-normative-types.git" branch "master"
    And I upload the git archive "tosca-normative-types"
    #And I upload a plugin from maven artifact "alien4cloud:alien4cloud-cloudify3-provider"
    And I upload a plugin from "../alien4cloud-cloudify3-provider"

    # Orchestrator and location
    And I create an orchestrator named "Mount doom orchestrator" and plugin name "alien-cloudify-3-orchestrator" and bean name "cloudify-orchestrator"
    And I get configuration for orchestrator "Mount doom orchestrator"
    And I update cloudify 3 manager's url to value defined in environment variable "AWS_CLOUDIFY3_MANAGER_URL" for orchestrator with name "Mount doom orchestrator"
    And I update "amazon" location import param for orchestrator with name "Mount doom orchestrator" using "http://www.getcloudify.org/spec/cloudify/3.3/types.yaml,http://www.getcloudify.org/spec/aws-plugin/1.3/plugin.yaml,http://www.getcloudify.org/spec/diamond-plugin/1.3/plugin.yaml"
    And I enable the orchestrator "Mount doom orchestrator"
    And I create a location named "Thark location" and infrastructure type "amazon" to the orchestrator "Mount doom orchestrator"
    And I create a resource of type "alien.cloudify.aws.nodes.InstanceType" named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "t2.nano" for the resource named "Small" related to the location "Mount doom orchestrator"/"Thark location"
    And I create a resource of type "alien.cloudify.aws.nodes.Image" named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I update the property "id" to "ami-47a23a30" for the resource named "Ubuntu" related to the location "Mount doom orchestrator"/"Thark location"
    And I autogenerate the on-demand resources for the location "Mount doom orchestrator"/"Thark location"

    And I create a new topology template with name "topology_template" and description "My topology template description1" and node templates
        | Compute | tosca.nodes.Compute:1.0.0-SNAPSHOT |

    When I create and deploy 100 applications using the topology template "topology_template" and location "Mount doom orchestrator"/"Thark location"
