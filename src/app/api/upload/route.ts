import { NextRequest, NextResponse } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('file') as File
    
    if (!file) {
      return NextResponse.json(
        { error: 'Dosya bulunamadı' },
        { status: 400 }
      )
    }

    // Upload dizini oluştur
    const uploadDir = join(process.cwd(), 'uploads')
    await mkdir(uploadDir, { recursive: true })

    // Dosyayı kaydet
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    const filePath = join(uploadDir, file.name)
    
    await writeFile(filePath, buffer)

    return NextResponse.json({
      message: 'Dosya başarıyla yüklendi',
      filename: file.name,
      size: file.size,
      type: file.type,
      path: filePath
    })

  } catch (error) {
    console.error('Upload hatası:', error)
    return NextResponse.json(
      { error: 'Dosya yükleme hatası' },
      { status: 500 }
    )
  }
}

export async function GET() {
  return NextResponse.json({
    message: 'Upload endpoint aktif',
    maxFileSize: '200MB',
    supportedTypes: ['*/*']
  })
}
