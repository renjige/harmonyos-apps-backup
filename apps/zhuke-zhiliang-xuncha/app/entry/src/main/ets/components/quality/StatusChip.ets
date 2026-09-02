import { Theme } from '../design-system/Theme'

@Component
export struct StatusChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop tone: string = 'neutral'

  private bg(): string {
    const c = Theme.colors()
    if (this.tone === 'success' || this.label === '已完成' || this.label === '已闭环' || this.label === '巡查正常') {
      return c.successContainer
    }
    if (this.tone === 'warning' || this.label === '重要' || this.label === '整改中' || this.label === '进行中') {
      return c.warningContainer
    }
    if (this.tone === 'danger' || this.label === '严重' || this.label === '待整改') {
      return c.dangerContainer
    }
    if (this.label === '一般' || this.label === '待完成' || this.label === '示例') {
      return c.surfaceSubtle
    }
    return c.brandPrimaryContainer
  }

  private fg(): string {
    const c = Theme.colors()
    if (this.tone === 'success' || this.label === '已完成' || this.label === '已闭环' || this.label === '巡查正常') {
      return c.success
    }
    if (this.tone === 'warning' || this.label === '重要' || this.label === '整改中' || this.label === '进行中') {
      return c.warning
    }
    if (this.tone === 'danger' || this.label === '严重' || this.label === '待整改') {
      return c.danger
    }
    if (this.label === '一般' || this.label === '待完成' || this.label === '示例') {
      return c.textSecondary
    }
    return c.brandPrimary
  }

  build() {
    Text(this.label)
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.fg())
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .backgroundColor(this.bg())
      .borderRadius(Theme.radius.pill)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
