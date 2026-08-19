import { useState, type FormEvent } from 'react'
import './App.css'

const API_URL = 'http://localhost:3000/query/test-sql'

type QueryResult = {
  sql: string
  results: Record<string, unknown>[]
}

type ApiError = {
  message: string
  error: string
  statusCode: number
}

type Status = 'idle' | 'loading' | 'success' | 'error'

function App() {
  const [question, setQuestion] = useState('')
  const [status, setStatus] = useState<Status>('idle')
  const [result, setResult] = useState<QueryResult | null>(null)
  const [errorMessage, setErrorMessage] = useState('')

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    const trimmed = question.trim()
    if (!trimmed || status === 'loading') return

    setStatus('loading')
    setErrorMessage('')

    try {
      const res = await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: trimmed }),
      })

      const data = await res.json()

      if (!res.ok) {
        const err = data as ApiError
        setErrorMessage(err.message || 'Something went wrong.')
        setStatus('error')
        return
      }

      setResult(data as QueryResult)
      setStatus('success')
    } catch {
      setErrorMessage('Could not reach the server. Is the backend running?')
      setStatus('error')
    }
  }

  const columns =
    result && result.results.length > 0 ? Object.keys(result.results[0]) : []

  return (
    <div className="page">
      <header className="header">
        <h1>SQL Oracle</h1>
        <p className="subtitle">Ask a question about your data in plain English</p>
      </header>

      <form className="query-form" onSubmit={handleSubmit}>
        <input
          type="text"
          className="question-input"
          placeholder="Which customers haven't ordered in the last 3 months?"
          value={question}
          onChange={(e) => setQuestion(e.target.value)}
          disabled={status === 'loading'}
        />
        <button
          type="submit"
          className="submit-btn"
          disabled={status === 'loading' || !question.trim()}
        >
          {status === 'loading' ? 'Asking…' : 'Ask'}
        </button>
      </form>

      <main className="content">
        {status === 'loading' && (
          <div className="state-panel loading">
            <div className="spinner" aria-hidden="true" />
            <p>Generating SQL and running your query…</p>
          </div>
        )}

        {status === 'error' && (
          <div className="state-panel error" role="alert">
            <p>{errorMessage}</p>
          </div>
        )}

        {status === 'success' && result && (
          <div className="result-panel">
            <div className="sql-block">
              <span className="sql-label">Generated SQL</span>
              <pre>
                <code>{result.sql}</code>
              </pre>
            </div>

            <div className="results-block">
              <span className="sql-label">
                Results {result.results.length > 0 && `(${result.results.length})`}
              </span>
              {result.results.length === 0 ? (
                <p className="empty-state">Query ran successfully but returned no rows.</p>
              ) : (
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        {columns.map((col) => (
                          <th key={col}>{col}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {result.results.map((row, i) => (
                        <tr key={i}>
                          {columns.map((col) => (
                            <td key={col}>{formatCell(row[col])}</td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        )}
      </main>
    </div>
  )
}

function formatCell(value: unknown): string {
  if (value === null || value === undefined) return '—'
  if (typeof value === 'object') return JSON.stringify(value)
  return String(value)
}

export default App
