# Capturas de Pantalla del Proyecto

**Propósito**: Esta carpeta contiene las evidencias visuales del funcionamiento del CyberSOC.

---

## 📸 Capturas Requeridas para Documentación

### 1. Infraestructura Docker ✅

**Archivo**: `01-docker-compose-up.png`  
**Comando**: `docker-compose ps`  
**Capturar**:
- Todos los contenedores en estado "Up"
- Estado "healthy" visible
- Puertos mapeados correctamente

**Verificación**:
```powershell
docker-compose ps
```

---

### 2. Kibana - Discover (Eventos de Seguridad) ✅

**Archivo**: `02-kibana-discover-events.png`  
**URL**: http://localhost:5601  
**Capturar**:
- Pantalla Discover con Data View "Syslog Security Events"
- Búsqueda: `tags:"security_event"`
- Mínimo 30-40 eventos visibles
- Campos visibles: @timestamp, severity, event_type, message

**Qué mostrar**:
- Barra de búsqueda con filtro aplicado
- Lista de eventos con diferentes severidades (colores)
- Panel lateral con campos disponibles

---

### 3. Kibana - Dashboard Completo ✅

**Archivo**: `03-kibana-dashboard.png`  
**URL**: http://localhost:5601 → Analytics → Dashboard  
**Capturar**:
- Dashboard "CyberSOC - Security Dashboard"
- 3 visualizaciones visibles simultáneamente:
  1. Pie Chart: Eventos por Severidad
  2. Area Chart: Timeline de Eventos
  3. Bar Chart: Top Eventos de Seguridad

**Qué mostrar**:
- Gráficos con datos reales
- Selector de tiempo visible (Last 7 days)
- Botón Refresh visible

---

### 4. Kibana - Evento Critical en Detalle ✅

**Archivo**: `04-kibana-event-detail.png`  
**Capturar**:
- Un evento con `severity:"critical"` expandido
- Todos los campos visibles:
  - @timestamp
  - severity: critical
  - event_type: Destructive Command
  - message: (comando rm -rf)
  - tags: [destructive_command, security_event]
  - host.name
  - log.file.path

---

### 5. GLPI - Panel Principal ✅

**Archivo**: `05-glpi-home.png`  
**URL**: http://localhost:9000  
**Capturar**:
- Dashboard principal después de login
- Menú de navegación visible
- Sección "Assistance" → "Tickets"
- Usuario logueado: glpi

---

### 6. GLPI - Ticket de Seguridad Creado ✅

**Archivo**: `06-glpi-ticket-critical.png`  
**Capturar**:
- Ticket creado con:
  - **Título**: "CRÍTICO: Comando destructivo detectado..."
  - **Prioridad**: 6 - Major
  - **Categoría**: Incident
  - **Estado**: New/In progress
  - **Descripción**: Detalles del evento copiados de Kibana

**Contenido visible**:
- Timestamp del incidente
- Severidad y tipo de evento
- Acciones tomadas
- Campos completos

---

### 7. Logstash - Logs de Procesamiento ✅

**Archivo**: `07-logstash-logs.png`  
**Comando**: `docker logs logstash-siem --tail 50`  
**Capturar**:
- Logs mostrando eventos procesados
- Mensajes con formato rubydebug:
  ```
  {
    "@version" => "1",
    "severity" => "high",
    "tags" => ["sql_injection", "security_event"],
    "event_type" => "SQL Injection Attempt"
  }
  ```

---

### 8. Elasticsearch - Índices y Conteo ✅

**Archivo**: `08-elasticsearch-indices.png`  
**PowerShell**:
```powershell
Invoke-RestMethod -Uri "http://localhost:9200/_cat/indices?v"
```
**Capturar**:
- Índice `syslog-2026.02.03` o similar
- Columna `docs.count` con 40+ documentos
- Estado `green` o `yellow`

---

### 9. Flujo Completo: Ataque → Detección → Ticket ✅

**Archivo**: `09-flujo-completo.png`  
**Capturar**: Composición de 3 pantallas:
1. Terminal con comando de ataque ejecutándose
2. Kibana mostrando el evento detectado (5 segundos después)
3. GLPI con ticket creado basado en ese evento

**Herramienta sugerida**: Paint / PowerPoint para juntar las 3 capturas

---

### 10. Script de Simulación de Ataques ✅

