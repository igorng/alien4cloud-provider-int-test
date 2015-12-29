package alien4cloud.it.provider;

import lombok.extern.slf4j.Slf4j;
import alien4cloud.it.application.deployment.ApplicationsDeploymentStepDefinitions;
import alien4cloud.it.common.CommonStepDefinitions;
import cucumber.api.java.en.When;

@Slf4j
public class LongRunStepDefinitions {

    private static final ApplicationsDeploymentStepDefinitions APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS = new ApplicationsDeploymentStepDefinitions();

    private static final CommonStepDefinitions COMMON_STEP_DEFINITIONS = new CommonStepDefinitions();

    @When("^I loop deploying/undeploying the app$")
    public void i_loop_deploying_undeploying_the_app() throws Throwable {
        int deployementCount = 0;
        while (true) {
            log.info("=============== Starting deployment #" + ++deployementCount);
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_deploy_it();
            COMMON_STEP_DEFINITIONS.I_should_receive_a_RestResponse_with_no_error();
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.The_application_s_deployment_must_succeed_after_minutes(15);
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_undeploy_it();
            COMMON_STEP_DEFINITIONS.I_should_receive_a_RestResponse_with_no_error();
            try {
                Thread.sleep(60 * 1000L);
            } catch (InterruptedException e) {
            }
            log.info("=============== Ended deployment #" + deployementCount);
        }
    }

}
