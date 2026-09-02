import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { InsectCatalog, InsectWikiItem } from '../../models/InsectCatalog'
import { InsectMedia } from '../../services/InsectMedia'

@Component
export struct WikiListSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onBack: () => void = () => {}
  onOpen: (id: string) => void = (id: string): void => { id.length }
  @State query: string = ''
  @State items: InsectWikiItem[] = InsectCatalog.all()

  private applySearch(v: string): void {
    this.query = v
    this.items = InsectCatalog.search(v)
  }

  build() {
    Column() {
      AppNavBar({ title: '昆虫知识库', onBack: (): void => this.onBack() })
      TextInput({ text: this.query, placeholder: '按名称或特征搜索' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .onChange((v: string): void => this.applySearch(v))
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: InsectWikiItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(InsectMedia.cover(item.coverKey))
                .width(72)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Column({ space: 4 }) {
                Text(item.name)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(item.habit)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => this.onOpen(item.id))
          }, (item: InsectWikiItem) => item.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
