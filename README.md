# 🚀 Next.js + SigNoz Observability Platform

Bu proje, **Next.js** uygulaması ile **SigNoz** observability platformunu entegre ederek, uygulama performansını izleme ve analiz etme amacıyla geliştirilmiştir.
<img width="1911" height="856" alt="image" src="https://github.com/user-attachments/assets/0cd2067c-d1eb-4262-bd40-5d1b20e63a7f" />

## 📋 Proje Hakkında

### 🎯 Amaç
- Next.js uygulamasından çıkan **trace'leri** ve **log'ları** toplamak
- **OpenTelemetry** ile otomatik instrumentation sağlamak
- **SigNoz** üzerinde performans analizi yapmak
- **ClickHouse** veritabanının stres testlerini gerçekleştirmek
- File upload/download işlemlerini test etmek

### 🛠️ Teknolojiler
- **Next.js 15.5.2** - React framework
- **OpenTelemetry** - Observability standardı
- **SigNoz** - Open-source observability platform
- **ClickHouse** - Yüksek performanslı veritabanı
- **Docker & Docker Compose** - Containerization
- **WSL Ubuntu** - Linux geliştirme ortamı

## 🚀 Kurulum

### Ön Gereksinimler
- Windows 10/11
- WSL2 Ubuntu
- Docker Desktop
- Node.js 18+

### 1. WSL Ubuntu Kurulumu
```bash
# WSL Ubuntu'yu etkinleştir
wsl --install -d Ubuntu

# Ubuntu'ya bağlan
wsl -d Ubuntu
```

### 2. WSL Ortamını Hazırla
```bash
# Gerekli paketleri yükle
sudo apt update
sudo apt install -y docker.io docker-compose git curl wget net-tools

# Docker servisini başlat
sudo service docker start
sudo usermod -aG docker $USER

# Yeni terminal aç veya WSL'i yeniden başlat
```

### 3. Projeyi Klonla
```bash
# Projeyi klonla
git clone <repository-url>
cd NextJS-Signoz

# Bağımlılıkları yükle
npm install
```

### 4. SigNoz'u Başlat
```bash
# SigNoz kurulum script'ini çalıştır
chmod +x wsl-setup.sh
./wsl-setup.sh

# SigNoz'u başlat
chmod +x wsl-signoz-setup.sh
./wsl-signoz-setup.sh
```

### 5. Next.js Uygulamasını Başlat
```bash
# Next.js uygulamasını başlat
npm run dev
```

## 🌐 Erişim Adresleri

| Servis | URL | Açıklama |
|--------|-----|----------|
| Next.js App | http://localhost:3003 | Ana uygulama |
| SigNoz UI | http://localhost:8080 | Observability platformu |
| OTLP HTTP | http://localhost:4318 | Trace collector |
| OTLP gRPC | localhost:4317 | Trace collector |

## 📊 Test Senaryoları

### 1. Temel API Testleri
```bash
# Test script'ini çalıştır
chmod +x wsl-test-scenarios.sh
./wsl-test-scenarios.sh
```

### 2. File Upload/Download Testleri
```bash
# Test dosyalarını oluştur
chmod +x wsl-create-test-files.sh
./wsl-create-test-files.sh

# Dosya upload testi
curl -X POST -F 'file=@test-files/small-1kb.txt' http://localhost:3003/api/upload

# Dosya download testi
curl http://localhost:3003/api/download
```


### 3. ClickHouse Stres Testi
```bash
# ClickHouse stres testini çalıştır
chmod +x wsl-clickhouse-test.sh
./wsl-clickhouse-test.sh

# Gelişmiş stres testi
chmod +x wsl-clickhouse-stress-test.sh
./wsl-clickhouse-stress-test.sh
```
<img width="433" height="222" alt="image" src="https://github.com/user-attachments/assets/2dc28542-630e-4eaf-83a4-242c34e247c1" />

