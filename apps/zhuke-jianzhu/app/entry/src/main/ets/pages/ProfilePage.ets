import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { AuthService } from '../services/AuthService'

@Component
export struct ProfilePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  onBack: () => void = () => {}
  onOpenLogin: () => void = () => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  build() {
    Column() {
      AppNavBar({ title: '个人信息', onBack: () => this.onBack() })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s4 }) {
            Column() {
              Text('Z')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandOnPrimary)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.lg)

            Column({ space: Theme.space.s1 }) {
              Text(this.isLoggedIn() ? AuthService.currentUsername() : '未登录')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.isLoggedIn() ? '项目管理人员' : '登录后查看完整信息')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textTertiary)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          AppCard({ title: '企业信息' }) {
            Column({ space: Theme.space.s2 }) {
              Text('公司：筑科建筑工程有限公司')
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text('应用：筑科建筑 · 智慧工程管理')
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }

          if (!this.isLoggedIn()) {
            AppButton({
              label: '登录 / 注册',
              onTap: () => this.onOpenLogin()
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
