#!/bin/bash

echo "🔧 SigNoz Frontend Container Düzeltmesi"
echo "======================================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# SigNoz klasörüne git
cd ~/signoz/deploy/docker

echo -e "${BLUE}📊 Mevcut container durumu:${NC}"
sudo docker-compose ps

echo ""

# Docker Compose dosyasını kontrol et
echo -e "${BLUE}📋 Docker Compose dosyası kontrol ediliyor...${NC}"
if [ -f docker-compose.yaml ]; then
    echo -e "${GREEN}✅ Docker Compose dosyası mevcut${NC}"
    
    # Frontend servisi var mı kontrol et
    if grep -q "frontend:" docker-compose.yaml; then
        echo -e "${GREEN}✅ Frontend servisi tanımlı${NC}"
    else
        echo -e "${RED}❌ Frontend servisi tanımlı değil${NC}"
        echo -e "${YELLOW}💡 SigNoz sürümünüz eski olabilir${NC}"
    fi
else
    echo -e "${RED}❌ Docker Compose dosyası bulunamadı${NC}"
    exit 1
fi

echo ""

# SigNoz'u tamamen durdur
echo -e "${YELLOW}🛑 SigNoz durduruluyor...${NC}"
sudo docker-compose down

echo ""

# Docker volume'larını temizle (opsiyonel)
echo -e "${BLUE}🧹 Docker volume'ları temizleniyor...${NC}"
read -p "Volume'ları temizlemek istiyor musunuz? (y/N): " clean_volumes
if [[ $clean_volumes =~ ^[Yy]$ ]]; then
    sudo docker-compose down -v
    echo -e "${GREEN}✅ Volume'lar temizlendi${NC}"
else
    echo -e "${YELLOW}⚠️ Volume'lar korundu${NC}"
fi

echo ""

# SigNoz'u yeniden başlat
echo -e "${YELLOW}🚀 SigNoz yeniden başlatılıyor...${NC}"
sudo docker-compose up -d

echo ""

# Container'ların başlamasını bekle
echo -e "${BLUE}⏳ Container'lar başlatılıyor (60 saniye bekleniyor)...${NC}"
sleep 60

echo ""

# Container durumlarını kontrol et
echo -e "${BLUE}📊 Güncel container durumları:${NC}"
sudo docker-compose ps

echo ""

# Frontend container'ını özel olarak kontrol et
echo -e "${BLUE}🌐 Frontend container kontrolü:${NC}"
if sudo docker-compose ps | grep -q frontend; then
    echo -e "${GREEN}✅ Frontend container çalışıyor${NC}"
    sudo docker-compose logs --tail=10 frontend
else
    echo -e "${RED}❌ Frontend container bulunamadı${NC}"
    echo -e "${YELLOW}💡 SigNoz sürümünüz frontend içermiyor olabilir${NC}"
fi

echo ""

# Port kontrolü
echo -e "${BLUE}🔌 Port kontrolü:${NC}"
if command -v netstat >/dev/null 2>&1; then
    sudo netstat -tlnp | grep -E ':(3301|4318|8080)' || echo "Portlar henüz açılmadı"
elif command -v ss >/dev/null 2>&1; then
    sudo ss -tlnp | grep -E ':(3301|4318|8080)' || echo "Portlar henüz açılmadı"
fi

echo ""

# SigNoz UI erişim testi
echo -e "${BLUE}🌐 SigNoz UI erişim testi:${NC}"
echo "SigNoz UI test ediliyor..."
if curl -s -I http://localhost:3301 | head -1 | grep -q "200\|302"; then
    echo -e "${GREEN}✅ SigNoz UI erişilebilir${NC}"
else
    echo -e "${RED}❌ SigNoz UI erişilemiyor${NC}"
    echo -e "${YELLOW}💡 SigNoz sürümünüzde UI farklı portta olabilir${NC}"
fi

echo ""

# SigNoz backend erişim testi
echo -e "${BLUE}🔧 SigNoz Backend erişim testi:${NC}"
if curl -s http://localhost:8080/health | grep -q "ok\|healthy"; then
    echo -e "${GREEN}✅ SigNoz Backend çalışıyor${NC}"
else
    echo -e "${RED}❌ SigNoz Backend erişilemiyor${NC}"
fi

echo ""

# Erişim bilgileri
echo -e "${GREEN}📋 Erişim Bilgileri:${NC}"
echo "🔧 SigNoz API: http://localhost:8080"
echo "📡 OTLP HTTP: http://localhost:4318/v1/traces"
echo "📡 OTLP gRPC: localhost:4317"

# Frontend varsa UI bilgisini ekle
if sudo docker-compose ps | grep -q frontend; then
    echo "🌐 SigNoz UI: http://localhost:3301"
else
    echo -e "${YELLOW}⚠️ SigNoz UI: Frontend container bulunamadı${NC}"
fi

echo ""

# SigNoz sürüm bilgisi
echo -e "${BLUE}📦 SigNoz Sürüm Bilgisi:${NC}"
if [ -f docker-compose.yaml ]; then
    echo "Docker Compose dosyasından sürüm:"
    grep -i "image:" docker-compose.yaml | head -5
fi

echo ""

# Çözüm önerileri
echo -e "${YELLOW}💡 Çözüm Önerileri:${NC}"
echo "1. Frontend container yoksa:"
echo "   - SigNoz'u güncelleyin: git pull origin main"
echo "   - Yeni sürümü kullanın"
echo ""
echo "2. UI farklı portta olabilir:"
echo "   - http://localhost:8080 adresini deneyin"
echo "   - Container loglarını kontrol edin"
echo ""
echo "3. Manuel UI erişimi:"
echo "   - Tarayıcıda http://localhost:8080 açın"
echo "   - SigNoz API'yi kullanarak manuel erişim sağlayın"

echo ""
echo -e "${GREEN}✅ Frontend düzeltme tamamlandı!${NC}"
