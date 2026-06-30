
# Springboot-API-REST - Ventas

1) Ejecutar localmente

```bash
docker-compose up --build
```

La app quedará en http://localhost:8080

2) Secrets necesarios en GitHub (Settings -> Secrets):
- AWS_ROLE_TO_ASSUME: ARN del role para GitHub Actions (con permisos ECR/EKS)
- AWS_REGION: tu región (ej. us-east-1)
- ECR_REPO: URI del repositorio ECR para (backend-ventas)
- EKS_CLUSTER_NAME: nombre del cluster

3) Qué hace la pipeline

- Construye la imagen con Docker y la sube a ECR.
- Configura kubectl con `aws-actions/eks-update-kubeconfig`.
- Actualiza la imagen del Deployment en EKS.

Notas del developer:

- He añadido requests/limits en los manifests para que el HPA tenga métricas útiles.
- En producción, usar Secrets Manager y montar los secretos en k8s vía IRSA.

