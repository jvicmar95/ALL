
# 🌐 Acceso por Ingress en Kubernetes (sin LoadBalancer)

Esta guía explica cómo configurar un **Ingress gratuito con NodePort** para acceder a servicios como **Grafana** y **Prometheus** en un clúster de Kubernetes sin usar LoadBalancer.

---

## ✅ Requisitos previos

- Clúster de Kubernetes funcionando
- Servicios `grafana` y `prometheus` expuestos como `ClusterIP` en el namespace `monitoring`

---

## 🔧 1. Instalar el controlador NGINX Ingress

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

---

## 🔄 2. Cambiar el servicio a NodePort

```bash
kubectl edit svc ingress-nginx-controller -n ingress-nginx
```

Cambia:
```yaml
type: LoadBalancer
```
por:
```yaml
type: NodePort
```

Guarda y sal (`:wq` en vi, `Ctrl+O`, `Ctrl+X` en nano).

---

## 🔍 3. Verificar el puerto NodePort asignado

```bash
kubectl get svc -n ingress-nginx
```

Busca algo como:

```
ingress-nginx-controller   NodePort   ...   80:30326/TCP,443:31728/TCP
```

---

## ✍️ 4. Editar `/etc/hosts` (en Windows)

Abre como administrador:

```
C:\Windows\System32\drivers\etc\hosts
```

Y añade:

```
127.0.0.1 grafana.monitor.local prometheus.monitor.local
```

---

## ✨ 5. Crear el recurso Ingress

Guarda esto como `ingress-monitoring.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-grafana-prometheus
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: grafana.monitor.local
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: grafana
                port:
                  number: 3000
    - host: prometheus.monitor.local
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: prometheus
                port:
                  number: 9090
```

Aplica:

```bash
kubectl apply -f ingress-monitoring.yaml
```

---

## 🚀 6. Acceder desde navegador

### Opción A - Usar NodePort directamente (si conoces IP del nodo)

```txt
kubectl get nodes -o wide
kubectl get svc -n ingress-nginx

http://<IP_DEL_NODO>:30326
```

### Opción B - Recomendado: usar port-forward

```bash
kubectl port-forward svc/ingress-nginx-controller 80:80 -n ingress-nginx
```

Y accede a:

- http://grafana.monitor.local:8080
- http://prometheus.monitor.local:8080

---

## ✅ Verificación

```bash
kubectl describe ingress ingress-grafana-prometheus -n monitoring
```

Debe mostrar:

```
Ingress Class: nginx
Rules:
  Host: grafana.monitor.local -> grafana:3000
  Host: prometheus.monitor.local -> prometheus:9090
```

---

🎉 ¡Listo! Ya tienes acceso a tus servicios usando Ingress gratuito y personalizado.
