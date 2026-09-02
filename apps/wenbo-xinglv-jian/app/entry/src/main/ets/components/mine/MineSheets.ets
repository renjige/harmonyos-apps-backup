import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'

@Component
export struct MineSettingsPane {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onBack: () => void = () => {}
  onPrivacy: () => void = () => {}
  onAgreement: () => void = () => {}
  onRevoke: () => void = () => {}
  onDeleteAccount: () => void = () => {}

  build() {
    Column() {
      AppNavBar({ title: '设置与隐私', onBack: (): void => { this.onBack() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('可再次阅读协议。撤回后，再次登录须重新勾选。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            .width('100%')
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => { this.onPrivacy() }
          })
          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => { this.onAgreement() }
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
          AppButton({
            label: '注销账号',
            variant: 'ghost',
            onTap: (): void => { this.onDeleteAccount() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}

@Component
export struct MineAboutPane {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onBack: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      AppNavBar({ title: '关于行程备忘', onBack: (): void => { this.onBack() } })
      Image($r('app.media.app_icon'))
        .width(72)
        .height(72)
        .borderRadius(18)
        .margin({ top: 12 })
      Text('行程备忘')
        .fontSize(Theme.type.titleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.palette(this.darkModeOn).textPrimary)
      Text('1.0.0')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.palette(this.darkModeOn).textTertiary)
      Text('把接下来的安排，先记下来。所有安排，一目了然。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.palette(this.darkModeOn).textSecondary)
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })
      Text('运营者：薛茂新')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.palette(this.darkModeOn).textTertiary)
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct MineFeedbackPane {
  @State text: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onBack: () => void = () => {}
  onSend: (text: string) => void = (_t: string) => {}

  build() {
    Column() {
      AppNavBar({ title: '反馈建议', onBack: (): void => { this.onBack() } })
      TextInput({ text: this.text, placeholder: '想让行程备忘怎样更好用？' })
        .height(120)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .fontColor(Theme.palette(this.darkModeOn).textPrimary)
        .placeholderColor(Theme.palette(this.darkModeOn).textTertiary)
        .caretColor(Theme.palette(this.darkModeOn).brandPrimary)
        .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
        .borderRadius(Theme.radius.md)
        .onChange((v: string) => { this.text = v })
      Column() {
        AppButton({
          label: '发送',
          onTap: (): void => { this.onSend(this.text) }
        })
      }
      .padding(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}

@Component
export struct MineSimplePane {
  @Prop title: string = ''
  @Prop body: string = ''
  @Prop action: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State private lastActionAt: number = 0
  onBack: () => void = () => {}
  onAction: () => void = () => {}

  private fireAction(): void {
    const now = Date.now()
    if (now - this.lastActionAt < 400) {
      return
    }
    this.lastActionAt = now
    this.onAction()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      AppNavBar({ title: this.title, onBack: (): void => { this.onBack() } })
      Text(this.body)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.palette(this.darkModeOn).textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Row() {
        AppButton({
          label: this.action,
          onTap: (): void => { this.fireAction() }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .onClick((): void => { this.fireAction() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
