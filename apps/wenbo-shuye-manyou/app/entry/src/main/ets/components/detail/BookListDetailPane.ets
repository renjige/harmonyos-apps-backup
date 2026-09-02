import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { BookListItem, ListBookItem } from '../../models/RoamModels'
import { RoamBizService } from '../../services/RoamBizService'
import { RoamDetailNav } from '../../services/RoamDetailNav'
import { RoamMedia } from '../../services/RoamMedia'

@Component
export struct BookListDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop listId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State list: BookListItem = new BookListItem()
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await RoamBizService.findList(this.listId)
    if (found !== undefined) {
      this.list = found
      this.loaded = true
    }
  }

  build() {
    DetailShell({
      title: '主题书单',
      onClose: (): void => { RoamDetailNav.close() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '书单不存在', description: '请返回后刷新再试。' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(RoamMedia.resource(this.list.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(45,74,62,0)', 0.32], ['rgba(45,74,62,0.76)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.list.month)
                  .fontSize(Theme.type.caption)
                  .fontColor('#F4EFE6')
                Text(this.list.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F4EFE6')
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.list.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            ForEach(this.list.books, (book: ListBookItem, index: number) => {
              Row({ space: Theme.space.s3 }) {
                Image(RoamMedia.resource(book.coverKey))
                  .width(72)
                  .height(96)
                  .borderRadius(Theme.radius.sm)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(book.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                  Text(book.author)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Text(book.summary)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .onClick((): void => {
                RoamDetailNav.openListBook(this.list.id, index)
              })
            }, (book: ListBookItem, index: number) => `${this.list.id}_${index}_${book.title}`)
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
