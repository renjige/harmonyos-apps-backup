import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppButton } from '../components/design-system/AppButton'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { PrivacyService } from '../services/PrivacyService'
import { AuthService } from '../services/AuthService'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State showLegal: boolean = false
  @State legalKind: 'privacy' | 'agreement' = 'privacy'
  @State tip: string = ''
  onBack: () => void = () => {}
  onLogout: () => void = () => {}

  private async revokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    await AuthService.logout()
    this.tip = '已撤回隐私同意并退出登录'
    this.onLogout()
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({ title: '设置与隐私', onBack: () => this.onBack() })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.tip.length > 0) {
              Text(this.tip)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }

            Column() {
              AppListRow({
                title: '用户协议',
                onTap: () => {
                  this.legalKind = 'agreement'
                  this.showLegal = true
                }
              })
              AppListRow({
                title: '隐私政策',
                onTap: () => {
                  this.legalKind = 'privacy'
                  this.showLegal = true
                }
              })
              AppListRow({
                title: '删除业务数据',
                subtitle: '清除本账号工程业务记录',
                onTap: async () => {
                  const ok = await PrivacyService.deleteData()
                  this.tip = ok ? '业务数据已删除' : '操作失败，请稍后重试'
                }
              })
              AppListRow({
                title: '注销账号',
                subtitle: '永久删除账号与关联数据',
                onTap: async () => {
                  const ok = await PrivacyService.deleteAccount()
                  if (ok) {
                    await PrivacyService.revoke()
                    await AuthService.logout()
                    this.onLogout()
                  } else {
                    this.tip = '注销失败，请稍后重试'
                  }
                }
              })
              AppListRow({
                title: '撤回隐私同意',
                subtitle: '撤回后将退出登录',
                showDivider: false,
                onTap: () => { this.revokePrivacy() }
              })
            }
            .padding({ left: Theme.space.s3, right: Theme.space.s3 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            AppButton({
              label: '退出登录',
              variant: 'secondary',
              onTap: () => {
                AuthService.logout().then(() => this.onLogout())
              }
            })
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

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
