import { NextRequest, NextResponse } from 'next/server'
import { readFile, readdir, stat } from 'fs/promises'
import { join } from 'path'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const filename = searchParams.get('file')
    const action = searchParams.get('action') || 'download'

    if (action === 'list') {
      // Dosya listesini döndür
      const uploadDir = join(process.cwd(), 'uploads')
      try {
        const files = await readdir(uploadDir)
        const fileList = []
        
        for (const file of files) {
          const filePath = join(uploadDir, file)
          const stats = await stat(filePath)
          fileList.push({
            name: file,
            size: stats.size,
            modified: stats.mtime
          })
        }
        
        return NextResponse.json({ files: fileList })
      } catch (error) {
        return NextResponse.json({ files: [] })
      }
    }

    if (!filename) {
      return NextResponse.json(
        { error: 'Dosya adı belirtilmedi' },
        { status: 400 }
      )
    }

    // Dosyayı oku
    const filePath = join(process.cwd(), 'uploads', filename)
    const fileBuffer = await readFile(filePath)
    
    // Response headers
    const headers = new Headers()
    headers.set('Content-Type', 'application/octet-stream')
    headers.set('Content-Disposition', `attachment; filename="${filename}"`)
    headers.set('Content-Length', fileBuffer.length.toString())

    return new NextResponse(fileBuffer, {
      status: 200,
      headers
    })

  } catch (error) {
    console.error('Download hatası:', error)
    return NextResponse.json(
      { error: 'Dosya bulunamadı veya okunamadı' },
      { status: 404 }
    )
  }
}
