import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { LifeScript } from '../../models/ScriptModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ScriptListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop script: LifeScript = new LifeScript()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.script.coverPath().length > 0) {
          Image(this.script.coverPath())
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        } else {
          Image($r('app.media.cover_mood_calm'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        }
        Column() {
          Blank()
          Column() {
            Text(this.script.title.length > 0 ? this.script.title : '未命名剧本')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(Theme.space.s3)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(44,62,80,0.78)', 1]]
          })
        }
        .width('100%')
        .height('100%')
        .borderRadius(Theme.radius.md)
      }
      .width('100%')

      Row() {
        Text(DateHelper.displayShort(this.script.dateKey))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(' · ')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Text(this.script.moodTag)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Blank()
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')

      Text(this.script.summaryLine())
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
    .shadow({ radius: 12, color: 'rgba(45,45,45,0.08)', offsetY: 4 })
    .onClick((): void => { this.onTap() })
  }
}
