import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { NoteExportService, NoteExportSummary } from '../../services/NoteExportService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct ExportNotesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State loading: boolean = true
  @State summary: NoteExportSummary = NoteExportSummary.empty()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    this.summary = await NoteExportService.buildExportSummary()
    this.loading = false
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { WisdomHallNav.closeExport() })
          Text('数据备份')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: 8 })

        if (this.loading) {
          Column({ space: Theme.space.s3 }) {
            ForEach([0, 1, 2], (i: number) => {
              Column({ space: 8 }) {
                Column().width('40%').height(14).backgroundColor(Theme.colors().strokeHairline).borderRadius(4)
                Column().width('100%').height(60).backgroundColor(Theme.colors().strokeHairline).borderRadius(8)
              }
              .width('100%')
            }, (i: number) => `sk-${i}`)
          }
          .padding(Theme.space.pageX)
          .layoutWeight(1)
        } else if (this.summary.noteCount === 0) {
          AppEmpty({
            title: '暂无可导出笔记',
            description: '登录并创建笔记后，可在此查看导出摘要',
            actionLabel: '关闭',
            onAction: (): void => { WisdomHallNav.closeExport() }
          })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text(`已汇总 ${this.summary.noteCount} 条笔记（纯文本摘要）`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(this.summary.bodyText)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(26)
                .width('100%')
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .padding(Theme.space.s4)
                .borderRadius(Theme.radius.card)
              Text('提示：可长按选择复制全文，或通过系统分享保存到备忘录。')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              AppButton({
                label: '刷新导出',
                variant: 'secondary',
                onTap: (): void => { void this.load() }
              })
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
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
