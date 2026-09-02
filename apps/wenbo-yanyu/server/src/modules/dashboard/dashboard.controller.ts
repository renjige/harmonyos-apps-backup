import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';

@Controller('dashboard')
export class DashboardController {
  @Get('kpis')
  kpis() {
    return ok({
      inspectionCountWeek: 28,
      openIssues: 6,
      overdueIssues: 1,
      closeRate: 0.86,
      trend: [12, 18, 15, 22, 19],
    });
  }
}
