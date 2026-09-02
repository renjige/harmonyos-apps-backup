import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { CatalogItem } from '../../models/EssayModels'
import { DawnMedia } from '../../services/DawnMedia'
import { EssayBizService } from '../../services/EssayBizService'
import { EssayNav } from '../../services/EssayNav'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct CatalogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'quote'
  @Prop itemId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onToken(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.kind === 'quote') {
      this.item = await EssayBizService.findQuote(this.itemId)
      return
    }
    if (this.kind === 'tag') {
      this.item = await EssayBizService.findTag(this.itemId)
      return
    }
    this.item = await EssayBizService.findWeather(this.itemId)
  }

  private heroKey(): string {
    if (this.kind === 'quote') {
      return 'banner_gold_beam'
    }
    if (this.kind === 'tag') {
      return 'cover_folded_jian'
    }
    return 'cover_tea_dawn'
  }

  private async fav(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const on = await EssayStore.toggleFav(this.item.id, this.item.title, this.item.body)
    this.toastText = on ? '已收藏这句晨语' : '已取消收藏'
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack() {
      if (this.item === undefined) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({ title: '暂时没有这条内容', description: '下拉返回笺集，稍后再试。' })
          AppButton({ label: '返回', variant: 'secondary', onTap: (): void => { EssayNav.closeDetail() } })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        DetailShell({ title: this.item.title, onClose: (): void => { EssayNav.closeDetail() } }) {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(DawnMedia.cover(this.heroKey()))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column() {
                  Text(this.kind === 'quote' ? '每日晨语' : (this.kind === 'tag' ? '标签' : '天气笺语'))
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                  Text(this.item.title)
                    .fontSize(Theme.type.title1)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                    .width('100%')
                }
                .width('100%')
                .padding({ left: 20, right: 20, bottom: 18 })
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(61,50,40,0)', 0], ['rgba(61,50,40,0.78)', 1]]
                })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .borderRadius(Theme.radius.lg)
              .clip(true)

              AppCard({ title: '说明' }) {
                Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }

              if (this.kind === 'quote') {
                AppButton({
                  label: EssayStore.isFav(this.item.id) ? '取消收藏' : '收藏这句晨语',
                  onTap: (): void => { void this.fav() }
                })
                AppButton({
                  label: '用它开始写一张笺',
                  variant: 'secondary',
                  onTap: (): void => {
                    EssayNav.closeDetail()
                    EssayNav.openWrite('')
                  }
                })
              } else if (this.kind === 'tag') {
                AppButton({
                  label: '查看含此标签的笺',
                  onTap: (): void => {
                    AppStorage.setOrCreate('filterTag', this.item !== undefined ? this.item.title : '')
                    EssayNav.closeDetail()
                    AppStorage.setOrCreate('mainTabIndex', 1)
                  }
                })
              } else {
                AppButton({
                  label: '写入天气笺语并开写',
                  onTap: (): void => {
                    if (this.item !== undefined) {
                      AppStorage.setOrCreate('pendingWeather', this.item.title)
                    }
                    EssayNav.closeDetail()
                    EssayNav.openWrite('')
                  }
                })
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
