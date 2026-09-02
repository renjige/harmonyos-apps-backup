import { InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from './InspirationBizService'
import { InspirationConvertService } from './InspirationConvertService'

export class PipelineStageItem {
  inspiration: InspirationItem = new InspirationItem()
  stage: string = 'capture'
  planId: string = ''
  stepText: string = ''
}

export class PipelineSnapshot {
  capture: PipelineStageItem[] = []
  board: PipelineStageItem[] = []
  plan: PipelineStageItem[] = []
  done: PipelineStageItem[] = []

  static empty(): PipelineSnapshot {
    return new PipelineSnapshot()
  }

  totalCount(): number {
    return this.capture.length + this.board.length + this.plan.length + this.done.length
  }
}

/** 灵感在各转化阶段的归类：捕捉 → 钉板 → 计划 → 完成 */
export class ConversionPipelineService {
  static async load(userId: string): Promise<PipelineSnapshot> {
    const snap = PipelineSnapshot.empty()
    if (userId.length === 0) {
      return snap
    }
    const inspirations = await InspirationBizService.loadInspirations(userId)
    const boards = await InspirationBizService.loadMoodBoards(userId)
    const plans = await InspirationBizService.loadCreativePlans(userId)
    for (const insp of inspirations) {
      const row = new PipelineStageItem()
      row.inspiration = insp
      const linked = ConversionPipelineService.findPlanForInspiration(plans, insp.id)
      if (linked !== undefined) {
        const goal = linked.goal.length > 0 ? linked.goal : linked.body
        row.planId = linked.id
        row.stepText = InspirationConvertService.stepProgressText(goal)
        const progress = InspirationConvertService.progressFromGoal(goal)
        if (progress >= 100) {
          row.stage = 'done'
          snap.done.push(row)
        } else {
          row.stage = 'plan'
          snap.plan.push(row)
        }
      } else if (ConversionPipelineService.isPinned(insp, boards)) {
        row.stage = 'board'
        snap.board.push(row)
      } else {
        row.stage = 'capture'
        snap.capture.push(row)
      }
    }
    return snap
  }

  static stageLabel(stage: string): string {
    if (stage === 'board') {
      return '待拆计划'
    }
    if (stage === 'plan') {
      return '推进中'
    }
    if (stage === 'done') {
      return '已完成'
    }
    return '待钉板'
  }

  static filterByStage(snap: PipelineSnapshot, stage: string): PipelineStageItem[] {
    if (stage === 'board') {
      return snap.board
    }
    if (stage === 'plan') {
      return snap.plan
    }
    if (stage === 'done') {
      return snap.done
    }
    if (stage === 'capture') {
      return snap.capture
    }
    const all: PipelineStageItem[] = []
    for (const row of snap.capture) {
      all.push(row)
    }
    for (const row of snap.board) {
      all.push(row)
    }
    for (const row of snap.plan) {
      all.push(row)
    }
    for (const row of snap.done) {
      all.push(row)
    }
    return all
  }

  private static findPlanForInspiration(plans: InspirationItem[], inspId: string): InspirationItem | undefined {
    const marker = `[[srcinsp:${inspId}]]`
    for (const p of plans) {
      const goal = p.goal.length > 0 ? p.goal : p.body
      if (goal.indexOf(marker) >= 0) {
        return p
      }
    }
    return undefined
  }

  private static isPinned(insp: InspirationItem, boards: InspirationItem[]): boolean {
    for (const b of boards) {
      const json = b.cardsJson
      if (json.indexOf(insp.id) >= 0) {
        return true
      }
      if (insp.title.length > 4 && json.indexOf(insp.title) >= 0) {
        return true
      }
    }
    return false
  }
}
