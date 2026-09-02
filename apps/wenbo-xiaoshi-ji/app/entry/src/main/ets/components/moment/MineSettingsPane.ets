import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppListRow } from '../design-system/AppListRow'

@Component
export struct MineSettingsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpenAgreement: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onClearCache: () => void = () => {}
  onRevoke: () => void = () => {}
  @State confirmRevoke: boolean = false

  build() {
    Column() {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppListRow({ title: '用户协议', onTap: (): void => this.onOpenAgreement() })
          AppListRow({ title: '隐私政策', onTap: (): void => this.onOpenPrivacy() })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => this.onClearCache()
          })
          if (!this.confirmRevoke) {
            Row() {
              AppButton({
                label: '撤回隐私同意',
                variant: 'ghost',
                onTap: (): void => { this.confirmRevoke = true }
              })
            }
            .width('100%')
            .onClick((): void => { this.confirmRevoke = true })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('撤回后不再弹出应用内协议窗。首次声明由华为应用市场托管；本机记录仍保留。')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmRevoke = false }
                  })
                }.layoutWeight(1)
                Column() {
                  AppButton({
                    label: '确认撤回',
                    variant: 'danger',
                    onTap: (): void => this.onRevoke()
                  })
                }.layoutWeight(1)
              }
              .width('100%')
            }
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
