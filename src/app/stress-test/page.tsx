'use client'

import { useState, useEffect } from 'react'

interface FileInfo {
  name: string
  size: number
  modified: string
}

interface TestResult {
  operation: string
  duration: number
  success: boolean
  error?: string
  timestamp: string
}

export default function StressTestPage() {
  const [uploadedFiles, setUploadedFiles] = useState<FileInfo[]>([])
  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [isRunning, setIsRunning] = useState(false)
  const [selectedFile, setSelectedFile] = useState<File | null>(null)

  // Uploaded dosyaları listele
  const fetchUploadedFiles = async () => {
    try {
      const response = await fetch('/api/download?action=list')
      const data = await response.json()
      setUploadedFiles(data.files || [])
    } catch (error) {
      console.error('Dosya listesi alınamadı:', error)
    }
  }

  useEffect(() => {
    fetchUploadedFiles()
  }, [])

  // Dosya upload
  const handleUpload = async (file: File) => {
    const startTime = Date.now()
    
    try {
      const formData = new FormData()
      formData.append('file', file)

      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData
      })

      const result = await response.json()
      const duration = Date.now() - startTime

      setTestResults(prev => [...prev, {
        operation: `Upload: ${file.name} (${(file.size / 1024 / 1024).toFixed(2)}MB)`,
        duration,
        success: response.ok,
        error: response.ok ? undefined : result.error,
        timestamp: new Date().toISOString()
      }])

      if (response.ok) {
        fetchUploadedFiles()
      }
    } catch (error) {
      const duration = Date.now() - startTime
      setTestResults(prev => [...prev, {
        operation: `Upload: ${file.name}`,
        duration,
        success: false,
        error: error instanceof Error ? error.message : 'Bilinmeyen hata',
        timestamp: new Date().toISOString()
      }])
    }
  }

  // Dosya download
  const handleDownload = async (filename: string) => {
    const startTime = Date.now()
    
    try {
      const response = await fetch(`/api/download?file=${filename}`)
      const duration = Date.now() - startTime

      if (response.ok) {
        const blob = await response.blob()
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = filename
        a.click()
        window.URL.revokeObjectURL(url)

        setTestResults(prev => [...prev, {
          operation: `Download: ${filename}`,
          duration,
          success: true,
          timestamp: new Date().toISOString()
        }])
      } else {
        const error = await response.json()
        setTestResults(prev => [...prev, {
          operation: `Download: ${filename}`,
          duration,
          success: false,
          error: error.error,
          timestamp: new Date().toISOString()
        }])
      }
    } catch (error) {
      const duration = Date.now() - startTime
      setTestResults(prev => [...prev, {
        operation: `Download: ${filename}`,
        duration,
        success: false,
        error: error instanceof Error ? error.message : 'Bilinmeyen hata',
        timestamp: new Date().toISOString()
      }])
    }
  }

  // Stress test - çoklu upload
  const runStressTest = async () => {
    setIsRunning(true)
    setTestResults([])

    // Test dosyaları oluştur
    const testFiles = [
      new File(['x'.repeat(1024)], 'test-1kb.txt', { type: 'text/plain' }),
      new File(['x'.repeat(1024 * 10)], 'test-10kb.txt', { type: 'text/plain' }),
      new File(['x'.repeat(1024 * 100)], 'test-100kb.txt', { type: 'text/plain' }),
      new File(['x'.repeat(1024 * 1024)], 'test-1mb.txt', { type: 'text/plain' }),
    ]

    // Paralel upload testi
    const uploadPromises = testFiles.map(file => handleUpload(file))
    await Promise.all(uploadPromises)

    // Kısa bir bekleme
    await new Promise(resolve => setTimeout(resolve, 1000))

    // Download testi
    await fetchUploadedFiles()
    const downloadPromises = uploadedFiles.map(file => handleDownload(file.name))
    await Promise.all(downloadPromises)

    setIsRunning(false)
  }

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Stress Test Paneli</h1>
        
        {/* Upload Bölümü */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Dosya Upload</h2>
          <div className="flex items-center space-x-4">
            <input
              type="file"
              onChange={(e) => setSelectedFile(e.target.files?.[0] || null)}
              className="border border-gray-300 rounded px-3 py-2"
            />
            <button
              onClick={() => selectedFile && handleUpload(selectedFile)}
              disabled={!selectedFile}
              className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 disabled:bg-gray-300"
            >
              Upload Et
            </button>
          </div>
        </div>

        {/* Uploaded Dosyalar */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Yüklenen Dosyalar</h2>
          <div className="grid gap-2">
            {uploadedFiles.map((file, index) => (
              <div key={index} className="flex items-center justify-between p-3 border rounded">
                <div>
                  <span className="font-medium">{file.name}</span>
                  <span className="text-gray-500 ml-2">
                    ({(file.size / 1024 / 1024).toFixed(2)}MB)
                  </span>
                </div>
                <button
                  onClick={() => handleDownload(file.name)}
                  className="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
                >
                  Download
                </button>
              </div>
            ))}
            {uploadedFiles.length === 0 && (
              <p className="text-gray-500">Henüz dosya yüklenmedi</p>
            )}
          </div>
        </div>

        {/* Stress Test */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Stress Test</h2>
          <button
            onClick={runStressTest}
            disabled={isRunning}
            className="bg-red-500 text-white px-6 py-3 rounded hover:bg-red-600 disabled:bg-gray-300"
          >
            {isRunning ? 'Test Çalışıyor...' : 'Stress Test Başlat'}
          </button>
        </div>

        {/* Test Sonuçları */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Test Sonuçları</h2>
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {testResults.map((result, index) => (
              <div
                key={index}
                className={`p-3 rounded border ${
                  result.success ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'
                }`}
              >
                <div className="flex justify-between items-start">
                  <div>
                    <span className="font-medium">{result.operation}</span>
                    {result.error && (
                      <p className="text-red-600 text-sm mt-1">{result.error}</p>
                    )}
                  </div>
                  <div className="text-right">
                    <span className={`font-medium ${
                      result.success ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {result.success ? 'Başarılı' : 'Başarısız'}
                    </span>
                    <p className="text-gray-500 text-sm">{result.duration}ms</p>
                  </div>
                </div>
              </div>
            ))}
            {testResults.length === 0 && (
              <p className="text-gray-500">Henüz test sonucu yok</p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
