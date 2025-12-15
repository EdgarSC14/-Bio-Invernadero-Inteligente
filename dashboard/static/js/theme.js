// dashboard/static/js/theme.js
class ThemeManager {
    constructor() {
        this.theme = localStorage.getItem('theme') || 'light';
        this.init();
    }

    init() {
        this.applyTheme(this.theme);
        this.setupEventListeners();
        this.setupSystemThemeDetection();
    }

    setupEventListeners() {
        const themeToggle = document.getElementById('themeToggle');
        if (themeToggle) {
            themeToggle.addEventListener('click', () => this.toggleTheme());
        }

        // Atajo de teclado Alt + T
        document.addEventListener('keydown', (e) => {
            if (e.altKey && e.key === 't') {
                this.toggleTheme();
                e.preventDefault();
            }
        });
    }

    setupSystemThemeDetection() {
        // Detectar preferencia del sistema
        if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches && !localStorage.getItem('theme')) {
            this.theme = 'dark';
            this.applyTheme(this.theme);
        }

        // Escuchar cambios en la preferencia del sistema
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
            if (!localStorage.getItem('theme')) {
                this.theme = e.matches ? 'dark' : 'light';
                this.applyTheme(this.theme);
            }
        });
    }

    toggleTheme() {
        this.theme = this.theme === 'light' ? 'dark' : 'light';
        this.applyTheme(this.theme);
        this.saveTheme();
        this.showThemeNotification();
    }

    applyTheme(theme) {
        // Aplicar tema a nivel de documento y compatibilidad con Bootstrap
        document.documentElement.setAttribute('data-theme', theme);
        document.documentElement.setAttribute('data-bs-theme', theme);
        
        // Actualizar meta theme-color para navegadores móviles
        const metaThemeColor = document.querySelector('meta[name="theme-color"]');
        if (metaThemeColor) {
            metaThemeColor.setAttribute('content', theme === 'dark' ? '#1a1a1a' : '#81C784');
        }
        
        // Actualizar icono y texto del botón
        this.updateThemeButton(theme);
        
        // Disparar evento personalizado
        window.dispatchEvent(new CustomEvent('themeChanged', { 
            detail: { theme, timestamp: new Date() }
        }));
    }

    updateThemeButton(theme) {
        const themeIcon = document.getElementById('themeIcon');
        const themeText = document.getElementById('themeText');
        
        if (themeIcon) {
            themeIcon.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
        }
        if (themeText) {
            themeText.textContent = theme === 'dark' ? 'Claro' : 'Oscuro';
        }
    }

    saveTheme() {
        localStorage.setItem('theme', this.theme);
    }

    showThemeNotification() {
        // Crear notificación elegante
        const notification = document.createElement('div');
        notification.className = `theme-notification fade-in`;
        notification.innerHTML = `
            <div class="d-flex align-items-center">
                <i class="fas fa-${this.theme === 'dark' ? 'moon' : 'sun'} me-2 text-${this.theme === 'dark' ? 'warning' : 'info'}"></i>
                <span>Modo ${this.theme === 'dark' ? 'oscuro' : 'claro'} activado</span>
            </div>
        `;
        
        notification.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background: var(--card-bg);
            color: var(--text-primary);
            padding: 12px 20px;
            border-radius: 10px;
            box-shadow: var(--shadow-hover);
            border-left: 4px solid ${this.theme === 'dark' ? '#FFA726' : '#4FC3F7'};
            z-index: 9999;
            font-weight: 500;
            min-width: 200px;
            backdrop-filter: blur(10px);
        `;

        document.body.appendChild(notification);

        // Auto-remover después de 3 segundos
        setTimeout(() => {
            if (notification.parentNode) {
                notification.style.opacity = '0';
                notification.style.transform = 'translateX(100px)';
                setTimeout(() => notification.remove(), 300);
            }
        }, 3000);
    }

    getCurrentTheme() {
        return this.theme;
    }

    // Método para forzar un tema específico
    setTheme(theme) {
        if (['light', 'dark'].includes(theme)) {
            this.theme = theme;
            this.applyTheme(theme);
            this.saveTheme();
        }
    }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.themeManager = new ThemeManager();
    
    // Aplicar transición suave después de la carga
    setTimeout(() => {
        document.body.style.transition = 'all 0.3s ease';
    }, 100);
});

// Manejar errores de carga
window.addEventListener('error', (e) => {
    console.error('Error en theme manager:', e.error);
});