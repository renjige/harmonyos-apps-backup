import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { ListMiniCard, SectionTitle, TemplateCard } from '../components/family/FamilyCards'
import { FamilyList, FamilyTemplate } from '../models/FamilyModels'
import { FamilyService } from '../services/FamilyService'

@Component
export struct TasksPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State filter: string = 'all'
  @State lists: FamilyList[] = []
  @State templates: FamilyTemplate[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpenList: (id: string) => void = () => {}
  onCreateList: () => void = () => {}
  onOpenTemplate: (tpl: FamilyTemplate) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.lists = await FamilyService.lists()
    this.templates = await FamilyService.templates()
  }

  private visible(): FamilyList[] {
    const out: FamilyList[] = []
    for (const row of this.lists) {
      if (this.filter === 'all') {
        out.push(row)
      } else if (this.filter === 'active' && row.status !== 'done') {
        out.push(row)
      } else if (this.filter === 'done' && row.status === 'done') {
        out.push(row)
      }
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
      AppHeader({ title: '家庭事项', subtitle: '创建、编辑、完成与分类管理' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: 8 }) {
            this.FilterChip('全部', 'all')
            this.FilterChip('进行中', 'active')
            this.FilterChip('已完成', 'done')
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

          if (this.visible().length === 0) {
            AppEmpty({
              title: this.filter === 'done' ? '还没有已完成的清单' : '还没有家庭清单',
              description: '创建家庭清单，或用模板一键开始。全部完成后会进入「已完成」。',
              actionLabel: '创建家庭清单',
              onAction: () => this.onCreateList()
            })
          } else {
            ForEach(this.visible(), (row: FamilyList) => {
              ListMiniCard({
                title: row.title,
                meta: row.status === 'done' ? '已完成' : '进行中',
                coverKey: row.coverKey,
                listId: row.id,
                onTap: () => this.onOpenList(row.id)
              })
            }, (row: FamilyList) => `${row.id}_${row.status}`)
          }

          SectionTitle({ title: '家庭清单模板' })
          ForEach(this.templates, (tpl: FamilyTemplate) => {
            TemplateCard({
              title: tpl.title,
              summary: tpl.summary,
              coverKey: tpl.coverKey,
              onTap: () => this.onOpenTemplate(tpl)
            })
          }, (tpl: FamilyTemplate) => tpl.id)
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
