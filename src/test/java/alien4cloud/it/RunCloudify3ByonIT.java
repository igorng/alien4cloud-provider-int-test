package alien4cloud.it;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/byon" }, format = { "pretty", "html:target/cucumber/cloudify3/byon",
        "json:target/cucumber/cloudify3/cucumber-byon.json" })
public class RunCloudify3ByonIT {
}
