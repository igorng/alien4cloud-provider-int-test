package alien4cloud.it.provider;

import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;

public class ScpStepsDefinitions {

    private static final String SCP_USER = "ubuntu";

    private static final int SCP_PORT = 22;

    private static final String PEM_PATH = "src/test/resources/keys/alienjenkins.pem";

    @When("^I upload the local file \"([^\"]*)\" to the node \"([^\"]*)\"'s remote path \"([^\"]*)\"$")
    public void I_upload_the_local_file_to_the_node_s_remote_path(String localFile, String nodeName, String remotePath) throws Throwable {
    }

    @When("^I download the remote file \"([^\"]*)\" from the node \"([^\"]*)\"$")
    public void I_download_the_remote_file_from_the_node(String remoteFilePath, String nodeName) throws Throwable {
    }

    @Then("^The downloaded file should have the same content as the local file \"([^\"]*)\"$")
    public void The_downloaded_file_should_have_the_same_content_as_the_local_file(String localFilePath) throws Throwable {
    }
}
