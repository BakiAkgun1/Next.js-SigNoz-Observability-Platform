#!/bin/bash

echo "🚀 WSL Ubuntu'da SigNoz Kurulumu Başlatılıyor..."

# SigNoz'u klonla
echo "📥 SigNoz repository'si klonlanıyor..."
cd ~
if [ -d "signoz" ]; then
    echo "📁 SigNoz klasörü zaten mevcut, güncelleniyor..."
    cd signoz
    git pull
else
    git clone https://github.com/SigNoz/signoz.git
    cd signoz
fi

# Docker Compose ile SigNoz'u başlat
echo "🐳 SigNoz Docker Compose ile başlatılıyor..."
cd deploy/docker

# Mevcut container'ları durdur
echo "🛑 Mevcut container'lar durduruluyor..."
sudo docker-compose down

# SigNoz'u başlat
echo "🚀 SigNoz başlatılıyor..."
sudo docker-compose up -d

# Durumu kontrol et
echo "📊 SigNoz durumu kontrol ediliyor..."
sleep 10
sudo docker-compose ps

# Port durumunu kontrol et
echo "🔌 Port durumu:"
if command -v netstat >/dev/null 2>&1; then
    sudo netstat -tlnp | grep -E ':(3301|8080|4318)'
elif command -v ss >/dev/null 2>&1; then
    sudo ss -tlnp | grep -E ':(3301|8080|4318)'
else
    echo "⚠️ netstat/ss bulunamadı, port durumu kontrol edilemiyor"
fi

echo "✅ SigNoz kurulumu tamamlandı!"
echo ""
echo "📋 Erişim Bilgileri:"
echo "🌐 SigNoz UI: http://localhost:3301"
echo "🔧 SigNoz API: http://localhost:8080"
echo "📡 OTLP Endpoint: http://localhost:4318"
echo ""
echo "📊 Durum kontrolü için:"
echo "sudo docker-compose ps"
echo "sudo docker-compose logs -f"
