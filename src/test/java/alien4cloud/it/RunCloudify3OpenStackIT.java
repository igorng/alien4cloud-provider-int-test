package alien4cloud.it;

import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/openstack" }, format = { "pretty", "html:target/cucumber/cloudify3/openstack",
        "json:target/cucumber/cloudify3/cucumber-openstack.json" })
public class RunCloudify3OpenStackIT {
}
