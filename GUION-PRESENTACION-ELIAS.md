# Guión de Presentación - CyberSOC Básico
## Elías - Presentación del Proyecto

---

## 1️⃣ Introducción

### Qué decir:
"Buenos días/tardes a todos. Hoy vamos a presentarles el proyecto **CyberSOC Básico**, un sistema de monitoreo y detección de amenazas que hemos desarrollado.

La idea surgió de la necesidad de tener una solución práctica para detectar ataques en tiempo real. En el mundo actual, con los ciberataques aumentando cada día, es fundamental tener un sistema que no solo registre eventos, sino que también los analice y nos permita responder rápidamente.

Este proyecto implementa un SOC (Security Operations Center) funcional usando herramientas de código abierto, lo que lo hace accesible y replicable para cualquier organización."

### Capturas a mostrar:
📸 **Captura 1**: Pantalla inicial de Kibana mostrando el dashboard principal
- **Cómo hacerla**: Abre http://localhost:5601 y captura la pantalla principal de Kibana

📸 **Captura 2**: Vista del repositorio de GitHub con el README
- **Cómo hacerla**: Abre https://github.com/EliasGJ/CyberSOC-Basico y captura la página principal

### Duración estimada: 1-2 minutos

---

## 2️⃣ Descripción General

### Qué decir:
"El sistema que hemos creado es un stack de seguridad completo que funciona de la siguiente manera:

Primero, tenemos **varios contenedores Docker** que simulan un entorno real de producción. Estos contenedores generan logs de diferentes servicios: SSH, Apache, comandos del sistema, etc.

Estos logs pasan por **syslog-ng**, que actúa como recolector central. Desde ahí, **Filebeat** los captura y los envía a **Logstash**, donde ocurre la magia: tenemos configuradas reglas de detección que identifican patrones sospechosos en tiempo real.

Por ejemplo, si alguien intenta hacer fuerza bruta en SSH, o ejecuta un comando peligroso como 'rm -rf', o intenta una inyección SQL, el sistema lo detecta automáticamente y le asigna una severidad: crítica, alta, media o baja.

Finalmente, todo esto se visualiza en **Kibana**, donde podemos ver dashboards en tiempo real, y los incidentes se gestionan en **GLPI**, nuestro sistema de tickets."

### Capturas a mostrar:
📸 **Captura 3**: Diagrama de arquitectura completo
- **Cómo hacerla**: Abre el archivo README.md o MEMORIA-TECNICA.md y captura la sección de arquitectura

📸 **Captura 4**: Terminal mostrando todos los contenedores corriendo
- **Cómo hacerla**: Ejecuta `docker ps` en PowerShell y captura la salida completa

📸 **Captura 5**: Kibana Discover con eventos de seguridad filtrados
- **Cómo hacerla**: En Kibana > Discover, busca `tags:security_event` y captura la vista con los resultados

### Duración estimada: 2-3 minutos

---

## 3️⃣ Herramientas Utilizadas

### Qué decir:
"Ahora vamos a hablar de las herramientas que utilizamos y cómo trabajan juntas:

**El Stack ELK** es el núcleo del sistema:

**Elasticsearch** - Es como una biblioteca gigante que guarda millones de eventos de seguridad. Puede buscar entre millones de registros en milisegundos. Por ejemplo, si queremos saber todos los intentos de login fallidos de los últimos 30 días, nos da la respuesta casi instantáneamente.

**Logstash** - Es el cerebro que procesa cada evento. Le hemos programado reglas específicas: si ve 'Failed password' repetido, lo marca como fuerza bruta. Si encuentra 'UNION SELECT' en una petición web, lo identifica como SQL Injection. Todo esto en tiempo real, procesando cientos de eventos por segundo.

**Kibana** - Es la interfaz visual. Convierte toda esa información en gráficos y dashboards interactivos. Los analistas pueden hacer preguntas como '¿cuántos ataques SQL tuvimos esta semana?' y ver la respuesta en segundos.

**syslog-ng** - El veterano confiable del mundo Unix. Lo usamos en dos niveles: en el cliente recolecta logs del sistema, en el servidor los recibe y organiza. Piensen en él como el cartero que entrega mensajes de forma ordenada.

**Filebeat** - El recolector ágil y ligero. Monitorea archivos de log constantemente y cuando detecta líneas nuevas, las envía a Logstash. Es tan eficiente que apenas consume recursos.

**GLPI** - Nuestro sistema de tickets. Cuando detectamos algo serio, creamos un ticket con toda la información: qué pasó, cuándo, severidad, servidor afectado. Lo asignamos a un analista, documentamos las acciones y lo cerramos. Esto nos da trazabilidad completa.

**Docker y Docker Compose** - Son las herramientas que hacen todo portable. Docker crea contenedores (como mini servidores aislados), y Docker Compose los orquesta todos. Con un solo comando levantamos el sistema completo.

