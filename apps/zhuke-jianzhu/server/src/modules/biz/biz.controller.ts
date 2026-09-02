import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';
import { contentStore } from '../content/content.service';

/** 业务别名路由 — 与 Content 模块数据一致 */
@Controller('biz')
export class BizController {
  @Get('projects')
  projects() {
    return ok({ list: contentStore.projects, total: contentStore.projects.length });
  }

  @Get('news')
  news() {
    return ok({ list: contentStore.news, total: contentStore.news.length });
  }

  @Get('jobs')
  jobs() {
    return ok({ list: contentStore.jobs, total: contentStore.jobs.length });
  }
}
