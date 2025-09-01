const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

class StressTest {
  constructor(baseUrl = 'http://localhost:3002') {
    this.baseUrl = baseUrl;
    this.results = [];
  }

  async createTestFile(size, filename) {
    const content = 'x'.repeat(size);
    const filePath = path.join(__dirname, 'temp', filename);
    
    // Temp dizini oluştur
    if (!fs.existsSync(path.join(__dirname, 'temp'))) {
      fs.mkdirSync(path.join(__dirname, 'temp'));
    }
    
    fs.writeFileSync(filePath, content);
    return filePath;
  }

  async uploadFile(filePath, filename) {
    const startTime = Date.now();
    
    try {
      const formData = new FormData();
      formData.append('file', fs.createReadStream(filePath), filename);
      
      const response = await axios.post(`${this.baseUrl}/api/upload`, formData, {
        headers: {
          ...formData.getHeaders(),
        },
        timeout: 30000 // 30 saniye timeout
      });
      
      const duration = Date.now() - startTime;
      
      this.results.push({
        operation: `Upload: ${filename}`,
        duration,
        success: true,
        size: fs.statSync(filePath).size,
        timestamp: new Date().toISOString()
      });
      
      return response.data;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      this.results.push({
        operation: `Upload: ${filename}`,
        duration,
        success: false,
        error: error.message,
        size: fs.statSync(filePath).size,
        timestamp: new Date().toISOString()
      });
      
      throw error;
    }
  }

  async downloadFile(filename) {
    const startTime = Date.now();
    
    try {
      const response = await axios.get(`${this.baseUrl}/api/download?file=${filename}`, {
        responseType: 'stream',
        timeout: 30000
      });
      
      const duration = Date.now() - startTime;
      
      this.results.push({
        operation: `Download: ${filename}`,
        duration,
        success: true,
        timestamp: new Date().toISOString()
      });
      
      return response.data;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      this.results.push({
        operation: `Download: ${filename}`,
        duration,
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      });
      
      throw error;
    }
  }

  async runConcurrentUploads(count = 10, fileSize = 1024 * 1024) {
    console.log(`🚀 ${count} adet ${(fileSize / 1024 / 1024).toFixed(2)}MB dosya paralel upload başlatılıyor...`);
    
    const promises = [];
    
    for (let i = 0; i < count; i++) {
      const filename = `stress-test-${i}-${Date.now()}.txt`;
      const filePath = await this.createTestFile(fileSize, filename);
      
      promises.push(this.uploadFile(filePath, filename));
    }
    
    await Promise.allSettled(promises);
    console.log('✅ Paralel upload tamamlandı');
  }

  async runSequentialUploads(count = 5, fileSizes = [1024, 10240, 102400, 1048576]) {
    console.log(`📁 ${count} adet farklı boyutlarda dosya sıralı upload başlatılıyor...`);
    
    for (let i = 0; i < count; i++) {
      for (const size of fileSizes) {
        const filename = `seq-test-${i}-${size}-${Date.now()}.txt`;
        const filePath = await this.createTestFile(size, filename);
        
        try {
          await this.uploadFile(filePath, filename);
          console.log(`✅ ${filename} yüklendi`);
        } catch (error) {
          console.error(`❌ ${filename} yüklenemedi:`, error.message);
        }
      }
    }
  }

  async runMixedTest() {
    console.log('🔄 Karışık test başlatılıyor...');
    
    // Küçük dosyalar paralel
    await this.runConcurrentUploads(20, 1024);
    
    // Orta boyut dosyalar sıralı
    await this.runSequentialUploads(3, [102400, 1048576]);
    
    // Büyük dosya tek
    const largeFilePath = await this.createTestFile(10 * 1024 * 1024, 'large-test.txt');
    await this.uploadFile(largeFilePath, 'large-test.txt');
  }

  printResults() {
    console.log('\n📊 TEST SONUÇLARI');
    console.log('='.repeat(50));
    
    const successful = this.results.filter(r => r.success);
    const failed = this.results.filter(r => !r.success);
    
    console.log(`Toplam İşlem: ${this.results.length}`);
    console.log(`Başarılı: ${successful.length}`);
    console.log(`Başarısız: ${failed.length}`);
    console.log(`Başarı Oranı: ${((successful.length / this.results.length) * 100).toFixed(2)}%`);
    
    if (successful.length > 0) {
      const avgDuration = successful.reduce((sum, r) => sum + r.duration, 0) / successful.length;
      const minDuration = Math.min(...successful.map(r => r.duration));
      const maxDuration = Math.max(...successful.map(r => r.duration));
      
      console.log(`\nOrtalama Süre: ${avgDuration.toFixed(2)}ms`);
      console.log(`En Hızlı: ${minDuration}ms`);
      console.log(`En Yavaş: ${maxDuration}ms`);
    }
    
    if (failed.length > 0) {
      console.log('\n❌ BAŞARISIZ İŞLEMLER:');
      failed.forEach(result => {
        console.log(`- ${result.operation}: ${result.error}`);
      });
    }
    
    // Dosyaya kaydet
    const reportPath = path.join(__dirname, 'stress-test-report.json');
    fs.writeFileSync(reportPath, JSON.stringify(this.results, null, 2));
    console.log(`\n📄 Detaylı rapor: ${reportPath}`);
  }
}

// Test çalıştırma
async function main() {
  const stressTest = new StressTest();
  
  try {
    console.log('🔥 Next.js + SigNoz Stress Test Başlatılıyor...\n');
    
    // Karışık test
    await stressTest.runMixedTest();
    
    // Sonuçları yazdır
    stressTest.printResults();
    
  } catch (error) {
    console.error('❌ Test hatası:', error.message);
  }
}

// Script doğrudan çalıştırılırsa
if (require.main === module) {
  main();
}

module.exports = StressTest;
