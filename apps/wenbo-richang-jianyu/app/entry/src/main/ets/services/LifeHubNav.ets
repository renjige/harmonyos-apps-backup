import { JournalDetailNav } from './JournalDetailNav'
import { LifeToolEntry } from '../models/LifeHubModels'

/** 生活工具箱 Overlay 路由 */
export class LifeHubNav {
  static open(kind: string, fromMenu: boolean = false): void {
    AppStorage.setOrCreate('lifeHubFromMenu', fromMenu)
    AppStorage.setOrCreate('lifeHubRoute', kind)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('lifeHubRoute', '')
    AppStorage.setOrCreate('lifeHubFromMenu', false)
    if (!JournalDetailNav.isOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static backOrClose(): void {
    const fromMenu = AppStorage.get<boolean>('lifeHubFromMenu') === true
    if (fromMenu) {
      AppStorage.setOrCreate('lifeHubFromMenu', false)
      AppStorage.setOrCreate('lifeHubRoute', 'menu')
      return
    }
    LifeHubNav.close()
  }

  static current(): string {
    const v = AppStorage.get<string>('lifeHubRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return LifeHubNav.current().length > 0
  }

  static tools(): LifeToolEntry[] {
    return [
      new LifeToolEntry('plans', '生活计划', '周期目标与任务进度', 'biz'),
      new LifeToolEntry('achievements', '成就墙', '由真实记录点亮徽章', 'ai'),
      new LifeToolEntry('activity', '生活动态', '把日子串成时间轴', 'calendar'),
      new LifeToolEntry('topics', '生活专题', '按标签收成主题', 'book'),
      new LifeToolEntry('search', '全文检索', '笺语待办计划一搜即达', 'search'),
      new LifeToolEntry('mood', '每日心情', '记录心情与备注', 'heart'),
      new LifeToolEntry('reminders', '日常提醒', '时间与分类提醒', 'alert'),
      new LifeToolEntry('todos', '待办清单', '生活 / 工作 / 学习', 'check'),
      new LifeToolEntry('calendar', '生活日历', '按日回看与补记', 'calendar'),
      new LifeToolEntry('tags', '生活标签', '自定义并筛选记录', 'book'),
      new LifeToolEntry('habits', '每日打卡', '习惯与连续天数', 'check'),
      new LifeToolEntry('photos', '照片时光册', '按日期整理照片', 'photo'),
      new LifeToolEntry('goals', '生活目标', '进度与完成情况', 'biz'),
      new LifeToolEntry('stats', '数据回顾', '月度总结与趋势', 'chart')
    ]
  }
}
