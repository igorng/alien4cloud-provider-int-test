import org.cloudifysource.utilitydomain.context.ServiceContextFactory

def context = ServiceContextFactory.getServiceContext()
if(volumeId==null) {
    throw new IllegalArgumentException("volumeId is mandatory for this storage type")
}
log.info "attaching storage volume <${volumeId}> to <${DEVICE}>... "
context.storage.attachVolume(volumeId, DEVICE)

return [volumeId: volumeId, device: DEVICE]
