import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SectionTitle, TemplateCard, TipCard } from '../components/travel/TravelCards'
import { TravelTemplate, TravelTip } from '../models/TravelModels'
import { TravelService } from '../services/TravelService'

@Component
export struct GuidePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State templates: TravelTemplate[] = []
  @State tips: TravelTip[] = []
  @State filteredTemplates: TravelTemplate[] = []
  @State filteredTips: TravelTip[] = []
  @State keyword: string = ''
  @State category: string = '全部'
  @State loading: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onOpenTemplate: (item: TravelTemplate) => void = () => {}
  onOpenTip: (item: TravelTip) => void = () => {}
  onOpenSearch: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load(true)
  }

  private async load(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.loading = true
    }
    try {
      this.templates = await TravelService.templates()
      this.tips = await TravelService.tips()
      this.applyFilter()
    } catch {
      this.templates = []
      this.tips = []
      this.filteredTemplates = []
      this.filteredTips = []
    }
    this.loading = false
  }

  private applyFilter(): void {
    const q = this.keyword.trim().toLowerCase()
    const tplOut: TravelTemplate[] = []
    for (const item of this.templates) {
      if (this.category !== '全部' && this.category !== '模板') {
        continue
      }
      const hay = `${item.title} ${item.destination} ${item.summary}`.toLowerCase()
      if (q.length === 0 || hay.includes(q)) {
        tplOut.push(item)
      }
    }
    const tipOut: TravelTip[] = []
    for (const item of this.tips) {
      if (this.category !== '全部' && this.category !== '贴士') {
        continue
      }
      const hay = `${item.title} ${item.summary} ${item.body}`.toLowerCase()
      if (q.length === 0 || hay.includes(q)) {
        tipOut.push(item)
      }
    }
    this.filteredTemplates = tplOut
    this.filteredTips = tipOut
  }

  build() {
    Column() {
      AppHeader({ title: '出行攻略', subtitle: '行程模板与出发前实用贴士' })
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          TextInput({ text: this.keyword, placeholder: '搜索模板或贴士' })
            .layoutWeight(1)
            .height(44)
            .fontSize(Theme.type.subhead)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .onChange((v: string) => {
              this.keyword = v
              this.applyFilter()
            })
          Row() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onOpenSearch())
        }
        Row({ space: Theme.space.s2 }) {
          this.FilterChip('全部')
          this.FilterChip('模板')
          this.FilterChip('贴士')
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('从模板一键生成行程、每日安排、打包清单与出发提醒，再按个人需求微调。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          if (this.loading) {
            LoadingProgress()
              .width(32)
              .height(32)
              .color(Theme.colors().brandPrimary)
          }
          SectionTitle({ title: '行程模板', action: `${this.filteredTemplates.length} 套` })
          if (this.filteredTemplates.length === 0 && !this.loading) {
            AppEmpty({
              title: '暂无匹配模板',
              description: '换个关键词或切换分类试试',
              actionLabel: '重新加载',
              onAction: () => { void this.load() }
            })
          } else {
            ForEach(this.filteredTemplates, (item: TravelTemplate) => {
              TemplateCard({ item: item, onTap: () => this.onOpenTemplate(item) })
            }, (item: TravelTemplate) => item.id)
          }
          SectionTitle({ title: '出行贴士', action: `${this.filteredTips.length} 篇` })
          if (this.filteredTips.length === 0 && !this.loading) {
            AppEmpty({
              title: '暂无匹配贴士',
              description: '换个关键词或切换分类试试',
              actionLabel: '重新加载',
              onAction: () => { void this.load() }
            })
          } else {
            ForEach(this.filteredTips, (item: TravelTip) => {
              TipCard({ item: item, onTap: () => this.onOpenTip(item) })
            }, (item: TravelTip) => item.id)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  FilterChip(label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.category === label ? '#FFFFFF' : Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.category === label ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.category = label
        this.applyFilter()
      })
  }
}
