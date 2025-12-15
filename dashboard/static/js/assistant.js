// dashboard/static/js/assistant.js
// Asistente de IA para el dashboard

class AIAssistant {
    constructor() {
        this.isOpen = false;
        this.messages = [];
        this.init();
    }
    
    init() {
        this.createChatWidget();
        this.attachEventListeners();
        this.loadChatHistory();
    }
    
    createChatWidget() {
        // Crear contenedor del chat
        const chatContainer = document.createElement('div');
        chatContainer.id = 'ai-assistant-container';
        chatContainer.innerHTML = `
            <div id="ai-assistant-chat" class="ai-chat-window">
                <div class="ai-chat-header">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-robot me-2"></i>
                        <span class="fw-bold">Asistente de IA</span>
                    </div>
                    <div class="ai-chat-actions">
                        <button id="ai-minimize-btn" class="btn btn-sm btn-link text-white p-0 me-2" title="Minimizar">
                            <i class="fas fa-minus"></i>
                        </button>
                        <button id="ai-close-btn" class="btn btn-sm btn-link text-white p-0" title="Cerrar">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>
                <div class="ai-chat-messages" id="ai-chat-messages">
                    <div class="ai-message ai-message-assistant">
                        <div class="ai-message-content">
                            <i class="fas fa-robot me-2"></i>
                            <p class="mb-0">¡Hola! Soy tu asistente de IA. Puedo ayudarte a entender cualquier información que veas en esta página. ¿En qué puedo ayudarte?</p>
                        </div>
                    </div>
                </div>
                <div class="ai-chat-input-container">
                    <div class="ai-chat-input-wrapper">
                        <input 
                            type="text" 
                            id="ai-chat-input" 
                            class="ai-chat-input" 
                            placeholder="Escribe tu pregunta..."
                            autocomplete="off"
                        />
                        <button id="ai-send-btn" class="ai-send-btn" title="Enviar">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </div>
                    <small class="text-muted d-block mt-2 px-3">
                        <i class="fas fa-info-circle me-1"></i>
                        El asistente puede analizar el contenido visible en esta página
                    </small>
                </div>
            </div>
            <button id="ai-assistant-toggle" class="ai-assistant-toggle" title="Abrir asistente de IA">
                <i class="fas fa-robot"></i>
                <span class="ai-assistant-badge">IA</span>
            </button>
        `;
        
        document.body.appendChild(chatContainer);
    }
    
    attachEventListeners() {
        // Toggle del botón flotante
        const toggleBtn = document.getElementById('ai-assistant-toggle');
        toggleBtn.addEventListener('click', () => this.toggleChat());
        
        // Botones del header
        document.getElementById('ai-minimize-btn').addEventListener('click', () => this.minimizeChat());
        document.getElementById('ai-close-btn').addEventListener('click', () => this.closeChat());
        
        // Enviar mensaje
        const sendBtn = document.getElementById('ai-send-btn');
        const input = document.getElementById('ai-chat-input');
        
        sendBtn.addEventListener('click', () => this.sendMessage());
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
    }
    
    toggleChat() {
        this.isOpen = !this.isOpen;
        const chatWindow = document.getElementById('ai-assistant-chat');
        const toggleBtn = document.getElementById('ai-assistant-toggle');
        
        if (this.isOpen) {
            chatWindow.classList.add('ai-chat-open');
            toggleBtn.classList.add('ai-assistant-active');
            document.getElementById('ai-chat-input').focus();
        } else {
            chatWindow.classList.remove('ai-chat-open');
            toggleBtn.classList.remove('ai-assistant-active');
        }
    }
    
    minimizeChat() {
        this.isOpen = false;
        const chatWindow = document.getElementById('ai-assistant-chat');
        const toggleBtn = document.getElementById('ai-assistant-toggle');
        chatWindow.classList.remove('ai-chat-open');
        toggleBtn.classList.remove('ai-assistant-active');
    }
    
    closeChat() {
        this.minimizeChat();
        // Opcional: limpiar mensajes al cerrar
        // this.messages = [];
        // this.updateChatDisplay();
    }
    
