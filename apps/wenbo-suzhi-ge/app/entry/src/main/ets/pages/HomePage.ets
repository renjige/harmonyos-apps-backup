import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadListCard } from '../components/wisdom/ReadListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { WisdomMedia } from '../services/WisdomMedia'
import { SuzhiLocalStore } from '../services/SuzhiLocalStore'
import { LunarHintUtil } from '../utils/LunarHintUtil'
import pasteboard from '@ohos.pasteboard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '素知阁'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fontScale') fontScale: string = 'medium'
  @State todayQuote: WisdomItem = new WisdomItem()
  @State allQuotes: WisdomItem[] = []
  @State reads: WisdomItem[] = []
  @State quoteIndex: number = 0
  @State hasQuote: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private bodySize(): number {
    return SuzhiLocalStore.bodySize()
  }

  private async reload(): Promise<void> {
    this.allQuotes = await WisdomHallBizService.loadQuotes()
    if (this.allQuotes.length > 0) {
      const day = new Date().getDate()
      this.quoteIndex = day % this.allQuotes.length
      this.todayQuote = this.allQuotes[this.quoteIndex]
      this.hasQuote = true
    } else {
      this.hasQuote = false
    }
    const allReads = await WisdomHallBizService.loadReads()
    const slice: WisdomItem[] = []
    const max = allReads.length > 4 ? 4 : allReads.length
    for (let i = 0; i < max; i++) {
      slice.push(allReads[i])
    }
    this.reads = slice
  }

  private swapQuote(): void {
    if (this.allQuotes.length === 0) {
      return
    }
    this.quoteIndex = (this.quoteIndex + 1) % this.allQuotes.length
    this.todayQuote = this.allQuotes[this.quoteIndex]
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async favoriteQuote(): Promise<void> {
    if (!this.hasQuote) {
      return
    }
    const ok = await SuzhiLocalStore.addFavorite('quote', this.todayQuote.id, this.todayQuote.title)
    if (ok) {
      this.showToast('已加入收藏')
    }
  }

  private shareQuote(): void {
    if (!this.hasQuote) {
      return
    }
    const text = `${this.todayQuote.title}\n—— ${this.todayQuote.authorName}\n\n来自「素知阁」`
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
    this.showToast('已复制到剪贴板，可粘贴分享')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Column({ space: 2 }) {
              Text(this.appName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('东方极简 · 静谧智慧')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text(LunarHintUtil.todayLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
          }
          .width('100%')

          Text('智慧阁 · 今日精选')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.hasQuote) {
            Column({ space: Theme.space.s3 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(WisdomMedia.resource(this.todayQuote.coverKey.length > 0 ?
                  this.todayQuote.coverKey : 'cover_wisdom_ink'))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(200)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(44,62,80,0)', 0.25], ['rgba(44,62,80,0.82)', 1]]
                  })
                Column({ space: 8 }) {
                  Text(this.todayQuote.title)
                    .fontSize(this.bodySize() + 4)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F2ED')
                    .width('100%')
                  Text(this.todayQuote.authorName.length > 0 ?
                    `—— ${this.todayQuote.authorName}` : '')
                    .fontSize(Theme.type.caption)
                    .fontColor('#C9A96E')
                    .width('100%')
                }
                .padding(Theme.space.s4)
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .onClick((): void => { WisdomHallNav.openDetail('quote', this.todayQuote.id) })

              Row({ space: Theme.space.s2 }) {
                AppButton({
                  label: '换一换',
                  variant: 'secondary',
                  onTap: (): void => { this.swapQuote() }
                })
                  .layoutWeight(1)
                Column() {
                  AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                }
                .width(48)
                .height(48)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.favoriteQuote() })
                Column() {
                  AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                }
                .width(48)
                .height(48)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.shareQuote() })
              }
              .width('100%')
            }
            .width('100%')
          } else {
            AppEmpty({ title: '暂无精选', description: '请检查网络后下拉刷新' })
          }

          Row() {
            Text('文萃推荐')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('进入文萃')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { WisdomHallNav.switchTab(1) })
          }
          .width('100%')

          if (this.reads.length === 0) {
            AppEmpty({ title: '暂无文萃', description: '请检查网络后刷新' })
          } else {
            ForEach(this.reads, (item: WisdomItem) => {
              ReadListCard({
                title: item.title,
                summary: item.summaryLine(),
                category: item.category,
                readMinutes: item.readMinutes,
                coverKey: item.coverKey,
                onOpen: (): void => { WisdomHallNav.openDetail('read', item.id) }
              })
            }, (item: WisdomItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s4 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
