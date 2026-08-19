import { Module } from '@nestjs/common';
import { QueryService } from './query.service';
import { QueryController } from './query.controller';

// TODO: This module will own the end-to-end text-to-SQL pipeline:
//   natural language question -> generated SQL -> validated/sandboxed
//   execution -> results. It will eventually import a database
//   connection provider (pg Pool) and a config module for DATABASE_URL
//   and GROQ_API_KEY.
@Module({
  providers: [QueryService],
  controllers: [QueryController],
})
export class QueryModule {}
