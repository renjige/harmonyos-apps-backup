import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ProjectCard } from '../components/reno/ProjectCard'
import { RenoProject } from '../models/RenoModels'
import { RenoService } from '../services/RenoService'

@Component
export struct ProjectsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('renoRev') @Watch('onRev') renoRev: number = 0
  @State items: RenoProject[] = []
  onOpen: (item: RenoProject) => void = (_i: RenoProject) => {}
  onAdd: () => void = () => {}

  aboutToAppear(): void {
    void this.boot()
  }

  onTick(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async boot(): Promise<void> {
    await RenoService.hydrateUser()
    await this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await RenoService.projects()
  }

  build() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text('项目')
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('多个装修项目分开记录')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: 22, color: Theme.colors().brandOnPrimary })
        }
        .width(44).height(44).borderRadius(22)
        .backgroundColor(Theme.colors().brandPrimary)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onAdd())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: 12 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无装修项目',
          description: '创建一个项目，开始记录你的装修进度',
          actionLabel: '创建项目',
          onAction: () => this.onAdd()
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.items, (it: RenoProject) => {
              ProjectCard({ item: it, onOpen: (row: RenoProject) => this.onOpen(row) })
            }, (it: RenoProject) => `${it.id}_${it.updatedAt}_${it.title}_${it.stage}_${it.progress}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
