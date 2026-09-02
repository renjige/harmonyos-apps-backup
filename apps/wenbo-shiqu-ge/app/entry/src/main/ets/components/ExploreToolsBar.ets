import { Theme } from './design-system/Theme'
import { PavilionDetailNav } from '../services/PavilionDetailNav'

class ToolChip {
  id: string = ''
  label: string = ''
}

@Component
export struct ExploreToolsBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  private tools: ToolChip[] = ExploreToolsBar.buildTools()

  private static buildTools(): ToolChip[] {
    const a = new ToolChip()
    a.id = 'logs'
    a.label = '探索记录'
    const b = new ToolChip()
    b.id = 'finds'
    b.label = '每日发现'
    const c = new ToolChip()
    c.id = 'tasks'
    c.label = '趣味挑战'
    const d = new ToolChip()
    d.id = 'wish'
    d.label = '兴趣清单'
    const e = new ToolChip()
    e.id = 'notes'
    e.label = '趣味笔记'
    const list: ToolChip[] = []
    list.push(a)
    list.push(b)
    list.push(c)
    list.push(d)
    list.push(e)
    return list
  }

  private openTool(id: string): void {
    if (id === 'logs') {
      PavilionDetailNav.openLogs()
      return
    }
    if (id === 'finds') {
      PavilionDetailNav.openFinds()
      return
    }
    if (id === 'tasks') {
      PavilionDetailNav.openTasks()
      return
    }
    if (id === 'wish') {
      PavilionDetailNav.openWish()
      return
    }
    PavilionDetailNav.openNotes()
  }

  build() {
    Column({ space: 8 }) {
      Text('我的探索')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
        .width('100%')
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.tools, (t: ToolChip) => {
            Text(t.label)
              .fontSize(13)
              .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(Theme.brandBox(this.themeEpoch, this.darkModeOn))
              .borderRadius(8)
              .onClick((): void => { this.openTool(t.id) })
          }, (t: ToolChip) => t.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
