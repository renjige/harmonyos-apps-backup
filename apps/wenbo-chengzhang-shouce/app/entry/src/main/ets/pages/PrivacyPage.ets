import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

/**
 * 保留页：设置或其他入口可复用；启动流已不再强制本页为首屏。
 * 默认打开隐私政策全文。
 */
@Component
export struct PrivacyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop allowBrowseBasic: boolean = false
  @State kind: LegalDocKind = 'privacy'
  onAccepted: () => void = () => {}
  onRefused: () => void = () => {}

  build() {
    Column() {
      LegalDocOverlay({
        kind: this.kind,
        onClose: () => this.onAccepted()
      })
        .layoutWeight(1)
      if (this.allowBrowseBasic) {
        AppButton({
          label: '返回',
          variant: 'ghost',
          onTap: () => this.onRefused()
        })
          .padding(Theme.space.pageX)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
