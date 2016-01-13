package alien4cloud.it;

import org.junit.Ignore;
import org.junit.runner.RunWith;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;

@Ignore
@RunWith(Cucumber.class)
@CucumberOptions(features = { "classpath:features/cloudify3/longruntest/amazon_incremental.feature" }, format = { "pretty",
        "html:target/cucumber/cloudify3/amazon_incremental", "json:target/cucumber/cloudify3/cucumber-amazon_incremental.json" })
public class RunCloudify3AmazonLongRunIncrementalIT {
}
