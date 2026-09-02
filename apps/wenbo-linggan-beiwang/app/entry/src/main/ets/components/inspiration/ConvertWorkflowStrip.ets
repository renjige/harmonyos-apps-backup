import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

/** 捕捉 → 钉板 → 计划：灵感备忘的转化工作台，区别于普通笔记列表 */
@Component
export struct ConvertWorkflowStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteCount: number = 0
  @Prop boardCount: number = 0
  @Prop planCount: number = 0
  onCapture: () => void = () => {}
  onOpenBoard: () => void = () => {}
  onOpenPlans: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('灵感转化台')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('不是记完就结束。一条灵感要钉上画板对照，再拆成可推进的计划。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        Column({ space: 6 }) {
          AppIcon({ name: 'book', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('捕捉')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`${this.noteCount} 条`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .layoutWeight(1)
        .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { this.onCapture() })

        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width(16)
        .justifyContent(FlexAlign.Center)

        Column({ space: 6 }) {
          AppIcon({ name: 'photo', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('钉板')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`${this.boardCount} 块`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .layoutWeight(1)
        .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { this.onOpenBoard() })

        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width(16)
        .justifyContent(FlexAlign.Center)

        Column({ space: 6 }) {
          AppIcon({ name: 'calendar', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('计划')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`${this.planCount} 个`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .layoutWeight(1)
        .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { this.onOpenPlans() })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
