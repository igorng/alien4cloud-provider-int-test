package alien4cloud.it;

import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/openstack_longruntest" }, format = { "pretty", "html:target/cucumber/cloudify3/longruntest",
        "json:target/cucumber/cloudify3/cucumber-longruntest.json" })
public class RunCloudify3OpenStackLongRunIT {
}
