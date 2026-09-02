import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { BookListItem, ListBookItem } from '../../models/InkModels'
import { InkBizService } from '../../services/InkBizService'
import { InkDetailNav } from '../../services/InkDetailNav'
import { InkMedia } from '../../services/InkMedia'

@Component
export struct ListDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop listId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: BookListItem = new BookListItem()
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await InkBizService.findList(this.listId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  build() {
    DetailShell({
      title: '书房书单',
      onClose: (): void => { InkDetailNav.close() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '书单不存在', description: '请返回后刷新。' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(InkMedia.resource(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0.22], ['rgba(26,26,46,0.82)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.item.theme)
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8D5A3')
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F4EFE4')
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
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(24)
                .width('100%')
            }
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            ForEach(this.item.books, (b: ListBookItem, idx: number) => {
              Column({ space: 4 }) {
                Text(b.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(b.hint)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            }, (b: ListBookItem, idx: number) => `bk-${idx}`)

            Column() {
              AppButton({
                label: '去读今日书摘',
                variant: 'primary',
                onTap: (): void => {
                  InkDetailNav.close()
                  InkDetailNav.switchTab(0)
                }
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
      }
    }
  }
}
