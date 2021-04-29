
#  Add Blob NFS Mount Options

Install blob-csi-drivers from here  https://github.com/kubernetes-sigs/blob-csi-driver
then deploy.sh
Login to the node where the test pod is running and then run nfsstat -m

``` 
azureuser@aks-nodepool1-3297-vmss000004:~$ nfsstat -m
/var/lib/kubelet/plugins/kubernetes.io/csi/pv/pv-blob-mountoptions/globalmount from <account-name>.blob.core.windows.net:/<account-name>/<containername>
Flags: rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,nconnect=16,port=2048,timeo=600,retrans=2,sec=sys,mountaddr=52.239.171.196,mountvers=3,mountport=2048,mountproto=tcp,local_lock=all,addr=52.239.171.196
```