**GitHub** - Todo el código está aquí, documentado. Cualquiera puede clonar el proyecto y tener su propio CyberSOC funcionando.

**Ahora, ¿cómo interactúan todas estas piezas?**

El flujo es así: 

1. **syslog-client** genera logs simulados → 
2. **syslog-server** los recibe por el puerto 514 y los guarda en archivos → 
3. **Filebeat** lee esos archivos constantemente → 
4. **Filebeat** envía los eventos a **Logstash** por el puerto 5044 → 
5. **Logstash** aplica las reglas de detección y enriquece cada evento con tags y severidad → 
6. **Logstash** envía los eventos procesados a **Elasticsearch** por el puerto 9200 → 
7. **Kibana** se conecta a **Elasticsearch** para visualizar todo →
8. Los analistas revisan en **Kibana** y crean tickets en **GLPI** cuando es necesario

Todo esto sucede en una red Docker privada llamada 'socnet', donde los contenedores se comunican entre sí de forma segura usando nombres de host. Por ejemplo, Filebeat no necesita saber la IP de Logstash, simplemente se conecta a 'logstash:5044'."

### Capturas a mostrar:
📸 **Captura 6**: Archivo docker-compose.yml abierto
- **Cómo hacerla**: Abre el archivo `docker-compose.yml` en VS Code y captura mostrando los servicios (elasticsearch, logstash, kibana, filebeat, glpi, syslog-server, syslog-client)

📸 **Captura 7**: Reglas de detección en Logstash
- **Cómo hacerla**: Abre `logstash/pipeline/logstash.conf` y captura la sección de filtros donde están las reglas (if [message] =~ /Failed password/, SQL Injection, XSS, etc.)

📸 **Captura 8**: GLPI pantalla de login/inicio
- **Cómo hacerla**: Abre http://localhost:9000 y captura la pantalla de login o dashboard principal

📸 **Captura 9**: Repositorio GitHub con estructura del proyecto
- **Cómo hacerla**: En GitHub, captura mostrando la estructura de carpetas y el README

### Duración estimada: 2-3 minutos

---

## 4️⃣ Arquitectura del Sistema

### Qué decir:
"Ahora vamos a explicar cómo fluye la información en el sistema:

**Capa 1 - Generación de logs**: 
Tenemos el contenedor `syslog-client` que simula un servidor real generando logs de diferentes servicios. Aquí es donde ejecutamos el script de simulación de ataques.

**Capa 2 - Recolección**: 
El `syslog-server` recibe todos estos logs por el puerto 514 y los organiza en archivos según su origen: SSH, Apache, Bash, etc.

**Capa 3 - Transporte**: 
Filebeat monitorea estos archivos constantemente. Cuando detecta cambios, lee las nuevas líneas y las envía a Logstash por el puerto 5044.

**Capa 4 - Procesamiento y Detección**: 
Aquí es donde Logstash aplica las reglas de seguridad. Tenemos configuradas expresiones regulares que buscan patrones sospechosos:
- Intentos de login fallidos repetidos → Fuerza bruta
- Palabras como SELECT, UNION, OR '1'='1 → SQL Injection  
- Tags de script en parámetros web → XSS
- Comandos peligrosos como rm -rf → Comando destructivo

Cuando encuentra una coincidencia, añade campos como `severity: critical` y `event_type: SQL Injection Attempt`.

**Capa 5 - Almacenamiento**: 
Elasticsearch guarda todo en índices organizados por fecha: `syslog-2026.02.04`. Esto permite búsquedas rápidas y análisis histórico.

**Capa 6 - Visualización**: 
Kibana se conecta a Elasticsearch y nos da dashboards interactivos. Podemos filtrar por severidad, tipo de ataque, fechas, buscar términos específicos, etc.

**Capa 7 - Gestión de Incidentes**: 
GLPI está para que cuando detectamos algo serio, abramos un ticket, lo asignemos al equipo correcto y hagamos seguimiento hasta su resolución.

Todo esto corre en una red Docker privada llamada `socnet`, donde los contenedores pueden comunicarse de forma segura."

### Capturas a mostrar:
📸 **Captura 10**: Diagrama de flujo detallado de arquitectura
- **Cómo hacerla**: Crea un diagrama simple con las 7 capas o captura la explicación del README mostrando el flujo completo

📸 **Captura 11**: Script de simulación de ataques ejecutándose
- **Cómo hacerla**: Ejecuta `.\simulate_attacks.ps1` en PowerShell y captura el menú de opciones

