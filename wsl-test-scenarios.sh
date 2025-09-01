#!/bin/bash

echo "🧪 SigNoz + Next.js Test Senaryoları"
echo "===================================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 SigNoz durumu kontrol ediliyor...${NC}"
curl -s -o /dev/null -w "SigNoz UI: HTTP %{http_code}\n" http://localhost:8080

echo ""

echo -e "${BLUE}🌐 Next.js uygulaması kontrol ediliyor...${NC}"
curl -s -o /dev/null -w "Next.js App: HTTP %{http_code}\n" http://localhost:3003

echo ""

echo -e "${GREEN}🎯 Test Senaryoları:${NC}"
echo ""

echo -e "${YELLOW}1. Temel API Testleri:${NC}"
echo "   - Ana sayfa: http://localhost:3003"
echo "   - Test API: http://localhost:3003/api/test"
echo "   - Users API: http://localhost:3003/api/users"
echo ""

echo -e "${YELLOW}2. File Upload/Download Testleri:${NC}"
echo "   - Upload sayfası: http://localhost:3003/stress-test"
echo "   - Download API: http://localhost:3003/api/download"
echo ""

echo -e "${YELLOW}3. SigNoz Trace Kontrolü:${NC}"
echo "   - SigNoz UI: http://localhost:8080"
echo "   - Services menüsüne gidin"
echo "   - 'nextjs-signoz-app' servisini bulun"
echo ""

echo -e "${YELLOW}4. OTLP Endpoint Testi:${NC}"
echo "   - OTLP HTTP: http://localhost:4318/v1/traces"
echo "   - OTLP gRPC: localhost:4317"
echo ""

echo -e "${BLUE}🔧 Manuel Test Komutları:${NC}"
echo ""

echo "1. Ana sayfa testi:"
echo "   curl http://localhost:3003"
echo ""

echo "2. Test API çağrısı:"
echo "   curl http://localhost:3003/api/test"
echo ""

echo "3. Users API çağrısı:"
echo "   curl http://localhost:3003/api/users"
echo ""

echo "4. File upload testi:"
echo "   curl -X POST -F 'file=@test.txt' http://localhost:3003/api/upload"
echo ""

echo "5. File download testi:"
echo "   curl http://localhost:3003/api/download"
echo ""

echo -e "${GREEN}📋 Test Adımları:${NC}"
echo ""

echo "1. Tarayıcıda http://localhost:3003 açın"
echo "2. Ana sayfadaki linklere tıklayın"
echo "3. /users sayfasına gidin"
echo "4. /stress-test sayfasına gidin"
echo "5. File upload/download testleri yapın"
echo "6. SigNoz UI'de (http://localhost:8080) trace'leri kontrol edin"
echo ""

echo -e "${BLUE}🎯 Beklenen Sonuçlar:${NC}"
echo ""

echo "✅ Next.js uygulaması 3003 portunda çalışıyor"
echo "✅ API endpoint'leri yanıt veriyor"
echo "✅ File upload/download çalışıyor"
echo "❌ SigNoz'da trace'ler görünmüyor (OpenTelemetry olmadığı için)"
echo "✅ OTLP endpoint (4318) çalışıyor"
echo ""

echo -e "${GREEN}🚀 Test başlatılıyor...${NC}"
echo ""

# Otomatik testler
echo -e "${BLUE}🔍 Otomatik API testleri...${NC}"

echo "1. Ana sayfa testi:"
curl -s -o /dev/null -w "   HTTP Status: %{http_code}\n" http://localhost:3003

echo "2. Test API testi:"
curl -s -o /dev/null -w "   HTTP Status: %{http_code}\n" http://localhost:3003/api/test

echo "3. Users API testi:"
curl -s -o /dev/null -w "   HTTP Status: %{http_code}\n" http://localhost:3003/api/users

echo "4. Download API testi:"
curl -s -o /dev/null -w "   HTTP Status: %{http_code}\n" http://localhost:3003/api/download

echo ""

echo -e "${GREEN}✅ Test tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}💡 Şimdi tarayıcıda test yapabilirsiniz:${NC}"
echo "   - Next.js: http://localhost:3003"
echo "   - SigNoz: http://localhost:8080"
