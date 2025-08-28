#!/bin/bash

set -euo pipefail # Salir ante cualquier error, variable no definida o error en un pipe.

# --- Constantes y Directorio del Script ---
# Hacemos el script independiente de la ubicación desde donde se ejecuta.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly SCRIPT_DIR

# --- Funciones ---

print_header() {
  echo ""
  echo "================================================="
  echo " $1"
  echo "================================================="
}

check_dependencies() {
  print_header "🔎 Verificando dependencias"
  local missing_deps=0
  for cmd in az terraform kubectl; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "❌ Error: El comando '$cmd' no se encuentra. Por favor, instálalo y asegúrate de que esté en el PATH." >&2
      missing_deps=1
    fi
  done

  if [ "$missing_deps" -eq 1 ]; then
    exit 1
  fi
  echo "✅ Dependencias encontradas (az, terraform, kubectl)."
}

main() {
  # === Variables ===
  # Ejemplo de uso: ./deploy_script.sh grupotestku-rg test-ku-aks
  local resource_group=${1:-"grupotestku-rg"}
  local cluster_name=${2:-"test-ku-aks"}
  local terraform_dir="${SCRIPT_DIR}/terraform"
  local k8s_manifests_dir="${SCRIPT_DIR}/ProjectKiu/clusteraks"

  print_header "Parámetros de Despliegue"
  echo "Resource Group:    $resource_group"
  echo "Cluster Name:      $cluster_name"
  echo "Terraform Dir:     $terraform_dir"
  echo "K8s Manifests Dir: $k8s_manifests_dir"

  check_dependencies

  print_header "🔐 Iniciando sesión en Azure"
  # Para automatización (CI/CD), se recomienda usar un Service Principal:
  # az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
  if ! az account show &> /dev/null; then
    echo "No se encontró una sesión activa. Iniciando sesión de forma interactiva..."
    az login --output none
  else
    echo "✅ Sesión de Azure activa encontrada."
  fi
  # Si tenés múltiples suscripciones, podés seleccionar una:
  # az account set --subscription "ade8ab0a-d71d-4489-81cb-4e23f3dc53bb"

  print_header "✅ Aplicando Terraform"
  ( # Usar un subshell (...) para que el cambio de directorio (cd) no afecte al resto del script.
    cd "$terraform_dir"
    terraform init -upgrade
    terraform apply -auto-approve
  )

  print_header "🔗 Obteniendo credenciales del cluster AKS"
  az aks get-credentials --resource-group "$resource_group" --name "$cluster_name" --overwrite-existing

  print_header "📦 Aplicando manifiestos de Kubernetes"
  # Aplicar todos los archivos .yaml del directorio de una sola vez. Es más simple y mantenible.
  kubectl apply -f "$k8s_manifests_dir"

  echo ""
  echo "🚀 ¡Despliegue completado correctamente!"
}

main "$@"
