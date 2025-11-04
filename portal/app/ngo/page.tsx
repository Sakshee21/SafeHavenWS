'use client'

import { useEffect, useState } from 'react'

type Case = {
  id: number
  victim: string
  status: number
  latitude: string
  longitude: string
  timestamp: number
  assignedVolunteer?: string
  acknowledgedBy?: string
}

const API_BASE = process.env.NEXT_PUBLIC_API_BASE || 'http://localhost:5000'

export default function NgoDashboard() {
  const [loading, setLoading] = useState(true)
  const [cases, setCases] = useState<Case[]>([])
  const [error, setError] = useState<string | null>(null)

  async function load() {
    try {
      setLoading(true)
      const res = await fetch(`${API_BASE}/api/ngo/cases`, { cache: 'no-store' })
      const data = await res.json()
      if (!data.success) throw new Error(data.error || 'Failed to load')
      setCases(data.cases)
      setError(null)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    load()
    const interval = setInterval(load, 5000) // refresh every 5s
    return () => clearInterval(interval)
  }, [])

  async function post(path: string) {
    const res = await fetch(`${API_BASE}${path}`, { method: 'POST', headers: { 'Content-Type': 'application/json' } })
    const data = await res.json().catch(() => ({}))
    if (!res.ok || data?.success === false) throw new Error(data?.error || 'Request failed')
    await load()
  }

  return (
    <main className="mx-auto max-w-5xl p-6 space-y-6">
      <h1 className="text-3xl font-semibold">NGO Command Portal</h1>
      {error && <div className="rounded border border-red-700 bg-red-950 p-3 text-red-200">{error}</div>}
      {loading ? (
        <div className="text-gray-400">Loading...</div>
      ) : (
        <div className="overflow-x-auto rounded border border-gray-800">
          <table className="min-w-full text-sm">
            <thead className="bg-gray-900 text-gray-300">
              <tr>
                <th className="px-3 py-2 text-left">ID</th>
                <th className="px-3 py-2 text-left">Victim</th>
                <th className="px-3 py-2 text-left">Status</th>
                <th className="px-3 py-2 text-left">Age</th>
                <th className="px-3 py-2 text-left">Lat,Lng</th>
                <th className="px-3 py-2 text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              {cases.length === 0 && (
                <tr>
                  <td className="px-3 py-4 text-gray-400" colSpan={5}>No active cases</td>
                </tr>
              )}
              {cases.map(c => (
                <tr key={c.id} className="border-t border-gray-800">
                  <td className="px-3 py-2">#{c.id}</td>
                  <td className="px-3 py-2 truncate max-w-[220px]">{c.victim}</td>
                  <td className="px-3 py-2">
                    <span className={`px-2 py-1 rounded text-xs ${statusColor(c.status)}`}>{statusLabel(c.status)}</span>
                  </td>
                  <td className="px-3 py-2">
                    <CaseTimer timestamp={c.timestamp} status={c.status} />
                  </td>
                  <td className="px-3 py-2">{c.latitude},{c.longitude}</td>
                  <td className="px-3 py-2 space-y-2">
                    <div className="space-x-2">
                      <button onClick={() => post(`/api/ngo/acknowledge/${c.id}`)} className="rounded bg-yellow-600 px-3 py-1 text-white">Acknowledge</button>
                      <button onClick={() => post(`/api/ngo/escalate/${c.id}`)} className="rounded bg-orange-600 px-3 py-1 text-white">Escalate</button>
                      <button onClick={() => post(`/api/ngo/resolve/${c.id}`)} className="rounded bg-green-600 px-3 py-1 text-white">Resolve</button>
                    </div>
                    <AssignVolunteer id={c.id} onDone={load} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </main>
  )
}

function statusLabel(s: number) {
  return ['Pending', 'Acknowledged', 'Escalated', 'Resolved'][s] ?? String(s)
}

function statusColor(s: number) {
  const colors = ['bg-yellow-900 text-yellow-200', 'bg-blue-900 text-blue-200', 'bg-red-900 text-red-200', 'bg-green-900 text-green-200']
  return colors[s] ?? 'bg-gray-800 text-gray-300'
}

function CaseTimer({ timestamp, status }: { timestamp: number; status: number }) {
  const [age, setAge] = useState(0)
  useEffect(() => {
    const update = () => {
      const now = Date.now()
      const t = timestamp * 1000
      setAge(Math.floor((now - t) / 1000))
    }
    update()
    const interval = setInterval(update, 1000)
    return () => clearInterval(interval)
  }, [timestamp])

  const minutes = Math.floor(age / 60)
  const isUrgent = age > 30 * 60 // 30 minutes
  const isCritical = age > 60 * 60 // 60 minutes

  return (
    <span className={`text-xs ${isCritical ? 'text-red-400 font-bold' : isUrgent ? 'text-orange-400' : 'text-gray-400'}`}>
      {minutes}m {age % 60}s
      {isCritical && ' ⚠️'}
    </span>
  )
}

function AssignVolunteer({ id, onDone }: { id: number; onDone: () => void }) {
  const [address, setAddress] = useState('')
  const [loading, setLoading] = useState(false)
  const [err, setErr] = useState<string | null>(null)
  async function submit() {
    try {
      setLoading(true)
      setErr(null)
      const res = await fetch(`${API_BASE}/api/ngo/assign/${id}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ volunteer: address }),
      })
      const data = await res.json().catch(() => ({}))
      if (!res.ok || data?.success === false) throw new Error(data?.error || 'Assign failed')
      setAddress('')
      onDone()
    } catch (e: any) {
      setErr(e.message)
    } finally {
      setLoading(false)
    }
  }
  return (
    <div className="flex items-center gap-2">
      <input
        value={address}
        onChange={e => setAddress(e.target.value)}
        className="w-72 rounded border border-gray-800 bg-gray-900 px-2 py-1 text-sm"
        placeholder="Volunteer address (0x...)"
      />
      <button disabled={loading} onClick={submit} className="rounded bg-blue-600 px-3 py-1 text-white disabled:opacity-50">
        Assign
      </button>
      {err && <span className="text-xs text-red-400">{err}</span>}
    </div>
  )
}
