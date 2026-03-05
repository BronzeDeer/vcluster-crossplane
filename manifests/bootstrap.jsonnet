local argocd = import "../deps/jsonnet-libs/argocd/main.libsonnet";
local argocdv1a1 = argocd.argoproj.v1alpha1;
local app = argocdv1a1.application;

local appUtil = import "./utils/apps.libsonnet";

function(sourceRepoURL="https://github.com/BronzeDeer/vcluster-crossplane",projectName="default",sourcePathPrefix="",sourceTargetRevision="origin/HEAD",applicationNamespace="argocd",namePrefix="")
local util = appUtil.fromTLA(namespace=applicationNamespace, namePrefix=namePrefix, sourceRepoURL=sourceRepoURL, projectName=projectName, sourcePathPrefix=sourcePathPrefix, sourceTargetRevision=sourceTargetRevision, applicationNamespace=applicationNamespace);
[
  util.jsonnetApp("bootstrap", "manifests/")
  + app.spec.source.directory.withInclude("main.jsonnet")
]
