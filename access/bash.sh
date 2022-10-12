# Within the namespace "acme", grant the permissions in the "admin" ClusterRole to a user named "bob"
kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=acme

# Within the namespace "acme", grant the permissions in the "view" ClusterRole to the service account in the namespace "acme" named "myapp"
kubectl create rolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp --namespace=acme

# Across the entire cluster, grant the permissions in the "cluster-admin" ClusterRole to a user named "root"
kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root

# 1
kubectl create serviceaccount demo-user

# 2
kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --serviceaccount default:demo-user

# 3
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: demo-user-secret
  annotations:
    kubernetes.io/service-account.name: demo-user
type: kubernetes.io/service-account-token
EOF

# 4
TOKEN=$(kubectl get secret demo-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')