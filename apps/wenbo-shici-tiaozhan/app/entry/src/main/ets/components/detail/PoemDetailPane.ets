import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailMetaRow, DetailSection, DetailShell } from './DetailShell'
import { PoemItem } from '../../models/PoetryModels'
import { PoetryMedia } from '../../services/PoetryMedia'
import { ProgressStore } from '../../services/ProgressStore'
import { PoetryNav } from '../../services/PoetryNav'

@Component
export struct PoemDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop poem: PoemItem = new PoemItem()
  @StorageLink('poetryTick') tick: number = 0
  @State toastText: string = ''

  private favLabel(): string {
    return ProgressStore.isFavorite(this.poem.id) ? '取消收藏' : '收藏此诗'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    await ProgressStore.toggleFavorite(this.poem.id)
    this.showToast(ProgressStore.isFavorite(this.poem.id) ? '已收藏' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({
          title: this.poem.title,
          cover: PoetryMedia.cover(this.poem.coverKey),
          onClose: () => PoetryNav.close()
        })
        Scroll() {
          Column({ space: 12 }) {
            DetailMetaRow({
              text: `${this.poem.dynasty} · ${this.poem.author} · ${this.poem.theme}`
            })
            Column({ space: 8 }) {
              Text('导语')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.poem.summary.length > 0 ? this.poem.summary : this.poem.body)
                .fontSize(15)
                .lineHeight(26)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(20)

            DetailSection({ heading: '原文', body: this.poem.body })
            DetailSection({ heading: '注释', body: this.poem.annotation })
            DetailSection({ heading: '译文', body: this.poem.translation })
            DetailSection({
              heading: '赏析',
              body: this.poem.appreciation.length > 0 ? this.poem.appreciation : this.poem.description
            })

            AppButton({
              label: this.favLabel(),
              onTap: (): void => { void this.toggleFav() }
            })
          }
          .padding({ left: 20, right: 20, top: 16, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#F8F4ED')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(28,40,51,0.88)')
          .borderRadius(12)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
