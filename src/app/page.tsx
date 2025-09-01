'use client'

import { useState, useEffect } from 'react'

export default function Home() {
  const [count, setCount] = useState(0)
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<any>(null)

  // Test fonksiyonu - trace'leri görmek için
  const testApiCall = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/test')
      const result = await response.json()
      setData(result)
    } catch (error) {
      console.error('API çağrısı hatası:', error)
    } finally {
      setLoading(false)
    }
  }

  // Hata oluşturan fonksiyon - error trace'lerini görmek için
  const triggerError = () => {
    throw new Error('Test hatası - SigNoz\'da görünecek')
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-between font-mono text-sm lg:flex">
        <div className="fixed bottom-0 left-0 flex h-48 w-full items-end justify-center bg-gradient-to-t from-white via-white dark:from-black dark:via-black lg:static lg:h-auto lg:w-auto lg:bg-none">
          <div className="flex place-items-center gap-2 p-8 lg:pointer-events-auto lg:p-0">
            <h1 className="text-4xl font-bold text-center mb-8">
              Next.js + SigNoz Demo
            </h1>
          </div>
        </div>
      </div>

      <div className="relative flex place-items-center">
        <div className="text-center space-y-6">
          <h2 className="text-2xl font-semibold">
            OpenTelemetry ile İzlenen Uygulama
          </h2>
          
          <div className="space-y-4">
            <div className="flex items-center justify-center space-x-4">
              <button
                onClick={() => setCount(count + 1)}
                className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
              >
                Sayaç: {count}
              </button>
              
              <button
                onClick={testApiCall}
                disabled={loading}
                className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:opacity-50"
              >
                {loading ? 'Yükleniyor...' : 'API Test'}
              </button>
              
              <button
                onClick={triggerError}
                className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
              >
                Hata Oluştur
              </button>
            </div>

            {data && (
              <div className="mt-4 p-4 bg-gray-100 rounded">
                <h3 className="font-semibold">API Yanıtı:</h3>
                <pre className="text-sm">{JSON.stringify(data, null, 2)}</pre>
              </div>
            )}
          </div>

          <div className="mt-8 text-sm text-gray-600">
            <p>Bu uygulama OpenTelemetry ile izlenmektedir.</p>
            <p>SigNoz UI'da <a href="http://localhost:8080" target="_blank" className="text-blue-500 hover:underline">http://localhost:8080</a> adresinden trace'leri görebilirsiniz.</p>
          </div>
        </div>
      </div>

      <div className="mb-32 grid text-center lg:max-w-5xl lg:w-full lg:mb-0 lg:grid-cols-4 lg:text-left">
        <a href="/users" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Kullanıcılar{' '}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              →
            </span>
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            Kullanıcılar sayfasını ziyaret et ve API çağrılarını izle.
          </p>
        </a>

        <a href="/stress-test" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Stress Test{' '}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              →
            </span>
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            Dosya upload/download stress testi yap ve performansı izle.
          </p>
        </a>

        <div className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Trace'ler{' '}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              →
            </span>
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            Her HTTP isteği ve API çağrısı otomatik olarak izlenir.
          </p>
        </div>

        <a href="http://localhost:3301" target="_blank" rel="noopener noreferrer" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            SigNoz{' '}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              →
            </span>
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            SigNoz UI'yi aç ve trace'leri, metrikleri görüntüle.
          </p>
        </a>
      </div>
    </main>
  )
}

