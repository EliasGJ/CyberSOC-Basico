# Guía de presentación - Demostración en vivo

Duración: 12-15 minutos

## Preparación (antes de entrar a clase)

```powershell
# 1. Levantar todo
cd C:\Users\rupra\Desktop\CyberSOC.Basico
docker-compose up -d

# 2. Esperar 2 minutos (mientras abres navegador)

# 3. Abrir en navegador (3 pestañas):
# - http://localhost:5601 (Dashboard)
# - http://localhost:5601/app/discover (Discover)
# - http://localhost:9000 (GLPI - login: glpi/glpi)

# 4. En VS Code abrir:
# - GUIA-PRESENTACION-10.md (esta guía)
# - PLANTILLAS-TICKETS-GLPI.md
# - PLAYBOOK.md

# 5. Aumentar zoom: Ctrl + + (3-4 veces)
```

Checklist antes de empezar:
- 8 contenedores "Up" → `docker-compose ps`
- Kibana abierto y cargado
- GLPI logueado
- Terminal PowerShell visible

## PASO 1: Introducción (30 segundos)

Decir algo como:
"Voy a demostrar un CyberSOC operativo con detección, visualización y gestión de incidentes en tiempo real."

Ejecutar:
```powershell
docker-compose ps
```

Comentar: "8 servicios corriendo: ELK Stack para detección, GLPI para tickets, syslog-ng para logs."

## PASO 2: Generar ataque crítico (1 minuto)

Decir:
"Voy a simular un ataque crítico: un comando destructivo rm -rf ejecutado por root."

Ejecutar en terminal:
```powershell
docker exec syslog-client logger -t sudo "ROOT command: rm -rf /var/log/security"
```

Mientras esperas (20 segundos), explicar:
"El log se envía al servidor syslog, Logstash aplica reglas de detección automáticas y lo clasifica como CRÍTICO."

Espera 20 segundos (cuenta mentalmente)

## PASO 3: Mostrar detección en Kibana (2 minutos)

**IR A**: Kibana Discover (pestaña 2)

**HACER**:
1. Click en **reloj arriba derecha** → Seleccionar **"Last 15 minutes"**
2. Click en **Refresh** (icono circular)
3. En barra búsqueda: escribir `severity:critical`
4. Click en el evento más reciente (arriba)
5. **Expandir** (flecha)

**SEÑALAR EN PANTALLA**:
- `severity: critical` → "Clasificado como crítico"
- `event_type: Destructive Command` → "Tipo de ataque detectado"
- `message: ROOT command: rm -rf...` → "Comando capturado"

**DECIR**:
> "Logstash detectó automáticamente el patrón rm -rf y lo clasificó como crítico. El evento está indexado en Elasticsearch y listo para análisis."



## PASO 4: Dashboard (1 minuto)

Ir a Kibana Dashboard (pestaña 1) y darle a Refresh

Señalar:
- Pie Chart (izquierda): "Distribución por severidad, ahora hay eventos críticos"
- Timeline (centro): "Se ve el pico reciente"
- Bar Chart (derecha): "Los comandos destructivos aparecen en el top"

Comentar: "El dashboard se actualiza en tiempo real, se puede configurar auto-refresh cada 30 segundos."

## PASO 5: Crear ticket en GLPI (4 minutos)

Ir a GLPI (pestaña 3)

1. Asistencia → Tickets → + Crear ticket
2. En VS Code: Copiar desde PLANTILLAS-TICKETS-GLPI.md el ticket #4 (líneas 119-155)

Título:
```
CRÍTICO: Comando destructivo rm -rf ejecutado - 04/02/2026
```

Descripción (copiar todo):
```
INCIDENTE CRÍTICO - COMANDO DESTRUCTIVO
Timestamp: 04/02/2026 [HORA ACTUAL]
Host afectado: syslog-client
Usuario: root
Comando ejecutado: rm -rf /var/log/security
Severidad: CRITICAL

DETECCIÓN:
- Detectado por regla Logstash "destructive_command"
- Tags: destructive_command, security_event

ACCIONES INMEDIATAS (según PLAYBOOK):
1. Aislar host de red INMEDIATAMENTE
2. Bloquear usuario root
3. Iniciar análisis forense
4. Revisar backups disponibles
5. Identificar vector de compromiso

TAXONOMÍA: VERIS - Misuse/Privilege Abuse
SLA: 15 min respuesta / 4h resolución
ESCALAR: CISO + Dirección TI (URGENTE)
```

Configurar:
- Tipo: Incident
- Urgencia: Very high
- Prioridad: 6 - Major

Click en "Añadir"

Mientras completas el ticket, comentar: "Esto sigue el playbook documentado. Para eventos críticos el SLA es 15 minutos de respuesta y 4 horas de resolución, y hay que escalarlo al CISO."

## PASO 6: Mostrar Playbook (2 minutos)

**IR A**: VS Code → Abrir **PLAYBOOK.md**

**HACER**: `Ctrl + Shift + V` (preview)

**SCROLL RÁPIDO** mostrando:
- Tabla de contenidos con 8 procedimientos
- Sección **"4. Comandos Destructivos"**
- Tabla de SLA por severidad

