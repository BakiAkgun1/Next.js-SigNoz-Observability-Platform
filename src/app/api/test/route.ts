import { NextResponse } from 'next/server'

export async function GET() {
  // Simüle edilmiş gecikme - trace'lerde görünecek
  await new Promise(resolve => setTimeout(resolve, Math.random() * 1000))

  // Rastgele hata oluşturma (test için)
  if (Math.random() < 0.1) {
    throw new Error('Rastgele API hatası')
  }

  return NextResponse.json({
    message: 'API çağrısı başarılı!',
    timestamp: new Date().toISOString(),
    data: {
      id: Math.floor(Math.random() * 1000),
      name: 'Test Verisi',
      value: Math.random()
    }
  })
}

