package alien4cloud.longrun;

import org.junit.Ignore;
import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@Ignore
@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/longruntest/openstack_incremental.feature" }, format = { "pretty",
        "html:target/cucumber/cloudify3/openstack_incremental", "json:target/cucumber/cloudify3/cucumber-openstack_incremental.json" })
public class RunCloudify3OpenStackLongRunIncrementalIT {
}
