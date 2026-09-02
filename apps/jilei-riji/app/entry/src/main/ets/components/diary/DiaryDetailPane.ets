import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { FormattedDiaryBody } from './FormattedDiaryBody'
import { DiaryEntry } from '../../models/DiaryModels'
import { DateHelper } from '../../services/DateHelper'
import { DiaryStore } from '../../services/DiaryStore'

@Component
export struct DiaryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: DiaryEntry = new DiaryEntry()
  onClose: () => void = () => {}
  onDeleted: () => void = () => {}

  private handleDelete(): void {
    void DiaryStore.deleteEntry(this.entry.id).then((): void => {
      this.onDeleted()
    })
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('日记详情')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.entry.imagePath.length > 0) {
                Image(this.entry.imagePath)
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              } else {
                Image($r('app.media.hero_paper_bg'))
                  .width('100%')
                  .height(160)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              }
              Column() {
                Blank()
                Column() {
                  Text(DateHelper.displayDate(this.entry.dateKey))
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(`${this.entry.wordCount} 字`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.72)', 1]]
                })
              }
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(200)

            if (DiaryEntry.stripMarkup(this.entry.body).trim().length === 0) {
              Text('（无正文）')
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            } else {
              FormattedDiaryBody({
                body: this.entry.body,
                fontSize: Theme.type.bodyL,
                lineHeight: 26
              })
            }

            AppButton({
              label: '删除本篇',
              variant: 'secondary',
              onTap: (): void => { this.handleDelete() }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('92%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .position({ x: 0, y: '8%' })
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
