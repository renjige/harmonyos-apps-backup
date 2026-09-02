import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { WardrobeLookLogModel } from '../../models/WardrobeModels'

@Component
export struct CalendarLookDetail {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dateStr: string = ''
  @Prop hasLog: boolean = false
  @Prop log: WardrobeLookLogModel = new WardrobeLookLogModel()
  onRecordToday: (dateStr: string) => void = () => {}
  onDeleteLog: (dateStr: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      // Header
      Row() {
        Row({ space: 6 }) {
          AppIcon({ name: 'calendar', iconSize: 16, color: Theme.colors().brandPrimary })
          Text(`${this.dateStr} 穿搭记录`)
            .fontSize(Theme.type.callout)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }

        Blank()

        if (this.hasLog) {
          Text('已记录')
            .fontSize(Theme.type.caption2)
            .fontColor(Theme.colors().brandSecondary)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(Theme.isDark() ? '#1C332D' : '#DDF2EB')
            .borderRadius(Theme.radius.xs)
        }
      }
      .width('100%')

      if (this.hasLog) {
        Column({ space: 8 }) {
          Text(this.log.outfitTitle)
            .fontSize(Theme.type.subheadline)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          // Items tags
          Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 6, unit: 0 }, cross: { value: 6, unit: 0 } } }) {
            ForEach(this.log.itemNames, (name: string) => {
              Row({ space: 4 }) {
                AppIcon({ name: 'hanger', iconSize: 12, color: Theme.colors().brandSecondary })
                Text(name)
                  .fontSize(Theme.type.caption1)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(Theme.isDark() ? '#22302D' : '#EEF5F2')
              .borderRadius(Theme.radius.pill)
            }, (name: string) => name)
          }

          Row({ space: 8 }) {
            Text(`风格：${this.log.style}`)
              .fontSize(Theme.type.caption2)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            Text(`场景：${this.log.scene}`)
              .fontSize(Theme.type.caption2)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.log.mood.length > 0) {
              Text(`心情：${this.log.mood}`)
                .fontSize(Theme.type.caption2)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }

            Blank()

            Text('删除记录')
              .fontSize(Theme.type.caption2)
              .fontColor(Theme.colors().semanticError)
              .onClick(() => this.onDeleteLog(this.dateStr))
          }
          .width('100%')
          .padding({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.isDark() ? '#1A2926' : '#F4FAF7')
        .borderRadius(Theme.radius.md)
      } else {
        Column({ space: 6 }) {
          Text('这天还没有穿搭记录')
            .fontSize(Theme.type.subheadline)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

          Text('记录日常搭配，形成专属的个人穿搭秩序日历')
            .fontSize(Theme.type.caption2)
            .fontColor(Theme.colors().textTertiary)

          AppButton({
            label: '＋ 记录这天穿搭',
            variant: 'secondary',
            onTap: () => this.onRecordToday(this.dateStr)
          })
          .margin({ top: Theme.space.s2 })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
        .borderRadius(Theme.radius.md)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({
      radius: 12,
      color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.05)',
      offsetY: 2
    })
  }
}
