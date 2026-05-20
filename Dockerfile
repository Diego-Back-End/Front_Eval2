# ==========================================
# STAGE 1: BUILDER
# ==========================================
# Imagen base para la etapa de construcción
FROM python:3.11-alpine AS builder

# Establecer directorio de trabajo
WORKDIR /app

# Copiar requirements.txt
COPY requirements.txt ./

# Instalar dependencias en un directorio temporal
# Esto permite copiar solo los paquetes instalados a la imagen final
RUN pip install --no-cache-dir --user -r requirements.txt && \
    # Limpiar caché de pip para reducir tamaño
    rm -rf /root/.cache/pip

# ==========================================
# STAGE 2: RUNTIME
# ==========================================
# Imagen base para la etapa de ejecución
FROM python:3.11-alpine AS runtime

# Crear usuario no root para seguridad (principio de mínimo privilegio)
RUN addgroup -g 1001 -S appuser && \
    adduser -S -u 1001 -G appuser appuser

# Establecer directorio de trabajo
WORKDIR /app

# Copiar paquetes Python instalados desde la etapa builder
# Se copian desde /root/.local al directorio de site-packages del sistema
COPY --from=builder /root/.local /usr/local

# Copiar archivos de la aplicación
COPY --chown=appuser:appuser app.py ./
COPY --chown=appuser:appuser requirements.txt ./

# Copiar carpeta de templates
COPY --chown=appuser:appuser templates ./templates

# Cambiar al usuario no root
USER appuser

# Exponer puerto 5000
EXPOSE 5000

# Comando de ejecución
CMD ["python", "app.py"]
