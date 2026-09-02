/** 研语 · 语言表达工坊数据模型 */

export class InspirationWire {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  example: string = ''
  coverMedia: string = ''
  coverKey: string = ''
}

export class InspirationListPayload {
  list: InspirationWire[] = []
}

export class InspirationItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  example: string = ''
  coverKey: string = ''

  static fromWire(w: InspirationWire): InspirationItem {
    const item = new InspirationItem()
    item.id = w.id
    item.title = w.title
    item.category = w.category
    item.summary = w.summary.length > 0 ? w.summary : w.description
    item.body = w.body.length > 0 ? w.body : w.description
    item.example = w.example
    const cover = w.coverMedia.length > 0 ? w.coverMedia : w.coverKey
    item.coverKey = cover.length > 0 ? cover : 'cover_daily'
    return item
  }
}

export class PolishRecord {
  id: string = ''
  sourceText: string = ''
  resultText: string = ''
  styleKey: string = ''
  styleLabel: string = ''
  createdAt: string = ''
}

export class SummaryRecord {
  id: string = ''
  sourceText: string = ''
  resultText: string = ''
  mode: string = ''
  modeLabel: string = ''
  createdAt: string = ''
}

export class FavoriteSnapshot {
  inspirationId: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  coverKey: string = ''
  favoritedAt: string = ''
}

export class LocalStats {
  polishCount: number = 0
  summaryCount: number = 0
  favoriteCount: number = 0
}

export class StyleChip {
  key: string = ''
  label: string = ''
  hint: string = ''

  static of(key: string, label: string, hint: string = ''): StyleChip {
    const s = new StyleChip()
    s.key = key
    s.label = label
    s.hint = hint
    return s
  }
}

export class StyleGuideItem {
  key: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  sample: string = ''

  static of(key: string, title: string, summary: string, body: string, coverKey: string, sample: string): StyleGuideItem {
    const row = new StyleGuideItem()
    row.key = key
    row.title = title
    row.summary = summary
    row.body = body
    row.coverKey = coverKey
    row.sample = sample
    return row
  }

  static oral(): string {
    return '那个就是想跟你说一下，然后这次方案其实挺急的，感觉你能不能帮忙看一下，尽快给个回复谢谢哈。'
  }

  static all(): StyleGuideItem[] {
    const sample = StyleGuideItem.oral()
    return [
      StyleGuideItem.of('formal', '正式', '书面说明 + 请审阅',
        '适合对上级、跨部门或对外发文。会去掉口语填充，加上「现将要点说明如下」和收尾「以上请审阅」，让对方能直接转发。',
        'cover_workplace', sample),
      StyleGuideItem.of('warm', '亲切', '同步语气 + 礼貌收尾',
        '适合熟悉的同事。保留温度，但仍写清请求和时限，避免「你看看」「随便你」这种含糊说法。',
        'cover_cafe', sample),
      StyleGuideItem.of('brief', '简洁', '要点列表，去掉铺垫',
        '适合催办和纪要。把一段话拆成 1. 2. 3. 可执行条目，方便对方逐条回复。',
        'cover_meeting', sample),
      StyleGuideItem.of('full', '详尽', '核心 / 补充 / 下一步',
        '适合汇报。补齐【核心意思】【补充说明】【下一步】，避免只丢一句结论让对方猜背景。',
        'cover_library', sample)
    ]
  }

  static find(key: string): StyleGuideItem {
    const list = StyleGuideItem.all()
    for (const row of list) {
      if (row.key === key) {
        return row
      }
    }
    return StyleGuideItem.of('formal', '正式', '书面说明 + 请审阅',
      '适合对上级、跨部门或对外发文。', 'cover_workplace', StyleGuideItem.oral())
  }
}

export class CategoryChip {
  key: string = ''
  label: string = ''

  static of(key: string, label: string): CategoryChip {
    const c = new CategoryChip()
    c.key = key
    c.label = label
    return c
  }
}

export class PolishChange {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): PolishChange {
    const row = new PolishChange()
    row.id = id
    row.label = label
    return row
  }
}

export class IssueItem {
  id: string = ''
  title: string = ''
  hint: string = ''

  static of(id: string, title: string, hint: string): IssueItem {
    const row = new IssueItem()
    row.id = id
    row.title = title
    row.hint = hint
    return row
  }
}

export class SampleChip {
  key: string = ''
  label: string = ''
  text: string = ''

  static of(key: string, label: string, text: string): SampleChip {
    const row = new SampleChip()
    row.key = key
    row.label = label
    row.text = text
    return row
  }
}

/** 创作场景：润色 / 成稿 / 样例一体化入口 */
export class WritingScenario {
  key: string = ''
  title: string = ''
  hint: string = ''
  category: string = 'work'
  draftKey: string = ''
  sceneKey: string = ''
  sampleText: string = ''

  static of(key: string, title: string, hint: string, category: string, draftKey: string,
    sceneKey: string, sampleText: string): WritingScenario {
    const row = new WritingScenario()
    row.key = key
    row.title = title
    row.hint = hint
    row.category = category
    row.draftKey = draftKey
    row.sceneKey = sceneKey
    row.sampleText = sampleText
    return row
  }
}

export class ScenarioCategory {
  key: string = ''
  label: string = ''

  static of(key: string, label: string): ScenarioCategory {
    const row = new ScenarioCategory()
    row.key = key
    row.label = label
    return row
  }
}

/** 一键创作工作流：样例 → 润色 → 可选四风格对照 */
export class WritingWorkflow {
  key: string = ''
  title: string = ''
  hint: string = ''
  sampleText: string = ''
  sceneKey: string = 'general'
  styleKey: string = 'formal'

  static of(key: string, title: string, hint: string, sampleText: string, sceneKey: string,
    styleKey: string): WritingWorkflow {
    const row = new WritingWorkflow()
    row.key = key
    row.title = title
    row.hint = hint
    row.sampleText = sampleText
    row.sceneKey = sceneKey
    row.styleKey = styleKey
    return row
  }
}

/** 使用指南条目 — 面向审核与新手的一键体验路径 */
export class UseCaseGuideItem {
  key: string = ''
  category: string = ''
  title: string = ''
  summary: string = ''
  stepOne: string = ''
  stepTwo: string = ''
  stepThree: string = ''
  actionKind: string = 'workflow'
  actionKey: string = ''

  static of(key: string, category: string, title: string, summary: string,
    stepOne: string, stepTwo: string, stepThree: string,
    actionKind: string, actionKey: string): UseCaseGuideItem {
    const row = new UseCaseGuideItem()
    row.key = key
    row.category = category
    row.title = title
    row.summary = summary
    row.stepOne = stepOne
    row.stepTwo = stepTwo
    row.stepThree = stepThree
    row.actionKind = actionKind
    row.actionKey = actionKey
    return row
  }
}

export class DraftTemplate {
  key: string = ''
  title: string = ''
  fieldA: string = ''
  fieldB: string = ''
  fieldC: string = ''

  static of(key: string, title: string, fieldA: string, fieldB: string, fieldC: string): DraftTemplate {
    const row = new DraftTemplate()
    row.key = key
    row.title = title
    row.fieldA = fieldA
    row.fieldB = fieldB
    row.fieldC = fieldC
    return row
  }
}

export class PolishResult {
  original: string = ''
  polished: string = ''
  styleKey: string = ''
  styleLabel: string = ''
  sceneKey: string = ''
  sceneLabel: string = ''
  note: string = ''
  origLen: number = 0
  polishedLen: number = 0
  rewriteLevel: string = ''
  changes: PolishChange[] = []
  issues: IssueItem[] = []
}
