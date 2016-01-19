package alien4cloud.it.provider;

import java.util.Map;

import lombok.extern.slf4j.Slf4j;

import org.elasticsearch.common.collect.Maps;

import alien4cloud.it.application.ApplicationStepDefinitions;
import alien4cloud.it.application.deployment.ApplicationsDeploymentStepDefinitions;
import alien4cloud.it.application.deployment.DeploymentTopologyStepDefinitions;
import alien4cloud.it.common.CommonStepDefinitions;
import alien4cloud.model.application.Application;
import cucumber.api.java.en.When;

@Slf4j
public class LongRunStepDefinitions {

    private static final ApplicationsDeploymentStepDefinitions APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS = new ApplicationsDeploymentStepDefinitions();

    private static final DeploymentTopologyStepDefinitions DEPLOYMENT_TOPOLOGY = new DeploymentTopologyStepDefinitions();

    private static final CommonStepDefinitions COMMON_STEP_DEFINITIONS = new CommonStepDefinitions();

    private static final ApplicationStepDefinitions APPLICATION = new ApplicationStepDefinitions();

    @When("^I loop deploying/undeploying applications using the topology template \"(.*?)\" and location \"([^\"]*)\"/\"([^\"]*)\"$")
    public void i_loop_deploying_undeploying_the_app(String templateName, String orchestratorName, String locationName) throws Throwable {
        int deployementCount = 0;
        while (true) {
            String appName = "MyLongRunAppApp-" + deployementCount++;
            log.info("Creating app '" + appName + "'");
            APPLICATION.I_create_a_new_application_with_name_and_description_based_on_the_template_with_name(appName, "a description", templateName);
            DEPLOYMENT_TOPOLOGY.I_Set_a_unique_location_policy_to_for_all_nodes(orchestratorName, locationName);
            log.info("Deploying app '" + appName + "'");
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_deploy_it();
            COMMON_STEP_DEFINITIONS.I_should_receive_a_RestResponse_with_no_error();
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.The_application_s_deployment_should_succeed_after_minutes(15);
            log.info("Undeploying app '" + appName + "'");
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_failsafe_undeploy_it();
            log.info("Undeployed app '" + appName + "'");
        }
    }

    @When("^I create and deploy (\\d+) applications using the topology template \"(.*?)\" and location \"([^\"]*)\"/\"([^\"]*)\"$")
    public void i_create_and_deploy_applications_using_the_topology_template_version(int appCount, String templateName, String orchestratorName,
            String locationName) throws Throwable {
        Map<Integer, Application> apps = Maps.newHashMap();
        for (int i = 0; i < appCount; i++) {
            String appName = "MyApp-" + i;
            log.info("Creating app '" + appName + "'");
            APPLICATION.I_create_a_new_application_with_name_and_description_based_on_the_template_with_name("MyApp-" + i, "a description", templateName);
            Application application = ApplicationStepDefinitions.CURRENT_APPLICATION;
            apps.put(i, application);
            DEPLOYMENT_TOPOLOGY.I_Set_a_unique_location_policy_to_for_all_nodes(orchestratorName, locationName);
            log.info("Deploying app '" + appName + "'");
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_deploy_it();
            COMMON_STEP_DEFINITIONS.I_should_receive_a_RestResponse_with_no_error();
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.The_application_s_deployment_should_succeed_after_minutes(15);
            log.info("Deployed app '" + appName + "'");
        }
        log.info("Now we will undeploy all computes...");
        for (Application app : apps.values()) {
            ApplicationStepDefinitions.CURRENT_APPLICATION = app;
            log.info("Undeploying app '" + app.getName() + "'");
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_failsafe_undeploy_it();
            log.info("Undeployed app '" + app.getName() + "'");
        }
    }

}
