import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CaptureListCard } from '../components/capture/CaptureListCard'
import { CaptureItem } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct FocusListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @StorageLink('zwFocusTitle') title: string = ''
  @StorageLink('zwFocusKind') @Watch('onKind') kind: string = ''
  @StorageLink('zwFocusKey') @Watch('onKey') focusKey: string = ''
  @State items: CaptureItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  onKind(): void {
    this.reload()
  }

  onKey(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ZhiweiStore.focusItems(this.kind, this.focusKey)
  }

  private summaryOf(item: CaptureItem): string {
    if (item.body.length <= 48) {
      return item.body
    }
    return `${item.body.substring(0, 48)}…`
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeFocus())
        Text(this.title.length > 0 ? this.title : '相关收录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '这一组还没有收录',
            description: '换个分类试试，或回去记一条微知识。'
          })
        }
        .layoutWeight(1)
        .padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(`共 ${this.items.length} 条，点开可跟进或消化`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            ForEach(this.items, (item: CaptureItem) => {
              CaptureListCard({
                itemId: item.id,
                title: item.title,
                summary: this.summaryOf(item),
                category: item.category,
                priority: item.priority,
                status: item.status,
                timeLabel: ZhiweiStore.displayTime(item.updatedAt),
                onTap: (): void => ZhiweiNav.openCapture(item.id)
              })
            }, (item: CaptureItem) => item.id)
            Blank().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
    .id(`focus_${this.themeEpoch}`)
  }
}
