# ✅ Exponer Grafana por HTTPS con Cert-Manager en K3s

Este documento describe el procedimiento completo para exponer Grafana de forma segura en un clúster K3s utilizando:

- Cert-Manager para la gestión de certificados TLS.
- Ingress NGINX para enrutar tráfico HTTP/S.
- Certificado autofirmado (para entornos de laboratorio).
- Redirección local con `kubectl port-forward`.

---

## 🧱 Requisitos previos

- Clúster K3s en funcionamiento (instalado en una máquina Linux en Azure).
- Ingress NGINX desplegado.
- Helm instalado.
- Grafana funcionando en el namespace `monitoring` y accesible por Ingress.
- Dominio: `grafana.monitor.local` apuntando a `127.0.0.1` en el archivo `hosts`.

---

## 🔐 Paso 1: Instalar Cert-Manager con Helm

```bash
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --set installCRDs=true
```

---

## 🏷️ Paso 2: Crear ClusterIssuer autofirmado

Archivo `clusterissuer-selfsigned.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-cluster-issuer
spec:
  selfSigned: {}
```

```bash
kubectl apply -f clusterissuer-selfsigned.yaml
```

---

## 📜 Paso 3: Crear certificado TLS para Grafana

Archivo `grafana-certificate.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-tls
  namespace: monitoring
spec:
  secretName: grafana-tls-secret
  duration: 4320h  # 180 días
  renewBefore: 360h
  commonName: grafana.monitor.local
  dnsNames:
    - grafana.monitor.local
  issuerRef:
    name: selfsigned-cluster-issuer
    kind: ClusterIssuer
```

```bash
kubectl apply -f grafana-certificate.yaml
kubectl get secret grafana-tls-secret -n monitoring
```

---

## 🌐 Paso 4: Modificar el Ingress para usar HTTPS

Archivo `ingress-monitoring.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-grafana-prometheus
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - grafana.monitor.local
      secretName: grafana-tls-secret
  rules:
    - host: grafana.monitor.local
      http:
        paths:
          - path: /(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: grafana
                port:
                  number: 3000
```

```bash
kubectl apply -f ingress-monitoring.yaml
```

---

## 📥 Paso 5: Configurar acceso en el equipo local

Editar el archivo `hosts` en Windows:

```
C:\Windows\System32\drivers\etc\hosts
```

Añadir:

```
127.0.0.1 grafana.monitor.local
```

---

## 🔁 Paso 6: Redirección local con port-forward

Desde PowerShell (Windows):

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 443:443
```

---

## ✅ Acceder a Grafana

Abre en el navegador:

```
https://grafana.monitor.local
```

> Acepta el aviso de “sitio no seguro” debido al certificado autofirmado.

---

## 🧪 Comprobaciones útiles

Ver eventos del certificado:

```bash
kubectl describe certificate grafana-tls -n monitoring
```

Ver logs del pod cert-manager:

```bash
kubectl logs -n cert-manager deploy/cert-manager
```

---

## 🔄 Renovar el certificado manualmente

### Ver qué certificado usa tu dominio

```bash
kubectl get ingress -n monitoring
kubectl describe ingress ingress-grafana-prometheus -n monitoring
```

Revisa la sección:

```
TLS:
  grafana-tls-secret terminates grafana.monitor.local
```

### Ver qué `Certificate` creó ese `Secret`

```bash
kubectl get certificate -n monitoring
```

---

### Si no tienes el YAML original

1. Exporta el actual:

```bash
kubectl get certificate grafana-tls -n monitoring -o yaml > grafana-certificate.yaml
```

2. Modifica el archivo:

```yaml
duration: 4320h  # por ejemplo, 180 días
```

3. Fuerza la renovación:

```bash
kubectl delete certificate grafana-tls -n monitoring
kubectl delete secret grafana-tls-secret -n monitoring
kubectl apply -f grafana-certificate.yaml
```

4. Verifica que se haya renovado correctamente:

```bash
kubectl describe certificate grafana-tls -n monitoring
```

---

## 🧹 Observaciones

- Este entorno es de laboratorio. Para producción, se recomienda usar Let's Encrypt.
- El acceso por puerto 443 se realiza con `port-forward`. Si se desea acceso externo real, se debe exponer con un LoadBalancer o abrir el puerto en el NSG de Azure.

---
