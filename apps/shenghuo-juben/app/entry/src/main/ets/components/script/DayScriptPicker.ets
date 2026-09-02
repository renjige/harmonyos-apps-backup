import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ScriptListCard } from './ScriptListCard'
import { LifeScript } from '../../models/ScriptModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct DayScriptPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dateKey: string = ''
  @Prop scripts: LifeScript[] = []
  onClose: () => void = () => {}
  onPick: (script: LifeScript) => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column({ space: Theme.space.s3 }) {
        Row() {
          Text(`${DateHelper.displayDate(this.dateKey)} 的剧本`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
        }
        .width('100%')

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.scripts, (item: LifeScript) => {
              ScriptListCard({
                script: item,
                onTap: (): void => { this.onPick(item) }
              })
            }, (item: LifeScript) => item.id)
          }
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('92%')
      .height('70%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(35)
  }
}
