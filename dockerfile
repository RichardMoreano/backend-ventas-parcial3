# ====================== BUILD STAGE ======================
# ====================== RUNTIME STAGE ======================
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Uso multi-stage: construyo con Maven y luego copio solo el JAR final.
COPY pom.xml .
COPY src ./src

# Compilo el jar (skip tests para iteraciones rápidas).
RUN mvn clean package -DskipTests -U

# ====================== RUNTIME STAGE ======================
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Agrego un usuario no-root para mayor seguridad y curl para healthchecks.
RUN addgroup -S spring && adduser -S spring -G spring && apk add --no-cache curl
USER spring

# Metadatos del contenedor (reemplaza con tu repo/autor si hace falta).
LABEL org.opencontainers.image.source="https://github.com/RichardMoreano/backend-ventas-parcial3"
LABEL org.opencontainers.image.maintainer="tu-email@ejemplo.com"

# Copio el jar generado desde el builder.
COPY --from=builder /app/target/*.jar app.jar

# Perfil y opciones Java (ajustables en Kubernetes con env var o args).
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# Exponemos el puerto 8080 que usa la app.
EXPOSE 8080

# Healthcheck para que Kubernetes verifique liveness/readiness.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD curl -f http://localhost:8080/actuator/health || curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]