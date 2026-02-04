# 🎫 GUÍA RÁPIDA - GLPI (Gestión de Incidentes)

**Sistema de Ticketing para CyberSOC**  
**Puerto**: http://localhost:9000

---

## 🚀 Primer Acceso

### Paso 1: Acceder a GLPI
```
URL: http://localhost:9000
```

### Paso 2: Completar Instalación (Solo primera vez)

1. **Idioma**: Seleccionar **Español (es_ES)**
2. **Licencia**: Aceptar términos → Click "Continuar"
3. **Tipo de instalación**: Seleccionar **Instalar**
4. **Base de datos**:
   ```
   Servidor MySQL: glpi-mysql
   Usuario MySQL: glpi_user
   Contraseña MySQL: glpi_password
   Base de datos: glpidb
   ```
5. Click "Continuar" hasta completar instalación
6. **Credenciales por defecto**:
   ```
   Usuario administrador:
   - Usuario: glpi
   - Contraseña: glpi
   
   O para superadmin:
   - Usuario: glpi-admin  
   - Contraseña: glpi
   ```

### Paso 3: Cambiar Contraseña
1. Login con `glpi / glpi`
2. Ir a **Administración → Usuarios**
3. Click en usuario `glpi`
4. Cambiar contraseña

---

## 📋 Crear un Ticket de Incidente

### Desde Kibana → GLPI

Cuando detectas una alerta en Kibana:

**Paso 1: En GLPI**
1. Click en **Asistencia → Tickets** (menú superior)
2. Click en **+ Nuevo ticket**

**Paso 2: Rellenar información**
```
Título: [SQL-INJ] SQL Injection detectado desde IP 192.168.1.105

Tipo: Incidente
Categoría: Seguridad → Incidente de seguridad

Urgencia: Alta
Impacto: Alto  
(Esto generará Prioridad: ALTA automáticamente)

Descripción:
Se detectó un intento de SQL Injection en el endpoint /login.php

Detalles del evento:
- Timestamp: 2026-02-03 14:32:15 UTC
- IP origen: 192.168.1.105
- Sistema afectado: web-server-01
- Payload: admin' OR '1'='1
- Severidad: HIGH

Acciones tomadas:
- IP bloqueada en firewall
- Revisión de logs de BD - Sin acceso exitoso

Asignar a: Analista SOC L1
Estado: Nuevo (en proceso)
```

**Paso 3: Añadir Seguimiento**
- Tab **Seguimiento** → Añadir nota con actualizaciones
- Adjuntar evidencia (exportar CSV desde Kibana)

---

## 🔧 Configuración Inicial Recomendada

### 1. Crear Categorías de Seguridad

**Configuración → Menús desplegables → Categorías de tickets**

Añadir:
- `Seguridad > SQL Injection`
- `Seguridad > SSH Brute Force`
- `Seguridad > Port Scanning`
- `Seguridad > Malware`
- `Seguridad > Comando Destructivo`

### 2. Crear Usuarios SOC

**Administración → Usuarios → + Usuario**

```
Analista L1:
- Nombre: Analista SOC L1
- Login: analista.l1
- Perfil: Technician
- Grupo: SOC Team

Analista L2:
- Nombre: Analista SOC L2  
- Login: analista.l2
- Perfil: Supervisor
- Grupo: SOC Team
```

### 3. Configurar Prioridades

**Configuración → Administración → Matriz de prioridad**

| Urgencia | Impacto Alto | Impacto Medio |
|----------|--------------|---------------|
| Crítica  | Muy Alta (1) | Alta (2)      |
| Alta     | Alta (2)     | Media (3)     |
| Media    | Media (3)    | Baja (4)      |

---

## 📊 Dashboard de Métricas

### Ver Estadísticas del SOC

**Herramientas → Informe → Informes predefinidos**

Informes útiles:
- **Tickets por estado**: Ver cuántos abiertos/cerrados
- **Tickets por categoría**: Tipos de incidentes más comunes
- **Tickets por técnico**: Carga de trabajo de analistas
- **Tiempo de resolución**: MTTR (Mean Time To Resolve)

---

## 🔍 Búsqueda Avanzada

