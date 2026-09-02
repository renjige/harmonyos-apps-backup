import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { QuoteItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'

@Component
export struct QuoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onDeleted: () => void = () => {}
  @State item: QuoteItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findQuote(this.itemId)
    this.loading = false
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await ReadingBizService.deleteQuote(this.item.id)
    if (ok) {
      this.showToast('已删除明悟')
      this.onDeleted()
      setTimeout(() => { ReadingDetailNav.close() }, 800)
    } else {
      this.showToast('删除失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载明悟…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '明悟不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '明悟摘录',
          onClose: (): void => { ReadingDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      this.QuoteBody(this.item)
    }
  }

  @Builder
  QuoteBody(quote: QuoteItem) {
    Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ReadingMedia.coverMedia('hero_reading_desk'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(45,90,74,0)', 0], ['rgba(45,90,74,0.82)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            if (quote.source.length > 0) {
              Text(quote.source)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
            }
            Text(quote.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (quote.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(quote.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '明悟', variant: 'plain' }) {
            Text(quote.content)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(26)
              .fontStyle(FontStyle.Italic)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '删除明悟',
            variant: 'danger',
            onTap: (): void => { void this.handleDelete() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
  }
}
