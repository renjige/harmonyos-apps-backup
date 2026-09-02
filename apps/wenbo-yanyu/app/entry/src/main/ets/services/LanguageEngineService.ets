import {
  IssueItem,
  PolishChange,
  PolishResult,
  SampleChip,
  StyleChip
} from '../models/LanguageCraftModels'

/**
 * 本机规则润色 / 摘要 / 待办抽取（不调用 /ai/chat）。
 * 按风格与场景做结构性重写，保证输出与原文可见不同。
 */
export class LanguageEngineService {
  static styleLabel(key: string): string {
    if (key === 'warm') {
      return '亲切'
    }
    if (key === 'brief') {
      return '简洁'
    }
    if (key === 'full') {
      return '详尽'
    }
    return '正式'
  }

  static sceneLabel(key: string): string {
    if (key === 'email') {
      return '邮件'
    }
    if (key === 'minutes') {
      return '纪要'
    }
    if (key === 'report') {
      return '汇报'
    }
    if (key === 'leave') {
      return '请假'
    }
    if (key === 'thanks') {
      return '感谢'
    }
    if (key === 'followup') {
      return '催办'
    }
    if (key === 'academic') {
      return '学术'
    }
    if (key === 'note') {
      return '札记'
    }
    return '通用'
  }

  static sceneChips(): StyleChip[] {
    return [
      StyleChip.of('general', '通用', '直接重写正文'),
      StyleChip.of('email', '邮件', '称呼 + 此致'),
      StyleChip.of('minutes', '纪要', '标题 + 推进说明'),
      StyleChip.of('report', '汇报', '汇报如下 + 请示'),
      StyleChip.of('leave', '请假', '事由 + 交接'),
      StyleChip.of('thanks', '感谢', '致谢 + 收尾'),
      StyleChip.of('followup', '催办', '事项 + 时限'),
      StyleChip.of('academic', '学术', '论点 + 论据'),
      StyleChip.of('note', '札记', '摘录 + 思考')
    ]
  }

  static oralSample(): string {
    return '那个就是想跟你说一下，然后这次方案其实挺急的，感觉你能不能帮忙看一下，尽快给个回复谢谢哈。'
  }

  static summarySample(): string {
    return '上周项目例会决定下周一提交评审材料。市场部负责竞品对照，产品部补交互说明。预算还没批，需要财务本周五前确认。客户希望增加夜间模式，产品认为可以排进下一迭代。综上先保证评审材料按时提交。'
  }

  static sampleChips(): SampleChip[] {
    return [
      SampleChip.of('oral', '口语催办', LanguageEngineService.oralSample()),
      SampleChip.of('meeting', '会议拖沓',
        '然后我们就是开了个会，那个进度其实挺慢的，感觉下周能不能赶紧把材料整一下，谢谢哈。'),
      SampleChip.of('thanks', '含糊致谢',
        '你看看这个稿子，有空的话帮忙改改，随便你，弄好了跟我说一声就行。'),
      SampleChip.of('leave', '口语请假',
        '我明天想请个假，家里有点事，你看行不行，工作我会跟同事交接一下。'),
      SampleChip.of('follow', '模糊催办',
        '那个材料你看得咋样了，我们这边挺急的，能不能今天给个回复谢谢哈。'),
      SampleChip.of('academic', '课程口语',
        '我觉得作者那个结论有点跳，样本量好像也不够，然后跟第三讲的理论是不是有点矛盾。'),
      SampleChip.of('research', '调研口语',
        '这次调研发现用户最在意的是响应速度，然后价格敏感度反而没那么高，对后续产品策略挺重要。'),
      SampleChip.of('handover', '交接口语',
        '我下周要出差，那个客户对接和周报你先帮忙看着，有问题找王姐，材料在共享盘。')
    ]
  }

  static rewriteLevel(original: string, polished: string, changeCount: number): string {
    const o = original.length
    const p = polished.length
    if (o === 0) {
      return '高'
    }
    const diff = Math.abs(p - o)
    const pct = Math.floor((diff * 100) / o)
    if (pct >= 35 || changeCount >= 3 || p >= o + 24) {
      return '高'
    }
    if (pct >= 12 || changeCount >= 2) {
      return '中'
    }
    return '低'
  }