**Asistencia → Tickets → Búsqueda avanzada**

Filtros útiles:
- `Estado = Nuevo` → Tickets sin asignar
- `Prioridad >= Alta` → Incidentes críticos
- `Categoría = Seguridad` → Solo eventos de seguridad
- `Fecha de apertura = Hoy` → Incidentes del día

---

## ✅ Flujo de Trabajo Recomendado

```
1. Alerta detectada en Kibana (severity: HIGH)
   ↓
2. Crear ticket en GLPI
   - Título descriptivo
   - Categoría: Seguridad > [Tipo ataque]
   - Urgencia/Impacto según severidad
   - Asignar a analista disponible
   ↓
3. Analista investiga
   - Añadir notas en tab "Seguimiento"
   - Cambiar estado a "En curso (asignado)"
   - Adjuntar evidencia (capturas, logs, CSV)
   ↓
4. Contención y solución
   - Documentar acciones en "Solución"
   - Cambiar estado a "Solucionado"
   ↓
5. Verificación
   - Supervisor revisa
   - Estado final: "Cerrado"
```

---

## 🎨 Personalización

### Estados de Ticket Personalizados

**Configuración → Menús desplegables → Estado de ticket**

Añadir:
- `Investigación en curso`
- `Pendiente de escalamiento`
- `Esperando respuesta del cliente`

### Plantillas de Ticket

**Asistencia → Plantillas → + Plantilla**

Crear plantilla para cada tipo de incidente:
- SQL Injection Template
- SSH Brute Force Template
- Port Scanning Template

---

## 📧 Notificaciones por Email (Opcional)

**Configuración → Notificaciones**

Configurar para que:
- Analista reciba email cuando se le asigna ticket
- Supervisor reciba email cuando ticket es crítico
- Usuario reciba email cuando ticket es cerrado

---

## 🆘 Troubleshooting

### No puedo acceder a GLPI
```powershell
# Verificar que el contenedor esté corriendo
docker ps | findstr glpi

# Ver logs de GLPI
docker logs glpi-incidentes

# Reiniciar GLPI
docker-compose restart glpi
```

### Base de datos no conecta
```powershell
# Verificar MySQL
docker logs glpi-mysql

# Esperar a que MySQL termine de iniciar (1-2 minutos)
docker-compose restart glpi
```

### Olvidé la contraseña
```powershell
# Acceder al contenedor y resetear
docker exec -it glpi-incidentes bash
# Luego usar la interfaz de recuperación de contraseña
```

---

## 📚 Recursos Adicionales

- **Documentación oficial**: https://glpi-project.org/documentation/
- **Plugins útiles**: 
  - GLPI Agent (para inventario automatizado)
  - Dashboard plugin (para métricas visuales)
  - Data Injection (para importar tickets desde CSV)

---

## 🔑 Credenciales por Defecto

| Usuario | Contraseña | Perfil | Uso |
|---------|------------|--------|-----|
| glpi | glpi | Administrador | Configuración general |
| tech | tech | Técnico | Analista SOC L1 |
| normal | normal | Usuario | Usuario final |
| post-only | postonly | Post-only | Solo crear tickets |

**⚠️ Cambiar todas las contraseñas en producción**

---

## ✅ Checklist de Configuración

- [ ] GLPI accesible en http://localhost:9000
- [ ] Instalación completada
- [ ] Contraseñas cambiadas
- [ ] Categorías de seguridad creadas
- [ ] Usuarios SOC añadidos (L1, L2)
- [ ] Matriz de prioridad configurada
- [ ] Plantillas de ticket creadas
- [ ] Primer ticket de prueba creado

---

## 🎯 Integración con Kibana

### Workflow Manual (Actual)
1. Ver alerta en Kibana
2. Copiar información
3. Crear ticket en GLPI manualmente
4. Documentar seguimiento

### Workflow Automatizado (Futuro - Fase 2)
- Usar webhook de Kibana para crear tickets automáticamente
- Plugin GLPI para recibir alertas vía API REST

---

**Para procedimientos específicos de respuesta, consulta**: [PLAYBOOK-OPERACION.md](../PLAYBOOK-OPERACION.md)
