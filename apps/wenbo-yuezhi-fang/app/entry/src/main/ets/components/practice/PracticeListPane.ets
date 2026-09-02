import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { PracticeItem } from '../../models/PracticeModels'
import { AtelierPractice } from '../../services/AtelierPractice'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'

@Component
export struct PracticeListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: PracticeItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = AtelierPractice.all()
  }

  build() {
    DetailShell({
      title: '我的课业',
      onClose: (): void => { AtelierDetailNav.close() }
    }) {
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有课业',
          description: '在发现页工坊台选一种练习，写完会留在这里，仅自己可见。',
          actionLabel: '去做一页',
          onAction: (): void => { AtelierDetailNav.openWorkNew('review', '') }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (row: PracticeItem) => {
              Column({ space: 4 }) {
                Text(`${row.kindLabel()} · ${row.dateKey}`)
                  .fontSize(12)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
                Text(row.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .maxLines(1)
                  .width('100%')
                Text(row.preview())
                  .fontSize(13)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .maxLines(2)
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(12)
              .onClick((): void => { AtelierDetailNav.openWorkEdit(row.id) })
            }, (row: PracticeItem) => row.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
