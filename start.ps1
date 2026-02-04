# Script de inicio rapido para CyberSOC
# Levanta todos los servicios y muestra informacion de acceso

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "  CyberSOC - Inicio Rapido" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error: Docker no esta corriendo. Inicia Docker Desktop primero." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker esta corriendo" -ForegroundColor Green
Write-Host ""

Write-Host "[*] Levantando servicios del CyberSOC..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Servicios iniciados correctamente" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Esperando que los servicios esten listos..." -ForegroundColor Yellow
    Write-Host "(Esto puede tomar 1-2 minutos)" -ForegroundColor Gray
    Start-Sleep -Seconds 30
    
    Write-Host ""
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host "  Estado de los Servicios" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host ""
    Write-Host "===================================" -ForegroundColor Green
    Write-Host "  Acceso a Interfaces Web" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Kibana (SIEM Dashboard):" -ForegroundColor Cyan
    Write-Host "   URL: http://localhost:5601" -ForegroundColor White
    Write-Host "   (No requiere usuario ni password)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "GLPI (Gestion de Incidentes):" -ForegroundColor Magenta
    Write-Host "   URL: http://localhost:9000" -ForegroundColor White
    Write-Host "   Usuario: glpi" -ForegroundColor Gray
    Write-Host "   Password: glpi" -ForegroundColor Gray
    Write-Host "   [!] Completar instalacion en primer acceso" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===================================" -ForegroundColor Yellow
    Write-Host "  Proximos Pasos" -ForegroundColor Yellow
    Write-Host "===================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Espera 2-3 minutos a que todos los servicios esten listos"
    Write-Host "2. Abre Kibana: http://localhost:5601"
    Write-Host "3. Ve a Management > Data Views y crea: syslog-*"
    Write-Host "4. Ejecuta: .\simulate_attacks.ps1 para generar eventos"
    Write-Host "5. Abre GLPI: http://localhost:9000 para gestionar incidentes"
    Write-Host "4. Ejecuta: .\simulate_attacks.ps1 (opcion 11)"
    Write-Host "5. Busca en Kibana Discover: tags:security_event"
    Write-Host ""
    Write-Host "Para detener todos los servicios:" -ForegroundColor Cyan
    Write-Host "   docker-compose down"
    Write-Host ""
} else {
    Write-Host "[!] Error al iniciar los servicios" -ForegroundColor Red
    Write-Host "Revisa los logs con: docker-compose logs" -ForegroundColor Yellow
    exit 1
}
