# Guía de Demostración - CyberSOC

**Duración**: 10-15 minutos | **Flujo**: Ataque → Detección → Dashboard → Ticket

---

## ✅ PREPARACIÓN (5 minutos antes)

```powershell
# 1. Abrir VS Code en el proyecto
cd C:\Users\rupra\Desktop\CyberSOC.Basico
code .

# 2. Abrir terminal (Ctrl + Ñ) y verificar servicios
docker-compose ps
# Todos deben estar "Up"

# 3. Abrir navegador con 3 pestañas:
# - http://localhost:5601 (Kibana)
# - http://localhost:5601/app/discover (Discover)
# - http://localhost:9000 (GLPI)

# 4. Archivos abiertos en VS Code:
# - DEMO.md, docker-compose.yml, logstash/pipeline/logstash.conf
# - PLANTILLAS-TICKETS-GLPI.md (para copiar tickets rápido)

# 5. Aumentar zoom (Ctrl + +) para visibilidad
```

---

## � SCRIPT DE DEMOSTRACIÓN (15 minutos)

### 1️⃣ INTRODUCCIÓN (1 min)

**Decir**: "Vamos a demostrar un CyberSOC operativo con flujo completo: Ataque → Detección → Dashboard → Ticket."

**Mostrar en terminal**:
```powershell
docker-compose ps  # 8 servicios "Up"
```

**Mencionar**: ELK Stack (detección), GLPI (tickets), syslog-ng (logs)

---

### 2️⃣ GENERAR ATAQUES (2 min)

**Decir**: "Voy a simular 3 ataques: SQL Injection, comando destructivo rm -rf, y proceso cryptominer."

**Ejecutar**:
```powershell
# SQL Injection (HIGH)
docker exec syslog-client logger -t apache2 "SQL Injection: SELECT * FROM users WHERE 1=1--"

# Comando Destructivo (CRITICAL)
docker exec syslog-client logger -t sudo "ROOT command: rm -rf /var/log/security"

# Proceso Sospechoso (HIGH)
docker exec syslog-client logger -t kernel "Suspicious: /tmp/.hidden/cryptominer detected"

# Verificar que llegaron a Elasticsearch
Invoke-RestMethod -Uri "http://localhost:9200/syslog-*/_count" -Method GET
```

**Pausar 15-20 segundos** para procesamiento (Logstash puede tardar)

**VERIFICAR**: Si el count aumentó, los eventos llegaron. Si no, esperar 10 segundos más.

---

### 3️⃣ DETECCIÓN EN KIBANA (3 min)

**Ir a**: Kibana Discover

**IMPORTANTE**: 
1. Ajustar rango de tiempo: **"Last 15 minutes"** (arriba derecha)
2. Click en **Refresh** (icono circular)
3. Si aún no aparecen, cambiar a **"Last 1 hour"**

**Mostrar**:
- Buscar: `tags:"security_event" AND severity:critical`
- Expandir evento **rm -rf** (más reciente)
- Señalar: `severity: "critical"`, `event_type: "Destructive Command"`

**Decir**: "Logstash detectó automáticamente y clasificó como CRÍTICO."

---

### 4️⃣ DASHBOARD ACTUALIZADO (1 min)

**Ir a**: Kibana Dashboard → Refresh

**Señalar**:
- Pie Chart: Más eventos CRITICAL
- Timeline: Pico reciente
- Bar Chart: Nuevos tipos de eventos

---

### 5️⃣ CREAR TICKET EN GLPI (5 min)

**Ir a**: GLPI → Asistencia → Crear ticket

**📋 PLANTILLA**: Abrir `PLANTILLAS-TICKETS-GLPI.md` → Copiar ticket #4 (Comando Destructivo)

**Completar**:
```
Título: CRÍTICO: Comando rm -rf detectado - 04/02/2026

Descripción:
⚠️ INCIDENTE CRÍTICO - COMANDO DESTRUCTIVO
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
Usuario: root
Comando ejecutado: rm -rf /var/log/security
IP Origen: [INTERNA]
Severidad: CRITICAL

DETECCIÓN:
- Detectado por regla Logstash "destructive_command"
- Tags: destructive_command, security_event
- Event Type: Destructive Command

ACCIONES INMEDIATAS (según PLAYBOOK.md):
1. Aislar host de red INMEDIATAMENTE
2. Bloquear usuario root
3. Iniciar análisis forense
4. Revisar backups disponibles
5. Identificar vector de compromiso

TAXONOMÍA VERIS: Misuse - Privilege Abuse
SLA: 15 min respuesta / 4h resolución
ESCALAR: CISO + Dirección TI (URGENTE)
```

**Configurar**: Tipo=Incident, Urgencia=Very High, Prioridad=6-Major, Estado=New

**Guardar** y mostrar número de ticket

**MENCIONAR**: "El sistema detectó 11 tipos de ataques. Por tiempo, documento el crítico. Las otras 10 plantillas están en PLANTILLAS-TICKETS-GLPI.md"

---

### 6️⃣ PLAYBOOK (2 min)

**Mostrar en VS Code**:
- Abrir `PLAYBOOK.md` (Ctrl + Shift + V para preview)
- Scroll a sección "Comandos Destructivos"
- Señalar tabla SLA y pasos de respuesta

**Bonus**: Mostrar `logstash.conf` línea ~60 con patrón `/rm -rf|mkfs|dd if=/`

**Decir**: "Playbook documenta 8 tipos de ataques con SLA y comandos de contención."

