import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ArticleItem } from '../../models/PavilionModels'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionMedia } from '../../services/PavilionMedia'
import { PavilionStore } from '../../services/PavilionStore'
import { ExploreStore } from '../../services/ExploreStore'

@Component
export struct ArticleDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: ArticleItem = new ArticleItem()
  @State favorited: boolean = false
  @State loaded: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const found = await PavilionBizService.findArticle(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      this.favorited = PavilionStore.isFavorite(found.id)
      await PavilionStore.markRead(found.id)
    }
  }

  private async toggleFavorite(): Promise<void> {
    const on = await PavilionStore.toggleFavorite(this.item.id)
    this.favorited = on
    this.showToast(on ? '已收入收藏夹' : '已取消收藏')
  }

  private async saveCard(): Promise<void> {
    await ExploreStore.saveCard(this.item.title, this.item.summary, this.item.id, '')
    this.showToast('已生成知识卡片')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.item.categoryLabel(),
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { PavilionDetailNav.close() },
        onFavorite: (): void => { void this.toggleFavorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '这篇趣知暂时找不到', description: '请返回首页刷新后再试。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(PavilionMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(61,52,44,0)', 0.28], ['rgba(61,52,44,0.82)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(`${this.item.kindLabel()} · ${this.item.readMinutes} 分钟`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F7F4F0')
                  Text(this.item.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F7F4F0')
                    .maxLines(2)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.favorited ? '取消收藏' : '收藏这篇',
                  variant: 'primary',
                  onTap: (): void => { void this.toggleFavorite() }
                })
                AppButton({
                  label: '收入收藏夹',
                  variant: 'secondary',
                  onTap: (): void => { PavilionDetailNav.openAlbums(this.item.id) }
                })
                AppButton({
                  label: '趣味问答',
                  variant: 'secondary',
                  onTap: (): void => { PavilionDetailNav.openQuiz(this.item.id) }
                })
                AppButton({
                  label: '写探索笔记',
                  variant: 'secondary',
                  onTap: (): void => { PavilionDetailNav.openNoteNew(this.item.id) }
                })
                AppButton({
                  label: '生成知识卡片',
                  variant: 'secondary',
                  onTap: (): void => { void this.saveCard() }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
