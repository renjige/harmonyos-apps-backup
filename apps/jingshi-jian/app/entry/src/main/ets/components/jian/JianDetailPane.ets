import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { JianEntry } from '../../models/JianModels'
import { DateHelper } from '../../services/DateHelper'
import { JianStore } from '../../services/JianStore'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct JianDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: JianEntry = new JianEntry()
  @State favorite: boolean = false
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.favorite = this.entry.isFavorite
  }

  private handleDelete(): void {
    void JianStore.deleteEntry(this.entry.id).then((): void => {
      this.onChanged()
      this.onClose()
    })
  }

  private toggleFavorite(): void {
    void JianStore.toggleFavorite(this.entry.id).then((v: boolean): void => {
      this.favorite = v
      this.onChanged()
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
          Text('笺页详情')
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
              Image($r('app.media.hero_paper_bg'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Column() {
                Blank()
                Column({ space: 4 }) {
                  Text(DateHelper.displayDate(this.entry.dateKey))
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Row({ space: 8 }) {
                    Text(`${this.entry.timeStr} · ${this.entry.wordCount} 字`)
                      .fontSize(Theme.type.caption)
                      .fontColor('#FFFFFF')
                    if (this.entry.moodId.length > 0) {
                      Text(`${MoodCatalog.emojiOf(this.entry.moodId)} ${MoodCatalog.labelOf(this.entry.moodId)}`)
                        .fontSize(Theme.type.caption)
                        .fontColor('#FFFFFF')
                    }
                  }
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.78)', 1]]
                })
              }
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(160)

            Text(JianEntry.stripText(this.entry.body).trim().length === 0 ? '（空白笺页）' : this.entry.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
              .width('100%')

            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: this.favorite ? '已收藏' : '收藏笺页',
                variant: 'secondary',
                onTap: (): void => { this.toggleFavorite() }
              }).layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'secondary',
                onTap: (): void => { this.handleDelete() }
              }).layoutWeight(1)
            }
            .width('100%')
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
