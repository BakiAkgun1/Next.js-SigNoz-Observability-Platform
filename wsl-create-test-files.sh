#!/bin/bash

echo "📁 Stres Testi için Test Dosyaları Oluşturuluyor"
echo "=============================================="

# Renk kodları
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test dosyaları klasörü oluştur
mkdir -p test-files

echo -e "${BLUE}📄 Küçük dosyalar oluşturuluyor...${NC}"

# 1KB dosya
echo "Bu 1KB'lık test dosyasıdır. $(date)" > test-files/small-1kb.txt
for i in {1..50}; do
    echo "Satır $i: Lorem ipsum dolor sit amet, consectetur adipiscing elit." >> test-files/small-1kb.txt
done

# 10KB dosya
echo "Bu 10KB'lık test dosyasıdır. $(date)" > test-files/medium-10kb.txt
for i in {1..500}; do
    echo "Satır $i: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." >> test-files/medium-10kb.txt
done

# 100KB dosya
echo "Bu 100KB'lık test dosyasıdır. $(date)" > test-files/large-100kb.txt
for i in {1..5000}; do
    echo "Satır $i: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris." >> test-files/large-100kb.txt
done

# 1MB dosya
echo -e "${BLUE}📄 Büyük dosyalar oluşturuluyor...${NC}"
echo "Bu 1MB'lık test dosyasıdır. $(date)" > test-files/xlarge-1mb.txt
for i in {1..50000}; do
    echo "Satır $i: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." >> test-files/xlarge-1mb.txt
done

# Binary dosyalar (farklı türler)
echo -e "${BLUE}📄 Binary dosyalar oluşturuluyor...${NC}"

# JSON dosyası
cat > test-files/data.json << 'EOF'
{
  "users": [
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
    {"id": 3, "name": "Bob Johnson", "email": "bob@example.com"}
  ],
  "products": [
    {"id": 1, "name": "Laptop", "price": 999.99},
    {"id": 2, "name": "Mouse", "price": 29.99},
    {"id": 3, "name": "Keyboard", "price": 89.99}
  ],
  "timestamp": "$(date)"
}
EOF

# CSV dosyası
echo "id,name,email,age,city" > test-files/users.csv
for i in {1..1000}; do
    echo "$i,User$i,user$i@example.com,$((20 + i % 50)),City$((i % 10))" >> test-files/users.csv
done

# XML dosyası
cat > test-files/data.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <users>
    <user id="1">
      <name>John Doe</name>
      <email>john@example.com</email>
    </user>
    <user id="2">
      <name>Jane Smith</name>
      <email>jane@example.com</email>
    </user>
  </users>
</root>
EOF

echo -e "${GREEN}✅ Test dosyaları oluşturuldu!${NC}"
echo ""

# Dosya boyutlarını göster
echo -e "${YELLOW}📊 Oluşturulan Dosyalar:${NC}"
ls -lh test-files/

echo ""
echo -e "${BLUE}🎯 Stres Testi Senaryoları:${NC}"
echo ""

echo "1. Küçük Dosya Testi (1KB):"
echo "   curl -X POST -F 'file=@test-files/small-1kb.txt' http://localhost:3003/api/upload"
echo ""

echo "2. Orta Dosya Testi (10KB):"
echo "   curl -X POST -F 'file=@test-files/medium-10kb.txt' http://localhost:3003/api/upload"
echo ""

echo "3. Büyük Dosya Testi (100KB):"
echo "   curl -X POST -F 'file=@test-files/large-100kb.txt' http://localhost:3003/api/upload"
echo ""

echo "4. Çok Büyük Dosya Testi (1MB):"
echo "   curl -X POST -F 'file=@test-files/xlarge-1mb.txt' http://localhost:3003/api/upload"
echo ""

echo "5. JSON Dosya Testi:"
echo "   curl -X POST -F 'file=@test-files/data.json' http://localhost:3003/api/upload"
echo ""

echo "6. CSV Dosya Testi:"
echo "   curl -X POST -F 'file=@test-files/users.csv' http://localhost:3003/api/upload"
echo ""

echo "7. XML Dosya Testi:"
echo "   curl -X POST -F 'file=@test-files/data.xml' http://localhost:3003/api/upload"
echo ""

echo -e "${GREEN}🚀 Stres testi için hazır!${NC}"
