import { Theme } from '../design-system/Theme'
import { AppIconName } from '../design-system/AppIcon'
import { AskNav } from '../../services/AskNav'
import { HomeCompactTile } from './HomeCompactTile'

class HubEntry {
  title: string = ''
  sub: string = ''
  icon: AppIconName = 'home'
  panel: string = ''
}

@Component
export struct HomeHubGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private items: HubEntry[] = HomeHubGrid.entries()

  private static entries(): HubEntry[] {
    const rows: HubEntry[] = []
    const defs: string[][] = [
      ['学习路径', '4 条专题', 'chart', 'paths'],
      ['闪卡复习', '卡片错题', 'bookmark', 'flashcards'],
      ['知识挑战', '5/10 题', 'chart', 'challenge5'],
      ['错题再练', '薄弱专项', 'alert', 'wrong'],
      ['学习计划', '目标打卡', 'check', 'plan'],
      ['学习日历', '14 日热力', 'biz', 'calendar'],
      ['知识检索', '分类关键词', 'search', 'catalog'],
      ['我的笔记', '知识沉淀', 'book', 'notes']
    ]
    for (const d of defs) {
      const row = new HubEntry()
      row.title = d[0]
      row.sub = d[1]
      row.icon = d[2] as AppIconName
      row.panel = d[3]
      rows.push(row)
    }
    return rows
  }

  private open(item: HubEntry): void {
    if (item.panel === 'paths') {
      AskNav.switchTab(1)
      return
    }
    if (item.panel === 'challenge5') {
      AskNav.openChallenge(5)
      return
    }
    if (item.panel === 'flashcards') {
      AskNav.openLearn('flashcards')
      return
    }
    if (item.panel === 'calendar') {
      AskNav.openLearn('calendar')
      return
    }
    AskNav.openLearn(item.panel)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('学习功能中心')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
      Grid() {
        ForEach(this.items, (item: HubEntry) => {
          GridItem() {
            HomeCompactTile({
              title: item.title,
              sub: item.sub,
              icon: item.icon,
              onTap: (): void => { this.open(item) }
            })
          }
        }, (item: HubEntry) => item.panel)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Theme.space.s2)
      .rowsGap(Theme.space.s2)
      .width('100%')
    }
    .width('100%')
  }
}
