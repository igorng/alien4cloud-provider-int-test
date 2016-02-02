package alien4cloud.it.provider;

import alien4cloud.it.Context;
import alien4cloud.it.exception.ITException;
import alien4cloud.it.orchestrators.OrchestrationLocationResourceSteps;
import alien4cloud.it.provider.util.AttributeUtil;
import alien4cloud.it.provider.util.OpenStackClient;
import alien4cloud.tosca.serializer.VelocityUtil;
import alien4cloud.utils.FileUtil;
import com.google.common.collect.Maps;
import cucumber.api.java.en.When;
import java.io.FileWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.MapUtils;
import org.apache.commons.lang3.StringUtils;
import org.elasticsearch.common.collect.Lists;
import org.jclouds.openstack.neutron.v2.domain.Network;
import org.jclouds.openstack.nova.v2_0.domain.FloatingIP;
import org.jclouds.openstack.nova.v2_0.domain.Server;
import org.jclouds.openstack.nova.v2_0.domain.ServerCreated;
import org.jclouds.openstack.nova.v2_0.options.CreateServerOptions;
import org.junit.Assert;

@Slf4j
public class ByonStepDefinitions {

    private static final String IMAGE_REF = "imageRef";
    private static final String FLAVOR_REF = "flavorRef";
    private static final String NAME = "name";

    private static Map<String, String> SAVED_ATTR = Maps.newHashMap();
    public static Map<String, ComputeInstance> CREATED_COMPUTES = Maps.newHashMap();

    private OrchestrationLocationResourceSteps orchestrationLocationResourceSteps = new OrchestrationLocationResourceSteps();

    @When("^I create (\\d+) instances of the openstack compute with options$")
    public void I_create_instance_s_of_the_openstack_compute(int count, Map<String, String> options) throws Throwable {
        String baseName = getAndAssertNotEmpty(NAME, options);
        String imageRef = getAndAssertNotEmpty(IMAGE_REF, options);
        String flavorRef = getAndAssertNotEmpty(FLAVOR_REF, options);

        CreateServerOptions createOption = buildOptions(options);
        OpenStackClient osClient = Context.getInstance().getOpenStackClient();

        for (int i = 0; i < count; i++) {
            String name = count > 1 ? baseName.concat("-").concat("" + (i + 1)) : baseName;

            ServerCreated server = osClient.create(name, imageRef, flavorRef, createOption);
            String ipAddress = waitServerStatus(server.getId(), "Active", 1);

            // floatin Ip
            FloatingIP floatingIp = null;
            String floatingIpPool = MapUtils.getString(options, "floatingIpPool");
            if (StringUtils.isNotBlank(floatingIpPool)) {
                floatingIp = osClient.associateFloationgIpToServer(server.getId(), floatingIpPool);
            }

            OpenstackComputeInstance instance = new OpenstackComputeInstance();
            instance.setId(server.getId());
            instance.setIpAddress(ipAddress);
            instance.setName(name);
            instance.setFloatingIp(floatingIp);
            CREATED_COMPUTES.put(name, instance);
        }

    }

    private String waitServerStatus(String serverId, String expectedStatus, int numberOfMinutes) throws Throwable {
        OpenStackClient osClient = Context.getInstance().getOpenStackClient();
        Server server = osClient.getServer(serverId);
        long timeout = numberOfMinutes * 60L * 1000L;
        long now = System.currentTimeMillis();
        while (true) {
            if (System.currentTimeMillis() - now > timeout) {
                throw new ITException("Expected created compute <" + server.getName() + ":" + server.getId() + "> to be in status [" + expectedStatus
                        + "] but Test has timeouted");
            }
            boolean ok = true;
            server = osClient.getServer(serverId);
            if (!Objects.equals(server.getStatus().toString().toLowerCase(), expectedStatus.toLowerCase())) {
                Thread.sleep(1000L);
                ok = false;
            }
            if (ok) {
                return server.getAddresses().values().iterator().next().getAddr();
            }
        }
    }

    private CreateServerOptions buildOptions(Map<String, String> optionsMap) {

        CreateServerOptions options = new CreateServerOptions();
        options.keyPairName(MapUtils.getString(optionsMap, "keyPairName"));
        OpenStackClient osClient = Context.getInstance().getOpenStackClient();

        // security groups
        String secGroups = MapUtils.getString(optionsMap, "securityGroups");
        if (StringUtils.isNotBlank(secGroups)) {
            String[] splitted = secGroups.split(",");
            options.securityGroupNames(splitted);
        } else {
            options.securityGroupNames("openbar");
        }

        // networks
        // By default, create in the same network as the manager
        String networks = MapUtils.getString(optionsMap, "networksIds");
        if (StringUtils.isNotBlank(networks)) {
            String[] splitted = networks.split(",");
            options.networks(splitted);
        } else {
            String managerName = Context.getInstance().getAppProperty("openstack.cfy3.manager_name");
            String managerNetworkName = osClient.getServerNetworksNames(managerName).iterator().next();
            Network network = osClient.findNetworkByName(managerNetworkName);
            Assert.assertNotNull("Cannot find the manager private network " + managerNetworkName, network);
            options.networks(network.getId());
        }

        return options;
    }