📸 **Captura 12**: Archivos de logs generados
- **Cómo hacerla**: Abre el explorador en `logs\server\syslog-client\` y captura mostrando los archivos (sshd.log, apache.log, bash.log, etc.)

📸 **Captura 13**: Evento de seguridad con campos completos en Kibana
- **Cómo hacerla**: En Kibana > Discover, expande un evento y captura mostrando los campos: `@timestamp`, `message`, `severity`, `event_type`, `tags`

📸 **Captura 14**: Búsqueda de eventos en Kibana con filtros
- **Cómo hacerla**: En Kibana, busca `tags:security_event AND severity:critical` y captura los resultados

📸 **Captura 15**: Visualización de eventos por tipo/severidad
- **Cómo hacerla**: En Kibana > Visualize, crea un gráfico de barras o pie chart mostrando eventos agrupados por severidad (critical, high, medium)

### Duración estimada: 3-4 minutos

---

## 🎯 DEMO EN VIVO (Opcional pero recomendado)

### Qué hacer:
"Ahora les vamos a mostrar el sistema en acción:

1. **Ejecutar ataque**: Vamos a simular un ataque de SQL Injection..."
   ```powershell
   docker exec syslog-client logger -t apache "GET /login.php?user=admin' OR '1'='1-- HTTP/1.1"
   ```

2. **Mostrar el log generado**: "Como ven, el log se genera aquí..."
   ```powershell
   Get-Content .\logs\server\syslog-client\apache.log -Tail 1
   ```

3. **Buscar en Elasticsearch**: "Y en unos segundos, ya está en Elasticsearch con la detección..."
   ```powershell
   # Mostrar en Kibana o PowerShell
   ```

4. **Mostrar en Kibana**: "Aquí lo vemos clasificado como severidad ALTA, tipo SQL Injection Attempt, con las etiquetas correspondientes."

5. **(Opcional) Crear ticket en GLPI**: "Y podríamos crear un ticket para dar seguimiento a este incidente..."

### Duración estimada: 3-5 minutos

---

## 📋 Resumen y Cierre

### Qué decir:
"Para resumir, hemos creado un CyberSOC funcional que:
- ✅ Detecta ataques en tiempo real
- ✅ Clasifica eventos por severidad
- ✅ Permite visualización clara en dashboards
- ✅ Facilita la gestión de incidentes
- ✅ Es completamente open source y replicable
- ✅ Está documentado en GitHub

Este tipo de sistema es esencial para cualquier organización que quiera proteger sus activos digitales. Lo mejor es que usando contenedores, cualquiera puede desplegar esto en su entorno en minutos.

¿Alguna pregunta?"

### Duración estimada: 1 minuto

---

## ⏱️ TIMING TOTAL
- Introducción: 1-2 min
- Descripción General: 2-3 min
- Herramientas: 2-3 min
- Arquitectura: 3-4 min
- Demo (opcional): 3-5 min
- Cierre: 1 min

**Total: 10-15 minutos** (perfecto para una presentación)

---

## 💡 CONSEJOS PARA LA PRESENTACIÓN

1. **Practica antes**: Ensaya al menos 2-3 veces para que fluya natural
2. **No leas**: Usa este guión como referencia, pero habla con tus palabras
3. **Contacto visual**: Mira a tu audiencia, no solo a la pantalla
4. **Pausa estratégica**: Después de cada sección, pregunta "¿Alguna duda hasta aquí?"
5. **Ten el sistema corriendo**: Antes de empezar, asegúrate de que todos los contenedores estén UP
6. **Backup plan**: Ten capturas de pantalla listas por si algo falla en vivo
7. **Entusiasmo**: Muestra pasión por el proyecto, ¡es tu trabajo!
8. **Prepara respuestas**: Anticipa preguntas comunes (costos, escalabilidad, casos de uso)

---

## 🎤 POSIBLES PREGUNTAS Y RESPUESTAS

**P: ¿Cuánto cuesta implementar esto?**
R: "Todo es open source, el único costo sería el servidor. Puede correr en una VM con 4GB RAM y 2 CPUs."

**P: ¿Escala a producción?**
R: "Sí, Elasticsearch puede escalar horizontalmente. Para producción agregaría más nodos y configuraciones de alta disponibilidad."

**P: ¿Qué tan rápido detecta ataques?**
R: "En tiempo real. Desde que se genera el log hasta que aparece en Kibana, toma menos de 10 segundos."

**P: ¿Se puede integrar con otras herramientas?**
R: "Totalmente. Logstash tiene plugins para enviar alertas por email, Slack, PagerDuty, etc."

**P: ¿Cómo manejas los falsos positivos?**
R: "Ajustando las reglas de detección en Logstash. Es un proceso iterativo de afinar los patrones."

---

## ✅ CHECKLIST PRE-PRESENTACIÓN

- [ ] Todos los contenedores corriendo (`docker ps`)
- [ ] Kibana accesible en http://localhost:5601
- [ ] GLPI accesible en http://localhost:9000
- [ ] Elasticsearch respondiendo (`curl http://localhost:9200`)
- [ ] Carpeta de logs tiene contenido
- [ ] Script de ataques probado
- [ ] Capturas de pantalla respaldadas
- [ ] Presentación ensayada al menos 2 veces
- [ ] Laptop cargada / conectada
- [ ] Internet disponible (por si necesitas mostrar GitHub)

---

¡Mucha suerte con tu presentación! 🚀
