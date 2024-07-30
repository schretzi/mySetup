---
creation date: 2023-09-22 08:15
tags:
  - Mesh
  - IPL
aliases: 
account: Rewe
---
## Create shared docker network 
If we need multiple Cluster to communicate with each other (eg. for the Kong Mesh) these clusters need a shared network:

```
docker network create k3d
```

## Create a k3d registry
```
export REGISTRY_PORT=12345
export REGISTRY_NAME=registry-ipl.localhost
k3d registry create -p 0.0.0.0:$REGISTRY_PORT $REGISTRY_NAME --no-help
```

## k3d prepared for istio
```
k3d cluster create main-cl --api-port 6550 -p '9080:80@loadbalancer' -p '9443:443@loadbalancer' --agents 3 --k3s-arg '--disable=traefik@server:*' --registry-use k3d-$REGISTRY_NAME:$REGISTRY_PORT --network k3d --wait
```

## Get kubectl config information

```
export CL_CONFIG_DIR=~/.kube/configs/main-cl
mkdir -p $CL_CONFIG_DIR
k3d kubeconfig get main-cl >$CL_CONFIG_DIR/kubeconfig
```
  
## Merge all my kubeconfigs into one

```
cp ~/.kube/config ~/.kube/config.backup
export KUBECONFIG=$(find configs -type f -name kubeconfig| tr '\n' ':')
kubectl config view --flatten > ~/.kube/config
unset KUBECONFIG
```

## istio 

https://istio.io/latest/docs/setup/platform-setup/k3d/
```
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --wait
helm install istiod istio/istiod -n istio-system --wait

kubectl label namespace istio-system istio-injection=enabled
helm install istio-ingressgateway istio/gateway -n istio-system --wait
```

## Dashboard:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

kubectl create serviceaccount -n kubernetes-dashboard admin-user
kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

token=$(kubectl -n kubernetes-dashboard create token admin-user)
echo $token

kubectl proxy &

security add-generic-password -a "token" -s "k3d main-cl dashboard" -w $token `security default-keychain`
```

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=default

## vault
https://medium.com/@verove.clement/inject-secret-in-application-from-vault-agent-injector-60a3fe71628e

### Install Vault
```
STORAGE_CLASS=local-path  
  
# Vault installation  
helm repo add hashicorp https://helm.releases.hashicorp.com  
helm install vault hashicorp/vault \
-n vault \
--set server.dataStorage.storageClass=$STORAGE_CLASS \
--set server.auditStorage.storageClass=$STORAGE_CLASS \
--create-namespace;  
  
  
# Wait for Vault in running state  
while [[ $(kubectl get pods vault-0 -n vault -o 'jsonpath={..status.phase}') != "Running" ]]  
do  
echo "INFO: Wait for vault get running..." && sleep 5  
done  
  
  
# Init Vault / get credentials  
kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > vault-keys.json

# Get Vault credentials  
VAULT_UNSEAL_KEY=$(cat vault-keys.json | jq -r ".unseal_keys_b64[]")  
VAULT_ROOT_KEY=$(cat vault-keys.json | jq -r ".root_token")  
  
# Unseal Vault  
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY  
  
security add-generic-password -a "token" -s "k3d main-cl vault unseal" -w $VAULT_UNSEAL_KEY `security default-keychain`
security add-generic-password -a "token" -s "k3d main-cl vault root" -w $VAULT_ROOT_KEY `security default-keychain`

```

```
kubectl port-forward -n vault services/vault 8200:8200
```

### Initial Configuration
```
# Enable Key Value engine  
kubectl exec vault-0 -n vault -- /bin/sh -c "VAULT_TOKEN=$VAULT_ROOT_KEY vault secrets enable -version=2 -path=rd-platform-k8s-production/riag/tech/ipl kv"  
kubectl exec vault-0 -n vault -- /bin/sh -c "VAULT_TOKEN=$VAULT_ROOT_KEY vault secrets enable -version=2 -path=external/ipl-messaging kv"

# Enable Kubernetes engine  
kubectl exec vault-0 -n vault -- /bin/sh -c "VAULT_TOKEN=$VAULT_ROOT_KEY vault auth enable kubernetes"
```

### Example for a vault configuration for an application

```

kubectl exec vault-0 -n vault -- /bin/sh -c "VAULT_TOKEN=$VAULT_ROOT_KEY vault policy write ipl-connect-external -<<EOF  
path \"ipl-test/data/ipl-connect/connect-external/*\" {  
capabilities = [\"read\", \"list\"]  
}  
EOF"

TOKEN_REVIEWER_JWT_COMMAND=$(kubectl exec vault-0 -n vault -- /bin/sh -c "cat /var/run/secrets/kubernetes.io/serviceaccount/token")  
  
KUBERNETES_PORT_443_TCP_ADDR=$(kubectl exec vault-0 -n vault -- /bin/sh -c "echo \$KUBERNETES_PORT_443_TCP_ADDR")  
  
kubectl exec vault-0 -n vault -- /bin/sh -c "VAULT_TOKEN=$VAULT_ROOT_KEY vault write auth/kubernetes/config \
token_reviewer_jwt=$TOKEN_REVIEWER_JWT_COMMAND \
kubernetes_host=https://$KUBERNETES_PORT_443_TCP_ADDR:443 \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"  
  
kubectl exec vault-0 -n vault -- /bin/sh -c "VAULT_TOKEN=$VAULT_ROOT_KEY vault write auth/kubernetes/role/api \
bound_service_account_names=api-serviceaccount \
bound_service_account_namespaces=riag-tech-ipl-ipl-connect \
policies=ipl-connect-external \
ttl=1h"


```

### Unlock Vault after kubernetes restart
```
VAULT_UNSEAL_KEY=$(security find-generic-password -a "token" -s "k3d main-cl vault unseal" -w)
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY  
```



