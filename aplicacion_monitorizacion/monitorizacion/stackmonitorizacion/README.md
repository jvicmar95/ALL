# 📊 Grafana + Loki + Prometheus + cAdvisor + Aplicación en Kubernetes (YAML Only)

Este repositorio contiene el despliegue completo de un stack de monitorización (Grafana, Loki, Prometheus, cAdvisor) junto con una aplicación personalizada en un clúster de Kubernetes, **usando únicamente manifiestos YAML**, sin Helm.

---

## 📁 Repositorio principal

🔗 https://github.com/jvicmar95/ALL/tree/main/APLICACION

---

## 🧱 Namespace de monitorización

```bash
kubectl create namespace monitoring
```

---

## 📦 Despliegue de componentes

### 🟣 Loki

```bash
kubectl apply -f pvc-loki.yaml -n monitoring
kubectl apply -f loki-config.yaml -n monitoring
kubectl apply -f loki-service.yaml -n monitoring
kubectl apply -f loki-deployment.yaml -n monitoring
```

📌 Verificación:

```bash
kubectl get pods -n monitoring -l app=loki
kubectl port-forward svc/loki 3100:3100 -n monitoring
```

Accede a [http://localhost:3100/ready](http://localhost:3100/ready)

---

### 🔁 Promtail

```bash
kubectl apply -f promtail-config.yaml -n monitoring
kubectl apply -f promtail-serviceaccount.yaml -n monitoring
kubectl apply -f promtail-daemonset.yaml -n monitoring
```

---

### 📈 Prometheus

```bash
kubectl apply -f pvc-prometheus.yaml -n monitoring
kubectl apply -f pvc-alertmanager.yaml -n monitoring
kubectl apply -f prometheus-config.yaml -n monitoring
kubectl apply -f prometheus-service.yaml -n monitoring
kubectl apply -f prometheus-deployment.yaml -n monitoring
kubectl apply -f kube-state-metrics-serviceaccount.yaml -n monitoring
kubectl apply -f kube-state-metrics-clusterrole.yaml
kubectl apply -f kube-state-metrics-clusterrolebinding.yaml
kubectl apply -f kube-state-metrics-service.yaml -n monitoring
kubectl apply -f kube-state-metrics-deployment.yaml -n monitoring
```

---

### 📦 cAdvisor

```bash
kubectl apply -f cadvisor-service.yaml
kubectl apply -f cadvisor-daemonset.yaml
```

---

### 📊 Grafana

```bash
kubectl apply -f pvc-grafana.yaml -n monitoring
kubectl apply -f grafana-config.yaml -n monitoring
kubectl apply -f grafana-datasources.yaml -n monitoring
kubectl apply -f grafana-service.yaml -n monitoring
kubectl apply -f grafana-deployment.yaml -n monitoring
```

📌 Verificación:

```bash
kubectl port-forward svc/grafana 3000:3000 -n monitoring
```

Accede a: [http://localhost:3000](http://localhost:3000)

---

## 🧱 Despliegue de la Aplicación

```bash
kubectl create namespace aplicacion
kubectl apply -f pvc-aplicacion.yaml -n aplicacion
kubectl apply -f service-aplicacion.yaml -n aplicacion
kubectl apply -f deployment-aplicacion.yaml -n aplicacion
```

📌 Verificación:

```bash
kubectl port-forward svc/aplicacion-service 8080:80 -n aplicacion
```

Accede a: [http://localhost:8080](http://localhost:8080)

---

## ✅ Estado Final Esperado

```bash
kubectl get pods -n monitoring
kubectl get pods -n aplicacion
```

Todos los pods deben estar en `Running`.

---

## 💬 Autor

Desplegado manualmente por Jorge con asistencia de ChatGPT 🚀

## 📉 cAdvisor

cAdvisor exporta métricas clave del rendimiento de los contenedores para ser visualizadas en Prometheus y Grafana.

### 📊 Tabla resumen de métricas clave de cAdvisor

| Categoría | Métrica Prometheus | Descripción | Consulta útil |
|-----------|--------------------|-------------|----------------|
| **CPU** | `container_cpu_usage_seconds_total` | Tiempo total de CPU usado (en segundos acumulados) | `rate(container_cpu_usage_seconds_total{name!~".*POD.*"}[5m])` |
| | `container_cpu_cfs_throttled_seconds_total` | Tiempo que el contenedor fue limitado por CPU (throttled) | `rate(container_cpu_cfs_throttled_seconds_total[5m])` |
| | `container_cpu_cfs_periods_total` | Número de periodos en los que se evaluó el uso de CPU | `rate(container_cpu_cfs_periods_total[5m])` |
| **Memoria** | `container_memory_usage_bytes` | Total de memoria usada por el contenedor | `container_memory_usage_bytes{name!~".*POD.*"}` |
| | `container_memory_working_set_bytes` | Memoria en uso activo (excluye caché liberable) | `container_memory_working_set_bytes{name!~".*POD.*"}` |
| | `container_memory_rss` | Memoria residente física (RAM real) | `container_memory_rss{name!~".*POD.*"}` |
| | `container_memory_failcnt` | Fallos al asignar memoria (OOM events) | `container_memory_failcnt{name!~".*POD.*"}` |
| **Disco** | `container_fs_usage_bytes` | Bytes usados en el sistema de archivos del contenedor | `container_fs_usage_bytes{name!~".*POD.*"}` |
| | `container_fs_reads_bytes_total` | Bytes leídos del disco por el contenedor | `rate(container_fs_reads_bytes_total[5m])` |
| | `container_fs_writes_bytes_total` | Bytes escritos al disco por el contenedor | `rate(container_fs_writes_bytes_total[5m])` |
| **Red** | `container_network_receive_bytes_total` | Total de bytes recibidos por red | `rate(container_network_receive_bytes_total[5m])` |
| | `container_network_transmit_bytes_total` | Total de bytes enviados por red | `rate(container_network_transmit_bytes_total[5m])` |
| | `container_network_receive_errors_total` | Errores al recibir tráfico de red | `rate(container_network_receive_errors_total[5m])` |
| | `container_network_transmit_errors_total` | Errores al transmitir tráfico de red | `rate(container_network_transmit_errors_total[5m])` |