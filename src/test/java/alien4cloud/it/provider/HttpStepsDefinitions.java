package alien4cloud.it.provider;

import java.util.Map;

import org.apache.commons.collections4.MapUtils;

import alien4cloud.it.Context;
import alien4cloud.it.application.ApplicationStepDefinitions;
import alien4cloud.it.provider.util.HttpUtil;
import alien4cloud.rest.model.RestResponse;
import alien4cloud.rest.utils.JsonUtil;
import cucumber.api.java.en.And;

public class HttpStepsDefinitions {

    @And("^The URL which is defined in attribute \"([^\"]*)\" of the node \"([^\"]*)\" should work$")
    public void The_URL_which_is_defined_in_attribute_of_the_node_should_work(String attributeName, String nodeName) throws Throwable {
        The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain(attributeName, nodeName, null);
    }

    @And("^The URL which is defined in attribute \"([^\"]*)\" of the node \"([^\"]*)\" should work and the html should contain \"([^\"]*)\"$")
    public void The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain(String attributeName, String nodeName,
            String expectedContent) throws Throwable {
        RestResponse<?> response = JsonUtil.read(Context.getRestClientInstance().get(
                "/rest/applications/" + ApplicationStepDefinitions.CURRENT_APPLICATION.getId() + "/environments/"
                        + Context.getInstance().getDefaultApplicationEnvironmentId(ApplicationStepDefinitions.CURRENT_APPLICATION.getName())
                        + "/deployment/informations"));
        Map<String, Object> instancesInformation = (Map<String, Object>) response.getData();
        org.junit.Assert.assertFalse(MapUtils.isEmpty(instancesInformation));
        Map<String, Object> nodeInformation = (Map<String, Object>) instancesInformation.get(nodeName);
        org.junit.Assert.assertFalse(MapUtils.isEmpty(nodeInformation));
        Map<String, Object> instanceInformation = (Map<String, Object>) nodeInformation.values().iterator().next();
        Map<String, Object> attributes = (Map<String, Object>) instanceInformation.get("attributes");
        String url = (String) attributes.get(attributeName);
        HttpUtil.checkUrl(url, expectedContent, 2 * 60 * 1000L);
    }
}
