import { Theme } from '../components/design-system/Theme'
import { AppListRow, AppSectionLabel } from '../components/design-system/AppListRow'
import { AppButton } from '../components/design-system/AppButton'
import { AuthService } from '../services/AuthService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '筑科建筑'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenRoute: (route: string) => void = (_route: string) => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  onRefreshChange(): void {
    // refresh hook
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s4 }) {
            Column() {
              Text('Z')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandOnPrimary)
            }
            .width(72)
            .height(72)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.lg)
            .shadow(Theme.cardShadow())

            Column({ space: Theme.space.s1 }) {
              Text(this.isLoggedIn() ? AuthService.currentUsername() : '未登录')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.isLoggedIn() ? '筑科建筑工程有限公司' : '登录后同步工程数据')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textTertiary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY
        })

        AppSectionLabel({ label: '账户' })
        Column() {
          AppListRow({
            title: '个人信息',
            subtitle: '姓名 · 角色 · 联系方式',
            onTap: () => this.onOpenRoute('profile')
          })
          AppListRow({
            title: '设置',
            subtitle: '通知 · 偏好 · 隐私合规',
            showDivider: false,
            onTap: () => this.onOpenRoute('settings')
          })
        }
        .padding({ left: Theme.space.s3, right: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .shadow(Theme.cardShadow())
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppSectionLabel({ label: '支持' })
        Column() {
          AppListRow({
            title: '帮助中心',
            subtitle: '使用指南 · 常见问题',
            onTap: () => this.onOpenRoute('help')
          })
          AppListRow({
            title: '意见反馈',
            onTap: () => this.onOpenRoute('feedback')
          })
          AppListRow({
            title: '关于筑科建筑',
            showDivider: false,
            onTap: () => this.onOpenRoute('about')
          })
        }
        .padding({ left: Theme.space.s3, right: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .shadow(Theme.cardShadow())
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          if (this.isLoggedIn()) {
            AppButton({
              label: '退出登录',
              variant: 'secondary',
              onTap: () => {
                AuthService.logout()
                this.onLogout()
              }
            })
          } else {
            AppButton({
              label: '登录 / 注册',
              onTap: () => this.onOpenLogin()
            })
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
  }
}
