'use client'

import { useState, useEffect } from 'react'

interface User {
  id: number
  name: string
  email: string
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchUsers()
  }, [])

  const fetchUsers = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/users')
      if (!response.ok) {
        throw new Error('Kullanıcılar yüklenemedi')
      }
      const data = await response.json()
      setUsers(data.users)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Bilinmeyen hata')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">Kullanıcılar yükleniyor...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-red-500 text-xl">Hata: {error}</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Kullanıcılar</h1>
        
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {users.map((user) => (
            <div
              key={user.id}
              className="bg-white p-6 rounded-lg shadow-md border"
            >
              <h3 className="text-lg font-semibold mb-2">{user.name}</h3>
              <p className="text-gray-600">{user.email}</p>
              <div className="mt-4 text-sm text-gray-500">
                ID: {user.id}
              </div>
            </div>
          ))}
        </div>

        <div className="mt-8 text-center">
          <button
            onClick={fetchUsers}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Yenile
          </button>
        </div>
      </div>
    </div>
  )
}

