import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AuthorRow, WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct AuthorListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State authors: AuthorRow[] = []
  @State keyword: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await WisdomHallBizService.loadAllQuotes()
    this.authors = WisdomHallBizService.extractAuthors(all)
  }

  private filtered(): AuthorRow[] {
    const kw = this.keyword.trim()
    if (kw.length === 0) {
      return this.authors
    }
    const out: AuthorRow[] = []
    for (const row of this.authors) {
      if (row.name.indexOf(kw) >= 0) {
        out.push(row)
      }
    }
    return out
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { WisdomHallNav.closeAuthorList() })
        Text('按作者浏览')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      TextInput({ text: this.keyword, placeholder: '搜索作者名' })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .onChange((v: string) => { this.keyword = v })

      if (this.filtered().length === 0) {
        AppEmpty({ title: '未找到作者', description: '试试其他关键词' })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s2 }) {
          ForEach(this.filtered(), (row: AuthorRow) => {
            ListItem() {
              Row() {
                Text(row.name)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${row.count} 条`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => {
                WisdomHallNav.closeAuthorList()
                WisdomHallNav.openLibraryAuthor(row.name)
              })
            }
          }, (row: AuthorRow) => row.name)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
