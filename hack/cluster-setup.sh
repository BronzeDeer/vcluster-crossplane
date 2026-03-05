SCRIPT_PATH="`realpath $0`"
SCRIPT_DIR=`dirname $SCRIPT_PATH`


kind create cluster --config $SCRIPT_DIR/cluster.yaml --wait=30s
kubectl create ns argocd
helm -n argocd template bootstrap-argocd $SCRIPT_DIR/../deps/argocd/vendor/chart/ -f $SCRIPT_DIR/../deps/argocd/values.yaml \
| kubectl --context kind-vcluster-crossplane -n argocd apply --server-side -f -
jsonnet -y --tla-str "sourceTargetRevision=$(git rev-parse --abbrev-ref=strict HEAD)" manifests/bootstrap.jsonnet \
| kubectl --context kind-vcluster-crossplane -n argocd apply --server-side -f -
