#!/bin/bash

echo "🔥 WSL Ubuntu ClickHouse Test Sistemi"
echo "====================================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ClickHouse container'ını bul
get_clickhouse_container() {
    sudo docker ps --format "table {{.Names}}\t{{.Image}}" | grep clickhouse
}

# ClickHouse bağlantı testi
test_clickhouse_connection() {
    echo -e "${BLUE}🔗 ClickHouse Bağlantı Testi...${NC}"
    
    container=$(get_clickhouse_container | awk '{print $1}')
    if [ -z "$container" ]; then
        echo -e "${RED}❌ ClickHouse container bulunamadı${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ ClickHouse container: $container${NC}"
    
    # Bağlantı testi
    if sudo docker exec $container clickhouse-client --query "SELECT 1"; then
        echo -e "${GREEN}✅ ClickHouse bağlantısı başarılı${NC}"
        return 0
    else
        echo -e "${RED}❌ ClickHouse bağlantısı başarısız${NC}"
        return 1
    fi
}

# ClickHouse performans testi
test_clickhouse_performance() {
    echo -e "${BLUE}⚡ ClickHouse Performans Testi...${NC}"
    
    container=$(get_clickhouse_container | awk '{print $1}')
    if [ -z "$container" ]; then
        echo -e "${RED}❌ ClickHouse container bulunamadı${NC}"
        return 1
    fi
    
    # Test tablosu oluştur
    echo -e "${YELLOW}📊 Test tablosu oluşturuluyor...${NC}"
    sudo docker exec $container clickhouse-client --query "
    CREATE TABLE IF NOT EXISTS stress_test (
        id UInt32,
        timestamp DateTime,
        data String,
        value Float64
    ) ENGINE = MergeTree()
    ORDER BY (timestamp, id)
    "
    
    # Test verisi ekle
    echo -e "${YELLOW}📝 Test verisi ekleniyor...${NC}"
    start_time=$(date +%s)
    
    for i in {1..1000}; do
        sudo docker exec $container clickhouse-client --query "
        INSERT INTO stress_test VALUES 
        ($i, now(), 'test_data_$i', $i * 1.5)
        " > /dev/null 2>&1
    done
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo -e "${GREEN}✅ 1000 kayıt $duration saniyede eklendi${NC}"
    
    # Sorgu performans testi
    echo -e "${YELLOW}🔍 Sorgu performans testi...${NC}"
    
    # Basit sorgu
    echo "Basit SELECT sorgusu:"
    time sudo docker exec $container clickhouse-client --query "SELECT COUNT(*) FROM stress_test"
    
    # Karmaşık sorgu
    echo "Karmaşık sorgu:"
    time sudo docker exec $container clickhouse-client --query "
    SELECT 
        toDate(timestamp) as date,
        COUNT(*) as count,
        AVG(value) as avg_value
    FROM stress_test 
    GROUP BY date 
    ORDER BY date
    "
}

# ClickHouse disk kullanımı
show_clickhouse_disk_usage() {
    echo -e "${BLUE}💾 ClickHouse Disk Kullanımı...${NC}"
    
    container=$(get_clickhouse_container | awk '{print $1}')
    if [ -z "$container" ]; then
        echo -e "${RED}❌ ClickHouse container bulunamadı${NC}"
        return 1
    fi
    
    # Container disk kullanımı
    echo "Container disk kullanımı:"
    sudo docker exec $container df -h
    
    # ClickHouse veri dizini
    echo "ClickHouse veri dizini:"
    sudo docker exec $container du -sh /var/lib/clickhouse/
}

# ClickHouse log analizi
analyze_clickhouse_logs() {
    echo -e "${BLUE}📋 ClickHouse Log Analizi...${NC}"
    
    container=$(get_clickhouse_container | awk '{print $1}')
    if [ -z "$container" ]; then
        echo -e "${RED}❌ ClickHouse container bulunamadı${NC}"
        return 1
    fi
    
    echo "Son 20 log satırı:"
    sudo docker logs --tail=20 $container | grep -i clickhouse
}

# ClickHouse stress testi
run_clickhouse_stress_test() {
    echo -e "${BLUE}🚀 ClickHouse Stress Testi...${NC}"
    
    container=$(get_clickhouse_container | awk '{print $1}')
    if [ -z "$container" ]; then
        echo -e "${RED}❌ ClickHouse container bulunamadı${NC}"
        return 1
    fi
    
    # Büyük veri seti oluştur
    echo -e "${YELLOW}📊 Büyük veri seti oluşturuluyor...${NC}"
    
    # 10,000 kayıt ekle
    start_time=$(date +%s)
    
    for batch in {1..10}; do
        echo "Batch $batch/10 işleniyor..."
        for i in {1..1000}; do
            id=$((batch * 1000 + i))
            sudo docker exec $container clickhouse-client --query "
            INSERT INTO stress_test VALUES 
            ($id, now(), 'stress_data_$id', $id * 2.5)
            " > /dev/null 2>&1
        done
    done
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo -e "${GREEN}✅ 10,000 kayıt $duration saniyede eklendi${NC}"
    
    # Paralel sorgu testi
    echo -e "${YELLOW}🔄 Paralel sorgu testi...${NC}"
    
    for i in {1..5}; do
        (
            echo "Sorgu $i başlatıldı..."
            time sudo docker exec $container clickhouse-client --query "
            SELECT COUNT(*) FROM stress_test WHERE value > $i * 1000
            " > /dev/null 2>&1
            echo "Sorgu $i tamamlandı"
        ) &
    done
    wait
    
    echo -e "${GREEN}✅ Paralel sorgu testi tamamlandı${NC}"
}

# Ana menü
while true; do
    echo ""
    echo -e "${YELLOW}🎯 ClickHouse Test Menüsü${NC}"
    echo "1. ClickHouse Bağlantı Testi"
    echo "2. ClickHouse Performans Testi"
    echo "3. Disk Kullanımı"
    echo "4. Log Analizi"
    echo "5. Stress Testi"
    echo "6. Tüm Testleri Çalıştır"
    echo "7. Container Durumu"
    echo "8. Çıkış"
    echo ""
    read -p "Seçiminiz (1-8): " choice
    
    case $choice in
        1)
            test_clickhouse_connection
            ;;
        2)
            test_clickhouse_performance
            ;;
        3)
            show_clickhouse_disk_usage
            ;;
        4)
            analyze_clickhouse_logs
            ;;
        5)
            run_clickhouse_stress_test
            ;;
        6)
            echo -e "${YELLOW}🚀 Tüm ClickHouse Testleri Çalıştırılıyor...${NC}"
            test_clickhouse_connection
            test_clickhouse_performance
            show_clickhouse_disk_usage
            analyze_clickhouse_logs
            run_clickhouse_stress_test
            ;;
        7)
            echo -e "${BLUE}🐳 ClickHouse Container Durumu:${NC}"
            get_clickhouse_container
            echo ""
            echo "Tüm SigNoz container'ları:"
            sudo docker ps | grep signoz
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