  static polish(source: string, styleKey: string, sceneKey: string): PolishResult {
    const result = new PolishResult()
    result.original = source.trim()
    result.styleKey = styleKey
    result.styleLabel = LanguageEngineService.styleLabel(styleKey)
    result.sceneKey = sceneKey
    result.sceneLabel = LanguageEngineService.sceneLabel(sceneKey)
    if (result.original.length === 0) {
      result.polished = ''
      result.note = '请先输入要润色的文字'
      return result
    }
    const changes: PolishChange[] = []
    let text = LanguageEngineService.normalizeWhitespace(result.original)
    text = LanguageEngineService.replaceOral(text, changes)
    if (styleKey === 'warm') {
      text = LanguageEngineService.wrapWarm(text)
      changes.push(PolishChange.of('c-warm', '改为亲切结构：先同步事由，再礼貌收尾'))
    } else if (styleKey === 'brief') {
      text = LanguageEngineService.toBullets(text)
      changes.push(PolishChange.of('c-brief', '拆成可执行要点列表，去掉口头铺垫'))
    } else if (styleKey === 'full') {
      text = LanguageEngineService.wrapFull(text)
      changes.push(PolishChange.of('c-full', '补齐【核心意思】【补充说明】【下一步】三段'))
    } else {
      text = LanguageEngineService.wrapFormal(text)
      changes.push(PolishChange.of('c-formal', '改为书面结构：说明要点 + 请审阅'))
    }
    text = LanguageEngineService.applyScene(text, sceneKey, changes)
    text = LanguageEngineService.ensureEnding(text)
    if (text === result.original || text === `${result.original}。`) {
      text = LanguageEngineService.wrapFormal(LanguageEngineService.replaceOral(result.original, changes))
      text = LanguageEngineService.applyScene(text, sceneKey, changes)
      text = LanguageEngineService.ensureEnding(text)
    }
    result.polished = text
    result.changes = changes
    result.issues = LanguageEngineService.scanIssues(result.original)
    result.origLen = result.original.length
    result.polishedLen = text.length
    result.rewriteLevel = LanguageEngineService.rewriteLevel(result.original, text, changes.length)
    const issueHint = result.issues.length > 0 ? `；原文检出 ${result.issues.length} 处表达问题` : ''
    const diff = Math.abs(text.length - result.original.length)
    const diffPct = result.original.length > 0 ?
      Math.floor((diff * 100) / result.original.length) : 100
    const lenHint = `字数 ${result.origLen}→${result.polishedLen}（结构变化约 ${diffPct}%）`
    result.note = `改写幅度「${result.rewriteLevel}」· 已按「${result.styleLabel}」×「${result.sceneLabel}」结构性重写，${lenHint}，共 ${changes.length} 处调整${issueHint}`
    return result
  }

  static compareAll(source: string, sceneKey: string): PolishResult[] {
    const keys: string[] = ['formal', 'warm', 'brief', 'full']
    const out: PolishResult[] = []
    for (const key of keys) {
      out.push(LanguageEngineService.polish(source, key, sceneKey))
    }
    return out
  }

  static summarize(source: string, mode: string): string {
    const text = source.trim()
    if (text.length === 0) {
      return ''
    }
    if (mode === 'actions') {
      return LanguageEngineService.extractByKeywords(text,
        ['请', '需要', '负责', '截止', '待', '提交', '确认', '完成', '周五', '周一', '下周'],
        '待办')
    }
    if (mode === 'conclusions') {
      return LanguageEngineService.extractByKeywords(text,
        ['决定', '结论', '同意', '因此', '综上', '确认', '批准'],
        '结论')
    }
    const paragraphs = LanguageEngineService.splitParagraphs(text)
    if (mode === 'detail') {
      return LanguageEngineService.detailSummary(paragraphs)
    }
    return LanguageEngineService.briefSummary(paragraphs)
  }

  static modeLabel(mode: string): string {
    if (mode === 'detail') {
      return '详细要点'
    }
    if (mode === 'actions') {
      return '提取待办'
    }
    if (mode === 'conclusions') {
      return '提取结论'
    }
    return '精简摘要'
  }

