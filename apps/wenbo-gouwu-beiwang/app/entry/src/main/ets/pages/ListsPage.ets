import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { ListMiniCard, SectionTitle, TemplateCard } from '../components/shop/ShoppingCards'
import { ShoppingList, ShoppingTemplate } from '../models/ShoppingModels'
import { ShoppingService } from '../services/ShoppingService'
import { ShoppingCatalog } from '../services/ShoppingCatalog'

@Component
export struct ListsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State filter: string = 'all'
  @State kind: string = '全部'
  @State keyword: string = ''
  @State lists: ShoppingList[] = []
  @State templates: ShoppingTemplate[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  @Prop templatesOnly: boolean = false
  onOpenList: (id: string) => void = () => {}
  onCreateList: () => void = () => {}
  onOpenTemplate: (tpl: ShoppingTemplate) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.lists = await ShoppingService.lists()
    this.templates = await ShoppingService.templates()
  }

  private visible(): ShoppingList[] {
    const key = this.keyword.trim()
    const out: ShoppingList[] = []
    for (const row of this.lists) {
      if (this.filter === 'active' && row.status === 'done') {
        continue
      }
      if (this.filter === 'done' && row.status !== 'done') {
        continue
      }
      if (this.filter === 'star' && !row.starred) {
        continue
      }
      if (this.kind !== '全部' && row.kind !== this.kind) {
        continue
      }
      if (key.length > 0 && row.title.indexOf(key) < 0) {
        continue
      }
      out.push(row)
    }
    return out
  }

  @Builder
  FilterChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.filter === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.filter === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.filter = value })
  }

  build() {
    Column() {
      AppHeader({
        title: this.templatesOnly ? '清单模板' : '我的清单',
        subtitle: this.templatesOnly ? '按场景一键生成可勾选清单' : '搜索、复用模板，勾选完自动记为已完成'
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (!this.templatesOnly) {
          TextInput({ text: this.keyword, placeholder: '搜索清单名称' })
            .height(44)
            .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.keyword = v })
          Row({ space: 8 }) {
            this.FilterChip('全部', 'all')
            this.FilterChip('进行中', 'active')
            this.FilterChip('已完成', 'done')
            this.FilterChip('收藏', 'star')
            Blank()
            Text('+ 新建')
              .fontSize(Theme.type.footnote)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.onCreateList())
          }
          .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            Text('全部分类')
              .fontSize(Theme.type.caption)
              .fontColor(this.kind === '全部' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 6, bottom: 6 })
              .backgroundColor(this.kind === '全部' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.kind = '全部' })
            ForEach(ShoppingCatalog.listKinds(), (k: string) => {
              Text(k)
                .fontSize(Theme.type.caption)
                .fontColor(this.kind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: 6, bottom: 6 })
                .backgroundColor(this.kind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.kind = k })
            }, (k: string) => k)
          }
          .width('100%')

          if (this.visible().length === 0) {
            AppEmpty({
              title: this.keyword.length > 0 ? '没有匹配的清单' : '还没有购物清单',
              description: '创建清单，或用模板一键开始',
              actionLabel: '创建清单',
              onAction: () => this.onCreateList()
            })
          } else {
            Grid() {
              ForEach(this.visible(), (row: ShoppingList) => {
                GridItem() {
                  ListMiniCard({
                    title: row.title,
                    meta: `${row.kind} · ${row.status === 'done' ? '已完成' : '进行中'}`,
                    coverKey: row.coverKey,
                    onTap: () => this.onOpenList(row.id)
                  })
                }
              }, (row: ShoppingList) => `${row.id}_${row.status}`)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
          }
          }

          if (!this.templatesOnly) {
            SectionTitle({ title: '清单模板' })
          }
          Text('家庭、日常、旅行、早餐等场景，一键生成可勾选清单。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          ForEach(this.templates, (tpl: ShoppingTemplate) => {
            TemplateCard({
              title: tpl.title,
              summary: tpl.summary,
              coverKey: tpl.coverKey,
              onTap: () => this.onOpenTemplate(tpl)
            })
          }, (tpl: ShoppingTemplate) => tpl.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
