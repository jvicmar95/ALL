#!/bin/bash

# Script: instalar_k3s.sh
# Objetivo: Instalar solo K3s en la máquina local
# Uso: Ejecutar como root o con sudo
# ----------------------------------------

set -e

# Variables
K3S_VERSION="v1.29.6+k3s2"

echo "🔧 Cambiando al directorio home..."
cd ~

# -------------------------
# 1. Instalar dependencias
# -------------------------
echo "📦 Instalando dependencias necesarias (git, curl)..."
sudo dnf install -y git curl

# -------------------------
# 2. Instalar K3s
# -------------------------
echo "🐳 Instalando K3s versión ${K3S_VERSION}..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - --write-kubeconfig-mode 644

# -------------------------
# 3. Verificar estado de K3s
# -------------------------
echo "✅ Verificando que K3s esté activo..."
if sudo systemctl is-active --quiet k3s; then
  echo "✅ K3s está activo y corriendo correctamente."
else
  echo "❌ K3s no se está ejecutando correctamente."
  exit 1
fi

# -------------------------
# 4. Mostrar estado del clúster
# -------------------------
echo "📦 Estado actual de los nodos:"
kubectl get nodes

echo "🎉 ¡K3s se ha instalado correctamente y está listo para usarse!"
