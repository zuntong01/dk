## __`04. serviceaccount, roleginding, secret.md`__

#### <b><span style="color:cyan">[TektonConfig 설명]</span></b>  
```bash
Tekton Operator 설치 시 ServiceAccount(pipeline)는 모든 namespace에 배포되며, 배포된 serviceaccount에 필요한 인증을 위한 설정을함
기본적인 rolebinding도 자동으로 수행 하는것으로 예상
```

#### <b><span style="color:cyan">[TektonConfig yaml 구문]</span></b> 

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipeline
  namespace: cma-p-ocn-ocr
secrets:
  - name: pipeline-dockercfgl4stf 
  - name: cma-p-ocn-ocr-secret-tkn       ## TASK 내부step에서 Gitlab 인증용도 (예 : git clone)
  - name: cma-p-ocn-ocr-secret-quay-dr   ## TASK 내부step에서 quay 인증용도 (예 : skopeo, buildah push)
 
imagePullSecrets:
  - name: pipeline-dockercfg-l4stf   
  - name: cma-p-ocn-ocr-pull-secret      ## pipeline의 TASK의 이미지를 pull 하기 위해 내부 registry(quay) 인증을 위해 명시
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipelines-scc-rolebinding
  namespace: cma-d-ocn-ocr
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pipelines-scc-clusterrole
subjects:
- kind: ServiceAccount
  name: pipeline
  namespace: cma-d-ocn-ocr
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: openshift-pipeline-edit
  namespace: cia-d-eid-eic
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- kind: ServiceAccount
  name: pipeline
  namepsace: cia-d-eid-eic
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pipelines-scc-clusterrole
rules:
- apiGroups:
  - security.openshift.io
  resourceNames:
  - pipelines-scc
  resources:
  - securitycontextconstraints
  verbs:
  - use
---
apiVersion: v1
data:
  password: glpat-xfGx5wctoSSTP2GPJaaz
  username: tekton-cicd
kind: Secret
metadata:
  annotations:
    tekton.dev/git-0: “http://10.77.247.120:9080/“
  name: cma-p-ocn-ocr-secret-tkn
  namespace: cma-p-ocn-ocr
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  password: cmaocnocradm1!
  username: cmaocnocradm
kind: Secret
metadata:
  annotations:
    tekton.dev/docker-0: http://hubp-quay-registry.apps.hubp.infra.io
    tekton.dev/docker-1: http://hubr-quay-registry.apps.hubr.infra.io
  name: cma-p-ocn-ocr-secret-quay-dr
  namespace: cma-p-ocn-ocr
type: kubernetes.io/basic-auth
---
apiVersion: v1
kind: Secret
metadata:
  name: cma-p-ocn-ocr-pull-secret
  namespace: cma-p-ocn-ocr
data:
  .dockerconfigjson: >-
    {“auths”:{“hubp-quay-registry.apps.hubp.infra.io”:{“username”:”cmaocnocradm”,”password”:”cmaocnocradm1!”,”auth”:”Y21hb2Nub2NyYWRtOmNtYW9jbm9jcmFkbTEh”}}}
type: kubernetes.io/dockerconfigjson
---
    ```