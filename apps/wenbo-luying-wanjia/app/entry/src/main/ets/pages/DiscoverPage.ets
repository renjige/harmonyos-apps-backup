import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppLoading } from '../components/design-system/AppLoading'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CatalogItem } from '../models/CampModels'
import { CampCard } from '../components/camp/CampCard'

@Component
export struct DiscoverPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State keyword: string = ''
  @State typeFilter: string = '全部'
  @State items: CatalogItem[] = []
  private types: string[] = ['全部', '野营', '房车营地', '公园营地']

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await CampBizService.loadCamps()
    this.loading = false
  }

  private visible(): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const c of this.items) {
      let ok = true
      if (this.typeFilter !== '全部' && c.campType !== this.typeFilter) {
        ok = false
      }
      if (this.keyword.trim().length > 0) {
        const k = this.keyword.trim()
        if (c.title.indexOf(k) < 0 && c.region.indexOf(k) < 0) {
          ok = false
        }
      }
      if (ok) {
        out.push(c)
      }
    }
    return out
  }

  build() {
    Column() {
      AppHeader({ title: '发现营地', subtitle: '按地区与类型浏览' })
      TextInput({ text: this.keyword, placeholder: '搜索名称或地区' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .onChange((v: string) => { this.keyword = v })
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.types, (t: string) => {
            Text(t)
              .fontSize(Theme.type.caption)
              .fontColor(this.typeFilter === t ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.typeFilter === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.typeFilter = t })
          }, (t: string) => t)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      if (this.loading) {
        AppLoading({ label: '打开营地档案' }).layoutWeight(1)
      } else if (this.visible().length === 0) {
        AppEmpty({
          title: '没有匹配的营地',
          description: '换个类型或清空搜索',
          actionLabel: '重试',
          onAction: () => { void this.reload() }
        }).layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.visible(), (c: CatalogItem) => {
            ListItem() {
              CampCard({
                title: c.title,
                summary: c.summary,
                coverKey: c.coverKey,
                region: c.region,
                campType: c.campType,
                rating: c.rating,
                onTap: () => CampDetailNav.openCamp(c.id)
              })
            }
          }, (c: CatalogItem) => c.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
