import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { ProjectDetailPane } from '../components/detail/ProjectDetailPane'
import { ProjectEditorOverlay } from '../components/portfolio/ProjectEditorOverlay'
import { ProfileEditorOverlay } from '../components/portfolio/ProfileEditorOverlay'
import { PortfolioProject, CreatorProfile } from '../models/PortfolioModels'
import { PortfolioStore } from '../services/PortfolioStore'
import { ProfileStore } from '../services/ProfileStore'
import { VisitStatsService } from '../services/VisitStatsService'
import { WorksPage } from './WorksPage'
import { AboutPage } from './AboutPage'
import { StatsPage } from './StatsPage'
import { SettingsPage } from './SettingsPage'

class TabItem {
  index: number = 0
  name: AppIconName = 'grid'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'grid', '作品'],
      ['1', 'user', '关于'],
      ['2', 'chart', '看板'],
      ['3', 'gear', '设置']
    ]
    for (const row of defs) {
      const t = new TabItem()
      t.index = parseInt(row[0], 10)
      t.name = row[1] as AppIconName
      t.label = row[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State reloadToken: number = 0
  @State detailProject: PortfolioProject | null = null
  @State showProjectEditor: boolean = false
  @State editingProject: PortfolioProject = new PortfolioProject()
  @State isNewProject: boolean = true
  @State showProfileEditor: boolean = false
  @State editingProfile: CreatorProfile = new CreatorProfile()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('openSettingsTab') @Watch('onSettingsTabFlag') openSettingsTab: boolean = false
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.consumeSettingsTabFlag()
  }

  onSettingsTabFlag(): void {
    this.consumeSettingsTabFlag()
  }

  private consumeSettingsTabFlag(): void {
    if (this.openSettingsTab) {
      this.current = 3
      AppStorage.setOrCreate('openSettingsTab', false)
    }
  }

  private bumpReload(): void {
    this.reloadToken++
  }

  private openDetail(p: PortfolioProject): void {
    this.detailProject = p
    void VisitStatsService.recordDetailView()
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeDetail(): void {
    this.detailProject = null
    if (!this.showProjectEditor && !this.showProfileEditor) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private openCreateProject(): void {
    this.editingProject = new PortfolioProject()
    this.isNewProject = true
    this.showProjectEditor = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openEditProject(p: PortfolioProject): void {
    this.editingProject = p
    this.isNewProject = false
    this.detailProject = null
    this.showProjectEditor = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeProjectEditor(): void {
    this.showProjectEditor = false
    if (this.detailProject === null && !this.showProfileEditor) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private async openProfileEditor(): Promise<void> {
    this.editingProfile = await ProfileStore.load()
    this.showProfileEditor = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeProfileEditor(): void {
    this.showProfileEditor = false
    if (this.detailProject === null && !this.showProjectEditor) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          WorksPage({
            reloadToken: this.reloadToken,
            onOpenProject: (p: PortfolioProject): void => { this.openDetail(p) },
            onOpenSettings: (): void => { this.current = 3 },
            onCreateProject: (): void => { this.openCreateProject() }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          AboutPage({
            reloadToken: this.reloadToken,
            onEditProfile: (): void => { void this.openProfileEditor() }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          StatsPage({ reloadToken: this.reloadToken }).layoutWeight(1)
        } else {
          SettingsPage({
            reloadToken: this.reloadToken,
            onDataChanged: (): void => { this.bumpReload() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .padding({ top: 6, bottom: 6 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.detailProject !== null) {
        ProjectDetailPane({
          project: this.detailProject as PortfolioProject,
          onClose: (): void => { this.closeDetail() },
          onEdit: (): void => { this.openEditProject(this.detailProject as PortfolioProject) }
        })
          .width('100%')
          .height('100%')
          .zIndex(10)
      }

      if (this.showProjectEditor) {
        ProjectEditorOverlay({
          project: this.editingProject,
          isNew: this.isNewProject,
          onClose: (): void => { this.closeProjectEditor() },
          onSaved: (): void => { this.bumpReload() },
          onDeleted: (): void => { this.bumpReload() }
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      }

      if (this.showProfileEditor) {
        ProfileEditorOverlay({
          profile: this.editingProfile,
          onClose: (): void => { this.closeProfileEditor() },
          onSaved: (): void => { this.bumpReload() }
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.lg,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .padding({ left: 14, right: 14, top: 4, bottom: 4 })
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)

      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => { this.current = t.index })
  }
}
