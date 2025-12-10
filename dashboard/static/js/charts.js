// dashboard/static/js/charts.js
// Utilidades para gráficos

class ChartManager {
    static createLineChart(canvasId, data, options = {}) {
        const ctx = document.getElementById(canvasId).getContext('2d');
        return new Chart(ctx, {
            type: 'line',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        });
    }
    
    static createBarChart(canvasId, data, options = {}) {
        const ctx = document.getElementById(canvasId).getContext('2d');
        return new Chart(ctx, {
            type: 'bar',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        });
    }
    
    static createGaugeChart(canvasId, value, maxValue = 100, label = '') {
        // Implementar gráfico de gauge si es necesario
    }
}

// Exportar para uso global
window.ChartManager = ChartManager;