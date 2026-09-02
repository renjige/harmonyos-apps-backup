import { GrowthRecordItem } from './GrowthModels'

export class StuckKindItem {
  id: string = ''
  title: string = ''
  summary: string = ''
}

export class StuckWorkshop {
  static kinds(): StuckKindItem[] {
    const list: StuckKindItem[] = []
    list.push(StuckWorkshop.of('delay', '拖延开始', '事情在脑子里转，就是没动手'))
    list.push(StuckWorkshop.of('too_big', '目标太大', '想一次做完，结果哪步都不迈'))
    list.push(StuckWorkshop.of('no_feedback', '看不见进度', '做了却感觉白做，缺少反馈'))
    list.push(StuckWorkshop.of('low_energy', '精力不够', '不是不想，是今天提不起劲'))
    return list
  }

  static of(id: string, title: string, summary: string): StuckKindItem {
    const item = new StuckKindItem()
    item.id = id
    item.title = title
    item.summary = summary
    return item
  }

  static question1(kind: string): string[] {
    const list: string[] = []
    if (kind === 'delay') {
      list.push('怕做不好')
      list.push('不知从哪下手')
      list.push('总被别的事打断')
    } else if (kind === 'too_big') {
      list.push('范围还没裁剪')
      list.push('标准定得太高')
      list.push('步骤没有拆开')
    } else if (kind === 'no_feedback') {
      list.push('没有可勾选的结果')
      list.push('没人看到')
      list.push('自己也不记进度')
    } else {
      list.push('睡眠或身体在报警')
      list.push('事情太多在切换')
      list.push('情绪在占带宽')
    }
    return list
  }

  static question2(kind: string): string[] {
    const list: string[] = []
    if (kind === 'delay') {
      list.push('打开文档写第一句')
      list.push('只整理材料 10 分钟')
      list.push('把下一步写在纸上')
    } else if (kind === 'too_big') {
      list.push('切出今天能完成的一小块')
      list.push('把完成标准写成一句话')
      list.push('删掉本周不必做的两项')
    } else if (kind === 'no_feedback') {
      list.push('给当前目标加一个可勾步骤')
      list.push('写一条 3 行的进展记录')
      list.push('把进度从现在再推 10%')
    } else {
      list.push('只做一件 10 分钟的小事')
      list.push('先完成今日仪式再行动')
      list.push('把目标暂停，改成休息步骤')
    }
    return list
  }

  static question3(): string[] {
    const list: string[] = []
    list.push('今晚收工前')
    list.push('明天上午')
    list.push('本周末之前')
    return list
  }

  static stepOf(kind: string, a1: string, a2: string, a3: string): string {
    return `解卡 · ${a3}：${a2}（卡点：${a1}）`
  }

  static kindTitle(kind: string): string {
    if (kind === 'delay') {
      return '拖延开始'
    }
    if (kind === 'too_big') {
      return '目标太大'
    }
    if (kind === 'no_feedback') {
      return '看不见进度'
    }
    return '精力不够'
  }
}

export class MonthThemeUtil {
  static monthKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const mm = m < 10 ? `0${m}` : `${m}`
    return `${d.getFullYear()}-${mm}`
  }

  static themeTitle(): string {
    return `月度主题 · ${MonthThemeUtil.monthKey()}`
  }

  static reportTitle(): string {
    return `月报 · ${MonthThemeUtil.monthKey()}`
  }

  static options(): string[] {
    const list: string[] = []
    list.push('学习')
    list.push('健康')
    list.push('作品')
    list.push('关系')
    return list
  }

  static findTheme(records: GrowthRecordItem[]): string {
    const prefix = MonthThemeUtil.themeTitle()
    for (const r of records) {
      if (r.title === prefix) {
        if (r.category.length > 0) {
          return r.category
        }
        if (r.summary.length > 0) {
          return r.summary
        }
      }
    }
    return ''
  }
}
