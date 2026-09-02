export class UseScenario {
  id: string = ''
  title: string = ''
  desc: string = ''
  action: string = ''

  static all(): UseScenario[] {
    const list: UseScenario[] = []
    list.push(UseScenario.make('sc_read', '通勤读一篇',
      '打开知识文库，选生活百科或科普类短文，无需先记笔记即可阅读。',
      'catalog'))
    list.push(UseScenario.make('sc_daily', '每日学习打卡',
      '阅读每日一知并完成三问，自动生成可复习的结构化笔记。',
      'daily'))
    list.push(UseScenario.make('sc_review', '间隔复习巩固',
      '对「待学习」条目抽卡回忆，按记得/模糊/忘了安排下次复习。',
      'review'))
    list.push(UseScenario.make('sc_template', '技巧沉淀模板',
      '用技巧卡/摘录卡/百科卡模板记录，比空白备忘录更易整理检索。',
      'template'))
    list.push(UseScenario.make('sc_inbox', '消化跟进闭环',
      '在消化处理台把条目从待消化推进到跟进中，再标为已消化。',
      'inbox'))
    list.push(UseScenario.make('sc_weekly', '周度成长回顾',
      '查看近七日分类分布、本周回顾与成就，复盘学习节奏。',
      'weekly'))
    return list
  }

  private static make(id: string, title: string, desc: string, action: string): UseScenario {
    const row = new UseScenario()
    row.id = id
    row.title = title
    row.desc = desc
    row.action = action
    return row
  }
}
