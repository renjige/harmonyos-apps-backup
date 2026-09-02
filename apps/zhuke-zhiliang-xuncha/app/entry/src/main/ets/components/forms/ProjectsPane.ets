import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { ProjectCard } from '../quality/ProjectCard'
import { ProjectItem } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct ProjectsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('qualityTick') tick: number = 0
  onClose: () => void = () => {}

  private rows(): ProjectItem[] {
    const _keep = this.tick
    return QualityService.projects()
  }

  build() {
    Column() {
      Row() {
        Text('我的项目')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      if (this.rows().length === 0) {
        AppEmpty({
          title: '还没有项目',
          description: '新增项目后即可开始巡查。',
          actionLabel: '新增项目',
          onAction: () => QualityNav.open('newProject')
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.rows(), (p: ProjectItem) => {
              ProjectCard({ item: p, onOpen: (id: string) => QualityNav.open('project', id) })
            }, (p: ProjectItem) => p.id)
          }
          .padding({ left: 16, right: 16, bottom: 24 })
        }
        .layoutWeight(1)
      }

      Column() {
        AppButton({ label: '新增项目', onTap: () => QualityNav.open('newProject') })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
