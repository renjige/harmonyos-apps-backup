import { PipelineSnapshot } from './ConversionPipelineService'

export class ReadinessAnswers {
  captureVolume: number = 1
  boardStatus: number = 0
  planStatus: number = 0
  timeBudget: number = 1
  blocker: number = 0
}

export class ReadinessReport {
  score: number = 0
  level: string = ''
  headline: string = ''
  summary: string = ''
  action1: string = ''
  action2: string = ''
  action3: string = ''
}

/** 创意转化就绪度：规则模板诊断（非大模型） */
export class ConvertReadinessService {
  static buildReport(answers: ReadinessAnswers, pipeline: PipelineSnapshot): ReadinessReport {
    const report = new ReadinessReport()
    let score = 20
    if (answers.captureVolume >= 2) {
      score += 15
    } else if (answers.captureVolume >= 1) {
      score += 8
    }
    if (answers.boardStatus >= 2) {
      score += 20
    } else if (answers.boardStatus >= 1) {
      score += 10
    }
    if (answers.planStatus >= 2) {
      score += 25
    } else if (answers.planStatus >= 1) {
      score += 12
    }
    if (answers.timeBudget >= 2) {
      score += 10
    } else if (answers.timeBudget >= 1) {
      score += 5
    }
    if (pipeline.done.length > 0) {
      score += 10
    }
    if (score > 100) {
      score = 100
    }
    report.score = score
    if (score >= 75) {
      report.level = '高就绪'
      report.headline = '转化链路运转良好，可聚焦推进与回顾'
    } else if (score >= 45) {
      report.level = '中就绪'
      report.headline = '已有基础，建议补齐钉板或计划环节'
    } else {
      report.level = '待启动'
      report.headline = '建议从「捕捉→钉板→计划」三步走完整走一遍'
    }
    report.summary =
      `队列 ${pipeline.totalCount()} 条：待钉板 ${pipeline.capture.length} · 待拆计划 ${pipeline.board.length} · 推进中 ${pipeline.plan.length} · 已完成 ${pipeline.done.length}。`
    report.action1 = ConvertReadinessService.actionForBlocker(answers, pipeline)
    report.action2 = ConvertReadinessService.actionForBoard(answers, pipeline)
    report.action3 = ConvertReadinessService.actionForPlan(answers, pipeline)
    return report
  }

  private static actionForBlocker(answers: ReadinessAnswers, pipeline: PipelineSnapshot): string {
    if (answers.blocker === 0 || pipeline.capture.length > 0) {
      return '打开「精选→对照三问」，用结构化备忘补齐参考对照'
    }
    if (answers.blocker === 1) {
      return '从待钉板队列选 1 条灵感，详情里「做成创意计划」勾选转化步骤'
    }
    if (answers.blocker === 2) {
      return '计划详情勾选「本周推进到可演示」，并在归档 Tab 做周回顾'
    }
    return '用快记四模板捕捉 1 条可执行灵感，再钉入画板对照'
  }

  private static actionForBoard(answers: ReadinessAnswers, pipeline: PipelineSnapshot): string {
    if (pipeline.capture.length > 0) {
      return `优先处理 ${pipeline.capture.length} 条待钉板：详情 → 钉到画板 → 对照构图/文案`
    }
    if (answers.boardStatus <= 0) {
      return '画板 Tab 新建「灵感工作台」，把标题与摘要钉成文字卡片对照'
    }
    return '画板卡片已就绪，进入下一步拆计划'
  }

  private static actionForPlan(answers: ReadinessAnswers, pipeline: PipelineSnapshot): string {
    if (pipeline.board.length > 0) {
      return ` ${pipeline.board.length} 条已钉板待拆计划：详情 → 做成创意计划（三步勾选）`
    }
    if (pipeline.plan.length > 0) {
      return `推进中 ${pipeline.plan.length} 个计划：打开计划勾选步骤，更新进度百分比`
    }
    if (answers.planStatus <= 0) {
      return '转化台 → 创意计划，从灵感生成带「钉板/拆解/本周推进」步骤的计划'
    }
    return '归档 Tab → 日/周/月回顾，用模板总结本周转化成果'
  }
}
