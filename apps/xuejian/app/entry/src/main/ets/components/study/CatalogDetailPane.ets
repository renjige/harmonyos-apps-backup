import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppIcon } from '../design-system/AppIcon'
import { StudyMedia } from '../../services/StudyMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct CatalogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemTitle: string = ''
  @Prop itemBody: string = ''
  @Prop itemSummary: string = ''
  @Prop itemCover: string = 'hero_desk'
  @Prop itemCategory: string = '方法'
  @Prop kindLabel: string = '智慧推荐'
  onClose: () => void = () => {}
  onStartFocus: () => void = () => {}
  onNewCard: () => void = () => {}
  onOpenReview: () => void = () => {}

  private suggestCard(): boolean {
    return this.itemBody.indexOf('卡片') >= 0 || this.itemTitle.indexOf('卡片') >= 0
  }

  private suggestReview(): boolean {
    return this.itemBody.indexOf('复习') >= 0 || this.itemTitle.indexOf('热身') >= 0
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(48).height(48).justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.kindLabel)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(StudyMedia.resource(this.itemCover))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column() {
              Blank()
              Column({ space: 6 }) {
                Text(CategoryEmojiUtil.chipLabel(this.itemCategory.length > 0 ? this.itemCategory : '方法'))
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                Text(this.itemTitle)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,74,0.88)', 1]]
              })
            }
            .width('100%')
            .height(200)
          }
          .width('100%')
          .height(200)
          .borderRadius(Theme.radius.md)
          .clip(true)

          AppCard({ title: '摘要' }) {
            Text(this.itemSummary.length > 0 ? this.itemSummary : this.itemBody)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }

          Text(this.itemBody)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(22)

          AppButton({ label: '开始一段专注', onTap: (): void => { this.onStartFocus() } })
          if (this.suggestCard()) {
            AppButton({
              label: '读完写一张卡片',
              variant: 'secondary',
              onTap: (): void => { this.onNewCard() }
            })
          }
          if (this.suggestReview()) {
            AppButton({
              label: '先随机复习',
              variant: 'ghost',
              onTap: (): void => { this.onOpenReview() }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
