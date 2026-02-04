# CyberSOC Básico

Sistema de Centro de Operaciones de Seguridad (SOC) basado en contenedores Docker que implementa detección, análisis y gestión de incidentes de seguridad.

## Características principales

- **Detección automática**: ELK Stack con 10 reglas de seguridad configuradas
- **Visualización**: Dashboard Kibana con eventos en tiempo real
- **Gestión de incidentes**: Sistema de ticketing GLPI integrado
- **Recolección de logs**: syslog-ng + Filebeat para captura distribuida
- **Simulación de ataques**: Scripts para generar 10 tipos de ataques diferentes

## Requisitos

- Docker Desktop instalado y en ejecución
- 8GB RAM mínimo (16GB recomendado)
- Windows 10/11 con PowerShell 5.1+
- 10GB espacio en disco disponible

## Inicio rápido

```powershell
# Clonar el repositorio
git clone https://github.com/EliasGJ/CyberSOC-Basico.git
cd CyberSOC-Basico

# Levantar todos los servicios
docker-compose up -d

# Esperar 2-3 minutos para que se inicialicen
```

## Acceso a las interfaces

Una vez iniciados los servicios:

- **Kibana** (Dashboard + Discover): http://localhost:5601
- **GLPI** (Tickets): http://localhost:9000
  - Usuario: `glpi`
  - Contraseña: `glpi`
- **Elasticsearch** (API): http://localhost:9200

## Uso básico

### Simular ataque

```powershell
# Comando destructivo (CRITICAL)
docker exec syslog-client logger -t sudo "ROOT command: rm -rf /var/log/security"

# SQL Injection (HIGH)
docker exec syslog-client logger -t apache2 "SQL Injection: SELECT * FROM users WHERE 1=1--"
```

### Ver eventos en Kibana

1. Ir a http://localhost:5601/app/discover
2. Cambiar rango de tiempo a "Last 15 minutes" (arriba derecha)
3. Buscar: `tags:"security_event"`

### Crear ticket en GLPI

1. Ir a http://localhost:9000
2. Login con glpi/glpi
3. Asistencia → Tickets → Crear ticket
4. Usar plantillas del archivo `PLANTILLAS-TICKETS-GLPI.md`

## Estructura del proyecto

```
CyberSOC.Basico/
├── docker-compose.yml          # Orquestación de 8 servicios
├── logstash/
│   └── pipeline/
│       └── logstash.conf       # 10 reglas de detección configuradas
├── filebeat/
│   └── filebeat.yml            # Configuración recolector
├── client/
│   └── syslog-ng.conf          # Cliente syslog
├── server/
│   └── syslog-ng.conf          # Servidor syslog
├── simulate_attacks.ps1        # Script de simulación de ataques
├── MEMORIA-TECNICA.md          # Documentación técnica completa
├── PLAYBOOK.md                 # Procedimientos de respuesta
├── PLANTILLAS-TICKETS-GLPI.md  # Templates para tickets
├── GUIA-PRESENTACION-10.md     # Guía para presentación
└── docs/
    └── screenshots/
        └── README.md           # Guía para capturas

```

## Servicios incluidos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Elasticsearch | 9200 | Motor de búsqueda e indexación |
| Kibana | 5601 | Visualización y dashboards |
| Logstash | 5000 | Procesamiento y clasificación |
| Filebeat | - | Recolector de logs |
| GLPI | 9000 | Sistema de ticketing |
| MySQL | 3306 | Base de datos GLPI |
| syslog-server | 514 | Servidor de logs |
| syslog-client | - | Generador de eventos |

## Reglas de detección

El sistema detecta automáticamente 10 tipos de ataques:

1. **SSH Brute Force** (MEDIUM) - Múltiples intentos de login fallidos
2. **SQL Injection** (HIGH) - Intentos de inyección SQL (SELECT, UNION, OR '1'='1')
3. **XSS Attack** (HIGH) - Cross-Site Scripting (<script>, javascript:)
4. **Path Traversal** (HIGH) - Acceso a archivos no autorizados (../, /etc/passwd)
5. **Comandos Destructivos** (CRITICAL) - Comandos peligrosos (rm -rf, mkfs, dd)
6. **Escalada de Privilegios** (CRITICAL) - Cambios a root no autorizados
7. **Port Scanning** (MEDIUM) - Escaneos de puertos (Nmap scan)
8. **Procesos Sospechosos** (HIGH) - Procesos maliciosos (ncat, cryptominer)
9. **Exfiltración de Datos** (HIGH) - Transferencias sospechosas (curl, scp, sftp)
10. **Instalación No Autorizada** (MEDIUM) - Instalación de software (apt, dpkg)

## Documentación

- `MEMORIA-TECNICA.md`: Documentación técnica completa (política de retención, SLA, taxonomía VERIS)
- `PLAYBOOK.md`: Procedimientos de respuesta para cada tipo de ataque (10 playbooks)
- `PLANTILLAS-TICKETS-GLPI.md`: 10 plantillas listas para copiar
- `GUIA-PRESENTACION-10.md`: Guía paso a paso para demostración en vivo
- `GUION-PRESENTACION-ELIAS.md`: Guión humanizado para presentación grupal

## Comandos útiles

```powershell
# Ver estado de servicios
docker-compose ps

# Ver logs de un servicio
docker logs logstash-siem --tail 50

# Reiniciar un servicio
docker-compose restart logstash-siem

# Parar todo
docker-compose down

# Levantar de nuevo
docker-compose up -d
```

## Troubleshooting

### Los eventos no aparecen en Kibana

1. Verificar que llegaron a Elasticsearch:
```powershell
Invoke-RestMethod -Uri "http://localhost:9200/syslog-*/_count"
```

2. En Kibana, cambiar el rango de tiempo a "Last 1 hour"
3. Click en Refresh (icono circular arriba derecha)

### GLPI no responde

```powershell
docker-compose restart glpi-incidentes
# Esperar 30 segundos
```

### Permisos en logs

Si Logstash no puede leer logs:
```powershell
docker exec syslog-server chmod -R 755 /var/log/syslog-ng
docker restart logstash-siem
```

## Política de retención

- **CRITICAL**: 90 días
- **HIGH**: 60 días
- **MEDIUM**: 30 días
- **Otros**: 7 días

Cumple GDPR, Directiva NIS2 e ISO 27001.

## Autor

Proyecto desarrollado para el módulo de Ciberseguridad.

## Licencia

Uso educativo.
