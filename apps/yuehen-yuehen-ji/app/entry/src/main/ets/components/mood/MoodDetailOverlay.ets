import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MoodRecord } from '../../models/MoodModels'
import { EmotionCatalog } from '../../models/EmotionCatalog'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct MoodDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: MoodRecord = new MoodRecord()
  onClose: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Text(DateHelper.displayDate(this.record.dateKey))
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('关闭')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { this.onClose() })
          }
          .width('100%')

          Text(`能量 ${this.record.score}/10`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandAccent)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.record.emotions, (id: string) => {
              Text(EmotionCatalog.labelOf(id))
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandDeep)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(EmotionCatalog.colorOf(id))
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
            }, (id: string) => id)
          }
          .width('100%')

          if (this.record.imagePath.length > 0) {
            Image(this.record.imagePath)
              .width('100%')
              .height(180)
              .borderRadius(Theme.radius.md)
              .objectFit(ImageFit.Cover)
          }

          Text(this.record.diary.length > 0 ? this.record.diary : '这一天没有写下文字')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(24)

          AppButton({
            label: '删除此日记录',
            variant: 'secondary',
            onTap: (): void => { this.onDelete() }
          })
        }
        .width('100%')
        .padding(Theme.space.s6)
      }
      .width('92%')
      .constraintSize({ maxHeight: '80%' })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
  }
}