  static scanIssues(source: string): IssueItem[] {
    const text = source.trim()
    const issues: IssueItem[] = []
    if (text.length === 0) {
      return issues
    }
    if (LanguageEngineService.hasAny(text, ['那个', '就是', '然后', '其实', '感觉', '挺', '谢谢哈', '谢谢啦'])) {
      issues.push(IssueItem.of('i-filler', '口语填充偏多', '「那个 / 就是 / 然后 / 其实」会削弱重点，建议改书面说法'))
    }
    if (LanguageEngineService.hasAny(text, ['能不能', '帮忙看一下', '你看看', '整一下', '弄好了'])) {
      issues.push(IssueItem.of('i-vague', '请求不够明确', '把「能不能帮忙看一下」改成对象 + 动作 + 时限'))
    }
    if (text.length > 40 && text.indexOf('。') < 0 && text.indexOf('！') < 0 && text.indexOf('？') < 0) {
      issues.push(IssueItem.of('i-punct', '缺少句读', '长句没有句号，读起来一口气说完，建议拆句'))
    }
    const longest = LanguageEngineService.longestSentence(text)
    if (longest > 48) {
      issues.push(IssueItem.of('i-long', '单句过长', `最长一句约 ${longest} 字，建议拆成两句`))
    }
    if (issues.length === 0) {
      issues.push(IssueItem.of('i-ok', '结构尚可', '仍可用风格重写，让开头、收尾和场景更完整'))
    }
    return issues
  }

  private static replaceOral(text: string, changes: PolishChange[]): string {
    let out = text
    const before = out
    out = out.replace(/帮忙看一下/g, '请协助审阅')
    out = out.replace(/看一下/g, '审阅')
    out = out.replace(/能不能/g, '是否可以')
    out = out.replace(/就是想跟你说一下/g, '现同步如下')
    out = out.replace(/想跟你说一下/g, '现同步如下')
    out = out.replace(/跟你说一下/g, '现同步如下')
    out = out.replace(/给个回复/g, '给予回复')
    out = out.replace(/谢谢哈/g, '谢谢')
    out = out.replace(/谢谢啦/g, '谢谢')
    out = out.replace(/谢谢哦/g, '谢谢')
    out = out.replace(/挺急的/g, '时间较紧')
    out = out.replace(/这次方案/g, '本次方案')
    out = out.replace(/你看看/g, '请你确认')
    out = out.replace(/有空的话/g, '方便时')
    out = out.replace(/帮忙改改/g, '协助修订')
    out = out.replace(/随便你/g, '请按你方便安排')
    out = out.replace(/弄好了跟我说一声就行/g, '完成后请告知即可')
    out = out.replace(/整一下/g, '处理')
    out = out.replace(/尽快/g, '尽快')
    out = out.replace(/跟我说一声/g, '告知我')
    out = out.replace(/跟我说/g, '告知我')
    out = out.replace(/吧/g, '')
    out = out.replace(/哈/g, '')
    out = out.replace(/啦/g, '')
    out = out.replace(/哦/g, '')
    out = out.replace(/嘛/g, '')
    out = out.replace(/呗/g, '')
    out = out.replace(/有点/g, '较为')
    out = out.replace(/大概/g, '约')
    out = out.replace(/可能/g, '或可')
    out = out.replace(/应该/g, '建议')
    out = out.replace(/好像/g, '似乎')
    out = out.replace(/这边/g, '我方')
    out = out.replace(/那边/g, '贵方')
    out = out.replace(/搞/g, '推进')
    out = out.replace(/弄/g, '处理')
    out = out.replace(/咋样/g, '进展如何')
    out = out.replace(/咋/g, '如何')
    out = out.replace(/请假/g, '申请请假')
    out = out.replace(/帮大忙/g, '提供重要帮助')
    out = out.replace(/请你吃饭/g, '当面致谢')
    out = out.replace(/那个/g, '')
    out = out.replace(/就是/g, '')
    out = out.replace(/然后/g, '随后')
    out = out.replace(/其实/g, '实际上')
    out = out.replace(/感觉/g, '认为')
    out = out.replace(/挺/g, '较为')
    out = out.replace(/，，/g, '，')
    out = out.replace(/,,/g, '，')
    out = out.replace(/  +/g, ' ')
    out = out.replace(/随后随后/g, '随后')
    out = out.trim()
    if (out !== before) {
      changes.push(PolishChange.of('c-oral', '清洗口语填充并改成可执行请求'))
    }
    return out
  }

