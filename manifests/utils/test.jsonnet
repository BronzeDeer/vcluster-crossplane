local apps = import "./apps.libsonnet";

{
  base: {
    args: apps.appArgs.new(name="base",namespace="default",sourceRepoURL="https://github.com/BronzeDeer/vcluster-crossplane") {
      namePrefix: "test"
    },
    test: apps.baseApp(self.args)
  },

  helm: {
    local this = self,
    base: {
      args: 
        $.base.args {
          namePrefix: super.namePrefix + "-helm",
        }
        + apps.appArgs.withHelmGit()
      ,
      test: apps.helmGitApp(self.args)
    }
  },
  jsonnet: {
    local this = self,
    base: {
      args: 
        $.base.args {
          namePrefix: super.namePrefix + "-jsonnet",
        }
        + apps.appArgs.withJsonnet()
      ,
      test: apps.jsonnetApp(self.args),
    },

    withNS: {
      args: this.base.args {
        name: "withns",
        namespace:"my-namespace",
      },
      test: apps.jsonnetApp(self.args)
    },

    withNamePrefix: {
      args: this.withNS.args{
        name: "withteam",
        namePrefix:"team-a",
      },
      test: apps.jsonnetApp(self.args),
    },
  }
}