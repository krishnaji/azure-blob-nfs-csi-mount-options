RESOURCE_GROUP=<REPLACE-RG-NAME>
SANAME=<REPLACE-STORAGE-ACCOUNT>
STORAGE_CONTAINER=<REPLACE-STORAGE-COmt>
kubectl create namespace mountoptions

SA_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $SANAME -o tsv --query "[?keyName=='key1']".value)

#SECRET
kubectl create secret generic blob-nfs-mountoption-secret -n mountoptions --from-literal=azurestorageaccountname="$SANAME" --from-literal azurestorageaccountkey="$SA_KEY" --type=Opaque 

# PV
cat << EOF | kubectl apply -n mountoptions -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-blob-mountoptions
  labels: 
    storage-tier: blobnfsmountoptions 
spec:
  capacity:
    storage: 10T
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain  # "Delete" is not supported in static provisioning
  mountOptions:
    - hard
    - nconnect=16
  csi:
    driver: blob.csi.azure.com
    readOnly: false
    volumeHandle: dfsdf-q4234-wfsdsd  # make sure this volumeid is unique in the cluster
    volumeAttributes:
      resourceGroup: $RESOURCE_GROUP
      storageAccount: $SANAME
      containerName: $STORAGE_CONTAINER
      protocol: nfs
    nodeStageSecretRef:
      name: blob-nfs-mountoption-secret
      namespace: mountoptions    
EOF
#PVC

cat << EOF | kubectl apply -n mountoptions -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-blob-nfs-mountoptions
spec:
  selector: 
    matchLabels:
      storage-tier: blobnfsmountoptions
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 10T
EOF

#TEST POD
cat << EOF | kubectl apply -n mountoptions -f -
apiVersion: v1
kind: Pod
metadata:
  namespace: mountoptions
  labels:
    run: ubuntu
  name: ubuntu
spec:
  containers:
  - image: ubuntu:20.04
    name: ubuntu
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
    volumeMounts:
    - name: blob-nfs-vol
      mountPath: /mnt/azure
  volumes:
  - name: blob-nfs-vol
    persistentVolumeClaim:
      claimName: pvc-blob-nfs-mountoptions
  restartPolicy: Never
EOF

