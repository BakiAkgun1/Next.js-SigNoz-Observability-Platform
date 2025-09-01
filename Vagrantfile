# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "20231025.0.0"
  
  config.vm.define "stress-test-server" do |server|
    server.vm.hostname = "stress-test-server"
    server.vm.network "private_network", ip: "192.168.56.10"
    
    # VM kaynakları
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "stress-test-server"
    end
    
    # Provisioning script
    server.vm.provision "shell", inline: <<-SHELL
      # Sistem güncellemesi
      apt-get update
      apt-get install -y curl wget nginx apache2-utils
      
      # Test dosyaları oluştur
      mkdir -p /var/www/test-files
      
      # Küçük dosyalar (1KB, 10KB, 100KB)
      dd if=/dev/zero of=/var/www/test-files/small-1k.bin bs=1K count=1
      dd if=/dev/zero of=/var/www/test-files/small-10k.bin bs=1K count=10
      dd if=/dev/zero of=/var/www/test-files/small-100k.bin bs=1K count=100
      
      # Orta boyut dosyalar (1MB, 10MB)
      dd if=/dev/zero of=/var/www/test-files/medium-1mb.bin bs=1M count=1
      dd if=/dev/zero of=/var/www/test-files/medium-10mb.bin bs=1M count=10
      
      # Büyük dosyalar (50MB, 100MB)
      dd if=/dev/zero of=/var/www/test-files/large-50mb.bin bs=1M count=50
      dd if=/dev/zero of=/var/www/test-files/large-100mb.bin bs=1M count=100
      
      # Nginx konfigürasyonu
      cat > /etc/nginx/sites-available/test-server << 'EOF'
server {
    listen 80;
    server_name stress-test-server;
    
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
    }
}
EOF
      
      # Upload dizini oluştur
      mkdir -p /var/www/uploads
      chmod 755 /var/www/uploads
      
      # Nginx'i etkinleştir ve başlat
      ln -sf /etc/nginx/sites-available/test-server /etc/nginx/sites-enabled/
      rm -f /etc/nginx/sites-enabled/default
      systemctl enable nginx
      systemctl start nginx
      
      echo "Stress test server hazır!"
      echo "Test dosyaları: http://192.168.56.10/test-files/"
    SHELL
  end
end
