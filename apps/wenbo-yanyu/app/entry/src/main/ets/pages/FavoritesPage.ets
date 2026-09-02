import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { FavoriteSnapshot } from '../models/LanguageCraftModels'
import { FavoriteStore } from '../services/FavoriteStore'
import { LanguageCraftMedia } from '../services/LanguageCraftMedia'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { ClipboardService } from '../services/ClipboardService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State items: FavoriteSnapshot[] = []
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await FavoriteStore.list()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2200)
  }

  private async copySummary(text: string): Promise<void> {
    const ok = await ClipboardService.copyText(text)
    this.showToast(ok ? '已复制摘要' : '复制失败')
  }

  private async removeFav(id: string): Promise<void> {
    await FavoriteStore.remove(id)
    await this.reload()
    this.showToast('已取消收藏')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => {
            LanguageCraftNav.closeFavorites()
            this.onClose()
          })
          Text('收藏夹')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有收藏', description: '在灵感页点爱心或详情里收藏' })
            } else {
              ForEach(this.items, (row: FavoriteSnapshot) => {
                Row({ space: Theme.space.s3 }) {
                  Image(LanguageCraftMedia.cover(row.coverKey))
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.md)
                    .objectFit(ImageFit.Cover)
                  Column({ space: 4 }) {
                    Text(row.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.of(this.darkModeOn).textPrimary)
                      .maxLines(2)
                      .width('100%')
                    Text(row.summary)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.of(this.darkModeOn).textSecondary)
                      .maxLines(2)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => {
                  LanguageCraftNav.openDetail(row.inspirationId)
                })

                Row({ space: Theme.space.s2 }) {
                  Column() {
                    AppButton({
                      label: '复制摘要',
                      variant: 'secondary',
                      onTap: (): void => { void this.copySummary(row.summary) }
                    })
                  }
                  .layoutWeight(1)
                  Column() {
                    AppButton({
                      label: '取消收藏',
                      variant: 'ghost',
                      onTap: (): void => { void this.removeFav(row.inspirationId) }
                    })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .margin({ top: -Theme.space.s2 })
              }, (row: FavoriteSnapshot) => row.inspirationId)
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
