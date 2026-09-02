import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ListBookItem } from '../../models/RoamModels'
import { RoamBizService } from '../../services/RoamBizService'
import { RoamDetailNav } from '../../services/RoamDetailNav'
import { RoamMedia } from '../../services/RoamMedia'

@Component
export struct ListBookDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop listId: string = ''
  @Prop bookIndex: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State book: ListBookItem = new ListBookItem()
  @State listTitle: string = ''
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await RoamBizService.findList(this.listId)
    if (found !== undefined && this.bookIndex >= 0 && this.bookIndex < found.books.length) {
      this.listTitle = found.title
      this.book = found.books[this.bookIndex]
      this.loaded = true
    }
  }

  private handleBackToList(): void {
    RoamDetailNav.backToBookList(this.listId)
  }

  build() {
    DetailShell({
      title: '书籍详情',
      onClose: (): void => { RoamDetailNav.close() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '书籍不存在', description: '请返回书单再试。' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(RoamMedia.resource(this.book.coverKey))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(45,74,62,0)', 0.28], ['rgba(45,74,62,0.78)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.listTitle)
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8DFD0')
                Text(this.book.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F4EFE6')
                  .maxLines(2)
                Text(this.book.author)
                  .fontSize(Theme.type.footnote)
                  .fontColor('#E8DFD0')
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s2 }) {
              Text('内容简介')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.book.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s2 }) {
              Text('推荐理由')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.book.reason)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(26)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Row() {
              AppButton({
                label: '返回书单',
                variant: 'secondary',
                onTap: (): void => { this.handleBackToList() }
              })
            }
            .width('100%')
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .onClick((): void => { this.handleBackToList() })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
