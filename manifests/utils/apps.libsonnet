local argocd = import "../../deps/jsonnet-libs/argocd/main.libsonnet";
local argocdv1a1 = argocd.argoproj.v1alpha1;
local app = argocdv1a1.application;
local tla = app.spec.sources.directory.jsonnet.tlas;

{
  appArgs:: {
    new(name,namespace,sourceRepoURL):: {
      name: name,
      namePrefix: "",
      fullName: if std.isEmpty(self.namePrefix) then self.name else (std.rstripChars(self.namePrefix, "_-") + "-" + self.name),
      projectName: "default",
      sourceRepoURL: sourceRepoURL,
      sourceRelPath: "/",
      sourcePathPrefix: "",
      sourcePreferResolvedRevision: true,
      sourceTargetRevision: "origin/HEAD",
      # Ensure that the full path is always relative and correctly joins prefix and relpath without doubling on slashes
      sourceFullPath: std.lstripChars(std.rstripChars(self.sourcePathPrefix,"/") + "/" + std.lstripChars(self.sourceRelPath,"/"),"/"),
      namespace: namespace,
      applicationNamespace: "argocd"
    },
    
    withJsonnet()::{
      directoryRecurse: false,
      jsonnetFilesOnly: true,
    },

    withHelmGit(relChartPath="./chart",valueFiles=["../values.yaml"]):: {
      sourceRelPath: relChartPath,
      valueFiles: valueFiles,
    }
  },

  helmGitApp(args)::
    self.baseApp(args)
    + app.spec.source.helm.withValueFiles(args.valueFiles)
  ,

  jsonnetApp(args)::
    self.baseApp(args)
    + app.spec.source.directory.withRecurse(args.directoryRecurse)
    + (if args.jsonnetFilesOnly then app.spec.source.directory.withInclude("*.jsonnet") else {})
    + app.spec.source.directory.jsonnet.withTlas([
      (
        tla.withName("namespace")
        + tla.withValue("$ARGOCD_APP_NAMESPACE")
      ),
      (
        tla.withName("namePrefix")
        + tla.withValue("$ARGOCD_APP_NAME")
      ),
      (
        tla.withName("projectName")
        + tla.withValue("$ARGOCD_APP_PROJECT_NAME")
      ),
      (
        tla.withName("repoURL")
        + tla.withValue("$ARGOCD_APP_SOURCE_REPO_URL")
      ),
      (
        tla.withName("sourcePathPrefix")
        + tla.withValue("$ARGOCD_APP_SOURCE_PATH")
      ),
      (
        tla.withName("sourceTargetRevision")
        +
        if args.sourcePreferResolvedRevision
        then 
          tla.withValue("$ARGOCD_APP_SOURCE_REVISION")
        else 
         tla.withValue("$ARGOCD_APP_SOURCE_TARGET_REVISION")
      ),
      (
        tla.withName("applicationNamespace")
        + tla.withValue(args.applicationNamespace)
      ),

    ])
  ,
  baseApp(args)::
    app.new(args.fullName)
    + app.metadata.withNamespace(args.applicationNamespace)
    + app.spec.withProject("default")
    + app.spec.destination.withNamespace(args.namespace)
    + app.spec.destination.withServer("https://kubernetes.default.svc")
    + app.spec.source.withRepoURL(args.sourceRepoURL)
    + app.spec.source.withPath(args.sourceFullPath)
  ,

  fromTLA(namespace,sourceRepoURL,projectName,sourcePathPrefix,sourceTargetRevision,applicationNamespace,namePrefix=""): {
    baseArgs(name): 
      $.appArgs.new(name, namespace, sourceRepoURL) 
      + {
        namePrefix: namePrefix,
        projectName: projectName,
        sourceRepoURL: sourceRepoURL,
        sourcePathPrefix: sourcePathPrefix,
        sourceTargetRevision: sourceTargetRevision,
        applicationNamespace: applicationNamespace,
      }
      ,
    baseApp(name):
      $.baseApp(self.baseArgs(name))
    ,
    jsonnetApp(name, relDirectoryPath):
      $.jsonnetApp(
        self.baseArgs(name)
        + $.appArgs.withJsonnet()
        + {
          sourceRelPath: relDirectoryPath,
        }
      )
    ,
    helmGitApp(name,relChartPath,valueFiles = ["../values.yaml"]):
      self.baseArgs(name)
      + $.appArgs.withHelmGit(relChartPath, valueFiles)

  }
}