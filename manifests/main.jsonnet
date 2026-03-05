local apps = import "./utils/apps.libsonnet";
function(namespace,sourceRepoURL,projectName,sourcePathPrefix,sourceTargetRevision,applicationNamespace)
  local util = apps.fromTLA(namespace, sourceRepoURL, projectName, sourcePathPrefix, sourceTargetRevision, applicationNamespace);
 [
  util.helmGitApp("argocd", "../deps/argocd/vendor/chart", "../../values.yaml"),
  util.helmGitApp("crossplane", "../deps/crossplane/vendor/chart", "../../values.yaml")
 ] 
