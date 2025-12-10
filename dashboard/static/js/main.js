// dashboard/static/js/main.js
// Utilidades globales del dashboard

class SystemStatus {
    constructor() {
        this.isOnline = true;
        this.lastUpdate = null;
        this.init();
    }
    
    init() {
        this.updateStatus();
        setInterval(() => this.updateStatus(), 30000);
    }
    
    updateStatus() {
        // Verificar estado del sistema
        fetch('/api/estado_actual')
            .then(response => {
                this.isOnline = response.ok;
                this.lastUpdate = new Date();
                this.updateUI();
            })
            .catch(() => {
                this.isOnline = false;
                this.updateUI();
            });
    }
    
    updateUI() {
        const statusElement = document.getElementById('status-text');
        const statusIcon = document.querySelector('#system-status i');
        
        if (this.isOnline) {
            statusElement.textContent = 'Sistema Conectado';
            statusIcon.className = 'fas fa-circle text-success me-1';
        } else {
            statusElement.textContent = 'Sistema Desconectado';
            statusIcon.className = 'fas fa-circle text-danger me-1';
        }
        
        if (this.lastUpdate) {
            document.getElementById('last-update').textContent = 
                'Última actualización: ' + this.lastUpdate.toLocaleTimeString();
        }
    }
}

// Inicializar cuando se carga la página
document.addEventListener('DOMContentLoaded', () => {
    new SystemStatus();
});

// Utilidades de formato
const FormatUtils = {
    formatTemperature: (temp) => `${temp}°C`,
    formatHumidity: (hum) => `${hum}%`,
    formatPH: (ph) => `pH ${ph}`,
    formatTime: (timestamp) => new Date(timestamp).toLocaleTimeString(),
    formatDate: (timestamp) => new Date(timestamp).toLocaleDateString()
};

// Exportar para uso global
window.FormatUtils = FormatUtils;