**Archivo**: `10-simulate-attacks-menu.png`  
**Comando**: `.\simulate_attacks.ps1`  
**Capturar**:
- Menú interactivo con 11 opciones
- Selección de "11 - Todos los ataques"
- Salida mostrando eventos generados

---

### 11. Docker Network - Arquitectura ✅

**Archivo**: `11-docker-network.png`  
**Comando**:
```powershell
docker network inspect socnet
```
**Capturar**:
- Red "socnet" con todos los contenedores conectados
- IPs asignadas a cada servicio
- Configuración de la red (driver: bridge)

---

### 12. Syslog Server - Archivos de Log ✅

**Archivo**: `12-syslog-logs.png`  
**Comando**:
```powershell
docker exec syslog-server ls -lh /var/log/syslog-ng/syslog-client/
```
**Capturar**:
- Lista de archivos .log (sshd.log, apache.log, kernel.log, etc.)
- Tamaños de archivo (mostrando actividad)
- Timestamps recientes

---

### 13. Reglas de Detección de Logstash ✅

**Archivo**: `13-logstash-rules.png`  
**Abrir**: `logstash/pipeline/logstash.conf` en editor  
**Capturar**:
- Código de una regla completa, por ejemplo:
```ruby
if [message] =~ /rm -rf|mkfs|dd if=/ {
  mutate {
    add_tag => [ "destructive_command", "security_event" ]
    add_field => { "event_type" => "Destructive Command" }
    add_field => { "severity" => "critical" }
  }
}
```

---

## 📊 Resumen de Capturas

| # | Archivo | Componente | Propósito |
|---|---------|------------|-----------|
| 1 | 01-docker-compose-up.png | Docker | Infraestructura operativa |
| 2 | 02-kibana-discover-events.png | Kibana | Detección en tiempo real |
| 3 | 03-kibana-dashboard.png | Kibana | Visualización avanzada |
| 4 | 04-kibana-event-detail.png | Kibana | Análisis detallado |
| 5 | 05-glpi-home.png | GLPI | Interface ticketing |
| 6 | 06-glpi-ticket-critical.png | GLPI | Gestión de incidentes |
| 7 | 07-logstash-logs.png | Logstash | Procesamiento de reglas |
| 8 | 08-elasticsearch-indices.png | Elasticsearch | Almacenamiento |
| 9 | 09-flujo-completo.png | Full Stack | Ciclo de vida completo |
| 10 | 10-simulate-attacks-menu.png | Generación | Ataques simulados |
| 11 | 11-docker-network.png | Docker | Arquitectura de red |
| 12 | 12-syslog-logs.png | Syslog | Recolección de logs |
| 13 | 13-logstash-rules.png | Logstash | Reglas de detección |

---

## 🎯 Checklist de Capturas

Antes de considerar la documentación completa, verifica:

- [ ] Todas las capturas muestran datos **reales** (no pantallas vacías)
- [ ] Las URLs son visibles en la barra de direcciones
- [ ] Los timestamps muestran fechas **recientes**
- [ ] Las capturas tienen **buena resolución** (1920x1080 mínimo)
- [ ] No hay información sensible expuesta (contraseñas visibles)
- [ ] Las capturas están **nombradas correctamente** (01-xxx.png)
- [ ] Se incluye al menos 1 captura de cada componente crítico

---

## 📝 Notas para la Memoria Técnica

Al insertar estas capturas en la memoria, incluir:

1. **Título descriptivo** de cada imagen
2. **Número de figura** (Figura 1, Figura 2, etc.)
3. **Pie de foto** explicando qué muestra
4. **Referencia en el texto** ("Como se observa en la Figura 3...")

**Ejemplo**:
```
Figura 3: Dashboard de Kibana mostrando la distribución de eventos
de seguridad por severidad. Se observa que el 86.49% de los eventos
son de severidad media (SSH brute force) y el 13.51% son de alta
severidad (SQL Injection, procesos sospechosos).
```

---

## 🚀 Cómo Tomar las Capturas Rápidamente

### Opción 1: Manual (Snipping Tool)
1. Windows + Shift + S
2. Seleccionar área
3. Guardar como .png

### Opción 2: Script Automático
```powershell
# Capturar pantalla completa
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
$bitmap.Save("C:\Users\rupra\Desktop\CyberSOC.Basico\docs\screenshots\01-screenshot.png")
```

---

**¡Una vez completes todas las capturas, tu proyecto tendrá evidencia visual profesional!** 📸✨
