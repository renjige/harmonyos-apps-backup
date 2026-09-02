import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { XdDateUtil, XdMemoryAlbumItem } from '../../models/XdModels'
import { XdStore } from '../../services/XdStore'
import { XdDetailNav } from '../../services/XdDetailNav'

@Component
export struct MemoryAlbumSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('xdDataRev') @Watch('onDataRev') dataRev: number = 0
  @State monthKey: string = XdDateUtil.monthKey(new Date())
  @State items: XdMemoryAlbumItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await XdStore.buildMemoryAlbum(this.monthKey)
  }

  private openItem(item: XdMemoryAlbumItem): void {
    XdDetailNav.closeMemoryAlbum()
    if (item.kind === 'clip') {
      XdDetailNav.openClip(item.id)
      return
    }
    XdDetailNav.openEntry(item.id)
  }

  build() {
    DetailShell({ title: '回忆册', onClose: (): void => { XdDetailNav.closeMemoryAlbum() } }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text(`${this.monthKey.substring(0, 4)}年${parseInt(this.monthKey.substring(5, 7), 10)}月 Highlights`)
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.items.length === 0) {
            AppEmpty({ title: '本月还没有珍藏片段', description: '把慢记或瞬间标记为珍藏/重要后会出现在这里' })
          } else {
            ForEach(this.items, (item: XdMemoryAlbumItem) => {
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${item.dateKey} · ${item.subtitle}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openItem(item) })
            }, (item: XdMemoryAlbumItem) => `${item.kind}_${item.id}`)
          }
          Column().height(Theme.space.s10)
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
  }
}