### 4. Manuel Testler
```bash
# API endpoint'lerini test et
curl http://localhost:3003/api/test
curl http://localhost:3003/api/users

# Eşzamanlı test
for i in {1..10}; do
    curl -X POST -F "file=@test-files/small-1kb.txt" http://localhost:3003/api/upload &
done
wait
```

## 📁 Proje Yapısı

```
NextJS-Signoz/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── test/route.ts          # Test API endpoint
│   │   │   ├── users/route.ts         # Users API endpoint
│   │   │   ├── upload/route.ts        # File upload endpoint
│   │   │   └── download/route.ts      # File download endpoint
│   │   ├── users/page.tsx             # Users sayfası
│   │   ├── stress-test/page.tsx       # Stres test sayfası
│   │   ├── page.tsx                   # Ana sayfa
│   │   └── layout.tsx                 # Layout
│   └── ...
├── tracing-fixed.js                   # OpenTelemetry konfigürasyonu
├── stress-test.js                     # Node.js stres test script'i
├── wsl-setup.sh                       # WSL kurulum script'i
├── wsl-signoz-setup.sh                # SigNoz kurulum script'i
├── wsl-test-scenarios.sh              # Test senaryoları
├── wsl-create-test-files.sh           # Test dosyaları oluşturma
├── wsl-clickhouse-test.sh             # ClickHouse test script'i
├── wsl-clickhouse-stress-test.sh      # ClickHouse stres testi
└── README.md                          # Bu dosya
```

## 🔧 Konfigürasyon

### OpenTelemetry Konfigürasyonu
```javascript
// tracing-fixed.js
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://localhost:4318/v1/traces',
    headers: {
      'Content-Type': 'application/json',
    },
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```

### Package.json Scripts
```json
{
  "scripts": {
    "dev": "cross-env NODE_OPTIONS=\"--require ./tracing-fixed.js\" next dev -p 3003",
    "build": "next build",
    "start": "cross-env NODE_OPTIONS=\"--require ./tracing-fixed.js\" next start -p 3003",
    "stress-test": "node stress-test.js"
  }
}
```

## 📈 SigNoz'da İzleme
<img width="1919" height="939" alt="image" src="https://github.com/user-attachments/assets/e3c0ba2e-525e-43d2-b2f4-bc27cf95d451" />

### 1. Services
- **nextjs-signoz-app** servisini bulun
- API endpoint'lerinin performansını izleyin

### 2. Traces
- HTTP request'lerin trace'lerini görün
- File upload/download işlemlerini analiz edin
- Hata oranlarını kontrol edin

### 3. Metrics
- Response time'ları izleyin
- Throughput metriklerini kontrol edin
- Resource kullanımını analiz edin

## 🧪 Test Sonuçları

### Beklenen Performans
- **API Response Time**: < 100ms
- **File Upload**: 1KB-1MB dosyalar
- **ClickHouse**: 10,000+ kayıt işleme
- **Concurrent Requests**: 10+ eşzamanlı istek

### Stres Test Sonuçları
- **File Upload**: Farklı boyutlarda dosyalar
- **ClickHouse**: 11,000+ kayıt ekleme
- **Query Performance**: 100 sorgu testi
- **Memory Usage**: Bellek kullanımı izleme

## 🔍 Sorun Giderme

### SigNoz Erişim Sorunu
```bash
# SigNoz'u yeniden başlat
cd ~/signoz/deploy/docker
sudo docker-compose restart

# Port kontrolü
netstat -tlnp | grep :8080
```

### OpenTelemetry Sorunu
```bash
# Bağımlılıkları yeniden yükle
rm -rf node_modules package-lock.json
npm install

# Tracing'i test et
node -e "require('./tracing-fixed.js')"
```

### ClickHouse Sorunu
```bash
# ClickHouse container'ını kontrol et
sudo docker-compose ps | grep clickhouse

# Logları kontrol et
sudo docker-compose logs signoz-clickhouse
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

Bu proje **Cursor AI** ile geliştirilmiştir.

---

**Not**: Bu proje eğitim ve test amaçlı geliştirilmiştir. Production ortamında kullanmadan önce güvenlik ve performans testlerini yapın.
