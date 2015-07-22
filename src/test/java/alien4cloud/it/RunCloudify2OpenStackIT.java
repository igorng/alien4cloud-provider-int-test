package alien4cloud.it;

import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify2/openstack/"
// "classpath:features/cloudify2/openstack/multi_storages.feature"

}, format = { "pretty", "html:target/cucumber/cloudify2/openstack", "json:target/cucumber/cloudify2/cucumber-openstack.json" })
// @Ignore
public class RunCloudify2OpenStackIT {
}
