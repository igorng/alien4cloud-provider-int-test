package alien4cloud.it.provider;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

import lombok.extern.slf4j.Slf4j;

import org.junit.Assert;

import alien4cloud.git.RepositoryManager;
import alien4cloud.it.Context;
import alien4cloud.it.application.ApplicationStepDefinitions;
import alien4cloud.it.application.deployment.ApplicationsDeploymentStepDefinitions;
import alien4cloud.it.common.CommonStepDefinitions;
import alien4cloud.it.orchestrators.OrchestratorsDefinitionsSteps;
import alien4cloud.rest.utils.RestClient;
import alien4cloud.utils.FileUtil;
import cucumber.api.java.After;
import cucumber.api.java.Before;
import cucumber.api.java.en.And;

@Slf4j
public class Setup {

    private static final RepositoryManager REPOSITORY_MANAGER = new RepositoryManager();

    private static final CommonStepDefinitions COMMON_STEP_DEFINITIONS = new CommonStepDefinitions();

    private static final ApplicationsDeploymentStepDefinitions APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS = new ApplicationsDeploymentStepDefinitions();

    private static final OrchestratorsDefinitionsSteps ORCHESTRATORS_DEFINITIONS_STEPS = new OrchestratorsDefinitionsSteps();

    static {
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                log.info("Wait for resources to be released on cloudify side before terminating the VM");
                // TODO For asynchronous problem of cloudify
                try {
                    Thread.sleep(60 * 1000L);
                } catch (InterruptedException e) {
                }
                log.info("Finished waiting, the VM will be terminated right after");
            }
        });
    }

    @Before
    public void beforeScenario() throws Throwable {
        log.info("Clean up before scenario");
        COMMON_STEP_DEFINITIONS.beforeScenario();
    }

    @After
    public void afterScenario() throws Throwable {
        if (ApplicationStepDefinitions.CURRENT_APPLICATION != null) {
            log.info("Clean up deployed application");
            APPLICATIONS_DEPLOYMENT_STEP_DEFINITIONS.I_undeploy_it();
            ApplicationStepDefinitions.CURRENT_APPLICATION = null;
        }
        ORCHESTRATORS_DEFINITIONS_STEPS.I_disable_all_orchestrators();
    }

    @And("^I checkout the git archive from url \"([^\"]*)\" branch \"([^\"]*)\"$")
    public void I_checkout_the_git_archive_from_url_branch(String gitURL, String branch) throws Throwable {
        String localDirectoryName = gitURL.substring(gitURL.lastIndexOf('/') + 1);
        if (localDirectoryName.endsWith(Context.GIT_URL_SUFFIX)) {
            localDirectoryName = localDirectoryName.substring(0, localDirectoryName.length() - Context.GIT_URL_SUFFIX.length());
        }
        REPOSITORY_MANAGER.cloneOrCheckout(Context.GIT_ARTIFACT_TARGET_PATH, gitURL, branch, localDirectoryName);
    }

    private void uploadArchive(Path source) throws Throwable {
        Path csarTargetPath = Context.CSAR_TARGET_PATH.resolve(source.getFileName() + ".csar");
        FileUtil.zip(source, csarTargetPath);
        Context.getInstance().registerRestResponse(Context.getRestClientInstance().postMultipart("/rest/csars", "file", Files.newInputStream(csarTargetPath)));
        COMMON_STEP_DEFINITIONS.I_should_receive_a_RestResponse_with_no_error();
    }

    @And("^I upload the git archive \"([^\"]*)\"$")
    public void I_upload_the_git_archive(String folderToUpload) throws Throwable {
        Path csarSourceFolder = Context.GIT_ARTIFACT_TARGET_PATH.resolve(folderToUpload);
        uploadArchive(csarSourceFolder);
    }

    @And("^I upload a plugin from maven artifact \"([^\"]*)\"$")
    public void I_upload_a_plugin_from_maven_artifact(String artifact) throws Throwable {
        String[] artifactTokens = artifact.split(":");
        Assert.assertTrue(artifactTokens.length == 2 || artifactTokens.length == 3);
        String version = Context.VERSION;
        if (artifactTokens.length == 3) {
            version = artifactTokens[2];
        }
        String repository;
        if (version.endsWith("SNAPSHOT")) {
            repository = "opensource-snapshot";
        } else {
            repository = "opensource";
        }
        String groupId = artifactTokens[0];
        String artifactId = artifactTokens[1];
        String artifactUrl = Context.FASTCONNECT_NEXUS + "r=" + repository + "&g=" + groupId + "&a=" + artifactId + "&v=" + version + "&p=zip";
        Path tempFile = Files.createTempFile(null, null);
        Files.copy(new RestClient(artifactUrl).getAsStream(""), tempFile, StandardCopyOption.REPLACE_EXISTING);
        Context.getInstance().registerRestResponse(Context.getRestClientInstance().postMultipart("/rest/plugins", "file", Files.newInputStream(tempFile)));
        COMMON_STEP_DEFINITIONS.I_should_receive_a_RestResponse_with_no_error();
    }

    @And("^I upload the local archive \"([^\"]*)\"$")
    public void I_upload_the_local_archive(String archive) throws Throwable {
        Path archivePath = Context.LOCAL_TEST_DATA_PATH.resolve(archive);
        uploadArchive(archivePath);
    }

    @And("^I should wait for (\\d+) seconds before continuing the test$")
    public void I_should_wait_for_seconds_before_continuing_the_test(int sleepTimeInSeconds) throws Throwable {
        I_wait_for_seconds_before_continuing_the_test(sleepTimeInSeconds);
    }

    @And("^I wait for (\\d+) seconds before continuing the test$")
    public void I_wait_for_seconds_before_continuing_the_test(int sleepTimeInSeconds) throws Throwable {
        log.info("Begin sleeping to wait before continuing the test");
        Thread.sleep(sleepTimeInSeconds * 1000L);
    }
}
