package alien4cloud.it.provider;

import alien4cloud.it.orchestrators.OrchestratorsConfigurationDefinitionsSteps;
import org.apache.commons.collections4.MapUtils;

import cucumber.api.java.en.Given;

public class DefaultValuesStepDefinitions {

    private static final String CDFY_URL_KEY = "CDFY_URL";
    private static final String CDFY_USERNAME_KEY = "CDFY_USERNAME";
    private static final String CDFY_PASSWORD_KEY = "CDFY_PASSWORD";
    private static final String DEFAULT_CDFY_URL = "https://129.185.67.22:8100";
    private static final String DEFAULT_CDFY_USERNAME = "Superuser";
    private static final String DEFAULT_CDFY_PASSWORD = "Superuser";

    @Given("^I set cloudify (\\d+) management url, login and password with the default provided environment values for cloud with name \"([^\"]*)\"$")
    public void I_set_cloudify_management_url_login_and_password_with_the_default_provided_environment_values_for_cloud_with_name(int cloudifyVersion,
            String cloudName) throws Throwable {
        String url = MapUtils.getString(System.getenv(), CDFY_URL_KEY, DEFAULT_CDFY_URL);
        String login = MapUtils.getString(System.getenv(), CDFY_USERNAME_KEY, DEFAULT_CDFY_USERNAME);
        String password = MapUtils.getString(System.getenv(), CDFY_PASSWORD_KEY, DEFAULT_CDFY_PASSWORD);
        new OrchestratorsConfigurationDefinitionsSteps().I_update_cloudify_manager_s_url_to_with_login_and_password_for_cloud_with_name(cloudifyVersion, url, login, password,
                cloudName);
    }

}
