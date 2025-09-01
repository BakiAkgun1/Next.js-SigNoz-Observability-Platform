#!/bin/bash

echo "🚀 Next.js Uygulaması Başlatma"
echo "=============================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Mevcut port durumu kontrol ediliyor...${NC}"

# 3002 portunu kontrol et
if command -v netstat >/dev/null 2>&1; then
    netstat -tlnp | grep :3002 || echo "3002 portu boş"
else
    ss -tlnp | grep :3002 || echo "3002 portu boş"
fi

echo ""

# Node.js ve npm kontrol et
echo -e "${BLUE}🔧 Node.js ve npm kontrol ediliyor...${NC}"
node --version
npm --version

echo ""

# Bağımlılıkları kontrol et
echo -e "${BLUE}📦 Bağımlılıklar kontrol ediliyor...${NC}"
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠️  node_modules bulunamadı, npm install çalıştırılıyor...${NC}"
    npm install
else
    echo -e "${GREEN}✅ node_modules mevcut${NC}"
fi

echo ""

# Tracing.js dosyasını kontrol et
echo -e "${BLUE}🔍 tracing.js dosyası kontrol ediliyor...${NC}"
if [ -f "tracing.js" ]; then
    echo -e "${GREEN}✅ tracing.js dosyası mevcut${NC}"
    echo "İçerik:"
    head -10 tracing.js
else
    echo -e "${RED}❌ tracing.js dosyası bulunamadı${NC}"
fi

echo ""

# Package.json kontrol et
echo -e "${BLUE}📋 package.json kontrol ediliyor...${NC}"
if [ -f "package.json" ]; then
    echo -e "${GREEN}✅ package.json mevcut${NC}"
    echo "Dev script:"
    grep -A 1 '"dev"' package.json
else
    echo -e "${RED}❌ package.json bulunamadı${NC}"
    exit 1
fi

echo ""

# Next.js uygulamasını başlat
echo -e "${BLUE}🚀 Next.js uygulaması başlatılıyor...${NC}"
echo "Port: 3002"
echo "NODE_OPTIONS: --require ./tracing.js"

# NODE_OPTIONS'ı ayarla ve Next.js'i başlat
export NODE_OPTIONS="--require ./tracing.js"
npm run dev

echo ""

echo -e "${GREEN}✅ Next.js uygulaması başlatıldı!${NC}"
echo "🌐 Erişim: http://localhost:3002"
echo "📊 SigNoz: http://localhost:8080"

echo ""

echo -e "${YELLOW}💡 Eğer port 3002 kullanımdaysa:${NC}"
echo "1. Ctrl+C ile durdurun"
echo "2. Farklı port ile başlatın:"
echo "   npm run dev -- -p 3003"
echo "3. Veya package.json'da port değiştirin"

echo ""

echo -e "${BLUE}🔧 Alternatif başlatma komutları:${NC}"
echo "1. Standart: npm run dev"
echo "2. Farklı port: npm run dev -- -p 3003"
echo "3. Manuel: npx next dev -p 3002"
echo "4. Debug modu: NODE_OPTIONS='--require ./tracing.js' npm run dev"
