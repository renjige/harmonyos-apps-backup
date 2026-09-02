export class ComposeTemplate {
  id: string = ''
  label: string = ''
  category: string = 'life_wiki'
  titleHint: string = ''
  bodySkeleton: string = ''

  static all(): ComposeTemplate[] {
    const list: ComposeTemplate[] = []
    list.push(ComposeTemplate.make('tpl_tip', '技巧卡', 'work_tip',
      '例如：会议开场白',
      '【情景】\n\n【步骤】\n1. \n2. \n\n【注意】\n'))
    list.push(ComposeTemplate.make('tpl_quote', '摘录卡', 'growth',
      '例如：书中一段启发',
      '【原文】\n\n【出处】\n\n【我的理解】\n'))
    list.push(ComposeTemplate.make('tpl_wiki', '百科卡', 'science',
      '例如：一个生活现象',
      '【是什么】\n\n【为什么】\n\n【例子】\n'))
    list.push(ComposeTemplate.make('tpl_reflect', '复盘卡', 'growth',
      '例如：本周收获',
      '【发生了什么】\n\n【我学到了什么】\n\n【下次怎么做】\n'))
    return list
  }

  private static make(id: string, label: string, category: string, titleHint: string, body: string): ComposeTemplate {
    const row = new ComposeTemplate()
    row.id = id
    row.label = label
    row.category = category
    row.titleHint = titleHint
    row.bodySkeleton = body
    return row
  }
}
