local argocd = import "../deps/jsonnet-libs/argocd/main.libsonnet";
local argocdv1a1 = argocd.argoproj.v1alpha1;
local app = argocdv1a1.application;

local appUtils = import "./utils/apps.libsonnet";

function(namespace,sourceRepoURL,projectName,sourcePathPrefix,sourceTargetRevision,applicationNamespace,namePrefix="")(
  local util = appUtils.fromTLA(namespace, sourceRepoURL, projectName, sourcePathPrefix, sourceTargetRevision, applicationNamespace,namePrefix="");
  [
    util.helmGitApp("argocd", "../deps/argocd/vendor/chart", "../../values.yaml")
    + app.spec.destination.withNamespace("argocd")
    ,
    util.helmGitApp("crossplane", "../deps/crossplane/vendor/chart", "../../values.yaml")
    + app.spec.destination.withNamespace("crossplane")
    ,
  ]
)
