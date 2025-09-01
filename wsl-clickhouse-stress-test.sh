#!/bin/bash

echo "🔥 ClickHouse Stres Testi"
echo "========================"

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# SigNoz klasörüne git
cd ~/signoz/deploy/docker

echo -e "${BLUE}📊 ClickHouse durumu kontrol ediliyor...${NC}"
sudo docker-compose ps | grep clickhouse

echo ""

# ClickHouse container'ına bağlan
echo -e "${BLUE}🔧 ClickHouse stres testi başlatılıyor...${NC}"

# Test 1: Basit veri ekleme
echo -e "${YELLOW}1. Basit Veri Ekleme Testi (1000 kayıt)${NC}"
sudo docker exec signoz-clickhouse clickhouse-client --query "
CREATE TABLE IF NOT EXISTS stress_test (
    id UInt32,
    name String,
    value Float64,
    timestamp DateTime
) ENGINE = MergeTree()
ORDER BY (timestamp, id);
"

# 1000 kayıt ekle
for i in {1..1000}; do
    sudo docker exec signoz-clickhouse clickhouse-client --query "
    INSERT INTO stress_test (id, name, value, timestamp) 
    VALUES ($i, 'Test$i', $i * 1.5, now());
    "
done

echo "✅ 1000 kayıt eklendi"

# Test 2: Büyük veri ekleme
echo -e "${YELLOW}2. Büyük Veri Ekleme Testi (10000 kayıt)${NC}"
for i in {1..10}; do
    echo "Batch $i/10: 1000 kayıt ekleniyor..."
    for j in {1..1000}; do
        id=$((i * 1000 + j))
        sudo docker exec signoz-clickhouse clickhouse-client --query "
        INSERT INTO stress_test (id, name, value, timestamp) 
        VALUES ($id, 'LargeTest$id', $id * 2.5, now());
        "
    done
done

echo "✅ 10000 kayıt eklendi"

# Test 3: Karmaşık sorgu testi
echo -e "${YELLOW}3. Karmaşık Sorgu Testi${NC}"
echo "Ortalama değer hesaplanıyor..."
sudo docker exec signoz-clickhouse clickhouse-client --query "
SELECT 
    toDate(timestamp) as date,
    count() as total_records,
    avg(value) as avg_value,
    min(value) as min_value,
    max(value) as max_value
FROM stress_test 
GROUP BY date 
ORDER BY date;
"

# Test 4: Disk kullanımı kontrol
echo -e "${YELLOW}4. Disk Kullanımı Kontrolü${NC}"
sudo docker exec signoz-clickhouse clickhouse-client --query "
SELECT 
    database,
    table,
    formatReadableSize(total_bytes) as size,
    formatReadableSize(total_rows) as rows
FROM system.tables 
WHERE database = 'default';
"

# Test 5: Performans testi
echo -e "${YELLOW}5. Performans Testi (100 sorgu)${NC}"
start_time=$(date +%s)

for i in {1..100}; do
    sudo docker exec signoz-clickhouse clickhouse-client --query "
    SELECT count() FROM stress_test WHERE value > $i;
    " > /dev/null 2>&1
done

end_time=$(date +%s)
duration=$((end_time - start_time))
echo "✅ 100 sorgu $duration saniyede tamamlandı"

# Test 6: Eşzamanlı sorgu testi
echo -e "${YELLOW}6. Eşzamanlı Sorgu Testi${NC}"
echo "5 eşzamanlı sorgu başlatılıyor..."

for i in {1..5}; do
    (
        echo "Sorgu $i başladı"
        sudo docker exec signoz-clickhouse clickhouse-client --query "
        SELECT 
            count() as count_$i,
            avg(value) as avg_$i
        FROM stress_test 
        WHERE id % $i = 0;
        "
        echo "Sorgu $i tamamlandı"
    ) &
done

wait
echo "✅ Eşzamanlı sorgular tamamlandı"

# Test 7: Bellek kullanımı kontrol
echo -e "${YELLOW}7. Bellek Kullanımı Kontrolü${NC}"
sudo docker exec signoz-clickhouse clickhouse-client --query "
SELECT 
    metric,
    value,
    formatReadableSize(value) as readable_value
FROM system.metrics 
WHERE metric IN ('MemoryUsage', 'MemoryTracking');
"

# Test 8: Sistem durumu
echo -e "${YELLOW}8. Sistem Durumu${NC}"
sudo docker exec signoz-clickhouse clickhouse-client --query "
SELECT 
    name,
    value
FROM system.events 
WHERE name LIKE '%Query%' OR name LIKE '%Insert%'
ORDER BY value DESC
LIMIT 10;
"

echo ""
echo -e "${GREEN}✅ ClickHouse stres testi tamamlandı!${NC}"
echo ""
echo -e "${BLUE}📊 Sonuçlar:${NC}"
echo "- Toplam kayıt: 11000"
echo "- Sorgu performansı: $duration saniye (100 sorgu)"
echo "- Eşzamanlı sorgular: Başarılı"
echo ""
echo -e "${YELLOW}💡 SigNoz'da trace'leri kontrol edin:${NC}"
echo "   http://localhost:8080"
