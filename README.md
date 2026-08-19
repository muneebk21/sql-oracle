# SQL Oracle

Ask a question in plain English, get back a SQL query and the results. SQL Oracle turns a natural-language question into a validated PostgreSQL `SELECT` statement, runs it against a Postgres database, and returns both the generated SQL and the query results.

This is a learning project — a hands-on exploration of the text-to-SQL pipeline: prompt construction, LLM-based SQL generation, safety validation, and execution.

## How it works

1. The frontend sends a natural-language question to the backend.
2. The backend builds a prompt containing the database schema and the question, and sends it to an LLM (via [Groq](https://groq.com/)'s OpenAI-compatible API) to generate a SQL query.
3. The generated SQL is validated — it must be a single `SELECT` statement with no destructive keywords (`DROP`, `DELETE`, `INSERT`, `UPDATE`, `TRUNCATE`, `ALTER`) and no statement chaining.
4. If valid, the query is executed against Postgres and the results are returned alongside the generated SQL.

## Stack

- **Backend** — [NestJS](https://nestjs.com/) + TypeScript (strict mode), [`pg`](https://node-postgres.com/) for Postgres access, Groq for LLM-based SQL generation.
- **Frontend** — [React](https://react.dev/) + TypeScript, built with [Vite](https://vitejs.dev/).
- **Database** — PostgreSQL 16, run via Docker Compose.

## Project structure

```
sql-oracle/
├── Backend/          # NestJS API
│   ├── src/
│   │   ├── database/  # Postgres connection pool (PG_POOL provider)
│   │   ├── query/      # Prompt construction, SQL generation, validation, execution
│   │   └── app.*       # Nest app bootstrap
│   ├── schema.sql       # Sample e-commerce dataset (customers, products, orders, order_items)
│   └── docker-compose.yml
└── Frontend/          # React + Vite UI
    └── src/App.tsx
```

## Getting started

### Prerequisites

- Node.js and npm
- Docker (for Postgres)
- A [Groq API key](https://console.groq.com/keys)

### 1. Start the database

```bash
cd Backend
docker compose up -d
```

### 2. Configure environment variables

Copy `.env.example` to `.env` in `Backend/` and fill in your Groq API key:

```bash
cp .env.example .env
```

### 3. Load the sample schema

Load `Backend/schema.sql` into the running Postgres instance to create the sample dataset (customers, products, orders, order_items).

### 4. Run the backend

```bash
cd Backend
npm install
npm run start:dev
```

The API starts on `http://localhost:3000` and exposes `POST /query/test-sql` with a JSON body `{ "question": "..." }`.

### 5. Run the frontend

```bash
cd Frontend
npm install
npm run dev
```

Open the printed local URL and start asking questions.

## Status

Actively evolving as a learning project — expect the prompt construction, validation rules, and error handling to change as the underlying concepts are explored further.
