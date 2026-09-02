import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

class ActionTile {
  kind: string = ''
  name: AppIconName = 'sparkle'
  title: string = ''
  hint: string = ''
}

@Component
export struct InsightActionGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onOpen: (kind: string) => void = (_k: string) => {}
  @State tiles: ActionTile[] = []

  aboutToAppear(): void {
    const list: ActionTile[] = []
    list.push(InsightActionGrid.make('prompt', 'sparkle', '今日一问', '用一个问题把闪念写成判断'))
    list.push(InsightActionGrid.make('week', 'calendar', '本周三问', '对照应验、未写清、下周验证'))
    list.push(InsightActionGrid.make('judgment', 'check', '判断台账', '给判断标应验、落空或修正'))
    list.push(InsightActionGrid.make('recall', 'refresh', '随机回看', '抽一条旧见解，写下现在怎么看'))
    list.push(InsightActionGrid.make('quotes', 'bookmark', '金句墙', '集中回看并复制到剪贴板'))
    this.tiles = list
  }

  private static make(kind: string, name: AppIconName, title: string, hint: string): ActionTile {
    const t = new ActionTile()
    t.kind = kind
    t.name = name
    t.title = title
    t.hint = hint
    return t
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('思考工坊')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tiles, (t: ActionTile) => {
          Column({ space: 6 }) {
            AppIcon({ name: t.name, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            Text(t.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(t.hint)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
              .width('100%')
          }
          .width('47%')
          .padding(12)
          .margin({ right: 8, bottom: 8 })
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpen(t.kind) })
        }, (t: ActionTile) => t.kind)
      }
      .width('100%')
    }
    .width('100%')
  }
}
