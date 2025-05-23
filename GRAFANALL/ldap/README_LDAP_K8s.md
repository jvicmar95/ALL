# 🛡️ Despliegue de OpenLDAP + phpLDAPadmin en Kubernetes

Esta guía describe cómo desplegar un entorno funcional de LDAP en Kubernetes utilizando:
- OpenLDAP (como backend de autenticación)
- phpLDAPadmin (interfaz gráfica para gestionar usuarios)
- Ingress TLS autofirmado
- Integración con Grafana para autenticación LDAP

---

## 🚀 1. Crear namespaces

```bash
kubectl create namespace ldap
```

---

## 📦 2. Desplegar OpenLDAP con manifiestos

Archivo: `openldap-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openldap
  namespace: ldap
spec:
  replicas: 1
  selector:
    matchLabels:
      app: openldap
  template:
    metadata:
      labels:
        app: openldap
    spec:
      containers:
        - name: openldap
          image: osixia/openldap:1.5.0
          ports:
            - containerPort: 389
          env:
            - name: LDAP_ORGANISATION
              value: "ExampleOrg"
            - name: LDAP_DOMAIN
              value: "example.org"
            - name: LDAP_ADMIN_PASSWORD
              value: "adminpassword"
---
apiVersion: v1
kind: Service
metadata:
  name: openldap
  namespace: ldap
spec:
  ports:
    - port: 1389
      targetPort: 389
  selector:
    app: openldap
```

---

## 🌐 3. Desplegar phpLDAPadmin

Archivo: `phpldapadmin-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpldapadmin
  namespace: ldap
spec:
  replicas: 1
  selector:
    matchLabels:
      app: phpldapadmin
  template:
    metadata:
      labels:
        app: phpldapadmin
    spec:
      containers:
        - name: phpldapadmin
          image: osixia/phpldapadmin:latest
          env:
            - name: PHPLDAPADMIN_LDAP_HOSTS
              value: openldap
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: phpldapadmin
  namespace: ldap
spec:
  selector:
    app: phpldapadmin
  ports:
    - port: 80
      targetPort: 80
```

---

## 🌍 4. Crear Ingress

Archivo: `ingress-ldap.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ldap-ingress
  namespace: ldap
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: selfsigned-clusterissuer
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - ldap.monitor.local
      secretName: ldap-tls
  rules:
    - host: ldap.monitor.local
      http:
        paths:
          - path: /(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: phpldapadmin
                port:
                  number: 80
```

Editar el `/etc/hosts` local:

```plaintext
127.0.0.1 ldap.monitor.local
```

---

## 👤 5. Crear un usuario en phpLDAPadmin

1. Iniciar sesión con:
   - **Login DN:** `cn=admin,dc=example,dc=org`
   - **Password:** `adminpassword`

2. Navegar a `ou=users` (crear si no existe).

3. Usar plantilla `Generic: User Account`.

4. Rellenar:
   - **Common Name:** nombre completo (ej. jorge vicente)
   - **User ID (uid):** nombre de usuario (ej. jvicente)
   - **Password:** contraseña
   - **uidNumber:** por ejemplo 1000
   - **gidNumber:** por ejemplo 500
   - **homeDirectory:** `/home/users/<usuario>`

5. Guardar el usuario.

---

## ✅ Verificar acceso LDAP

```bash
kubectl exec -it deploy/phpldapadmin -n ldap -- ldapsearch -x -H ldap://openldap.ldap.svc.cluster.local:389 -D "cn=admin,dc=example,dc=org" -w adminpassword -b "dc=example,dc=org"
```

---

## 🔐 Resultado final

¡Ya puedes autenticar usuarios desde LDAP en aplicaciones como Grafana o Keycloak!