import { BadRequestException, Inject, Injectable } from '@nestjs/common';
import { Pool } from 'pg';

const SCHEMA_CONTEXT = `
Table: customers
Columns: id (integer, primary key), name (text), email (text), created_at (timestamp)

Table: products
Columns: id (integer, primary key), name (text), category (text), price (numeric), stock_quantity (integer)

Table: orders
Columns: id (integer, primary key), customer_id (integer, foreign key -> customers.id), order_date (date), status (text: 'pending', 'shipped', 'delivered', or 'cancelled')

Table: order_items
Columns: id (integer, primary key), order_id (integer, foreign key -> orders.id), product_id (integer, foreign key -> products.id), quantity (integer), unit_price (numeric)
`;

@Injectable()
export class QueryService {
  constructor(@Inject('PG_POOL') private pool: Pool) {}

  async generateSql(question: string): Promise<string> {
    const prompt = `You are a SQL expert. Given the following database schema:

                        ${SCHEMA_CONTEXT}

                        Write a single PostgreSQL SELECT statement that answers this question: "${question}"

                        Rules:
                        - Return ONLY the raw SQL query, nothing else
                        - No explanations, no markdown code fences, no semicolon at the end
                        - Only use the tables and columns described in the schema above
                        - If the question cannot be answered with the given schema, return exactly: UNSUPPORTED`;

    const response = await fetch(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${process.env.GROQ_API_KEY}`,
        },
        body: JSON.stringify({
          model: 'openai/gpt-oss-120b',
          messages: [{ role: 'user', content: prompt }],
        }),
      },
    );

    const data = await response.json();
    console.log('data :', data);
    const sql = data.choices[0].message.content;
    return sql.trim();
  }

  validateSql(sql: string): boolean {
    const trimmed = sql.trim();
    const hasDrop = /\bDROP\b/i.test(trimmed);
    const hasDelete = /\bDELETE\b/i.test(trimmed);
    const hasInsert = /\bINSERT\b/i.test(trimmed);
    const hasUpdate = /\bUPDATE\b/i.test(trimmed);
    const hasTruncate = /\bTRUNCATE\b/i.test(trimmed);
    const hasAlter = /\bALTER\b/i.test(trimmed);

    if (!trimmed.toUpperCase().startsWith('SELECT')) return false;

    if (
      hasDrop ||
      hasDelete ||
      hasInsert ||
      hasUpdate ||
      hasTruncate ||
      hasAlter
    )
      return false;

    if (trimmed.includes(';')) return false;
    return true;
  }

  async askQuestion(question: string) {
    const genQuery = await this.generateSql(question);

    if (genQuery === 'UNSUPPORTED') {
      throw new BadRequestException(
        'This question cannot be answered with the available data.',
      );
    }

    const isValid = this.validateSql(genQuery);

    if (!isValid) {
      throw new BadRequestException(
        'Generated query failed safety validation.',
      );
    }

    const result = await this.pool.query(genQuery);

    return { sql: genQuery, results: [...result.rows] };
  }
}