    async sendMessage() {
        const input = document.getElementById('ai-chat-input');
        const message = input.value.trim();
        
        if (!message) return;
        
        // Agregar mensaje del usuario
        this.addMessage(message, 'user');
        input.value = '';
        
        // Mostrar indicador de carga
        const loadingId = this.addLoadingMessage();
        
        try {
            // Capturar contenido de la página
            const pageContent = this.capturePageContent();
            const currentUrl = window.location.pathname;
            
            // Enviar al backend
            const response = await fetch('/api/assistant/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: message,
                    page_content: pageContent,
                    current_url: currentUrl
                })
            });
            
            const data = await response.json();
            
            // Remover indicador de carga
            this.removeLoadingMessage(loadingId);
            
            // Agregar respuesta del asistente
            if (data.status === 'success') {
                this.addMessage(data.message, 'assistant');
            } else {
                this.addMessage(`Error: ${data.message}`, 'assistant', true);
            }
            
            // Guardar en historial
            this.saveChatHistory();
            
        } catch (error) {
            this.removeLoadingMessage(loadingId);
            this.addMessage('Error de conexión. Por favor, intenta de nuevo.', 'assistant', true);
            console.error('Error:', error);
        }
    }
    
    capturePageContent() {
        // Capturar texto visible en la página
        const content = {
            title: document.title,
            headings: [],
            text: [],
            stats: [],
            tables: []
        };
        
        // Capturar títulos y subtítulos
        document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(heading => {
            if (heading.offsetParent !== null) { // Solo elementos visibles
                content.headings.push(heading.textContent.trim());
            }
        });
        
        // Capturar texto de párrafos visibles
        document.querySelectorAll('p, span, div').forEach(element => {
            if (element.offsetParent !== null && element.textContent.trim().length > 10) {
                const text = element.textContent.trim();
                if (text.length < 200) { // Evitar textos muy largos
                    content.text.push(text);
                }
            }
        });
        
        // Capturar estadísticas y valores numéricos
        document.querySelectorAll('[id*="temp"], [id*="hum"], [id*="ph"], [id*="sensor"], [id*="prediccion"]').forEach(element => {
            if (element.offsetParent !== null) {
                content.stats.push({
                    id: element.id,
                    value: element.textContent.trim()
                });
            }
        });
        
        // Construir string de contenido
        let contentString = `Título: ${content.title}\n\n`;
        contentString += `Encabezados: ${content.headings.slice(0, 10).join(', ')}\n\n`;
        contentString += `Estadísticas: ${content.stats.map(s => `${s.id}: ${s.value}`).join(', ')}\n\n`;
        contentString += `Texto relevante: ${content.text.slice(0, 20).join(' ')}`;
        
        return contentString;
    }
    
    addMessage(text, type, isError = false) {
        const messagesContainer = document.getElementById('ai-chat-messages');
        const messageDiv = document.createElement('div');
        messageDiv.className = `ai-message ai-message-${type} ${isError ? 'ai-message-error' : ''}`;
        
        const icon = type === 'user' ? 'fa-user' : 'fa-robot';
        messageDiv.innerHTML = `
            <div class="ai-message-content">
                <i class="fas ${icon} me-2"></i>
                <div>${this.formatMessage(text)}</div>
            </div>
        `;
        
        messagesContainer.appendChild(messageDiv);
        this.scrollToBottom();
        
        // Guardar en historial
        this.messages.push({ text, type, timestamp: new Date().toISOString() });
    }
    
    addLoadingMessage() {
        const messagesContainer = document.getElementById('ai-chat-messages');
        const loadingDiv = document.createElement('div');
        loadingDiv.id = 'ai-loading-message';
        loadingDiv.className = 'ai-message ai-message-assistant';
        loadingDiv.innerHTML = `
            <div class="ai-message-content">
                <i class="fas fa-robot me-2"></i>
                <div class="ai-typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        `;
        
        messagesContainer.appendChild(loadingDiv);
        this.scrollToBottom();
        
        return 'ai-loading-message';
    }
    
    removeLoadingMessage(id) {
        const loadingElement = document.getElementById(id);
        if (loadingElement) {
            loadingElement.remove();
        }
    }
    
    formatMessage(text) {
        // Convertir saltos de línea a <br>
        return text.replace(/\n/g, '<br>');
    }
    
    scrollToBottom() {
        const messagesContainer = document.getElementById('ai-chat-messages');
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
    
    saveChatHistory() {
        try {
            localStorage.setItem('ai_assistant_history', JSON.stringify(this.messages.slice(-20))); // Guardar últimos 20 mensajes
        } catch (e) {
            console.warn('No se pudo guardar el historial:', e);
        }
    }
    
    loadChatHistory() {
        try {
            const saved = localStorage.getItem('ai_assistant_history');
            if (saved) {
                const history = JSON.parse(saved);
                // Opcional: cargar historial al abrir
                // this.messages = history;
            }
        } catch (e) {
            console.warn('No se pudo cargar el historial:', e);
        }
    }
}

// Inicializar cuando se carga la página
document.addEventListener('DOMContentLoaded', () => {
    window.aiAssistant = new AIAssistant();
});

