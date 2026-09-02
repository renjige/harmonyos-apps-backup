import { Theme } from '../design-system/Theme'
import { DetailShell } from '../detail/DetailShell'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { WorkbenchStats } from '../../models/GrowthModels'
import { WorkbenchService } from '../../services/WorkbenchService'
import { InsightStore } from '../../services/InsightStore'

@Component
export struct MinePanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpenSettings: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  @State stats: WorkbenchStats = new WorkbenchStats()
  @State nickname: string = '思考者'

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await WorkbenchService.loadStats()
    const profile = await InsightStore.loadProfile()
    this.nickname = profile.nickname
  }

  build() {
    Column() {
      DetailShell({ title: '我的', onClose: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: this.nickname }) {
            Column({ space: 6 }) {
              Text(`累计 ${this.stats.total} 条见解 · 连续 ${this.stats.streak} 天`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(`徽章 ${this.stats.achievementCount} · 应验率 ${this.stats.hitRate}%`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
          }
          AppButton({
            label: '成就墙',
            variant: 'secondary',
            onTap: (): void => { this.onOpenAchievements() }
          })
          AppButton({
            label: '设置与隐私',
            variant: 'primary',
            onTap: (): void => {
              this.onClose()
              this.onOpenSettings()
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
