package alien4cloud.it;

import org.junit.Ignore;
import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@Ignore
@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/longruntest/openstack_longrun.feature" }, format = { "pretty", "html:target/cucumber/cloudify3/openstack_longrun",
        "json:target/cucumber/cloudify3/cucumber-openstack_longrun.json" })
public class RunCloudify3OpenStackLongRunIT {
}
