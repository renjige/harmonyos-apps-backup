import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AchievementDef } from '../models/GrowthModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { GrowthStore } from '../services/GrowthStore'
import { AchievementService } from '../services/AchievementService'
import { AuthService } from '../services/AuthService'

@Component
export struct AchievementPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State unlocked: string[] = []
  @State defs: AchievementDef[] = AchievementService.all()

  aboutToAppear(): void {
    void this.reload()
  }

  private isOn(id: string): boolean {
    for (const x of this.unlocked) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.loading = false
      return
    }
    const ins = await InspirationBizService.loadInspirations(this.currentUsername)
    const fav = await InspirationBizService.loadFavorites(this.currentUsername)
    const plans = await InspirationBizService.loadCreativePlans(this.currentUsername)
    const growth = await GrowthStore.load(this.currentUsername)
    const newly = AchievementService.evaluate(growth, ins, plans, fav)
    if (newly.length > 0) {
      await GrowthStore.save(this.currentUsername, growth)
    }
    this.unlocked = growth.unlocked
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('成就墙')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '核对成就条件…' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后点亮成就',
          description: '成就来自真实捕捉、钉板、计划和打卡，不会预置亮灯',
          actionLabel: '去登录',
          onAction: (): void => { this.onRequireAuth() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('条件都绑在你自己的记录上。新用户墙是暗的，写第一条就会亮第一张备忘笺。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.defs, (d: AchievementDef) => {
              Row({ space: Theme.space.s3 }) {
                AppIcon({
                  name: this.isOn(d.id) ? 'check' : 'empty',
                  iconSize: Theme.icon.md,
                  color: this.isOn(d.id) ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                })
                Column({ space: 4 }) {
                  Text(d.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.isOn(d.id) ? `已点亮 · ${d.hint}` : d.hint)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({
                width: 1,
                color: this.isOn(d.id) ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
              })
              .opacity(this.isOn(d.id) ? 1 : 0.72)
            }, (d: AchievementDef) => d.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
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
