# Guía de Demostración - CyberSOC

Duración estimada: 10-15 minutos

## Preparación (5 minutos antes)

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

## Script de demostración

### 1. Introducción (1 minuto)

**Decir**: "Vamos a demostrar un CyberSOC operativo con flujo completo: Ataque → Detección → Dashboard → Ticket."

**Mostrar en terminal**:
```powershell
docker-compose ps  # 8 servicios "Up"
```

Mencionar los componentes: ELK Stack (detección), GLPI (ticketing), syslog-ng (logs)

### 2. Generar ataques (2 minutos)

Decir algo como: "Ahora voy a simular 3 ataques para ver cómo los detecta el sistema - un SQL Injection, un comando rm -rf que es muy peligroso, y un proceso sospechoso tipo cryptominer"

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

Verificar que el count haya aumentado. Si no aparece nada aún, esperar unos segundos más porque a veces Logstash tarda un poco.

### 3. Detección en Kibana (3 minutos)

**Ir a**: Kibana Discover

IMPORTANTE - lo más probable es que tengas que cambiar el rango de tiempo:
- Arriba a la derecha hay un reloj, clicka ahí
- Pon "Last 15 minutes" o "Last 1 hour"
- Dale a Refresh (el icono circular)

Luego busca: `tags:"security_event" AND severity:critical`

Expandir el evento del rm -rf (debería estar arriba porque es el más reciente) y señalar los campos importantes:
- severity: critical
- event_type: Destructive Command

Comentar que Logstash lo detectó automáticamente con las reglas que configuramos.

### 4. Dashboard actualizado (1 minuto)

Ir al Dashboard de Kibana y darle a Refresh. Señalar:
- En el gráfico circular ahora hay más eventos críticos
- En la timeline se ve el pico reciente
- En el bar chart aparecen los nuevos tipos de eventos

### 5. Crear ticket en GLPI (4-5 minutos)

Ir a GLPI → Asistencia → Crear ticket

Abrir el archivo PLANTILLAS-TICKETS-GLPI.md y copiar el ticket #4 (Comando Destructivo). Completar así:
```
Título: CRÍTICO: Comando rm -rf detectado - 04/02/2026

Descripción:
INCIDENTE CRÍTICO - COMANDO DESTRUCTIVO
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

Configurar: Tipo=Incident, Urgencia=Very High, Prioridad=6-Major, Estado=New

Guardar y mostrar el número de ticket generado.

Mencionar que el sistema puede detectar 11 tipos de ataques diferentes pero por tiempo solo documentamos el crítico. Las otras plantillas están en el archivo PLANTILLAS-TICKETS-GLPI.md

### 6. Playbook (2 minutos)

En VS Code:
- Abrir PLAYBOOK.md (Ctrl + Shift + V para preview)
- Ir a la sección de "Comandos Destructivos"
- Enseñar la tabla SLA y los pasos de respuesta

Si da tiempo, también se puede mostrar el logstash.conf alrededor de la línea 60 donde está el patrón que detecta rm -rf, mkfs, etc.

Explicar que el Playbook documenta 8 tipos de ataques con sus SLA y los comandos para contenerlos.

### 7. Cierre (1 minuto)

Resumen: hemos visto el flujo completo funcionando en tiempo real. El sistema cumple todos los requisitos - detección automática, visualización en dashboard, ticketing profesional y playbook documentado.

Mencionar también que hay política de retención configurada (90 días para eventos críticos) y que cumple GDPR/NIS2.

## Preguntas frecuentes

Por si preguntan:

¿Por qué GLPI y no TheHive?
TheHive necesitaba más de 16GB de RAM y mi máquina no daba. GLPI es más ligero, estable y cumple perfectamente los requisitos del proyecto.

¿Cuántos eventos procesa?
Logstash puede procesar alrededor de 1000 eventos por segundo, Elasticsearch unos 5000/seg. Para un SOC básico es más que suficiente.

¿Cómo evitáis falsos positivos?
Con reglas específicas - por ejemplo detectamos "rm -rf" completo, no solo "rm". También vemos el contexto del log. Hay que ir ajustando las reglas, pero la tasa de falsos positivos está por debajo del 10%.

¿Qué pasa si cae Elasticsearch?
Logstash tiene un buffer de 1GB, el syslog-server guarda todo en disco, y Filebeat reintenta automáticamente. No se pierden eventos.

¿Diferencia entre Logstash y Elasticsearch?
Logstash procesa y clasifica los eventos, Elasticsearch los almacena e indexa, y Kibana los visualiza. Cada uno tiene su función en la pipeline.

## Plan B (si algo falla)

PROBLEMA MÁS COMÚN: Los eventos no aparecen en Kibana

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

Checklist rápido:
- Rango de tiempo en Kibana: "Last 15 minutes" o más
- Click en Refresh después de generar eventos
- Data View correcto: "Syslog Security Events"
- Sin filtros antiguos activos (limpiar con X)
- Esperar 20-30 segundos tras ejecutar comandos

## Atajos de VS Code útiles para la demo

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

Tip: practica estos atajos antes, usarlos bien da muy buena impresión.

## Criterios de evaluación

Esta demo cubre el 30% de la nota (Demo/Exposición):

| Criterio | Cómo lo demuestra esta demo |
|----------|----------------------------|
| **Infraestructura (25%)** | Docker-compose levanta todo → Mostramos `docker-compose ps` |
| **Detección (10%)** | Reglas Logstash funcionan → Eventos clasificados en Kibana |
| **Gestión Incidentes (10%)** | Ticket en GLPI con taxonomía → Cumple VERIS/ENISA |
| **Memoria/Playbook (25%)** | Mencionamos PLAYBOOK.md, política retención, SLA |
| **Demo Flujo (30%)** | Ataque → Detección → Ticket en 15 min (LO MÁS IMPORTANTE) |

## Últimos consejos

1. Practica mínimo 3 veces antes de la presentación
2. Cronometra cada práctica (lo ideal es entre 12-15 minutos)
3. En las prácticas simula fallos - desconecta la red, mata un contenedor, etc
4. Si puedes grábate y mírate después, ayuda a mejorar
5. Pide feedback a algún compañero
6. Duerme bien la noche antes
7. Llega 15 minutos antes para tener todo configurado

Recuerda: el objetivo no es que salga perfecto, sino demostrar que entiendes lo que has hecho, que el sistema funciona, cumple los requisitos y está bien documentado.
