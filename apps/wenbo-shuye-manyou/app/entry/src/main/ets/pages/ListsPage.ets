import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { BookListItem, ListBookItem } from '../models/RoamModels'
import { RoamBizService } from '../services/RoamBizService'
import { RoamDetailNav } from '../services/RoamDetailNav'
import { RoamMedia } from '../services/RoamMedia'

@Component
export struct ListsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State lists: BookListItem[] = []
  @State selectedIndex: number = 0
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.lists = await RoamBizService.loadLists()
    if (this.selectedIndex >= this.lists.length) {
      this.selectedIndex = 0
    }
    this.loading = false
  }

  private currentList(): BookListItem {
    if (this.lists.length === 0 || this.selectedIndex < 0 || this.selectedIndex >= this.lists.length) {
      return new BookListItem()
    }
    return this.lists[this.selectedIndex]
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('主题书单')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.loading) {
          AppEmpty({ title: '正在加载书单…', description: '' })
        } else if (this.lists.length === 0) {
          AppEmpty({
            title: '暂无书单',
            description: '请检查网络后重试。',
            actionLabel: '重试',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.lists, (list: BookListItem, index: number) => {
                Text(list.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.selectedIndex === index ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedIndex === index ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.selectedIndex = index })
              }, (list: BookListItem) => list.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image(RoamMedia.resource(this.currentList().coverKey))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(45,74,62,0)', 0.32], ['rgba(45,74,62,0.76)', 1]]
              })
            Column({ space: 6 }) {
              Text(this.currentList().month)
                .fontSize(Theme.type.caption)
                .fontColor('#F4EFE6')
              Text(this.currentList().title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F4EFE6')
            }
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius(Theme.radius.card)
          .clip(true)
          .onClick((): void => { RoamDetailNav.openBookList(this.currentList().id) })

          Text(this.currentList().summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .width('100%')

          ForEach(this.currentList().books, (book: ListBookItem, index: number) => {
            Row({ space: Theme.space.s3 }) {
              Image(RoamMedia.resource(book.coverKey))
                .width(56)
                .height(76)
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
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => {
              RoamDetailNav.openListBook(this.currentList().id, index)
            })
          }, (book: ListBookItem, index: number) => `${this.currentList().id}_${index}_${book.title}`)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
