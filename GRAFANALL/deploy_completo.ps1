kubectl create namespace ldap
kubectl create namespace keycloak
kubectl create namespace monitoring
kubectl create namespace cert-manager
kubectl create namespace aplicacion

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
kubectl edit svc ingress-nginx-controller -n ingress-nginx

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\cert-manager\clusterissuer-selfsigned.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\cert-manager\grafana-certificate.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\cert-manager\prometheus-certificate.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\cert-manager\keycloak-certificate.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\cert-manager\ldap-certificate.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\cert-manager\aplicacion-certificate.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\ldap\namespace-ldap.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\ldap\openldap-secret.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\ldap\openldap-pvc.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\ldap\openldap-deployment.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\ldap\phpldapadmin-deployment.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\keycloak\namespace-keycloak.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\keycloak\keycloak-admin-secret.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\keycloak\keycloak-postgres.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\keycloak\keycloak-deployment.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\keycloak\keycloak-service.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\pvc-prometheus.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\pvc-alertmanager.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\prometheus-config.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\prometheus-deployment.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\prometheus-service.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\kube-state-metrics-serviceaccount.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\kube-state-metrics-deployment.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\kube-state-metrics-service.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\kube-state-metrics-clusterrole.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\prometheus\kube-state-metrics-clusterrolebinding.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\pvc-loki.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\loki-config.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\loki-deployment.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\loki-service.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\promtail-config.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\promtail-daemonset.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\promtail-service.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\loki\promtail-serviceaccount.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\grafana\pvc-grafana.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\ldap\grafana-ldap-configmap.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\grafana\grafana-config.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\grafana\grafana-datasources.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\grafana\grafana-deployment.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\grafana\grafana-service.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\cAdvisor\cadvisor-daemonset.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Desplegar_Grafana+Loki+Prometheus+cAdvisor\cAdvisor\cadvisor-service.yaml

kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Ingress\ldap-ingress.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Ingress\keycloak-ingress.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Ingress\ingress-monitoring.yaml
kubectl apply -f C:\Users\0020360\Documents\DEVOPS\ALL\GRAFANALL\Ingress\ingress-aplicacion.yaml

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 443:443