import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

class QuickActionDef {
  label: string = ''
  icon: AppIconName = 'home'
  route: string = ''
}

@Component
export struct QuickActionRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onAction: (route: string) => void = (_r: string) => {}

  private row1(): QuickActionDef[] {
    const out: QuickActionDef[] = []
    const defs: string[][] = [
      ['精选课', 'biz', 'presets'],
      ['跟练', 'check', 'presets'],
      ['自测', 'chart', 'quiz'],
      ['编排', 'add', 'combo']
    ]
    for (const row of defs) {
      const a = new QuickActionDef()
      a.label = row[0]
      a.icon = row[1] as AppIconName
      a.route = row[2]
      out.push(a)
    }
    return out
  }

  private row2(): QuickActionDef[] {
    const out: QuickActionDef[] = []
    const defs: string[][] = [
      ['图鉴', 'biz', 'catalog'],
      ['打卡', 'check', 'logform'],
      ['周报', 'message', 'weeklyreport'],
      ['挑战', 'ai', 'challenge']
    ]
    for (const row of defs) {
      const a = new QuickActionDef()
      a.label = row[0]
      a.icon = row[1] as AppIconName
      a.route = row[2]
      out.push(a)
    }
    return out
  }

  @Builder
  ActionRow(items: QuickActionDef[]) {
    Row() {
      ForEach(items, (a: QuickActionDef) => {
        Column({ space: 6 }) {
          Column() {
            AppIcon({
              name: a.icon,
              iconSize: Theme.icon.md,
              color: Theme.colors().brandPrimary
            })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          Text(a.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick((): void => { this.onAction(a.route) })
      }, (a: QuickActionDef) => `${a.label}_${a.route}`)
    }
    .width('100%')
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      this.ActionRow(this.row1())
      this.ActionRow(this.row2())
    }
    .width('100%')
    .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
  }
}
