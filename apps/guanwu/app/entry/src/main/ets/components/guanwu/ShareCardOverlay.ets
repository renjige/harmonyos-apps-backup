import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ObserveRecord } from '../../models/ObserveModels'
import { CategoryOption } from '../../models/ObserveCatalog'
import { DateHelper } from '../../services/DateHelper'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct ShareCardOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: ObserveRecord = new ObserveRecord()
  onClose: () => void = () => {}
  @State toastText: string = ''

  private cardText(): string {
    const lines: string[] = []
    lines.push('观物 · 观察笔记')
    lines.push(DateHelper.displayDate(this.record.dateKey))
    if (this.record.itemName.length > 0) {
      lines.push(this.record.itemName)
    }
    lines.push(`${this.record.kindLabel()} · ${CategoryOption.labelOf(this.record.categoryKey)}`)
    if (this.record.tags.length > 0) {
      lines.push(`标签 ${this.record.tags}`)
    }
    lines.push(this.record.content)
    lines.push('—— 用观察收藏日常')
    return lines.join('\n')
  }

  private async copyCard(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.cardText())
      await pasteboard.getSystemPasteboard().setData(data)
      this.toastText = '卡片文案已复制，可粘贴到备忘录或截图本页分享'
      setTimeout((): void => { this.toastText = '' }, 2600)
    } catch {
      this.toastText = '复制失败'
      setTimeout((): void => { this.toastText = '' }, 2200)
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => this.onClose())

      Column({ space: Theme.space.s4 }) {
        Text('观察笔记卡片')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('观物')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
          Text(this.record.itemName.length > 0 ? this.record.itemName : this.record.kindLabel())
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text(`${DateHelper.displayDate(this.record.dateKey)} · ${CategoryOption.labelOf(this.record.categoryKey)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          Text(this.record.content)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(24)
          if (this.record.tags.length > 0) {
            Text(this.record.tags)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
        }
        .width('100%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)

        AppButton({ label: '复制卡片文案', variant: 'primary', onTap: (): void => { void this.copyCard() } })
        AppButton({ label: '关闭', variant: 'secondary', onTap: (): void => this.onClose() })
      }
      .width('88%')
      .padding(Theme.space.s5)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 40 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
