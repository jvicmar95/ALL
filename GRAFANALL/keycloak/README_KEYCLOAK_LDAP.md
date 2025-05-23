# 🛡️ Integración de Keycloak con OpenLDAP en Kubernetes

Este documento describe el proceso completo para desplegar **Keycloak** y **OpenLDAP** en un clúster de Kubernetes y configurar su integración, permitiendo la autenticación de usuarios desde el servidor LDAP en Keycloak.

---

## 📅 Fecha

2025-05-23

---

## 📦 Componentes desplegados

- ✅ Keycloak 24.0.4
- ✅ OpenLDAP (Bitnami u osixia/openldap)
- ✅ Ingress NGINX con TLS autofirmado vía Cert-Manager
- ✅ Keycloak configurado para autenticarse contra OpenLDAP en modo **READ_ONLY**

---

## 🌐 Namespaces utilizados

- `keycloak`: para Keycloak y su base de datos PostgreSQL
- `ldap`: para el servidor OpenLDAP y phpLDAPadmin

---

## 🚀 Pasos realizados

### 1. Despliegue de OpenLDAP
- Se desplegó un servidor OpenLDAP en el namespace `ldap`
- Se expuso internamente con el servicio:
  ```bash
  ldap://openldap.ldap.svc.cluster.local:389
  ```
- Se creó una unidad organizativa `ou=users` y un usuario `cn=admin,dc=example,dc=org` con su contraseña

### 2. Despliegue de Keycloak
- Se desplegó Keycloak en el namespace `keycloak` con base de datos PostgreSQL
- Se expuso por Ingress con TLS usando Cert-Manager
- Acceso: `https://keycloak.monitor.local`

### 3. Configuración del proveedor LDAP en Keycloak
Desde la interfaz gráfica de Keycloak:

- Se accedió a: `User Federation` → `Add provider > ldap`
- Se configuró con:

| Campo                       | Valor                                                    |
|----------------------------|-----------------------------------------------------------|
| Connection URL             | ldap://openldap.ldap.svc.cluster.local:389               |
| Bind DN                    | cn=admin,dc=example,dc=org                                |
| Bind credentials           | (la contraseña definida al instalar OpenLDAP)             |
| Users DN                   | ou=users,dc=example,dc=org                                |
| Edit mode                  | READ_ONLY                                                 |
| Username attribute         | uid                                                       |
| RDN LDAP attribute         | uid                                                       |
| UUID LDAP attribute        | entryUUID                                                 |
| User object classes        | inetOrgPerson, organizationalPerson, person, top          |

### 4. Sincronización de usuarios
- Se pulsó el botón `Synchronize all users` tras guardar el proveedor LDAP
- Los usuarios de LDAP fueron importados correctamente a Keycloak

---

## 🔐 Resultado

- Los usuarios de OpenLDAP están disponibles en la consola de Keycloak
- El login en Keycloak puede autenticarse con los usuarios de LDAP
- La configuración es segura, funcional y preparada para SSO (con Grafana, por ejemplo)

---

## 📝 Notas

- El modo READ_ONLY implica que los usuarios deben ser creados y gestionados **directamente en OpenLDAP**, no desde Keycloak.
- Para sincronización bidireccional, se debe usar `Edit mode: WRITABLE` y garantizar permisos adecuados en el servidor LDAP.
