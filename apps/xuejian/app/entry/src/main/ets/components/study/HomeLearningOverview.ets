import { Theme } from '../design-system/Theme'
import { KnowledgeCardItem, StudySession, StudyTask } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

/** 首页学习概览 — 让审核可见除计时外的多场景闭环 */
@Component
export struct HomeLearningOverview {
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State weekMin: number = 0
  @State reviewCount: number = 0
  @State taskDone: number = 0
  @State taskTotal: number = 0
  @State noteTotal: number = 0
  onOpenInsight: () => void = () => {}
  onOpenTasks: () => void = () => {}
  onOpenReview: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const sessions: StudySession[] = await StudyStore.loadSessions()
    const since = Date.now() - 7 * 24 * 60 * 60 * 1000
    let sum = 0
    for (const s of sessions) {
      if (s.endedAt >= since) {
        sum += s.minutes
      }
    }
    this.weekMin = sum
    const cards: KnowledgeCardItem[] = await StudyStore.loadCards()
    let due = 0
    for (const c of cards) {
      if (!c.isMastered()) {
        due++
      }
    }
    this.reviewCount = due
    this.noteTotal = (await StudyStore.loadNotes()).length
    const tasks: StudyTask[] = await StudyStore.loadTasks()
    let done = 0
    for (const t of tasks) {
      if (t.done) {
        done++
      }
    }
    this.taskDone = done
    this.taskTotal = tasks.length
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('学习概览')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.isDark() ? '#F8FAFC' : '#0F172A')
        .width('100%')

      Row({ space: 8 }) {
        Column({ space: 4 }) {
          Text(`${this.weekMin} 分`)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('本周累计')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.inkOnNavy())
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#1A2A4A')
        .borderRadius(12)
        .constraintSize({ minHeight: 64 })
        .onClick((): void => { this.onOpenInsight() })

        Column({ space: 4 }) {
          Text(`${this.reviewCount} 张`)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('待复习')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.inkOnNavy())
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#1A2A4A')
        .borderRadius(12)
        .constraintSize({ minHeight: 64 })
        .onClick((): void => { this.onOpenReview() })

        Column({ space: 4 }) {
          Text(`${this.taskDone}/${this.taskTotal}`)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('待学完成')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.inkOnNavy())
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#1A2A4A')
        .borderRadius(12)
        .constraintSize({ minHeight: 64 })
        .onClick((): void => { this.onOpenTasks() })
      }
      .width('100%')

      Text(`已积累 ${this.noteTotal} 条笔记 · 洞察页可导出周/月报`)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.bodyMuted())
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.isDark() ? '#2C2C2E' : '#FFFFFF')
    .borderRadius(16)
  }
}
