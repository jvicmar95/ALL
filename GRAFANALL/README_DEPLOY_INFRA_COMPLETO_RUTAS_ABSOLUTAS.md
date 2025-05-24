
# 🧠 Despliegue Completo de Infraestructura con LDAP, Keycloak y Stack de Monitorización

Este documento detalla paso a paso el proceso para desplegar un entorno Kubernetes con:

- OpenLDAP + phpLDAPadmin
- Keycloak con PostgreSQL
- Cert-Manager + Ingress
- Stack de monitorización: Prometheus, Loki, Grafana, cAdvisor
- Configuración para autenticación mediante LDAP

---

## 🔧 1. Crear los Namespaces

```bash
kubectl create namespace ldap
kubectl create namespace keycloak
kubectl create namespace monitoring
kubectl create namespace cert-manager
kubectl create namespace aplicacion
```

---

## 🌐 2. Desplegar Ingress NGINX

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
kubectl edit svc ingress-nginx-controller -n ingress-nginx  # Cambiar a type: NodePort
```

---

## 🔐 3. Instalar Cert-Manager con Helm

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```

---

## 📜 4. Aplicar Certificados TLS

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/cert-manager/clusterissuer-selfsigned.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/cert-manager/grafana-certificate.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/cert-manager/prometheus-certificate.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/cert-manager/keycloak-certificate.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/cert-manager/ldap-certificate.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/cert-manager/aplicacion-certificate.yaml
```

---

## 🧩 5. Desplegar OpenLDAP y phpLDAPadmin

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/ldap/namespace-ldap.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/ldap/openldap-secret.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/ldap/openldap-pvc.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/ldap/openldap-deployment.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/ldap/phpldapadmin-deployment.yaml
```

---

## 🛡 6. Desplegar Keycloak con PostgreSQL

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/keycloak/namespace-keycloak.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/keycloak/keycloak-admin-secret.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/keycloak/keycloak-postgres.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/keycloak/keycloak-deployment.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/keycloak/keycloak-service.yaml
```

---

## 📊 7. Desplegar Prometheus y Alertmanager

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Desplegar_Grafana+Loki+Prometheus+cAdvisor/prometheus/
```

---

## 📄 8. Desplegar Loki y Promtail

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Desplegar_Grafana+Loki+Prometheus+cAdvisor/loki/
```

---

## 📈 9. Desplegar Grafana con integración LDAP

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Desplegar_Grafana+Loki+Prometheus+cAdvisor/grafana/
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/ldap/grafana-ldap-configmap.yaml
```

---

## 🐳 10. Desplegar cAdvisor

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Desplegar_Grafana+Loki+Prometheus+cAdvisor/cAdvisor/
```

---

## 🌍 11. Aplicar Ingress para todos los servicios

```bash
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Ingress/ldap-ingress.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Ingress/keycloak-ingress.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Ingress/ingress-monitoring.yaml
kubectl apply -f C:/Users/0020360/Documents/DEVOPS/ALL/GRAFANALL/Ingress/ingress-aplicacion.yaml
```

---

## 🔁 12. Redirección Local para Pruebas

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 443:443
```

---

## 👤 13. Añadir un Usuario a LDAP


1. Accede a `phpLDAPadmin` vía navegador.
   - `cn=admin,dc=example,dc=org`
   - `adminpassword`
2. Inicia sesión con el admin configurado (ej: `cn=admin,dc=example,dc=org`).
3. Crea primero Una OU llamada users; y luego crear una Posix group llamado viewnext y luego crear una User account
5. Rellena campos obligatorios como:
   - UID
   - GID Number
   - User Password
6. La estructura será
	
	
+--> dc=example,dc=org (2)
  +--> ou=groups (1)
  | ---> cn=devops
  +--> ou=users (1)
    +--> ou=viewnext (1+)
      ---> cn=jorge vicente
      ---> uid=pedro

*EL usuario pedro lo hice desde keycloak, el de jorge con ldap primero.



---

## 🔗 14. Configurar Proveedor LDAP en Keycloak

1. Accede a Keycloak
   - `admin`
   - `admin123`

2. Creamos realm
Nombre viewnext y en On
2. Entra en tu Realm → ve a **User Federation**.
2. Haz clic en **Add provider** → selecciona **ldap**.
3. Rellena:

```text
UI display name : ldap
Vendor : Other
-
Connection and authentication settings
Connection URL ldap://openldap.ldap.svc.cluster.local:389 -> kubectl get svc -n ldap(Vemos el puerto)
Enable StartTLS Off
Use Truststore SPI Always
Connection pooling On
Connection timeout 5000
-
Bind type: simple
Bind DN: cn=admin,dc=example,dc=org
Bind credentials: adminpassword
-
LDAP searching and updating
Edit mode WRITABLE
Users DN ou=viewnext,ou=users,dc=example,dc=org
Username LDAP attribute uid
RDN LDAP attribute uid
UUID LDAP attribute entryUUID
User object classes inetOrgPerson, top
User LDAP filter: vacio 
Search scope One Level
Read timeout 5000
Pagination Off
Referral follow
-
Synchronization settings
Import users On
Sync Registrations On
Batch size 100
Periodic full sync Off
Periodic changed users sync Off
-
Kerberos integration
Allow Kerberos authentication Off
Use Kerberos for password authentication Off
```

4. Guarda.
5. En **Mappers**, verifica que estén `username`, `mail`, `givenName`, `sn`.
6. Ve a **Synchronization** → pulsa **Synchronize all users**.



---

🎉 ¡Tu entorno está desplegado e integrado correctamente!


Para autenticacion con google
Vamos a neustro realm viewnext
