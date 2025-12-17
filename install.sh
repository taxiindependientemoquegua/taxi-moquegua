#!/bin/bash

set -e

log() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
    exit 1
}

log "Verificando Docker..."
if ! docker --version &> /dev/null; then
    error "Docker no está instalado"
fi

# 1. Crear estructura si no existe
mkdir -p backend admin-panel

# 2. Crear package.json para backend
cat > backend/package.json << 'EOF'
{
  "name": "taxi-moquegua-backend",
  "version": "1.0.0",
  "main": "server.cjs",
  "type": "commonjs",
  "scripts": { "start": "node server.cjs" },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "@supabase/supabase-js": "^2.42.0"
  }
}
EOF

# 3. Crear server.cjs
cat > backend/server.cjs << 'EOF'
const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
app.get('/health', (req, res) => res.json({ status: 'ok' }));
const PORT = process.env.BACKEND_PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`✅ Backend corriendo en puerto ${PORT}`));
EOF

# 4. Crear package.json para admin
cat > admin-panel/package.json << 'EOF'
{
  "name": "taxi-moquegua-admin",
  "version": "1.0.0",
  "scripts": { "dev": "vite" },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.0.0"
  }
}
EOF

# 5. Crear archivos mínimos de React/Vite
mkdir -p admin-panel/src
cat > admin-panel/index.html << 'EOF'
<!DOCTYPE html>
<html>
  <head><title>TAXI MOQUEGUA</title></head>
  <body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body>
</html>
EOF

cat > admin-panel/src/main.jsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
ReactDOM.createRoot(document.getElementById('root')).render(<h1>✅ Panel Admin Funcionando</h1>);
EOF

# 6. Crear docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  backend:
    build: ./backend
    ports: ["3000:3000"]
    env_file: [.env]
  admin:
    build: ./admin-panel
    ports: ["5173:5173"]
EOF

# 7. Crear .env
cat > .env << EOF
SUPABASE_URL=https://nrkmmsyuqkcxcmzgbias.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ya21tc3l1cWtjeGNtemdiaWFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NTM5NDIsImV4cCI6MjA3NTQyOTk0Mn0.uaLz09QqBEXkKYSTyxJcvqhzw9xydT6wghb-bcaJaIA
PLIN_DEFAULT=978281111
EOF

# 8. Crear Dockerfiles
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

cat > admin-panel/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]
EOF

# 9. Levantar servicios
log "Construyendo servicios..."
docker compose up --build -d

log "✅ Listo! Visita:"
echo "Panel: http://localhost:5173"
echo "Backend: http://localhost:3000/health"