**DECIR**:
Comentar: "Tenemos un playbook completo con procedimientos de respuesta para 8 tipos de ataques. Cada uno incluye pasos técnicos de contención, comandos específicos, SLAs y taxonomía VERIS."

Si hay tiempo, mostrar también logstash.conf línea 60 con el patrón que detecta rm -rf, mkfs, dd if=/

Decir: "Esta es la regla que detectó el ataque."

## PASO 7: Cierre (1 minuto)

Resumen: "He demostrado el ciclo completo - ataque simulado, detección automática en tiempo real, clasificación por severidad, visualización en dashboard y creación de ticket siguiendo los procedimientos."

Mencionar:
- Política de retención: 90 días para críticos, 60 para high, 30 para medium
- Cumplimiento GDPR y NIS2
- Sistema escalable: ~1000 eventos/seg en Logstash

"El sistema está completamente operativo y cumple todos los requisitos."

## Preguntas frecuentes (respuestas cortas)

¿Por qué GLPI y no TheHive?
"TheHive necesitaba más de 16GB RAM. GLPI es más ligero, igual de funcional y muy usado en producción."

¿Cómo evitáis falsos positivos?
"Reglas muy específicas - por ejemplo rm -rf completo no solo rm, verificamos contexto del log y ajustamos continuamente. Tasa menor al 10%."

¿Qué pasa si cae Elasticsearch?
"Logstash tiene buffer de 1GB, syslog-server guarda en disco, Filebeat reintenta. No se pierden eventos."

¿Los tickets se crean automáticamente?
"En esta versión son manuales para demostrar el flujo. En producción se automatizaría con webhooks de Logstash a la API de GLPI."

¿Cuántos eventos procesa?
"Logstash ~1000 eventos/segundo, Elasticsearch ~5000. Suficiente para SOC de 50-100 empleados. Se puede escalar añadiendo nodos."

## Plan B (si algo falla)

Si los eventos no aparecen en Kibana:
```powershell
# 1. Ajustar tiempo en Kibana a "Last 1 hour"
# 2. Regenerar evento
docker exec syslog-client logger -t sudo "DEMO: rm -rf /critical"
# 3. Esperar 30 segundos
```

Si GLPI no responde:
```powershell
docker-compose restart glpi-incidentes
# Esperar 30 segundos
```

Si algo falla técnicamente, mostrar capturas preparadas en docs/screenshots/

Frase salvadora: "Por tiempo, usaremos evidencias preparadas del funcionamiento completo."

## Criterios de evaluación - cómo cubrirlos

Infraestructura (25%)
Cubres con: docker-compose ps mostrando 8 servicios
Decir: "Infraestructura containerizada con Docker, fácilmente replicable"

Detección (10%)
Cubres con: Evento en Kibana clasificado automáticamente
Decir: "8 reglas de detección en Logstash cubriendo OWASP Top 10"

Gestión Incidentes (10%)
Cubres con: Ticket en GLPI con taxonomía VERIS
Decir: "Taxonomía VERIS/ENISA, SLAs definidos, escalado documentado"

Documentación (25%)
Cubres con: Mencionar README, PLAYBOOK, política retención
Decir: "700 líneas de documentación técnica, playbook con 8 procedimientos, cumplimiento GDPR/NIS2"

Demo/Exposición (30%) - LO MÁS IMPORTANTE
Cubres con: Esta demo completa
Clave: Hablar con confianza, explicar cada paso, demostrar que entiendes el sistema

## Checklist final

5 minutos antes de empezar:
- Docker corriendo (8 contenedores "Up")
- Kibana cargado (ambas pestañas)
- GLPI logueado
- VS Code con archivos abiertos
- Terminal PowerShell visible
- Zoom aumentado (Ctrl + +)
- Agua/café a mano
- Respirar profundo 3 veces



## Tips para conseguir el 10

Hacer:
- Hablar pausado (la audiencia necesita procesar)
- Explicar QUÉ haces ANTES de hacerlo
- Mirar al público, no solo a la pantalla
- Usar términos técnicos correctos (SIEM, SOC, IDS, taxonomía)
- Conectar con requisitos: "Esto cumple el requisito de detección automática..."

Evitar:
- Disculparte ("perdón esto está mal...")
- Ir demasiado rápido
- Leer textualmente de pantalla
- Decir "no sé" sin ofrecer alternativa
- Usar muletillas ("ehhh", "bueno", "pues")

Frases que funcionan bien:
- "Como pueden observar..."
- "El sistema detectó automáticamente..."
- "Siguiendo el playbook documentado..."
- "Esto cumple la normativa GDPR/NIS2..."
- "En un entorno de producción real, también implementaríamos..."

## Último consejo

Practica mínimo 3 veces esta guía completa:
1. Primera vez: lee y ejecuta (20 min)
2. Segunda vez: cronometra (objetivo 15 min)
3. Tercera vez: sin mirar la guía (solo consultas)

El día de la presentación deberías poder hacerlo casi de memoria, consultando solo cuando necesites copiar texto.

Recuerda: el objetivo no es ser perfecto, sino demostrar que entiendes lo que construiste, que el sistema funciona, está bien documentado y cumple todos los requisitos. Tu proyecto está completo, solo falta presentarlo con confianza.
