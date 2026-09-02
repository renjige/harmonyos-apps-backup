import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

/** 游客可见：计划/灵感/成长能力说明（非用户假数据，仅产品预览） */
@Component
export struct GuestCapabilityPreview {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('无需登录即可浏览')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('精选片段、场景模板、成长说明均可体验；登录后可同步计划与创作')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Row({ space: Theme.space.s3 }) {
        this.PreviewCell('灵感 Tab', '12+ 场景模板', 'ai', 1)
        this.PreviewCell('计划 Tab', '计划·待办·打卡', 'check', 2)
        this.PreviewCell('成长 Tab', '回顾与趋势', 'chart', 4)
      }
      .width('100%')

      Text('登录解锁：云端同步 · 个人计划 · 成就墙')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
        .padding({ top: 4 })
        .onClick((): void => { this.onRequireAuth() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  PreviewCell(title: string, sub: string, icon: AppIconName, tab: number) {
    Column({ space: 4 }) {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(title)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(sub)
        .fontSize(Theme.type.overline)
        .fontColor(Theme.colors().textTertiary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { AppStorage.setOrCreate('pendingTab', tab) })
  }
}
