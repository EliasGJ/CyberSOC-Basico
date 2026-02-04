# Playbook de Operaciones - CyberSOC

Manual de Procedimientos para Analistas SOC
Versión: 1.0
Fecha: 04/02/2026

## Tabla de Contenidos

1. [Respuesta ante SSH Brute Force](#1-ssh-brute-force)
2. [Respuesta ante SQL Injection](#2-sql-injection)
3. [Respuesta ante XSS Attack](#3-xss-attack)
4. [Respuesta ante Comandos Destructivos](#4-comandos-destructivos)
5. [Respuesta ante Escalada de Privilegios](#5-escalada-de-privilegios)
6. [Respuesta ante Port Scanning](#6-port-scanning)
7. [Respuesta ante Proceso Sospechoso](#7-proceso-sospechoso)
8. [Respuesta ante Exfiltración de Datos](#8-exfiltración-de-datos)



## 1. SSH Brute Force

Severidad: MEDIUM
Tag: ssh_failed_login
Tipo: Ataque de Autenticación

### Procedimiento de Respuesta

Paso 1: Detección (0-5 minutos)
Alerta aparece en Kibana Dashboard
Buscar: tags:"ssh_failed_login"
Revisar eventos similares en última hora

Paso 2: Análisis (5-15 minutos)
1. **Identificar IP de origen**:
   - Revisar campo `message` en Kibana
   - Extraer IP atacante
   - Buscar: `message:"Failed password" AND [IP_ATACANTE]`

2. **Contar intentos**:
   - Filtrar eventos por IP en últimos 15 minutos
   - Si > 10 intentos → Escalar a HIGH

3. **Verificar impacto**:
   - Buscar autenticaciones exitosas: `message:"Accepted password"`
   - Si hay acceso exitoso → CRITICAL

#### Paso 3: Contención (15-30 minutos)
**Acciones inmediatas**:
```powershell
# Bloquear IP en firewall (ejemplo Windows)
netsh advfirewall firewall add rule name="Block SSH Attacker" dir=in action=block remoteip=[IP_ATACANTE]

# Verificar sesiones activas SSH
netstat -an | Select-String "22"
```

#### Paso 4: Documentación (30-45 minutos)
**Crear ticket en GLPI**:
- **Título**: `MEDIUM: SSH Brute Force desde [IP] - [FECHA]`
- **Descripción**:
```
DETECCIÓN SSH BRUTE FORCE

Timestamp: [FECHA_HORA]
IP Origen: [IP_ATACANTE]
Host Destino: [HOST]
Usuario objetivo: [USUARIO]
Intentos fallidos: [CANTIDAD]
Acceso logrado: [SÍ/NO]

ACCIONES TOMADAS:
1. IP bloqueada en firewall
2. Revisión logs sin acceso exitoso
3. Monitoreo continuo 24h

ESTADO: Contenido
PRIORIDAD: Alta
```

#### Paso 5: Seguimiento (24 horas)
- Monitorear intentos desde misma IP
- Verificar no hay intentos desde IPs similares (mismo rango /24)
- Cerrar ticket si no hay actividad en 24h

**SLA**: Respuesta 1h / Resolución 24h



## 2. SQL Injection

**Severidad**: HIGH  
**Tag**: `sql_injection`  
**Tipo**: Ataque Web

### Procedimiento de Respuesta

Paso 1: Detección (0-5 minutos)
Alerta HIGH en Kibana
Buscar: tags:"sql_injection"
Identificar aplicación web afectada

#### Paso 2: Análisis (5-20 minutos)
1. **Examinar payload**:
   - Revisar campo `message` completo
   - Identificar tipo: UNION, OR 1=1, etc.
   - Extraer IP de origen

2. **Verificar impacto**:
   - Revisar logs de base de datos
   - Buscar queries ejecutadas en timestamp del ataque
   - Verificar si hubo extracción de datos

3. **Evaluar alcance**:
   - Contar intentos similares
   - Identificar si es ataque automatizado (múltiples IPs)

#### Paso 3: Contención (20-45 minutos)
**Acciones inmediatas**:
```powershell
# Bloquear IP en WAF/Firewall
New-NetFirewallRule -DisplayName "Block SQLi Attacker" -Direction Inbound -RemoteAddress [IP] -Action Block

# Si aplicación vulnerable - desconectarla temporalmente
docker-compose stop [servicio-web]
```

**Verificación**:
- Comprobar que la aplicación no responde al atacante
- Verificar integridad de base de datos

#### Paso 4: Remediación (45 minutos - 2 horas)
1. **Revisar código vulnerable**:
   - Identificar endpoint atacado
   - Buscar queries SQL sin prepared statements
   - Aplicar sanitización/parameterización

2. **Aplicar parche temporal**:
   - Validación de entrada en WAF
   - Rate limiting en endpoint vulnerable

#### Paso 5: Documentación (2-3 horas)
**Crear ticket en GLPI**:
- **Título**: `HIGH: SQL Injection en [APLICACIÓN] - [FECHA]`
- **Categoría**: Incident
- **Prioridad**: 5 - High
- **Descripción**:
```
DETECCIÓN SQL INJECTION

Timestamp: [FECHA_HORA]
IP Origen: [IP_ATACANTE]
Aplicación: [NOMBRE_APP]
Endpoint: [URL]
Payload: [QUERY_MALICIOSA]
Datos comprometidos: [SÍ/NO/DESCONOCIDO]

ACCIONES TOMADAS:
1. IP bloqueada
2. Aplicación desconectada temporalmente
3. Revisión integridad BD - OK
4. Parche aplicado en código
5. WAF configurado con regla específica

ESTADO: Resuelto
PRIORIDAD: Alta
TAXONOMÍA: Hacking - Web Application Attack
```

#### Paso 6: Post-Incidente (3-7 días)
- Auditoría completa de código
- Implementar prepared statements
- Training a desarrolladores
- Actualizar reglas WAF

**SLA**: Respuesta 1h / Resolución 24h



## 3. XSS Attack

**Severidad**: HIGH  
**Tag**: `xss_attack`  
**Tipo**: Ataque Web

### Procedimiento de Respuesta

#### Paso 1: Detección
- Alerta en Kibana: `tags:"xss_attack"`
- Identificar payload: `<script>`, `javascript:`, `onerror=`

#### Paso 2: Análisis
1. Determinar tipo: Reflected, Stored, DOM-based
2. Identificar campo vulnerable (input, textarea, URL param)
3. Evaluar si fue exitoso (si el script se ejecutó)

#### Paso 3: Contención
```powershell
# Bloquear IP
New-NetFirewallRule -DisplayName "Block XSS Attacker" -RemoteAddress [IP] -Action Block

# Limpiar datos contaminados (si Stored XSS)
# Conectar a BD y sanitizar registros
```

#### Paso 4: Remediación
- Implementar encoding de salida (HTML Entity Encoding)
- Content Security Policy (CSP) en headers HTTP
- Validación estricta de entrada

#### Paso 5: Documentación GLPI
- **Prioridad**: 5 - High
- **Taxonomía**: Hacking - Web Application Attack - XSS
- Documentar payload y campo vulnerable

**SLA**: Respuesta 1h / Resolución 24h



## 4. Comandos Destructivos

**Severidad**: CRITICAL  
**Tag**: `destructive_command`  
**Tipo**: Sabotaje Interno

### Procedimiento de Respuesta

Paso 1: Detección INMEDIATA (0-2 minutos)
ALERTA CRÍTICA en Kibana
Buscar: tags:"destructive_command"
Comandos: rm -rf, mkfs, dd if=/dev/zero

#### Paso 2: Respuesta Inmediata (2-5 minutos)
**ACCIÓN URGENTE**:
1. **Aislar el host INMEDIATAMENTE**:
```powershell
# Desconectar host de la red
docker network disconnect socnet [container]

# O apagar el sistema completo
docker-compose stop [servicio]
```

2. **Verificar ejecución**:
   - ¿Se ejecutó el comando?
   - Revisar integridad de archivos críticos
   - Comprobar logs, configuraciones, datos

#### Paso 3: Análisis Forense (5-30 minutos)
1. **Identificar atacante**:
   - Usuario que ejecutó comando
   - Sesión SSH/terminal de origen
   - IP de conexión

2. **Evaluar daños**:
```bash
# Verificar archivos eliminados
ls -la /var/log/
ls -la /etc/

# Revisar historial bash
docker exec [container] cat /home/[user]/.bash_history
```

3. **Determinar vector de acceso**:
   - ¿Credenciales comprometidas?
   - ¿Escalada de privilegios previa?
   - Revisar eventos ANTES del comando crítico

#### Paso 4: Contención y Recuperación (30 minutos - 2 horas)
1. **Bloquear acceso**:
   - Cambiar contraseñas de usuario comprometido
   - Revocar claves SSH
   - Deshabilitar cuenta

2. **Restaurar desde backup**:
```powershell
# Restaurar volumen Docker
docker run --rm -v [volume]:/data -v C:\backups:/backup ubuntu tar xzf /backup/backup.tar.gz -C /data
```

3. **Validar integridad**:
   - Verificar servicios funcionando
   - Comprobar logs restaurados
   - Revisar configuraciones

#### Paso 5: Documentación CRÍTICA
**Crear ticket CRITICAL en GLPI**:
- **Título**: `CRÍTICO: Comando Destructivo ejecutado - [HOST] - [FECHA]`
- **Prioridad**: 6 - Major
- **Categoría**: Incident
- **Urgencia**: Very High
- **Descripción**:
```
INCIDENTE CRÍTICO - COMANDO DESTRUCTIVO

Timestamp: [FECHA_HORA]
Host afectado: [HOSTNAME]
Usuario: [USER]
Comando: [COMANDO_EJECUTADO]
IP Origen: [IP]

IMPACTO:
- Archivos eliminados: [LISTA]
- Servicios afectados: [LISTA]
- Datos perdidos: [SÍ/NO]
- Backup disponible: [SÍ/NO]

ACCIONES INMEDIATAS:
1. Host aislado de red
2. Usuario bloqueado
3. Contraseñas cambiadas
4. Restauración desde backup iniciada
5. Análisis forense en progreso

ESTADO: En investigación
TAXONOMÍA: Misuse - Privilege Abuse
REQUIERE: Escalado a CISO
```

#### Paso 6: Escalado (Inmediato)
- **Notificar CISO** (Chief Information Security Officer)
- **Notificar Legal** (posible caso criminal)
- **Preservar evidencias** para análisis forense
- **No modificar logs originales**

#### Paso 7: Post-Incidente (1 semana)
- Análisis forense completo
- Revisión de privilegios sudo
- Implementar MFA (Multi-Factor Authentication)
- Auditoría de accesos privilegiados
- Informe ejecutivo a dirección

**SLA**: Respuesta INMEDIATA (15 min) / Resolución 4h



## 5. Escalada de Privilegios

**Severidad**: CRITICAL  
**Tag**: `privilege_escalation`  
**Tipo**: Movimiento Lateral

### Procedimiento de Respuesta

#### Paso 1: Detección (0-5 minutos)
- Alerta CRITICAL: `tags:"privilege_escalation"`
- Comandos: `sudo su`, `su -`, `changed to root`

#### Paso 2: Análisis Urgente
1. Usuario que escaló
2. De qué privilegio → a root
3. Comandos ejecutados después

#### Paso 3: Contención Inmediata
```bash
# Terminar sesión root no autorizada
docker exec [container] pkill -u root

# Bloquear usuario
docker exec [container] usermod -L [usuario]

# Aislar host
docker network disconnect socnet [container]
```

#### Paso 4: Documentación GLPI
- **Prioridad**: 6 - Major
- **Taxonomía**: Misuse - Privilege Escalation
- Revisar logs sudo: `/var/log/auth.log`

**SLA**: Respuesta 15 min / Resolución 4h



## 6. Port Scanning

**Severidad**: MEDIUM  
**Tag**: `port_scan`  
**Tipo**: Reconocimiento

### Procedimiento de Respuesta

#### Paso 1: Detección
- Alerta: `tags:"port_scan"`
- Múltiples conexiones SYN a diferentes puertos

#### Paso 2: Análisis
1. IP de origen del escaneo
2. Puertos objetivo
3. Frecuencia (escaneo rápido/lento)
4. Herramienta usada (nmap, masscan)

#### Paso 3: Contención
```powershell
# Bloquear IP escaneadora
netsh advfirewall firewall add rule name="Block Scanner" dir=in action=block remoteip=[IP]
```

**Nota**: Port scanning es fase de reconocimiento, esperar ataques posteriores

#### Paso 4: Monitoreo Aumentado
- Vigilar IP escaneadora próximas 48h
- Alertar si intenta explotar puertos encontrados
- Revisar si hay vulnerabilidades en puertos abiertos

**SLA**: Respuesta 4h / Resolución 3 días



## 7. Proceso Sospechoso

**Severidad**: HIGH  
**Tag**: `suspicious_process`  
**Tipo**: Malware

### Procedimiento de Respuesta

#### Paso 1: Detección
- Alerta: `tags:"suspicious_process"`
- Procesos: cryptominer, `/tmp/.hidden/`, conexiones no autorizadas

#### Paso 2: Análisis
```bash
# Ver proceso completo
docker exec [container] ps aux | grep [proceso]

# Ver conexiones de red
docker exec [container] netstat -tulpn | grep [proceso]

# Revisar archivos
docker exec [container] ls -la /tmp/.hidden/
```

#### Paso 3: Contención
```bash
# Terminar proceso
docker exec [container] pkill -9 [nombre_proceso]

# Eliminar binario
docker exec [container] rm -f /tmp/.hidden/miner

# Bloquear IP de C2 (Command & Control)
iptables -A OUTPUT -d [IP_C2] -j DROP
```

#### Paso 4: Limpieza
- Buscar persistencia (cron, systemd)
- Eliminar backdoors
- Cambiar credenciales comprometidas

**SLA**: Respuesta 1h / Resolución 24h



## 8. Exfiltración de Datos

**Severidad**: HIGH  
**Tag**: `data_exfiltration`  
**Tipo**: Pérdida de Datos

### Procedimiento de Respuesta

#### Paso 1: Detección
- Alerta: `tags:"data_exfiltration"`
- Comandos: `curl`, `scp`, `sftp` a destinos externos

#### Paso 2: Análisis Urgente
1. ¿Qué datos se exfiltraron?
2. Destino de los datos (IP, dominio)
3. Volumen transferido
4. Usuario que ejecutó

#### Paso 3: Contención
```bash
# Bloquear destino
iptables -A OUTPUT -d [IP_DESTINO] -j DROP

# Terminar transferencia en curso
docker exec [container] pkill curl
docker exec [container] pkill scp
```

#### Paso 4: Evaluación de Daños
- Identificar archivos exfiltrados
- Clasificación de datos (PII, secretos, etc.)
- Impacto legal (GDPR, notificaciones)

#### Paso 5: Documentación GLPI
- **Prioridad**: 5 - High
- **Taxonomía**: Hacking - Data Breach
- **Requiere**: Notificación DPO (Data Protection Officer)

**SLA**: Respuesta 1h / Resolución 24h

## Tabla de SLA por Severidad

| Severidad | Tiempo Respuesta | Tiempo Resolución | Escalado |
|-----------|------------------|-------------------|----------|
| **CRITICAL** | 15 minutos | 4 horas | Inmediato a CISO |
| **HIGH** | 1 hora | 24 horas | A supervisor SOC |
| **MEDIUM** | 4 horas | 3 días | No requerido |

## Taxonomía de Incidentes (VERIS)

Clasificación según framework VERIS:

| Categoría | Subcategoría | Ejemplos en este SOC |
|-----------|--------------|---------------------|
| **Malware** | Cryptominer, Backdoor | Procesos sospechosos |
| **Hacking** | SQL Injection, XSS, Brute Force | Ataques web, SSH |
| **Misuse** | Privilege Abuse | Comandos destructivos, escalada |
| **Error** | Configuration Error | N/A |
| **Environmental** | Power Failure | N/A |
| **DoS** | Network Scanning | Port scanning |

## Flujo General de Respuesta

```
1. DETECCIÓN
   └─> Alerta en Kibana Dashboard

2. TRIAJE (5 minutos)
   ├─> Confirmar true positive
   └─> Clasificar severidad

3. ANÁLISIS (15-30 minutos)
   ├─> Identificar origen
   ├─> Evaluar impacto
   └─> Determinar alcance

4. CONTENCIÓN (30 minutos - 2 horas)
   ├─> Bloquear atacante
   ├─> Aislar sistemas
   └─> Detener propagación

5. ERRADICACIÓN (2-24 horas)
   ├─> Eliminar malware
   ├─> Cerrar vulnerabilidades
   └─> Aplicar parches

6. RECUPERACIÓN (24 horas - 3 días)
   ├─> Restaurar servicios
   ├─> Validar integridad
   └─> Monitorear normalidad

7. POST-INCIDENTE (1 semana)
   ├─> Lessons learned
   ├─> Actualizar playbook
   └─> Mejorar detección
```

## Contactos de Escalado

| Rol | Contacto | Cuándo Escalar |
|-----|----------|----------------|
| **Supervisor SOC** | supervisor@empresa.com | Severidad HIGH persistente |
| **CISO** | ciso@empresa.com | Severidad CRITICAL |
| **Legal/DPO** | legal@empresa.com | Data breach, PII comprometida |
| **IT Manager** | it@empresa.com | Necesidad de cambios infraestructura |
| **CEO** | ceo@empresa.com | Incidente impacto negocio |

Última actualización: 04/02/2026
Próxima revisión: Cada 3 meses o después de incidente mayor
