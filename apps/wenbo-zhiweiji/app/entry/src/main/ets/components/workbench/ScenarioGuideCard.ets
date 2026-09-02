import { Theme } from '../design-system/Theme'
import { UseScenario } from '../../services/ScenarioCatalog'
import { ZhiweiNav } from '../../services/ZhiweiNav'

@Component
export struct ScenarioGuideCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private scenarios: UseScenario[] = UseScenario.all()

  private run(action: string): void {
    if (action === 'catalog') {
      ZhiweiNav.openKnowledgeCatalog()
      return
    }
    if (action === 'daily') {
      ZhiweiNav.openDaily('')
      return
    }
    if (action === 'review') {
      ZhiweiNav.openReviewDeck()
      return
    }
    if (action === 'template') {
      ZhiweiNav.openComposeTemplate('tpl_tip')
      return
    }
    if (action === 'inbox') {
      ZhiweiNav.openInbox()
      return
    }
    if (action === 'weekly') {
      AppStorage.setOrCreate('zwTabJump', 1)
      ZhiweiNav.openWeekly()
    }
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('六大使用场景')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
      Text('覆盖阅读、打卡、复习、模板记录、消化跟进与周度回顾，不只是记笔记。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        .width('100%')
      ForEach(this.scenarios, (s: UseScenario) => {
        Column({ space: 4 }) {
          Text(s.title)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Text(s.desc)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            .width('100%')
          Text('立即体验 →')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.sm)
        .onClick(() => this.run(s.action))
      }, (s: UseScenario) => s.id)
    }
    .width('100%')
  }
}
