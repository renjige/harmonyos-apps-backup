import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CaptureListCard } from '../components/capture/CaptureListCard'
import { CaptureItem } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct InboxPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State inbox: CaptureItem[] = []
  @State follow: CaptureItem[] = []
  @State done: CaptureItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.inbox = ZhiweiStore.inboxByStatus('inbox')
    this.follow = ZhiweiStore.inboxByStatus('follow')
    const allDone = ZhiweiStore.inboxByStatus('done')
    const recent: CaptureItem[] = []
    let i = 0
    for (const it of allDone) {
      if (i >= 5) {
        break
      }
      recent.push(it)
      i += 1
    }
    this.done = recent
  }

  private summaryOf(item: CaptureItem): string {
    if (item.nextAction.length > 0) {
      return `下一步：${item.nextAction}`
    }
    if (item.body.length <= 40) {
      return item.body
    }
    return `${item.body.substring(0, 40)}…`
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
        .onClick(() => ZhiweiNav.closeInbox())
        Text('消化处理台')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('把新收录的微知识从「待消化」推进到「跟进中」，完成后再标为「已消化」。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            .width('100%')
          this.Section('待消化', this.inbox)
          this.Section('跟进中', this.follow)
          this.Section('最近已消化', this.done)
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }

  @Builder
  Section(title: string, items: CaptureItem[]) {
    Column({ space: Theme.space.s2 }) {
      Text(`${title}（${items.length}）`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
      if (items.length === 0) {
        Text('暂无条目')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.sm)
      } else {
        ForEach(items, (item: CaptureItem) => {
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
        }, (item: CaptureItem) => `inbox_${item.id}`)
      }
    }
    .width('100%')
  }
}
