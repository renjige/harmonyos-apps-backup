import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MinePrefRow } from './MinePrefRow'

export { MinePrefRow }

@Component
export struct MineSettingsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpenAgreement: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onDeleteAccount: () => void = () => {}
  onRevoke: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => { this.onClose() })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => { this.onOpenAgreement() }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => { this.onOpenPrivacy() }
          })
          Text('个人信息收集清单与第三方共享清单见应用内协议正文。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: '注销账号',
            variant: 'danger',
            onTap: (): void => { this.onDeleteAccount() }
          })
          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { this.onRevoke() }
            })
          }
          .width('100%')
          .onClick((): void => { this.onRevoke() })
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
    .width('100%')
    .height('100%')
  }
}

@Component
export struct MineExportPane {
  @Prop exportText: string = ''
  onCopy: () => void = () => {}
  onClose: () => void = () => {}

  build() {
    Column() {
      Column({ space: 12 }) {
        Text('导出记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Scroll() {
          Text(this.exportText)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .height(280)
        AppButton({ label: '复制这份文字', onTap: (): void => { this.onCopy() } })
        AppButton({
          label: '收起',
          variant: 'secondary',
          onTap: (): void => { this.onClose() }
        })
      }
      .padding(20)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
