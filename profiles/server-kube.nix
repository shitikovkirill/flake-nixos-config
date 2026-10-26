# docker-registry is bundled here rather than in server-plain: k3s (in
# ../server/k8s) pulls images from registry.home, so the two are coupled.
{
  imports = [
    ../server/k8s
    ../server/docker-registry
  ];
}
