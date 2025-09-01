import { NextResponse } from 'next/server'

export async function GET() {
  // Simüle edilmiş veritabanı sorgusu
  await new Promise(resolve => setTimeout(resolve, 500))

  const users = [
    { id: 1, name: 'Ahmet Yılmaz', email: 'ahmet@example.com' },
    { id: 2, name: 'Ayşe Demir', email: 'ayse@example.com' },
    { id: 3, name: 'Mehmet Kaya', email: 'mehmet@example.com' },
    { id: 4, name: 'Fatma Özkan', email: 'fatma@example.com' },
    { id: 5, name: 'Ali Çelik', email: 'ali@example.com' }
  ]

  return NextResponse.json({
    users,
    count: users.length,
    timestamp: new Date().toISOString()
  })
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    
    // Simüle edilmiş kullanıcı oluşturma
    await new Promise(resolve => setTimeout(resolve, 300))
    
    const newUser = {
      id: Math.floor(Math.random() * 1000),
      name: body.name,
      email: body.email,
      createdAt: new Date().toISOString()
    }

    return NextResponse.json({
      message: 'Kullanıcı başarıyla oluşturuldu',
      user: newUser
    }, { status: 201 })
  } catch (error) {
    return NextResponse.json({
      error: 'Kullanıcı oluşturulamadı'
    }, { status: 400 })
  }
}

