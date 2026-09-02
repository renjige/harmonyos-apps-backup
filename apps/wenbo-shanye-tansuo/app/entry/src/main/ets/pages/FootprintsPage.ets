import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { FootprintItem } from '../models/MxModels'
import { MxBizService } from '../services/MxBizService'
import { MxDetailNav } from '../services/MxDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct FootprintsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: FootprintItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.items = []
      this.loading = false
      return
    }
    this.items = await MxBizService.loadFootprints()
    this.loading = false
  }

  private async remove(f: FootprintItem): Promise<void> {
    await MxBizService.removeFootprint(f.id)
    await this.reload()
  }

  build() {
    DetailShell({ title: '探索足迹', onClose: () => MxDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '打开足迹' })
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后才能记足迹',
            description: '在路线详情里标记「已走」。'
          })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有足迹',
            description: '新账号不会出现别人走过的路。走完一条，在详情里标记即可。'
          })
        } else {
          ForEach(this.items, (f: FootprintItem) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(f.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(f.completedAt.length > 0 ? f.completedAt : '已标记')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                if (f.remark.length > 0) {
                  Text(f.remark)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
              }
              .layoutWeight(1)
              .onClick(() => {
                if (f.trailId.length > 0) {
                  MxDetailNav.openTrail(f.trailId)
                }
              })
              Text('删除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .onClick(() => { void this.remove(f) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (f: FootprintItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
