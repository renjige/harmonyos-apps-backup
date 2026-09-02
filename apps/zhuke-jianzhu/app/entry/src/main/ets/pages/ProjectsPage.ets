/** 项目列表 — 高级卡片布局 */
import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { ZhukeProjectCard } from '../components/zhuke/ZhukeProjectCard'
import { BizService, EngProjectView } from '../services/BizService'

class SegmentItem {
  code: string = ''
  label: string = ''

  static all(): SegmentItem[] {
    const codes: string[] = ['all', 'planned', 'in_progress', 'accepting', 'archived']
    const labels: string[] = ['全部', '立项', '在建', '验收', '归档']
    const list: SegmentItem[] = []
    for (let i = 0; i < codes.length; i++) {
      const s = new SegmentItem()
      s.code = codes[i]
      s.label = labels[i]
      list.push(s)
    }
    return list
  }
}

@Component
export struct ProjectsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State keyword: string = ''
  @State segment: string = 'all'
  @State items: EngProjectView[] = []
  @State loading: boolean = true
  private segments: SegmentItem[] = SegmentItem.all()
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.loadItems()
  }

  onRefreshChange(): void {
    this.loadItems()
  }

  private async loadItems(): Promise<void> {
    this.loading = true
    this.items = await BizService.listProjects(this.segment, this.keyword)
    this.loading = false
  }

  build() {
    Column() {
      Column({ space: Theme.space.s2 }) {
        Text('项目')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('全生命周期工程管理')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.keyword, placeholder: '搜索项目名称 / 编号' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding({ left: Theme.space.s4, right: Theme.space.s4 })
          .onChange((v: string) => { this.keyword = v })
        Button('搜索')
          .height(44)
          .backgroundColor(Theme.colors().brandPrimary)
          .fontColor(Theme.colors().brandOnPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.loadItems())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.segments, (s: SegmentItem) => {
            Text(s.label)
              .fontSize(Theme.type.subhead)
              .fontColor(this.segment === s.code ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({
                left: Theme.space.s4,
                right: Theme.space.s4,
                top: Theme.space.s2,
                bottom: Theme.space.s2
              })
              .backgroundColor(this.segment === s.code ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .border({
                width: this.segment === s.code ? 0 : 1,
                color: Theme.colors().strokeHairline
              })
              .onClick(() => {
                this.segment = s.code
                this.loadItems()
              })
          }, (s: SegmentItem) => s.code)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: Theme.space.s4 })

      if (this.loading) {
        AppLoading({ label: '加载项目中' })
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '暂无工程项目',
          description: '可在管理后台录入项目，或联系管理员初始化数据'
        })
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (row: EngProjectView) => {
            ListItem() {
              ZhukeProjectCard({
                item: row,
                onTap: () => this.onOpenDetail(row.id)
              })
            }
          }, (row: EngProjectView) => row.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