  private static wrapFormal(text: string): string {
    const body = LanguageEngineService.stripWraps(text)
    const lead = body.length > 28 ? `${body.substring(0, 28)}…` : body
    return `【书面说明】${lead}\n现将相关事项正式说明如下：${body}\n以上请审阅，并请予以回复。`
  }

  private static wrapWarm(text: string): string {
    const body = LanguageEngineService.stripWraps(text)
    return `你好，想跟你同步一下：\n${body}\n辛苦你帮忙看看，有问题随时回我，谢谢！`
  }

  private static wrapFull(text: string): string {
    const body = LanguageEngineService.stripWraps(text)
    const first = LanguageEngineService.firstSentence(body)
    let rest = body
    if (first.length > 0 && body.indexOf(first) === 0) {
      rest = body.substring(first.length).trim()
    }
    if (rest.length === 0) {
      rest = '原文较短，已按书面语气补全请求与时限。'
    }
    return `【核心意思】${first}\n【补充说明】${rest}\n【下一步】请确认对象、时限与回复方式。`
  }

  private static toBullets(text: string): string {
    const body = LanguageEngineService.stripWraps(text)
    const parts = body.split(/[。！？；\n]/)
    const lines: string[] = []
    let idx = 1
    for (const part of parts) {
      const seg = part.trim()
      if (seg.length === 0) {
        continue
      }
      const short = seg.length > 42 ? `${seg.substring(0, 42)}…` : seg
      lines.push(`${idx}. ${short}`)
      idx += 1
      if (idx > 6) {
        break
      }
    }
    if (lines.length === 0) {
      return `1. ${body}`
    }
    return lines.join('\n')
  }

  private static applyScene(text: string, sceneKey: string, changes: PolishChange[]): string {
    if (sceneKey === 'email') {
      changes.push(PolishChange.of('c-email', '套用邮件成稿：称呼 + 正文 + 此致'))
      return `您好：\n\n${text}\n\n此致\n谢谢。`
    }
    if (sceneKey === 'minutes') {
      changes.push(PolishChange.of('c-minutes', '套用纪要成稿：标题 + 正文 + 推进说明'))
      return `【会议纪要】\n${text}\n请各位按节点推进，如有异议请当日反馈。`
    }
    if (sceneKey === 'report') {
      changes.push(PolishChange.of('c-report', '套用汇报成稿：汇报如下 + 请示'))
      return `汇报如下：\n${text}\n请指示是否批准及下一步安排。`
    }
    if (sceneKey === 'leave') {
      changes.push(PolishChange.of('c-leave', '套用请假申请：事由 + 交接 + 请批'))
      return `请假申请\n${text}\n以上安排如遇冲突请批复，谢谢。`
    }
    if (sceneKey === 'thanks') {
      changes.push(PolishChange.of('c-thanks', '套用感谢信：致谢 + 具体帮助 + 收尾'))
      return `感谢信\n${text}\n再次致谢，期待继续协作。`
    }
    if (sceneKey === 'followup') {
      changes.push(PolishChange.of('c-follow', '套用催办：事项 + 时限 + 请回复'))
      return `跟进事项\n${text}\n烦请于时限内回复确认，谢谢。`
    }
    if (sceneKey === 'academic') {
      changes.push(PolishChange.of('c-academic', '套用学术表达：论点 + 论据 + 讨论'))
      return `【讨论要点】\n${text}\n以上供课堂/组会讨论参考。`
    }
    if (sceneKey === 'note') {
      changes.push(PolishChange.of('c-note', '套用阅读札记：摘录 + 思考'))
      return `【阅读札记】\n${text}\n—— 可继续关联研究笔记与专题。`
    }
    return text
  }

