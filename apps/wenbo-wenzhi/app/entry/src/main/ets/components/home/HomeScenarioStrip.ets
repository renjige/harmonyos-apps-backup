import { Theme } from '../design-system/Theme'
import { AppIconName } from '../design-system/AppIcon'
import { AskNav } from '../../services/AskNav'
import { PathStore } from '../../services/PathStore'
import { HomeCompactTile } from './HomeCompactTile'

class ScenarioItem {
  title: string = ''
  sub: string = ''
  icon: AppIconName = 'home'
  action: string = ''
}

@Component
export struct HomeScenarioStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private items: ScenarioItem[] = HomeScenarioStrip.rows()

  private static rows(): ScenarioItem[] {
    const out: ScenarioItem[] = []
    const defs: string[][] = [
      ['备考复习', '路径 + 闪卡', 'chart', 'path'],
      ['职场充电', '专题 + 笔记', 'biz', 'catalog'],
      ['日常科普', '新知 + 答题', 'book', 'daily'],
      ['错题巩固', '专项再练', 'alert', 'wrong'],
      ['知识整理', '六类收藏', 'bookmark', 'vault'],
      ['习惯打卡', '计划 + 日历', 'check', 'calendar']
    ]
    for (const d of defs) {
      const row = new ScenarioItem()
      row.title = d[0]
      row.sub = d[1]
      row.icon = d[2] as AppIconName
      row.action = d[3]
      out.push(row)
    }
    return out
  }

  private open(item: ScenarioItem): void {
    if (item.action === 'path') {
      void PathStore.ensureReady().then((): void => {
        const id = PathStore.firstIncompletePathId()
        if (id.length > 0) {
          AskNav.openPath(id)
          return
        }
        AskNav.switchTab(1)
      })
      return
    }
    if (item.action === 'catalog') {
      AskNav.openLearn('catalog')
      return
    }
    if (item.action === 'daily') {
      AskNav.switchTab(3)
      return
    }
    if (item.action === 'wrong') {
      AskNav.openLearn('wrong')
      return
    }
    if (item.action === 'vault') {
      AskNav.switchTab(2)
      return
    }
    if (item.action === 'calendar') {
      AskNav.openLearn('calendar')
      return
    }
    AskNav.switchTab(1)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('适用场景')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
      Grid() {
        ForEach(this.items, (item: ScenarioItem) => {
          GridItem() {
            HomeCompactTile({
              title: item.title,
              sub: item.sub,
              icon: item.icon,
              onTap: (): void => { this.open(item) }
            })
          }
        }, (item: ScenarioItem) => item.action)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Theme.space.s2)
      .rowsGap(Theme.space.s2)
      .width('100%')
    }
    .width('100%')
  }
}
