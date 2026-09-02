import { UseCaseGuideItem } from '../models/LanguageCraftModels'
import { LanguageCraftNav } from './LanguageCraftNav'
import { LanguageScenarioService } from './LanguageScenarioService'
import { LanguageWorkflowService } from './LanguageWorkflowService'
import { ResearchNav } from './ResearchNav'

/** 使用指南 — 15 条可点即用的真实写作场景路径 */
export class LanguageUseCaseService {
  static categories(): string[] {
    return ['全部', '职场', '学术', '研究', '综合']
  }

  static all(): UseCaseGuideItem[] {
    return [
      UseCaseGuideItem.of('uc_email', '职场', '口语改正式工作邮件',
        '对外沟通时把口头请求改成可发送的邮件成稿。',
        '点「一键体验」载入口语样例', '查看润色结果与四风格对照', '复制或存入稿本库',
        'workflow', 'wf_email'),
      UseCaseGuideItem.of('uc_minutes', '职场', '会议口水话整理成纪要',
        '会后把零散记录整理为带结论与待办的纪要。',
        '载入会议口语样例', '自动套用「纪要」场景润色', '按需切换简洁/详尽风格',
        'workflow', 'wf_minutes'),
      UseCaseGuideItem.of('uc_report', '职场', '进展汇报 / 周报',
        '向上级同步项目进度并明确请示事项。',
        '打开「进展汇报」成稿模板', '填写事项/进展/请示三栏', '生成草稿后送到润色台',
        'draft', 'report'),
      UseCaseGuideItem.of('uc_follow', '职场', '催办与跟进',
        '把模糊催促改成带时限的书面请求。',
        '一键载入催办口语样例', '查看「催办」场景成稿', '四风格对照选语气',
        'workflow', 'wf_follow'),
      UseCaseGuideItem.of('uc_leave', '职场', '请假申请',
        '事由、时段、交接一次写全。',
        '打开「请假申请」场景', '可先用样例体验润色', '或进成稿模板填空',
        'scenario', 'leave_request'),
      UseCaseGuideItem.of('uc_academic', '学术', '课程讨论书面化',
        '把课堂口语观点整理成可提交的讨论稿。',
        '载入课程讨论口语样例', '场景选「学术」+ 风格「正式」', '复制结果用于作业/讨论区',
        'workflow', 'wf_academic'),
      UseCaseGuideItem.of('uc_thesis', '学术', '论文 / 开题提纲',
        '问题、章节结构、研究方法三段式生成。',
        '打开「论文提纲」成稿', '填写研究问题与结构', '送到润色台统一语气',
        'draft', 'thesis'),
      UseCaseGuideItem.of('uc_literature', '学术', '文献阅读笔记',
        '来源、核心观点、研究启发结构化记录。',
        '打开「文献笔记」场景样例', '自动学术场景润色', '可同步存入研究笔记',
        'scenario', 'literature_note'),
      UseCaseGuideItem.of('uc_research', '研究', '调研结论写汇报',
        '田野/问卷结论改成汇报体。',
        '一键「研究笔记→汇报」工作流', '查看详尽风格分段结构', '存入稿本或研究计划',
        'workflow', 'wf_research'),
      UseCaseGuideItem.of('uc_reading', '研究', '阅读札记 + 观点卡片',
        '读书/长文摘录后沉淀为可回顾资料。',
        '研究 Tab 写阅读笔记', '详情页「生成观点卡片」', '成长 Tab 查看统计',
        'research', 'note'),
      UseCaseGuideItem.of('uc_note_polish', '研究', '笔记正文送润色',
        '已写研究笔记一键改书面语。',
        '研究 → 打开任意笔记', '点「送到润色台」', '选场景/风格后存稿本',
        'research', 'polish'),
      UseCaseGuideItem.of('uc_summary', '综合', '长文抽取摘要 / 待办',
        '会议纪要、长邮件、文章快速提炼。',
        '表达 Tab 切到「摘要」', '载入样例或粘贴长文', '切换精简/待办/结论模式',
        'summary', 'actions'),
      UseCaseGuideItem.of('uc_quad', '综合', '四风格对照选语气',
        '同一原文对比正式/亲切/简洁/详尽。',
        '润色台输入或载入样例', '点「四风格对照」', '选最适合的一版复制',
        'demo', 'quad'),
      UseCaseGuideItem.of('uc_draft', '综合', '24 类填空成稿',
        '邮件、通知、合作、婉拒等模板化写作。',
        '点「场景成稿」', '选类型填三栏', '生成 → 润色 → 存稿本',
        'draft', 'email'),
      UseCaseGuideItem.of('uc_diagnose', '综合', '表达诊断问卷',
        '自检口语、冗长、请求不清等问题并得改进建议。',
        '点「表达诊断」', '完成简短问卷', '查看模板化诊断报告',
        'diagnose', '')
    ]
  }

  static byCategory(label: string): UseCaseGuideItem[] {
    if (label === '全部' || label.length === 0) {
      return LanguageUseCaseService.all()
    }
    const out: UseCaseGuideItem[] = []
    for (const row of LanguageUseCaseService.all()) {
      if (row.category === label) {
        out.push(row)
      }
    }
    return out
  }

  static launch(item: UseCaseGuideItem): void {
    LanguageCraftNav.closeUseCaseGuide()
    if (item.actionKind === 'workflow') {
      const wf = LanguageWorkflowService.find(item.actionKey)
      if (wf !== undefined) {
        LanguageCraftNav.applyWorkflow(wf)
      }
      return
    }
    if (item.actionKind === 'scenario') {
      const sc = LanguageScenarioService.find(item.actionKey)
      if (sc !== undefined) {
        LanguageCraftNav.applyScenarioDemoRow(sc)
      }
      return
    }
    if (item.actionKind === 'draft') {
      LanguageCraftNav.openDraft(item.actionKey)
      return
    }
    if (item.actionKind === 'summary') {
      LanguageCraftNav.applyToSummary(LanguageUseCaseService.summaryDemo(), item.actionKey)
      return
    }
    if (item.actionKind === 'demo') {
      LanguageCraftNav.applyScenarioDemo('demo_quad', LanguageUseCaseService.polishDemo(), 'email')
      return
    }
    if (item.actionKind === 'diagnose') {
      LanguageCraftNav.openDiagnose()
      return
    }
    if (item.actionKind === 'research') {
      AppStorage.setOrCreate('mainTabIndex', 2)
      AppStorage.setOrCreate('tabBarHidden', false)
      if (item.actionKey === 'note') {
        ResearchNav.openNoteEditor('')
      }
      return
    }
  }

  private static polishDemo(): string {
    return '那个就是想跟你说一下，然后这次方案其实挺急的，感觉你能不能帮忙看一下，尽快给个回复谢谢哈。'
  }

  private static summaryDemo(): string {
    return '上周项目例会决定下周一提交评审材料。市场部负责竞品对照，产品部补交互说明。预算还没批，需要财务本周五前确认。客户希望增加夜间模式，产品认为可以排进下一迭代。综上先保证评审材料按时提交。'
  }
}
