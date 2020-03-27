apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: zpm-registry
  namespace: iris
spec:
  serviceName: zpm-registry
  replicas: 1
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: zpm-registry
  template:
    metadata:
      labels:
        app: zpm-registry
    spec:
      initContainers:
      - name: zpm-volume-change-owner-hack
        image: busybox
        command:
        - sh
        - -c
        - |
          echo IRIS_PASSWORD > /usr/irissys/mgr/password.txt
          chown -R 51773:52773 /opt/zpm/REGISTRY-DATA
          chmod g+w /opt/zpm/REGISTRY-DATA
          echo -e "zn \"%SYS\"\nwrite ##class(SYS.Container).ChangePassword(\"/usr/irissys/mgr/password.txt\")\nif (##class(SYS.Database).%ExistsId(\"/opt/zpm/REGISTRY-DATA\")) { halt }\nset db=##class(SYS.Database).%New()\nset db.Directory=\"/opt/zpm/REGISTRY-DATA\"\nset db.ResourceName=\"%DB_REGISTRY\"\nwrite db.%Save()\nhalt" > /mount-helper/mount_registry_data
        volumeMounts:
        - mountPath: /opt/zpm/REGISTRY-DATA
          name: zpm-registry-volume
        - mountPath: /mount-helper
          name: mount-helper
      volumes:
      - emptyDir: {}
        name: mount-helper
      containers:
      - image: DOCKER_REPO_NAME:DOCKER_IMAGE_TAG
        name: zpm-registry
        lifecycle:
          postStart:
            exec:
              command:
              - /bin/bash
              - -c
              - |
                sleep 30
                iris session iris < /mount-helper/mount_registry_data
        ports:
        - containerPort: 52773
          name: web
        readinessProbe:
          httpGet:
            path: /csp/sys/UtilHome.csp
            port: 52773
          initialDelaySeconds: 10
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /csp/sys/UtilHome.csp
            port: 52773
          periodSeconds: 10
        volumeMounts:
        - mountPath: /opt/zpm/REGISTRY-DATA
          name: zpm-registry-volume
        - mountPath: /mount-helper
          name: mount-helper
  volumeClaimTemplates:
  - metadata:
      name: zpm-registry-volume
      namespace: iris
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
