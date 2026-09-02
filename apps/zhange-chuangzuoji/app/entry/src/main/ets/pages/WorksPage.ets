import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CategoryChips } from '../components/portfolio/CategoryChips'
import { EditorialBanner } from '../components/portfolio/EditorialBanner'
import { ProjectGridCard } from '../components/portfolio/ProjectGridCard'
import { PortfolioProject } from '../models/PortfolioModels'
import { PortfolioStore } from '../services/PortfolioStore'

@Component
export struct WorksPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  onOpenProject: (project: PortfolioProject) => void = () => {}
  onOpenSettings: () => void = () => {}
  onCreateProject: () => void = () => {}
  @State projects: PortfolioProject[] = []
  @State filtered: PortfolioProject[] = []
  @State categoryId: string = 'all'
  @State searchQuery: string = ''
  @State loading: boolean = true
  @State refreshing: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    this.projects = await PortfolioStore.loadAll()
    this.applyFilter()
    this.loading = false
    this.refreshing = false
  }

  private async refresh(): Promise<void> {
    this.refreshing = true
    this.projects = await PortfolioStore.loadAll()
    this.applyFilter()
    this.refreshing = false
  }

  private applyFilter(): void {
    const q = this.searchQuery.trim().toLowerCase()
    const next: PortfolioProject[] = []
    for (const p of this.projects) {
      if (this.categoryId !== 'all' && p.category !== this.categoryId) {
        continue
      }
      if (q.length > 0) {
        const hay = `${p.title} ${p.description} ${p.tags.join(' ')}`.toLowerCase()
        if (hay.indexOf(q) < 0) {
          continue
        }
      }
      next.push(p)
    }
    this.filtered = next
  }

  private emptyTitle(): string {
    if (this.projects.length === 0) {
      return '还没有作品'
    }
    return '暂无匹配作品'
  }

  private emptyDescription(): string {
    if (this.projects.length === 0) {
      return '点击右上角 + 新建，或在设置中导入 JSON'
    }
    return '试试调整搜索词或分类筛选'
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column({ space: 2 }) {
          Text('展格创作集')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`${this.projects.length} 件作品 · 匠心陈列`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
        }
        .width(Theme.icon.minTouch)
        .height(Theme.icon.minTouch)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onCreateProject() })

        Row() {
          AppIcon({ name: 'gear', iconSize: Theme.icon.lg, color: Theme.colors().textSecondary })
        }
        .width(Theme.icon.minTouch)
        .height(Theme.icon.minTouch)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onOpenSettings() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      EditorialBanner({ countLabel: `${this.projects.length} 件作品` })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
        TextInput({ text: this.searchQuery, placeholder: '搜索作品、描述或标签' })
          .layoutWeight(1)
          .height(44)
          .fontSize(Theme.type.bodyS)
          .backgroundColor(Color.Transparent)
          .onChange((v: string) => {
            this.searchQuery = v
            this.applyFilter()
          })
      }
      .width('100%')
      .height(44)
      .padding({ left: Theme.space.s4, right: Theme.space.s4 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      .backgroundColor(Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)

      CategoryChips({
        selectedId: this.categoryId,
        onSelect: (id: string): void => {
          this.categoryId = id
          this.applyFilter()
        }
      })
      .margin({ bottom: Theme.space.s3 })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.colors().brandPrimary)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filtered.length === 0) {
        AppEmpty({
          title: this.emptyTitle(),
          description: this.emptyDescription(),
          actionLabel: this.projects.length === 0 ? '新建作品' : '清除筛选',
          onAction: (): void => {
            if (this.projects.length === 0) {
              this.onCreateProject()
            } else {
              this.searchQuery = ''
              this.categoryId = 'all'
              this.applyFilter()
            }
          }
        })
          .layoutWeight(1)
      } else {
        Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
          Scroll() {
            GridRow({ columns: 2, gutter: Theme.space.s3 }) {
              ForEach(this.filtered, (p: PortfolioProject) => {
                GridCol({ span: 1 }) {
                  ProjectGridCard({
                    project: p,
                    onTap: (): void => { this.onOpenProject(p) }
                  })
                }
              }, (p: PortfolioProject) => p.id)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
          }
          .width('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .layoutWeight(1)
        .width('100%')
        .onRefreshing((): void => { void this.refresh() })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
