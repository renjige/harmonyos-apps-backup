import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';
import { contentStore } from '../content/content.service';

@Controller('dashboard')
export class DashboardController {
  @Get('stats')
  stats() {
    return ok(contentStore.stats());
  }

  @Get('kpis')
  kpis() {
    const s = contentStore.stats();
    return ok({
      projectCount: s.projectCount,
      newsCount: s.newsCount,
      jobCount: s.jobCount,
      pendingMessages: s.pendingMessages,
      pageViewsWeek: s.pageViewsWeek,
    });
  }
}
