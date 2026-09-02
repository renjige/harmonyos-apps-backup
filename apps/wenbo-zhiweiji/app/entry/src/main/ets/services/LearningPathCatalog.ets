export class PathStep {
  id: string = ''
  title: string = ''
  hint: string = ''
  action: string = ''
  ref: string = ''
}

export class LearningPath {
  id: string = ''
  title: string = ''
  summary: string = ''
  steps: PathStep[] = []
}

export class LearningPathCatalog {
  static all(): LearningPath[] {
    const list: LearningPath[] = []
    list.push(LearningPathCatalog.makePath('path_start', '7天微知识入门',
      '从零开始：读一篇、打卡、用模板记笔记、复习巩固、消化跟进、周度回顾。',
      LearningPathCatalog.stepsStart()))
    list.push(LearningPathCatalog.makePath('path_work', '职场效率路径',
      '会议纪要、反馈技巧、邮件结论先行、清单情境化、复盘卡沉淀工作方法。',
      LearningPathCatalog.stepsWork()))
    list.push(LearningPathCatalog.makePath('path_life', '生活百科路径',
      '厨房安全、急救常识、睡眠习惯、泡茶水温、博物馆参观，把生活经验收成可检索知识。',
      LearningPathCatalog.stepsLife()))
    return list
  }

  static findById(id: string): LearningPath | null {
    for (const p of LearningPathCatalog.all()) {
      if (p.id === id) {
        return p
      }
    }
    return null
  }

  private static makePath(id: string, title: string, summary: string, steps: PathStep[]): LearningPath {
    const p = new LearningPath()
    p.id = id
    p.title = title
    p.summary = summary
    p.steps = steps
    return p
  }

  private static step(id: string, title: string, hint: string, action: string, ref: string): PathStep {
    const s = new PathStep()
    s.id = id
    s.title = title
    s.hint = hint
    s.action = action
    s.ref = ref
    return s
  }

  private static stepsStart(): PathStep[] {
    const list: PathStep[] = []
    list.push(LearningPathCatalog.step('ps1', '阅读一篇文库短文', '打开知识文库，任选一篇读完。', 'daily', 'dk02'))
    list.push(LearningPathCatalog.step('ps2', '每日一知打卡', '阅读今日推荐并完成三问。', 'daily_today', ''))
    list.push(LearningPathCatalog.step('ps3', '用模板记一条', '选「摘录卡」写下今天的一个收获。', 'template', 'tpl_quote'))
    list.push(LearningPathCatalog.step('ps4', '完成一次间隔复习', '进入复习抽卡，翻面并选择记忆程度。', 'review', ''))
    list.push(LearningPathCatalog.step('ps5', '推进消化状态', '在处理台把一条笔记标为跟进中或已消化。', 'inbox', ''))
    list.push(LearningPathCatalog.step('ps6', '查看周度成长', '打开周度洞察，看分类分布与摘要。', 'weekly', ''))
    return list
  }

  private static stepsWork(): PathStep[] {
    const list: PathStep[] = []
    list.push(LearningPathCatalog.step('pw1', '读：会议纪要三句话', '文库 dk04', 'daily', 'dk04'))
    list.push(LearningPathCatalog.step('pw2', '读：反馈要具体到行为', '文库 dk10', 'daily', 'dk10'))
    list.push(LearningPathCatalog.step('pw3', '读：邮件先写结论', '文库 dk17', 'daily', 'dk17'))
    list.push(LearningPathCatalog.step('pw4', '用技巧卡记录', '把一条工作心得写成技巧卡。', 'template', 'tpl_tip'))
    list.push(LearningPathCatalog.step('pw5', '标为常用技巧', '保存后在详情改学习标签。', 'catalog', ''))
    return list
  }

  private static stepsLife(): PathStep[] {
    const list: PathStep[] = []
    list.push(LearningPathCatalog.step('pl1', '读：厨房油锅安全', '文库 dk03', 'daily', 'dk03'))
    list.push(LearningPathCatalog.step('pl2', '读：遗忘曲线与复习', '文库 dk20', 'daily', 'dk20'))
    list.push(LearningPathCatalog.step('pl3', '读：泡茶水温', '文库 dk27', 'daily', 'dk27'))
    list.push(LearningPathCatalog.step('pl4', '用百科卡记录', '把一条生活发现写成百科卡。', 'template', 'tpl_wiki'))
    list.push(LearningPathCatalog.step('pl5', '加入复习队列', '在详情点「加入复习队列」。', 'review', ''))
    return list
  }
}
