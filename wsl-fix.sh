#!/bin/bash

echo "🔧 WSL Ubuntu Eksik Paket Düzeltmesi"
echo "====================================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Eksik paketler yükleniyor...${NC}"

# net-tools yükle (netstat için)
if ! command -v netstat >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 net-tools yükleniyor...${NC}"
    sudo apt update
    sudo apt install -y net-tools
    if command -v netstat >/dev/null 2>&1; then
        echo -e "${GREEN}✅ netstat yüklendi${NC}"
    else
        echo -e "${RED}❌ netstat yüklenemedi${NC}"
    fi
else
    echo -e "${GREEN}✅ netstat zaten yüklü${NC}"
fi

# ss komutu kontrolü (alternatif)
if command -v ss >/dev/null 2>&1; then
    echo -e "${GREEN}✅ ss komutu mevcut${NC}"
else
    echo -e "${YELLOW}⚠️ ss komutu bulunamadı${NC}"
fi

# Docker kontrolü
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker mevcut${NC}"
    if sudo systemctl is-active --quiet docker; then
        echo -e "${GREEN}✅ Docker servisi çalışıyor${NC}"
    else
        echo -e "${YELLOW}⚠️ Docker servisi çalışmıyor, başlatılıyor...${NC}"
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
else
    echo -e "${RED}❌ Docker bulunamadı${NC}"
fi

# Nginx kontrolü
if command -v nginx >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Nginx mevcut${NC}"
    if sudo systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✅ Nginx servisi çalışıyor${NC}"
    else
        echo -e "${YELLOW}⚠️ Nginx servisi çalışmıyor, başlatılıyor...${NC}"
        sudo systemctl start nginx
        sudo systemctl enable nginx
    fi
else
    echo -e "${RED}❌ Nginx bulunamadı${NC}"
fi

# Port durumu testi
echo -e "${BLUE}🔌 Port durumu testi...${NC}"
if command -v netstat >/dev/null 2>&1; then
    echo "netstat ile port kontrolü:"
    sudo netstat -tlnp | grep -E ':(80|3002|3301|8080|4318)' || echo "Açık port bulunamadı"
elif command -v ss >/dev/null 2>&1; then
    echo "ss ile port kontrolü:"
    sudo ss -tlnp | grep -E ':(80|3002|3301|8080|4318)' || echo "Açık port bulunamadı"
else
    echo -e "${RED}❌ Port kontrolü yapılamıyor${NC}"
fi

echo -e "${GREEN}✅ Düzeltme tamamlandı!${NC}"
echo ""
echo -e "${BLUE}📋 Sonraki adımlar:${NC}"
echo "1. ./wsl-stress-test.sh çalıştırın"
echo "2. ./wsl-clickhouse-test.sh çalıştırın"
echo "3. Port durumlarını kontrol edin"
