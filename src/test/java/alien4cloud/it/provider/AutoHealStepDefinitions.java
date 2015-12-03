package alien4cloud.it.provider;

import java.util.Map;

import lombok.extern.slf4j.Slf4j;
import alien4cloud.it.Context;
import alien4cloud.it.provider.util.RuntimePropertiesUtil;
import cucumber.api.java.en.When;

@Slf4j
public class AutoHealStepDefinitions {

    @When("^I delete one instance of the compute node \"([^\"]*)\"$")
    public void I_delete_one_instance_of_the_compute_node(String nodeName) throws Throwable {
        Map<String, String> iaaSComputeIds = RuntimePropertiesUtil.getProperties(nodeName, "external_id");
        String iaaSComputeId = iaaSComputeIds.entrySet().iterator().next().getValue();
        Context.getInstance().getOpenStackClient().deleteCompute(iaaSComputeId);
    }
}
