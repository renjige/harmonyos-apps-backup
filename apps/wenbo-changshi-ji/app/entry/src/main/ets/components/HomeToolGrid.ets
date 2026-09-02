import { Theme } from './design-system/Theme'
import { AppIcon, AppIconName } from './design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'

class ToolEntry {
  key: string = ''
  name: AppIconName = 'sparkle'
  label: string = ''
}

@Component
export struct HomeToolGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0

  private entries(): ToolEntry[] {
    const rows: ToolEntry[] = []
    const keys: string[] = ['search', 'scenes', 'quiz', 'lists', 'tools', 'remind']
    const names: AppIconName[] = ['search', 'grid', 'check', 'list', 'gear', 'bell']
    const labels: string[] = ['搜索', '场景库', '问答', '清单', '工具', '提醒']
    for (let i = 0; i < keys.length; i++) {
      const row = new ToolEntry()
      row.key = keys[i]
      row.name = names[i]
      row.label = labels[i]
      rows.push(row)
    }
    return rows
  }

  private open(key: string): void {
    if (key === 'search') {
      CommonSenseDetailNav.openSearch()
    } else if (key === 'scenes') {
      CommonSenseDetailNav.openScenes()
    } else if (key === 'quiz') {
      CommonSenseDetailNav.openQuiz()
    } else if (key === 'lists') {
      CommonSenseDetailNav.openLists()
    } else if (key === 'tools') {
      CommonSenseDetailNav.openTools()
    } else {
      CommonSenseDetailNav.openRemind()
    }
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('生活知识工具')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      GridRow({ columns: 3, gutter: 10 }) {
        ForEach(this.entries(), (row: ToolEntry) => {
          GridCol() {
            Column({ space: 6 }) {
              AppIcon({ name: row.name, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              Text(row.label)
                .fontSize(12)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.open(row.key) })
          }
        }, (row: ToolEntry) => row.key)
      }
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
