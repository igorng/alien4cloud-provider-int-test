import org.cloudifysource.utilitydomain.context.ServiceContextFactory

def context = ServiceContextFactory.getServiceContext()
def builder = new AntBuilder()
log.info "<${SELF}> device is: <${device}>, location is <${LOCATION}>"
builder.delete(dir:LOCATION,failonerror:false);
builder.sequential {
  chmod(dir:"${context.serviceDirectory}/scripts", perm:"+x", includes:"*.sh")
  mkdir(dir: LOCATION)
  echo(message:"mount.groovy: Running ${context.serviceDirectory}/scripts/mountStorage.sh...")
  exec(executable: "${context.serviceDirectory}/scripts/mountStorage.sh",failonerror: "true") {
    arg(value:"${device}")
    arg(value:"${LOCATION}")
  }
}

return LOCATION