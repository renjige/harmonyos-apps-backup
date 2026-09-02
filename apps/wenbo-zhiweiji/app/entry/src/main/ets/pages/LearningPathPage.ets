import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LearningPath, PathStep } from '../services/LearningPathCatalog'
import { LearningPathCatalog } from '../services/LearningPathCatalog'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct LearningPathPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State paths: LearningPath[] = []
  @State activeId: string = ''
  @State doneCount: number = 0

  aboutToAppear(): void {
    this.paths = LearningPathCatalog.all()
    this.doneCount = ZhiweiStore.pathStepsDone()
  }

  private activePath(): LearningPath | null {
    if (this.activeId.length === 0) {
      return null
    }
    return LearningPathCatalog.findById(this.activeId)
  }

  private async runStep(step: PathStep): Promise<void> {
    await ZhiweiStore.markPathStepDone(step.id)
    this.doneCount = ZhiweiStore.pathStepsDone()
    if (step.action === 'daily') {
      ZhiweiNav.openDaily(step.ref)
      return
    }
    if (step.action === 'daily_today') {
      ZhiweiNav.openDaily('')
      return
    }
    if (step.action === 'template') {
      ZhiweiNav.openComposeTemplate(step.ref.length > 0 ? step.ref : 'tpl_tip')
      return
    }
    if (step.action === 'review') {
      ZhiweiNav.openReviewDeck()
      return
    }
    if (step.action === 'inbox') {
      ZhiweiNav.openInbox()
      return
    }
    if (step.action === 'weekly') {
      ZhiweiNav.openWeekly()
      return
    }
    if (step.action === 'catalog') {
      ZhiweiNav.openKnowledgeCatalog()
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => {
          if (this.activeId.length > 0) {
            this.activeId = ''
            return
          }
          ZhiweiNav.closeLearningPath()
        })
        Text(this.activeId.length > 0 ? '路径步骤' : '学习路径')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.activePath() === null) {
            Text('三条引导式学习路径，覆盖入门、职场与生活场景。完成步骤会累计进度。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Text(`已完成 ${this.doneCount} 个步骤`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              .width('100%')
            ForEach(this.paths, (p: LearningPath) => {
              Column({ space: 6 }) {
                Text(p.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .width('100%')
                Text(p.summary)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
                Text(`${p.steps.length} 步 · 开始 →`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => { this.activeId = p.id })
            }, (p: LearningPath) => p.id)
          } else {
            Text(this.activePath()!.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(this.activePath()!.summary)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            ForEach(this.activePath()!.steps, (step: PathStep) => {
              Column({ space: 6 }) {
                Text(step.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .width('100%')
                Text(step.hint)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
                if (ZhiweiStore.isPathStepDone(step.id)) {
                  Text('已完成 ✓')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                    .width('100%')
                }
                AppButton({
                  label: '去完成',
                  variant: 'secondary',
                  onTap: (): void => { void this.runStep(step) }
                })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
            }, (step: PathStep) => step.id)
          }
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }
}
