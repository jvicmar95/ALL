# 🚀 Despliegue Completo de Stack de Monitorización y Aplicación en Kubernetes (K3s)

Este documento describe paso a paso cómo desplegar un entorno completo de monitorización y aplicación en un clúster K3s. Incluye los siguientes componentes:

- Ingress NGINX
- Cert-Manager con certificados autofirmados
- Grafana, Prometheus, Loki, Promtail, cAdvisor, kube-state-metrics
- Aplicación propia
- Acceso vía HTTPS usando dominios locales

---

## 📦 1. Desplegar Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
kubectl edit svc ingress-nginx-controller -n ingress-nginx  # Cambiar tipo a NodePort
kubectl get svc -n ingress-nginx
```

---

## 🌐 2. Desplegar Ingress y namespaces

```bash
kubectl create ns monitoring
kubectl apply -f ingress-monitoring.yaml
kubectl apply -f ingress-aplicacion.yaml
```

---

## 🔐 3. Instalar Cert-Manager con Helm

```bash
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --set installCRDs=true
```

---

## 🛡️ 4. Crear certificados TLS autofirmados

```bash
kubectl apply -f clusterissuer-selfsigned.yaml
kubectl apply -f grafana-certificate.yaml
kubectl apply -f prometheus-certificate.yaml
kubectl apply -f aplicación-certificate.yaml
kubectl get secret grafana-tls-secret -n monitoring
```

---

## 🧭 5. Configurar `/etc/hosts` (local)

Agrega lo siguiente:

```
127.0.0.1 grafana.monitor.local prometheus.monitor.local promtail.monitor.local loki.monitor.local cadvisor.monitor.local aplicación.local
```

---

## 🧪 6. Acceso a los servicios (opcional)

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 443:443
kubectl port-forward svc/ingress-nginx-controller 80:80 -n ingress-nginx
```

---

## 📈 7. Desplegar Stack de Monitorización

### 🔹 Loki

```bash
kubectl apply -f pvc-loki.yaml -n monitoring
kubectl apply -f loki-config.yaml -n monitoring
kubectl apply -f loki-service.yaml -n monitoring
kubectl apply -f loki-deployment.yaml -n monitoring
```

### 🔹 Promtail

```bash
kubectl apply -f promtail-config.yaml -n monitoring
kubectl apply -f promtail-serviceaccount.yaml -n monitoring
kubectl apply -f promtail-daemonset.yaml -n monitoring
```

### 🔹 Prometheus

```bash
kubectl apply -f pvc-prometheus.yaml -n monitoring
kubectl apply -f prometheus-config.yaml -n monitoring
kubectl apply -f prometheus-service.yaml -n monitoring
kubectl apply -f prometheus-deployment.yaml -n monitoring
```

### 🔹 Alertmanager

```bash
kubectl apply -f pvc-alertmanager.yaml -n monitoring
```

### 🔹 Kube-State-Metrics

```bash
kubectl apply -f kube-state-metrics-serviceaccount.yaml -n monitoring
kubectl apply -f kube-state-metrics-clusterrole.yaml
kubectl apply -f kube-state-metrics-clusterrolebinding.yaml
kubectl apply -f kube-state-metrics-service.yaml -n monitoring
kubectl apply -f kube-state-metrics-deployment.yaml -n monitoring
```

### 🔹 cAdvisor

```bash
kubectl apply -f cadvisor-service.yaml
kubectl apply -f cadvisor-daemonset.yaml
```

### 🔹 Grafana

```bash
kubectl apply -f pvc-grafana.yaml -n monitoring
kubectl apply -f grafana-config.yaml -n monitoring
kubectl apply -f grafana-datasources.yaml -n monitoring
kubectl apply -f grafana-service.yaml -n monitoring
kubectl apply -f grafana-deployment.yaml -n monitoring
```

---

## 📦 8. Desplegar Aplicación

```bash
kubectl create namespace aplicacion
kubectl apply -f pvc-aplicacion.yaml -n aplicacion
kubectl apply -f service-aplicacion.yaml -n aplicacion
kubectl apply -f deployment-aplicacion.yaml -n aplicacion
```

---

## ✅ Todo listo

Tu entorno completo de monitorización y aplicación está desplegado y accesible usando dominios locales definidos en `/etc/hosts` y certificados TLS gestionados por Cert-Manager.
