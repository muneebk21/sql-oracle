import { Body, Controller, Post } from '@nestjs/common';
import { QueryService } from './query.service';

@Controller('query')
export class QueryController {
  constructor(private readonly queryService: QueryService) {}

  @Post('test-sql')
  async testSql(@Body('question') question: string) {
    return this.queryService.askQuestion(question);
  }
}
