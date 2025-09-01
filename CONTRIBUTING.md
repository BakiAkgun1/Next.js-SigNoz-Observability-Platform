# 🤝 Katkıda Bulunma Rehberi

Bu projeye katkıda bulunmak istediğiniz için teşekkürler! İşte nasıl başlayabileceğiniz:

## 🚀 Başlangıç

1. **Fork yapın** - Bu repository'yi fork edin
2. **Clone yapın** - Fork'unuzu local'e clone edin
3. **Branch oluşturun** - Yeni bir feature branch oluşturun

```bash
git clone https://github.com/YOUR_USERNAME/NextJS-Signoz.git
cd NextJS-Signoz
git checkout -b feature/amazing-feature
```

## 🔧 Geliştirme

### Kurulum
```bash
npm install
```

### Geliştirme Sunucusu
```bash
npm run dev
```

### Test
```bash
# API testleri
./wsl-test-scenarios.sh

# Stres testleri
./wsl-clickhouse-stress-test.sh
```

## 📝 Commit Mesajları

Commit mesajlarınızı açıklayıcı yapın:

```bash
git commit -m "feat: add new API endpoint for user management"
git commit -m "fix: resolve OpenTelemetry configuration issue"
git commit -m "docs: update README with new installation steps"
```

## 🔄 Pull Request

1. **Test edin** - Tüm testlerin geçtiğinden emin olun
2. **Dokümantasyon** - Gerekli dokümantasyonu güncelleyin
3. **Pull Request açın** - Detaylı açıklama ile PR oluşturun

## 📋 PR Şablonu

```markdown
## 🎯 Değişiklik Açıklaması
Bu PR ne yapıyor?

## 🧪 Test Edildi mi?
- [ ] Evet, tüm testler geçiyor
- [ ] Manuel test yapıldı
- [ ] SigNoz'da trace'ler görünüyor

## 📸 Ekran Görüntüleri (varsa)
...

## 🔍 Kontrol Listesi
- [ ] Kod stil rehberine uygun
- [ ] Kendi kodumu test ettim
- [ ] Dokümantasyonu güncelledim
- [ ] Commit mesajları açıklayıcı
```

## 🐛 Bug Raporlama

Bug raporlarken şu bilgileri ekleyin:

- **İşletim Sistemi**: Windows 10/11, WSL Ubuntu
- **Node.js Sürümü**: `node --version`
- **Hata Mesajı**: Tam hata mesajı
- **Beklenen Davranış**: Ne olması gerekiyordu
- **Gerçek Davranış**: Ne oldu

## 💡 Özellik Önerileri

Yeni özellik önerirken:

- **Amaç**: Bu özellik neyi çözecek?
- **Kullanım Senaryosu**: Nasıl kullanılacak?
- **Alternatifler**: Mevcut çözümler var mı?

## 📞 İletişim

Sorularınız için:
- GitHub Issues kullanın
- Detaylı açıklama yapın
- Gerekli log'ları ekleyin

Teşekkürler! 🎉
