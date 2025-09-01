#!/bin/bash

echo "🚀 WSL Ubuntu Stress Test Sistemi Kurulumu Başlatılıyor..."

# Sistem güncellemesi
echo "📦 Sistem güncelleniyor..."
sudo apt update && sudo apt upgrade -y

# Gerekli paketleri yükle
echo "📦 Gerekli paketler yükleniyor..."
sudo apt install -y curl wget nginx apache2-utils docker.io docker-compose git net-tools

# Docker servisini başlat
echo "🐳 Docker servisi başlatılıyor..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Test dosyaları oluştur
echo "📁 Test dosyaları oluşturuluyor..."
sudo mkdir -p /var/www/test-files
sudo mkdir -p /var/www/uploads

# Küçük dosyalar (1KB, 10KB, 100KB)
echo "📄 Küçük dosyalar oluşturuluyor..."
sudo dd if=/dev/zero of=/var/www/test-files/small-1k.bin bs=1K count=1
sudo dd if=/dev/zero of=/var/www/test-files/small-10k.bin bs=1K count=10
sudo dd if=/dev/zero of=/var/www/test-files/small-100k.bin bs=1K count=100

# Orta boyut dosyalar (1MB, 10MB)
echo "📄 Orta boyut dosyalar oluşturuluyor..."
sudo dd if=/dev/zero of=/var/www/test-files/medium-1mb.bin bs=1M count=1
sudo dd if=/dev/zero of=/var/www/test-files/medium-10mb.bin bs=1M count=10

# Büyük dosyalar (50MB, 100MB)
echo "📄 Büyük dosyalar oluşturuluyor..."
sudo dd if=/dev/zero of=/var/www/test-files/large-50mb.bin bs=1M count=50
sudo dd if=/dev/zero of=/var/www/test-files/large-100mb.bin bs=1M count=100

# Nginx konfigürasyonu
echo "🌐 Nginx konfigürasyonu yapılıyor..."
sudo tee /etc/nginx/sites-available/stress-test-server > /dev/null << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    location /test-files/ {
        alias /var/www/test-files/;
        autoindex on;
        add_header Content-Disposition "attachment";
    }
    
    location /upload/ {
        alias /var/www/uploads/;
        client_max_body_size 200M;
    }
    
    location /api/upload {
        proxy_pass http://localhost:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/download {
        proxy_pass http://localhost:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Nginx'i etkinleştir
sudo ln -sf /etc/nginx/sites-available/stress-test-server /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl enable nginx
sudo systemctl start nginx

# İzinleri ayarla
sudo chown -R www-data:www-data /var/www/test-files
sudo chown -R www-data:www-data /var/www/uploads
sudo chmod -R 755 /var/www/test-files
sudo chmod -R 755 /var/www/uploads

# Node.js kurulumu (opsiyonel)
echo "📦 Node.js kurulumu..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Stress test script'i oluştur
echo "📝 Stress test script'i oluşturuluyor..."
cat > ~/stress-test-wsl.sh << 'EOF'
#!/bin/bash

echo "🔥 WSL Stress Test Başlatılıyor..."

# Test dosyalarını listele
echo "📁 Mevcut test dosyaları:"
ls -lh /var/www/test-files/

# Nginx durumunu kontrol et
echo "🌐 Nginx durumu:"
sudo systemctl status nginx --no-pager -l

# Docker durumunu kontrol et
echo "🐳 Docker durumu:"
sudo systemctl status docker --no-pager -l

# Port durumunu kontrol et
echo "🔌 Port durumu:"
if command -v netstat >/dev/null 2>&1; then
    sudo netstat -tlnp | grep -E ':(80|3002|3301|8080)'
elif command -v ss >/dev/null 2>&1; then
    sudo ss -tlnp | grep -E ':(80|3002|3301|8080)'
else
    echo "⚠️ netstat/ss bulunamadı, port durumu kontrol edilemiyor"
fi

echo "✅ Kurulum tamamlandı!"
echo "🌐 Test dosyaları: http://localhost/test-files/"
echo "📤 Upload dizini: http://localhost/upload/"
echo "🔧 API endpoint: http://localhost/api/upload"
EOF

chmod +x ~/stress-test-wsl.sh

echo "✅ WSL Ubuntu Stress Test Sistemi Kurulumu Tamamlandı!"
echo ""
echo "📋 Kullanım:"
echo "1. WSL Ubuntu'yu başlat"
echo "2. ~/stress-test-wsl.sh çalıştır"
echo "3. Test dosyalarına erişim: http://localhost/test-files/"
echo "4. Next.js uygulaması: http://localhost:3002"
echo "5. SigNoz UI: http://localhost:3301"
