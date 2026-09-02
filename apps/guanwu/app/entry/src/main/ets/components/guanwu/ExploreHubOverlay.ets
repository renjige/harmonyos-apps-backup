import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { TemplateStrip } from './TemplateStrip'
import { ExploreTaskCard } from './ExploreTaskCard'
import { ObserveTemplate, ExploreTaskDef } from '../../models/ObserveCatalog'
import { DailyChallenge } from '../../services/MorningCardService'

@Component
export struct ExploreHubOverlay {
  @Prop challenge: DailyChallenge = new DailyChallenge()
  onClose: () => void = () => {}
  onPickTemplate: (tpl: ObserveTemplate) => void = () => {}
  onPickExplore: (task: ExploreTaskDef) => void = () => {}
  onAcceptChallenge: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('探索中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({ label: '关闭', variant: 'ghost', onTap: (): void => this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s2 }) {
            Text('今日观察挑战')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.challenge.title)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Text(this.challenge.prompt)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '接受挑战并记录',
              variant: 'primary',
              onTap: (): void => this.onAcceptChallenge()
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          TemplateStrip({
            onPick: (tpl: ObserveTemplate): void => this.onPickTemplate(tpl)
          })

          ExploreTaskCard({
            onPick: (task: ExploreTaskDef): void => this.onPickExplore(task)
          })
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
