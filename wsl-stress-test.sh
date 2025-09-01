#!/bin/bash

echo "🔥 WSL Ubuntu Stress Test Sistemi"
echo "=================================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test fonksiyonları
test_nginx() {
    echo -e "${BLUE}🌐 Nginx Test Ediliyor...${NC}"
    if curl -s http://localhost/test-files/ > /dev/null; then
        echo -e "${GREEN}✅ Nginx çalışıyor${NC}"
        return 0
    else
        echo -e "${RED}❌ Nginx çalışmıyor${NC}"
        return 1
    fi
}

test_nextjs() {
    echo -e "${BLUE}⚛️ Next.js Test Ediliyor...${NC}"
    if curl -s http://localhost:3002 > /dev/null; then
        echo -e "${GREEN}✅ Next.js çalışıyor${NC}"
        return 0
    else
        echo -e "${RED}❌ Next.js çalışmıyor${NC}"
        return 1
    fi
}

test_signoz() {
    echo -e "${BLUE}📊 SigNoz Test Ediliyor...${NC}"
    if curl -s http://localhost:3301 > /dev/null; then
        echo -e "${GREEN}✅ SigNoz çalışıyor${NC}"
        return 0
    else
        echo -e "${RED}❌ SigNoz çalışmıyor${NC}"
        return 1
    fi
}

test_file_upload() {
    echo -e "${BLUE}📤 Dosya Upload Test Ediliyor...${NC}"
    # Test dosyası oluştur
    echo "test content" > /tmp/test-upload.txt
    
    # Upload testi
    response=$(curl -s -X POST -F "file=@/tmp/test-upload.txt" http://localhost:3002/api/upload)
    if echo "$response" | grep -q "başarıyla yüklendi"; then
        echo -e "${GREEN}✅ Upload API çalışıyor${NC}"
        rm -f /tmp/test-upload.txt
        return 0
    else
        echo -e "${RED}❌ Upload API çalışmıyor${NC}"
        rm -f /tmp/test-upload.txt
        return 1
    fi
}

test_file_download() {
    echo -e "${BLUE}📥 Dosya Download Test Ediliyor...${NC}"
    if curl -s http://localhost:3002/api/download?action=list > /dev/null; then
        echo -e "${GREEN}✅ Download API çalışıyor${NC}"
        return 0
    else
        echo -e "${RED}❌ Download API çalışmıyor${NC}"
        return 1
    fi
}

run_stress_test() {
    echo -e "${YELLOW}🚀 Stress Test Başlatılıyor...${NC}"
    
    # Test dosyalarını listele
    echo -e "${BLUE}📁 Mevcut test dosyaları:${NC}"
    ls -lh /var/www/test-files/
    
    # Paralel download testi
    echo -e "${YELLOW}📥 Paralel download testi...${NC}"
    for file in small-1k.bin small-10k.bin small-100k.bin; do
        if [ -f "/var/www/test-files/$file" ]; then
            (curl -s -o /dev/null http://localhost/test-files/$file && echo "✅ $file") &
        fi
    done
    wait
    
    # Büyük dosya testi
    echo -e "${YELLOW}📥 Büyük dosya testi...${NC}"
    if [ -f "/var/www/test-files/large-50mb.bin" ]; then
        echo "⏳ 50MB dosya indiriliyor..."
        time curl -s -o /dev/null http://localhost/test-files/large-50mb.bin
        echo "✅ Büyük dosya testi tamamlandı"
    fi
}

show_system_info() {
    echo -e "${BLUE}💻 Sistem Bilgileri:${NC}"
    echo "CPU: $(nproc) çekirdek"
    echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $4}') boş"
    echo "Uptime: $(uptime -p)"
}

show_service_status() {
    echo -e "${BLUE}🔧 Servis Durumları:${NC}"
    
    # Nginx
    if sudo systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✅ Nginx: Aktif${NC}"
    else
        echo -e "${RED}❌ Nginx: Pasif${NC}"
    fi
    
    # Docker
    if sudo systemctl is-active --quiet docker; then
        echo -e "${GREEN}✅ Docker: Aktif${NC}"
    else
        echo -e "${RED}❌ Docker: Pasif${NC}"
    fi
    
    # SigNoz containers
    if sudo docker ps | grep -q signoz; then
        echo -e "${GREEN}✅ SigNoz Containers: Çalışıyor${NC}"
    else
        echo -e "${RED}❌ SigNoz Containers: Çalışmıyor${NC}"
    fi
}

show_port_status() {
    echo -e "${BLUE}🔌 Port Durumları:${NC}"
    ports=(80 3002 3301 8080 4318)
    for port in "${ports[@]}"; do
        if command -v netstat >/dev/null 2>&1; then
            if sudo netstat -tlnp | grep -q ":$port "; then
                echo -e "${GREEN}✅ Port $port: Açık${NC}"
            else
                echo -e "${RED}❌ Port $port: Kapalı${NC}"
            fi
        elif command -v ss >/dev/null 2>&1; then
            if sudo ss -tlnp | grep -q ":$port "; then
                echo -e "${GREEN}✅ Port $port: Açık${NC}"
            else
                echo -e "${RED}❌ Port $port: Kapalı${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ Port $port: Kontrol edilemiyor (netstat/ss bulunamadı)${NC}"
        fi
    done
}

# Ana menü
while true; do
    echo ""
    echo -e "${YELLOW}🎯 WSL Stress Test Menüsü${NC}"
    echo "1. Sistem Bilgileri"
    echo "2. Servis Durumları"
    echo "3. Port Durumları"
    echo "4. Temel Testler"
    echo "5. Stress Test"
    echo "6. Tüm Testleri Çalıştır"
    echo "7. SigNoz Logları"
    echo "8. Çıkış"
    echo ""
    read -p "Seçiminiz (1-8): " choice
    
    case $choice in
        1)
            show_system_info
            ;;
        2)
            show_service_status
            ;;
        3)
            show_port_status
            ;;
        4)
            echo -e "${YELLOW}🧪 Temel Testler Çalıştırılıyor...${NC}"
            test_nginx
            test_nextjs
            test_signoz
            test_file_upload
            test_file_download
            ;;
        5)
            run_stress_test
            ;;
        6)
            echo -e "${YELLOW}🚀 Tüm Testler Çalıştırılıyor...${NC}"
            show_system_info
            show_service_status
            show_port_status
            test_nginx
            test_nextjs
            test_signoz
            test_file_upload
            test_file_download
            run_stress_test
            ;;
        7)
            echo -e "${BLUE}📋 SigNoz Logları:${NC}"
            cd ~/signoz/deploy/docker
            sudo docker-compose logs --tail=20
            ;;
        8)
            echo -e "${GREEN}👋 Çıkış yapılıyor...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Geçersiz seçim${NC}"
            ;;
    esac
done
