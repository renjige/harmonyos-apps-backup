import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { EmotionOption, ObservationNote } from '../../models/ObservationModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct DayNotesOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dateKey: string = ''
  @Prop notes: ObservationNote[] = []
  onClose: () => void = () => {}
  onOpenNote: (note: ObservationNote) => void = () => {}

  private labelColor(key: string): string {
    const em = EmotionOption.find(key)
    if (em !== undefined) {
      return em.color
    }
    return Theme.colors().brandPrimary
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => this.onClose())

      Column({ space: Theme.space.s4 }) {
        Row() {
          Text(`${DateHelper.displayDate(this.dateKey)} 的笔记`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('关闭')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => this.onClose())
        }
        .width('100%')

        if (this.notes.length === 0) {
          AppEmpty({
            title: '这一天没有记录',
            description: '去漫观页写一条吧',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          ForEach(this.notes, (n: ObservationNote) => {
            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(n.emotionLabel)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.labelColor(n.emotionKey))
                Text(n.text)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(22)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onClick((): void => this.onOpenNote(n))
          }, (n: ObservationNote) => n.id)
        }
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .constraintSize({ maxHeight: '70%' })
      .onClick((): void => {})
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
  }
}