  private static stripWraps(text: string): string {
    let out = text
    out = out.replace(/^【书面说明】[^\n]*\n现将相关事项正式说明如下：/, '')
    out = out.replace(/\n以上请审阅，并请予以回复。?$/, '')
    out = out.replace(/^现将要点说明如下：/, '')
    out = out.replace(/以上请审阅。?$/, '')
    out = out.replace(/^你好，想跟你同步一下：\n/, '')
    out = out.replace(/^跟你同步一件事：/, '')
    out = out.replace(/\n辛苦你帮忙看看，有问题随时回我，谢谢！?$/, '')
    out = out.replace(/谢谢，有问题随时回我。?$/, '')
    out = out.replace(/^您好：\n\n/, '')
    out = out.replace(/\n\n此致\n谢谢。?$/, '')
    out = out.replace(/^【会议纪要】\n/, '')
    out = out.replace(/\n请各位按节点推进，如有异议请当日反馈。?$/, '')
    out = out.replace(/^汇报如下：\n/, '')
    out = out.replace(/\n请指示是否批准及下一步安排。?$/, '')
    return out.trim()
  }

  private static normalizeWhitespace(text: string): string {
    let out = text.replace(/\r\n/g, '\n')
    out = out.replace(/[ \t]+/g, ' ')
    out = out.replace(/\n{3,}/g, '\n\n')
    return out.trim()
  }

  private static ensureEnding(text: string): string {
    if (text.length === 0) {
      return text
    }
    const last = text.charAt(text.length - 1)
    if (last === '。' || last === '！' || last === '？' || last === '…' || last === '.') {
      return text
    }
    return `${text}。`
  }

  private static hasAny(text: string, words: string[]): boolean {
    for (const w of words) {
      if (text.indexOf(w) >= 0) {
        return true
      }
    }
    return false
  }

  private static longestSentence(text: string): number {
    const parts = text.split(/[。！？\n]/)
    let maxLen = 0
    for (const p of parts) {
      if (p.length > maxLen) {
        maxLen = p.length
      }
    }
    return maxLen
  }

  private static splitParagraphs(text: string): string[] {
    const raw = text.split(/\n+/)
    const out: string[] = []
    for (const block of raw) {
      const seg = block.trim()
      if (seg.length > 0) {
        out.push(seg)
      }
    }
    if (out.length === 0) {
      out.push(text)
    }
    return out
  }

  private static briefSummary(paragraphs: string[]): string {
    const lines: string[] = []
    let total = 0
    for (const p of paragraphs) {
      const first = LanguageEngineService.firstSentence(p)
      if (first.length === 0) {
        continue
      }
      lines.push(first)
      total += first.length
      if (total >= 160 || lines.length >= 4) {
        break
      }
    }
    return lines.join('\n')
  }

  private static detailSummary(paragraphs: string[]): string {
    const lines: string[] = []
    let idx = 1
    for (const p of paragraphs) {
      const point = LanguageEngineService.keyPoint(p)
      if (point.length === 0) {
        continue
      }
      lines.push(`${idx}. ${point}`)
      idx += 1
      if (idx > 8) {
        break
      }
    }
    return lines.join('\n')
  }

  private static extractByKeywords(text: string, words: string[], title: string): string {
    const parts = text.split(/[。！？；\n]/)
    const lines: string[] = []
    let idx = 1
    for (const part of parts) {
      const seg = part.trim()
      if (seg.length === 0) {
        continue
      }
      if (!LanguageEngineService.hasAny(seg, words)) {
        continue
      }
      lines.push(`${idx}. ${seg}`)
      idx += 1
      if (idx > 8) {
        break
      }
    }
    if (lines.length === 0) {
      return `未从原文抽出明确${title}。可先用「详细要点」，或改用带「请 / 需要 / 决定」的句子。`
    }
    return `【${title}】\n${lines.join('\n')}`
  }

  private static firstSentence(paragraph: string): string {
    const m = paragraph.match(/^[^。！？]+[。！？]?/)
    if (m !== null && m[0] !== undefined) {
      return m[0].trim()
    }
    return paragraph.length > 72 ? `${paragraph.substring(0, 72)}…` : paragraph
  }

  private static keyPoint(paragraph: string): string {
    const first = LanguageEngineService.firstSentence(paragraph)
    if (first.length <= 96) {
      return first
    }
    return `${first.substring(0, 96)}…`
  }
}
