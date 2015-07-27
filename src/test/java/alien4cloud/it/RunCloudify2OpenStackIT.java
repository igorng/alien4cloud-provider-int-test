package alien4cloud.it;

import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify2/openstack/" }, format = { "pretty", "html:target/cucumber/cloudify2/openstack",
        "json:target/cucumber/cloudify2/cucumber-openstack.json" })
public class RunCloudify2OpenStackIT {
}
