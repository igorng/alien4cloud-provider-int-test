package alien4cloud.it;

import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/amazon/" }, format = { "pretty", "html:target/cucumber/cloudify3/amazon",
        "json:target/cucumber/cloudify3/cucumber-amazon.json" })
public class RunCloudify3AmazonIT {
}
