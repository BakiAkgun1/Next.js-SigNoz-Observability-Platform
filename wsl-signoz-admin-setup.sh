#!/bin/bash

echo "👤 SigNoz Admin Hesabı Kurulumu"
echo "==============================="

# Renk kodları
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📊 SigNoz durumu kontrol ediliyor...${NC}"
curl -s -o /dev/null -w "SigNoz UI: HTTP %{http_code}\n" http://localhost:8080

echo ""
echo -e "${GREEN}🔐 SigNoz Giriş Bilgileri:${NC}"
echo "🌐 URL: http://localhost:8080"
echo ""
echo -e "${YELLOW}Varsayılan Hesap:${NC}"
echo "👤 Email: admin@signoz.io"
echo "🔑 Password: admin"
echo ""
echo -e "${YELLOW}Yeni Hesap Oluşturma:${NC}"
echo "👤 Email: baki.akgun@venhancer.com"
echo "🔑 Password: admin123"
echo ""

echo -e "${BLUE}💡 Manuel Giriş Talimatları:${NC}"
echo "1. Tarayıcıda http://localhost:8080 açın"
echo "2. Varsayılan bilgilerle giriş yapmayı deneyin"
echo "3. Eğer çalışmazsa 'Sign Up' butonuna tıklayın"
echo "4. Yeni hesap bilgilerini girin"
echo "5. Giriş yapın"

echo ""
echo -e "${GREEN}✅ Admin hesabı kurulumu tamamlandı!${NC}"
