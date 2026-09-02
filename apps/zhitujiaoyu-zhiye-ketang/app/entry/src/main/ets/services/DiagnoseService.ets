import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 职业课堂 — 智慧问卷 → 模板学习建议（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('stage', '您目前的职业阶段？', [
        DiagnoseOption.of('graduate', '应届 / 初入职场'),
        DiagnoseOption.of('junior', '1–3 年基层'),
        DiagnoseOption.of('mid', '3–8 年骨干'),
        DiagnoseOption.of('senior', '管理 / 资深')
      ]),
      DiagnoseQuestion.of('industry', '所在行业更接近？', [
        DiagnoseOption.of('tech', '互联网 / 科技'),
        DiagnoseOption.of('finance', '金融 / 咨询'),
        DiagnoseOption.of('manufacturing', '制造 / 实体'),
        DiagnoseOption.of('service', '服务业 / 零售'),
        DiagnoseOption.of('other', '其他')
      ]),
      DiagnoseQuestion.of('need', '当前最想提升？', [
        DiagnoseOption.of('skill', '专业技能'),
        DiagnoseOption.of('manage', '管理与领导力'),
        DiagnoseOption.of('comm', '沟通与协作'),
        DiagnoseOption.of('plan', '职业规划'),
        DiagnoseOption.of('cert', '考证 / 资质')
      ]),
      DiagnoseQuestion.of('time', '每周可投入学习？', [
        DiagnoseOption.of('light', '1–3 小时'),
        DiagnoseOption.of('mid', '4–8 小时'),
        DiagnoseOption.of('heavy', '8 小时以上')
      ]),
      DiagnoseQuestion.of('style', '偏好的学习方式？', [
        DiagnoseOption.of('video', '视频精讲'),
        DiagnoseOption.of('case', '案例拆解'),
        DiagnoseOption.of('live', '直播 / 互动'),
        DiagnoseOption.of('doc', '图文 / 文档')
      ]),
      DiagnoseQuestion.of('goal', '近期目标？', [
        DiagnoseOption.of('promote', '晋升加薪'),
        DiagnoseOption.of('switch', '转岗换行'),
        DiagnoseOption.of('side', '副业探索'),
        DiagnoseOption.of('stable', '稳住基本盘')
      ]),
      DiagnoseQuestion.of('block', '最大阻碍？', [
        DiagnoseOption.of('time', '时间碎片化'),
        DiagnoseOption.of('direction', '方向不清'),
        DiagnoseOption.of('method', '方法不对'),
        DiagnoseOption.of('motivation', '难以坚持')
      ]),
      DiagnoseQuestion.of('next', '希望下一步？', [
        DiagnoseOption.of('course', '匹配课程'),
        DiagnoseOption.of('plan', '生成学习计划'),
        DiagnoseOption.of('enroll', '预约试听')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const need = DiagnoseService.optionId(answers, 'need')
    const stage = DiagnoseService.optionId(answers, 'stage')
    const time = DiagnoseService.optionId(answers, 'time')
    const block = DiagnoseService.optionId(answers, 'block')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '职业学习建议报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：阶段「${DiagnoseService.labelOf(answers, 'stage')}」、` +
      `诉求「${DiagnoseService.labelOf(answers, 'need')}」、` +
      `每周可投入「${DiagnoseService.labelOf(answers, 'time')}」。` +
      `以下为规则模板建议，供学习规划参考，不构成职业承诺或投资建议。`
    report.strength = DiagnoseService.strengthText(stage, time)
    report.weakness = DiagnoseService.weaknessText(block, time)
    report.opportunity = DiagnoseService.opportunityText(need, next)
    report.threat = DiagnoseService.threatText(block, stage)
    report.actions = DiagnoseService.actions(need, time, next)
    report.matchCategory = DiagnoseService.matchCategory(need)
    report.matchHint =
      `建议优先浏览「${report.matchCategory}」类课程，并按模板计划安排每周学习。`
    report.scoreLabel = DiagnoseService.scoreLabel(time, block)
    return report
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (let a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], qid: string): string {
    for (let a of answers) {
      if (a.questionId === qid) {
        return a.optionLabel
      }
    }
    return '未填'
  }

  private static nowLabel(): string {
    const d = new Date()
    const y = d.getFullYear()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${y}-${moStr}-${dayStr}`
  }

  private static strengthText(stage: string, time: string): string {
    let s = '已有明确提升意愿，适合制定可执行的微学习计划。'
    if (stage === 'mid' || stage === 'senior') {
      s = '具备一定职场积累，可将经验结构化并补齐短板。'
    }
    if (time === 'mid' || time === 'heavy') {
      s = `${s} 可投入时间较充足，适合系统课程。`
    }
    return s
  }

  private static weaknessText(block: string, time: string): string {
    let w = '学习路径尚未固化，需要外部框架辅助。'
    if (block === 'time' || time === 'light') {
      w = '可用时间有限，需优先短课与高频小练习。'
    } else if (block === 'direction') {
      w = '方向感不足时易频繁换课，建议先锁定 1 个主题。'
    } else if (block === 'method') {
      w = '方法不当会导致「学了用不上」，需案例驱动。'
    } else if (block === 'motivation') {
      w = '坚持难时需设置周复盘与可量化小目标。'
    }
    return w
  }

  private static opportunityText(need: string, next: string): string {
    let o = '平台课程可按分类筛选，配合本地进度记录形成闭环。'
    if (need === 'manage') {
      o = '管理类课程可结合团队场景做课后复盘，4–6 周见成效。'
    } else if (need === 'comm') {
      o = '沟通协作类适合案例演练 + 每周 1 次模拟汇报。'
    } else if (need === 'plan') {
      o = '职业规划宜先做能力盘点，再匹配 2–3 门核心课。'
    } else if (need === 'cert') {
      o = '考证类建议倒排时间表，优先选有习题讲解的班型。'
    }
    if (next === 'enroll') {
      o = `${o} 可提交报名由顾问确认班型与时段。`
    }
    return o
  }

  private static threatText(block: string, stage: string): string {
    let t = '长期碎片化学习可能导致知识不成体系。'
    if (block === 'motivation') {
      t = '缺乏反馈时易中断，需设置里程碑与复盘。'
    }
    if (stage === 'graduate') {
      t = `${t} 初入职场更需避免只囤课不练习。`
    }
    return t
  }

  private static actions(need: string, time: string, next: string): string[] {
    const list: string[] = []
    list.push('本周选定 1 门主课，在详情页记录学习进度。')
    if (time === 'light') {
      list.push('将学习切为 3×25 分钟番茄块，固定时段执行。')
    } else {
      list.push('安排周末 2 小时深度学 + 平日 15 分钟回顾。')
    }
    if (need === 'skill') {
      list.push('优先「职业技能」分类，完成 1 次实操作业。')
    } else if (need === 'manage') {
      list.push('浏览「管理提升」课程，输出 1 页团队改进清单。')
    } else {
      list.push(`浏览「${DiagnoseService.matchCategory(need)}」相关课程并收藏 2 门。`)
    }
    if (next === 'enroll') {
      list.push('在目标课程详情提交报名，等待工作人员联系。')
    } else {
      list.push('保存本报告，到「学习」Tab 跟踪进度与报名。')
    }
    return list
  }

  private static matchCategory(need: string): string {
    if (need === 'manage') {
      return '管理提升'
    }
    if (need === 'comm') {
      return '沟通协作'
    }
    if (need === 'plan') {
      return '职业规划'
    }
    if (need === 'cert') {
      return '职业技能'
    }
    return '职业技能'
  }

  private static scoreLabel(time: string, block: string): string {
    let score = 72
    if (time === 'heavy') {
      score += 10
    } else if (time === 'light') {
      score -= 8
    }
    if (block === 'motivation' || block === 'direction') {
      score -= 6
    }
    if (score >= 80) {
      return '学习条件较好'
    }
    if (score >= 65) {
      return '建议强化计划'
    }
    return '需优先建立节奏'
  }
}
