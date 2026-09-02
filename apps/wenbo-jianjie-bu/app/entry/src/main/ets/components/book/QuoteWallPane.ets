import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { InsightEntry } from '../../models/InsightModels'
import { InsightStore } from '../../services/InsightStore'
import { ClipService } from '../../services/ClipService'

@Component
export struct QuoteWallPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  @State items: InsightEntry[] = []
  @State toastText: string = ''
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await InsightStore.quotes()
    this.loaded = true
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private cardText(n: InsightEntry): string {
    return `「${n.title}」\n${n.body}\n—— 见解簿`
  }

  private async copyOne(n: InsightEntry): Promise<void> {
    const ok = await ClipService.copyText(this.cardText(n))
    this.showToast(ok ? '已复制到剪贴板' : '复制失败')
  }

  private async copyAll(): Promise<void> {
    if (this.items.length === 0) {
      this.showToast('还没有金句')
      return
    }
    const lines: string[] = []
    for (const n of this.items) {
      lines.push(this.cardText(n))
    }
    const ok = await ClipService.copyText(lines.join('\n\n'))
    this.showToast(ok ? '已复制全部金句' : '复制失败')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({ title: '金句墙', onClose: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('用「金句」框架写下的见解会集中在这里。可单条或全部复制，方便贴进笔记或聊天。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')
            if (this.items.length > 0) {
              AppButton({
                label: '复制全部金句',
                variant: 'secondary',
                onTap: (): void => { void this.copyAll() }
              })
            }
            if (this.loaded && this.items.length === 0) {
              AppEmpty({
                title: '金句墙还是空的',
                description: '新建见解时选「金句」框架，写下原文和你的理解。',
                actionLabel: '',
                onAction: (): void => {}
              })
            }
            ForEach(this.items, (n: InsightEntry) => {
              Column({ space: 8 }) {
                Text(n.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .onClick((): void => { this.onOpen(n.id) })
                Text(n.summaryLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text('复制这条')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .onClick((): void => { void this.copyOne(n) })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (n: InsightEntry) => n.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
