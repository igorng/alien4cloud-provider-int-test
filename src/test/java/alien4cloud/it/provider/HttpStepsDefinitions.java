package alien4cloud.it.provider;

import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;

import org.junit.Assert;

import alien4cloud.it.provider.util.AttributeUtil;
import alien4cloud.it.provider.util.HttpUtil;
import cucumber.api.java.en.And;

public class HttpStepsDefinitions {

    @And("^The URL which is defined in attribute \"([^\"]*)\" of the node \"([^\"]*)\" should work$")
    public void The_URL_which_is_defined_in_attribute_of_the_node_should_work(String attributeName, String nodeName) throws Throwable {
        The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain(attributeName, nodeName, null);
    }

    @And("^The URL which is defined in attribute \"([^\"]*)\" of the node \"([^\"]*)\" should work and the html should contain \"([^\"]*)\"$")
    public void The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain(String attributeName, String nodeName, String expectedContent) throws Throwable {
        HttpUtil.checkUrl(AttributeUtil.getAttribute(nodeName, attributeName), expectedContent, 2 * 60 * 1000L);
    }

    @And("^The URL\\(s\\) which are defined in attribute \"([^\"]*)\" of the (\\d+) instance\\(s\\) of the node \"([^\"]*)\" should work and the html should contain \"([^\"]*)\"$")
    public void The_URL_s_which_are_defined_in_attribute_of_the_instance_s_of_the_node_should_work_and_the_html_should_contain(String attributeName, int numberOfInstances, String nodeName, String expectedContent) throws Throwable {
        Map<String, String> allAttributes = AttributeUtil.getAttributes(nodeName, attributeName);
        Assert.assertEquals(numberOfInstances, allAttributes.size());
        for (String url : allAttributes.values()) {
            HttpUtil.checkUrl(url, expectedContent, 2 * 60 * 1000L);
        }
    }

    @And("^The URL which is defined in attribute \"([^\"]*)\" of the node \"([^\"]*)\" should work and the html should contain \"([^\"]*)\" and \"([^\"]*)\"$")
    public void The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain_and(String attributeName, String nodeName, String expectedContent, String otherExpectedContent) throws Throwable {
        The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain(attributeName, nodeName, expectedContent);
        The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain(attributeName, nodeName, otherExpectedContent);
    }

    @And("^The URL which is defined in attribute \"([^\"]*)\" of the node \"([^\"]*)\" should work and the html should contain \"([^\"]*)\" or \"([^\"]*)\"$")
    public void The_URL_which_is_defined_in_attribute_of_the_node_should_work_and_the_html_should_contain_or(final String attributeName, final String nodeName, final String expectedContent, String otherExpectedContent) throws Throwable {
//        ExecutorService executor = Executors.newCachedThreadPool(new ThreadFactory() {
//            @Override
//            public Thread newThread(Runnable r) {
//                return null;
//            }
//        });
    }
}
