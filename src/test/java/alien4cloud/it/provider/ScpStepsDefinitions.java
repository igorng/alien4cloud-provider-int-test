package alien4cloud.it.provider;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import junitx.framework.FileAssert;
import alien4cloud.it.provider.util.AttributeUtil;
import alien4cloud.it.provider.util.SSHUtil;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;

public class ScpStepsDefinitions {

    private static final String SCP_USER = "ubuntu";

    private static final int SCP_PORT = 22;

    private static final String PEM_PATH = "src/test/resources/keys/alienjenkins.pem";

    @When("^I upload the local file \"([^\"]*)\" to the node \"([^\"]*)\"'s remote path \"([^\"]*)\"$")
    public void I_upload_the_local_file_to_the_node_s_remote_path(String localFile, String nodeName, String remotePath) throws Throwable {
        SSHUtil.upload(SCP_USER, AttributeUtil.getAttribute(nodeName, "public_ip_address"), SCP_PORT, PEM_PATH, remotePath, localFile);
    }

    private static final String CURRENT_DOWNLOADED_FILE_PATH;

    static {
        try {
            CURRENT_DOWNLOADED_FILE_PATH = Files.createTempFile("provider-int-tst", "").toString();
        } catch (IOException e) {
            throw new RuntimeException("Unable to create temp file");
        }
    }

    @When("^I download the remote file \"([^\"]*)\" from the node \"([^\"]*)\"$")
    public void I_download_the_remote_file_from_the_node(String remoteFilePath, String nodeName) throws Throwable {
        SSHUtil.upload(SCP_USER, AttributeUtil.getAttribute(nodeName, "public_ip_address"), SCP_PORT, PEM_PATH, remoteFilePath, CURRENT_DOWNLOADED_FILE_PATH);
    }

    @Then("^The downloaded file should have the same content as the local file \"([^\"]*)\"$")
    public void The_downloaded_file_should_have_the_same_content_as_the_local_file(String localFilePath) throws Throwable {
        FileAssert.assertEquals(new File(localFilePath), new File(CURRENT_DOWNLOADED_FILE_PATH));
    }
}