    private String getAndAssertNotEmpty(String propertyName, Map<String, String> map) {
        String value = MapUtils.getString(map, propertyName);
        Assert.assertNotNull(propertyName + " Should not be provided.", value);
        return value;
    }

    @When("^I generate an \"(.*?)\" pool configuration with the created instances$")
    public void I_generate_an_pool_configuration_with_the_created_instances(String poolConfigType) throws Throwable {
        Map<String, Object> properties = Maps.newHashMap();
        String keyFilename = "alien";
        String username = null;
        String port = null;
        String password = null;
        switch (poolConfigType) {
        case "unix":
            username = "ubuntu";
            port = "22";
            break;
        case "windows":
            username = "root";
            port = "5985";
            password = "clouD?B";
            break;

        default:
            break;
        }

        List<Host> hosts = fromRegisteredOpenstackComputeToHost();

        properties.put("username", username);
        properties.put("port", port);
        properties.put("keyFileName", keyFilename);
        properties.put("hosts", hosts);
        properties.put("password", password);

        Path poolTemplate = Paths.get("host-pool-service/config/pool.yml.vm");
        Path configFolder = Context.getInstance().getTmpDirectory().resolve("config");
        FileUtil.delete(configFolder);
        Path poolPath = configFolder.resolve("pool.yml");
        FileUtil.touch(poolPath);
        VelocityUtil.generate(poolTemplate.toString(), new FileWriter(poolPath.toFile()), properties);

        // copy keys
        FileUtil.copy(Paths.get("src/test/resources/keys/openstack/alien.pem"), configFolder.resolve("keys/alien.pem"), StandardCopyOption.REPLACE_EXISTING);
        // zip it
        Path configZipPath = Context.getInstance().getTmpDirectory().resolve("config.tar.gz");
        FileUtil.delete(configZipPath);
        FileUtil.tar(configFolder, configZipPath, true, false);
    }

    @When("^I save the attribute \"(.*?)\" of the node \"(.*?)\" as \"(.*?)\"$")
    public void I_save_the_attribute_of_the_node(String attributeName, String nodeName, String saveAs) throws Throwable {
        String attribute = AttributeUtil.getAttribute(nodeName, attributeName);
        SAVED_ATTR.put(saveAs, attribute);
    }

    @When("^I update the property \"([^\"]*)\" to the saved attribute \"([^\"]*)\" for the resource named \"([^\"]*)\" related to the location \"([^\"]*)\"/\"([^\"]*)\"$")
    public void I_update_the_property_to_the_saved_attribute_for_the_resource_named_related_to_the_location(String propertyName, String savedAttributeName,
            String resourceName, String orchestratorName, String locationName) throws Throwable {
        String propertyValue = SAVED_ATTR.get(savedAttributeName);
        orchestrationLocationResourceSteps.I_update_the_property_to_for_the_resource_named_related_to_the_location_(propertyName, propertyValue, resourceName,
                orchestratorName, locationName);
    }

    private List<Host> fromRegisteredOpenstackComputeToHost() {
        List<Host> hosts = Lists.newArrayList();
        Map<String, ComputeInstance> instances = CREATED_COMPUTES;
        if (MapUtils.isNotEmpty(instances)) {
            for (ComputeInstance instance : instances.values()) {
                if (instance instanceof OpenstackComputeInstance) {
                    Host host = new Host();
                    host.ipAddress = instance.getIpAddress();
                    if (StringUtils.isNotBlank(instance.getFloatingIpAddress())) {
                        host.publicAddress = instance.getFloatingIpAddress();
                        hosts.add(host);
                    }
                }
            }
        }
        return hosts;
    }

    @Getter
    @Setter
    public static class OpenstackComputeInstance implements ComputeInstance {
        private String name;
        private String id;
        private String ipAddress;
        private FloatingIP floatingIp;

        @Override
        public String getFloatingIpAddress() {
            return floatingIp != null ? floatingIp.getIp() : null;
        }

        @Override
        public String getFloatingIpId() {
            return floatingIp != null ? floatingIp.getId() : null;
        }
    }

    public static interface ComputeInstance {
        String getName();

        String getId();

        String getIpAddress();

        String getFloatingIpAddress();

        String getFloatingIpId();
    }

    @Setter
    @Getter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Host {
        private String ipAddress;
        private String publicAddress;
    }

}