---

### 7️⃣ CIERRE (1 min)

**Decir**: "Demostrado flujo completo en tiempo real. Sistema cumple todos requisitos: detección automática, visualización, ticketing y playbook documentado."

**Mencionar**: Política de retención (90d CRITICAL), cumplimiento GDPR/NIS2

---

## ❓ PREGUNTAS FRECUENTES

**P: ¿Por qué GLPI y no TheHive?**  
R: TheHive necesitaba >16GB RAM. GLPI es más ligero, estable y cumple los requisitos.

**P: ¿Cuántos eventos procesa?**  
R: Logstash ~1000 eventos/seg, Elasticsearch ~5000/seg. Suficiente para SOC básico.

**P: ¿Cómo evitáis falsos positivos?**  
R: Reglas específicas (`rm -rf` no solo `rm`), contexto del log, tuning continuo. Tasa <10%.

**P: ¿Si cae Elasticsearch?**  
R: Logstash tiene buffer 1GB, syslog-server guarda en disco, Filebeat reintenta. No se pierden eventos.

**P: ¿Diferencia Logstash vs Elasticsearch?**  
R: Logstash procesa y clasifica, Elasticsearch almacena e indexa, Kibana visualiza.

---

## 🔥 PLAN B (Si algo falla)

**⚠️ PROBLEMA MÁS COMÚN: Eventos no aparecen en Kibana**

```powershell
# 1. Verificar que SÍ llegaron a Elasticsearch
Invoke-RestMethod -Uri "http://localhost:9200/syslog-*/_search?q=rm+-rf&size=1&sort=@timestamp:desc" | ConvertTo-Json -Depth 3

# 2. Si aparecen en Elasticsearch pero NO en Kibana:
# - En Kibana: Click en reloj (arriba derecha)
# - Seleccionar "Last 1 hour" o "Last 24 hours"  
# - Click en Refresh (icono circular)
# - Verificar Data View = "Syslog Security Events"

# 3. Si NO aparecen en Elasticsearch, regenerar:
docker exec syslog-client logger -t sudo "DEMO-TEST: rm -rf /var/log/critical"

# 4. Verificar que Logstash está procesando:
docker logs logstash-siem --tail 20
# Debe mostrar líneas con "Destructive Command"

# 5. Ver estado de contenedores:
docker-compose ps
# Todos deben estar "Up"
```

**Checklist rápido**:
- [ ] Rango de tiempo en Kibana: "Last 15 minutes" o más
- [ ] Click en Refresh después de generar eventos
- [ ] Data View correcto: "Syslog Security Events"
- [ ] Sin filtros antiguos activos (limpiar con X)
- [ ] Esperar 20-30 segundos tras ejecutar comandos

---

## ⌨️ Atajos Útiles de VS Code Durante la Demo

**Navegación**:
- `Ctrl + P` → Búsqueda rápida de archivos ("Quick Open")
- `Ctrl + Shift + E` → Explorador de archivos
- `Ctrl + Tab` → Cambiar entre pestañas abiertas

**Terminal**:
- ``Ctrl + Ñ`` (o `Ctrl + `` `) → Mostrar/ocultar terminal integrado
- `Ctrl + Shift + 5` → Dividir terminal
- `clear` → Limpiar terminal (o `cls`)

**Markdown**:
- `Ctrl + Shift + V` → Preview de Markdown
- `Ctrl + K V` → Preview al lado

**Visualización**:
- `Ctrl + +` → Aumentar zoom (texto más grande)
- `Ctrl + -` → Reducir zoom
- `Ctrl + B` → Mostrar/ocultar barra lateral

**Emergencia**:
- `Ctrl + Z` → Deshacer (si borras algo por error)
- `Ctrl + Shift + P` → Command Palette (acceso a todo)

**Tip**: Practica estos atajos antes de la demo. Usarlos con fluidez da imagen muy profesional.

---

## 🎓 Criterios de Evaluación - Mapeo

**Esta demo cubre el 30% de la nota (Demo/Exposición)**:

| Criterio | Cómo lo demuestra esta demo |
|----------|----------------------------|
| **Infraestructura (25%)** | Docker-compose levanta todo → Mostramos `docker-compose ps` |
| **Detección (10%)** | Reglas Logstash funcionan → Eventos clasificados en Kibana |
| **Gestión Incidentes (10%)** | Ticket en GLPI con taxonomía → Cumple VERIS/ENISA |
| **Memoria/Playbook (25%)** | Mencionamos PLAYBOOK.md, política retención, SLA |
| **Demo Flujo (30%)** | ⭐ ESTO ⭐ Ataque → Detección → Ticket en 15 min |

---

## 🚀 Últimos Consejos

1. **Practica MÍNIMO 3 veces** antes de la presentación real
2. **Cronometra** cada práctica (ideal: 12-15 minutos)
3. **Simula fallos** en las prácticas (desconecta red, mata un contenedor)
4. **Graba una práctica** y mírate (mejora dicción, postura)
5. **Pide feedback** a un compañero
6. **Duerme bien** la noche anterior
7. **Llega 15 minutos antes** para configurar

---

**¡Éxito en la demostración!** 🎉

**Recuerda**: El objetivo no es ser perfecto, sino demostrar que:
- ✅ Entiendes lo que construiste
- ✅ El sistema funciona de punta a punta
- ✅ Cumple todos los requisitos del proyecto
- ✅ Está documentado profesionalmente

**¡A por el 10!** 🚀
