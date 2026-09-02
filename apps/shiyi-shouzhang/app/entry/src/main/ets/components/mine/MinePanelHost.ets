import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct MinePanelHost {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'settings'
  @Prop displayName: string = ''
  @Prop showRitual: boolean = true
  @Prop reminderGentle: boolean = true
  onBack: () => void = () => {}
  onOpenAgreement: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onRevoke: () => void = () => {}
  onNameChange: (v: string) => void = (v: string) => {}
  onSaveProfile: () => void = () => {}
  onRitualChange: (v: boolean) => void = (v: boolean) => {}
  onRemindChange: (v: boolean) => void = (v: boolean) => {}
  onClear: () => void = () => {}

  private title(): string {
    if (this.kind === 'profile') {
      return '我的资料'
    }
    if (this.kind === 'journal') {
      return '手账设置'
    }
    if (this.kind === 'remind') {
      return '提醒设置'
    }
    if (this.kind === 'data') {
      return '数据管理'
    }
    if (this.kind === 'about') {
      return '关于手账拾意'
    }
    return '设置与隐私'
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .rotate({ angle: 180 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onBack()
        })
        Text(this.title())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2, bottom: Theme.space.s3 })

      if (this.kind === 'settings') {
        this.SettingsBody()
      } else if (this.kind === 'profile') {
        this.ProfileBody()
      } else if (this.kind === 'journal') {
        this.JournalBody()
      } else if (this.kind === 'remind') {
        this.RemindBody()
      } else if (this.kind === 'data') {
        this.DataBody()
      } else {
        this.AboutBody()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsBody() {
    Column({ space: Theme.space.s4 }) {
      AppButton({ label: '查看《用户协议》', variant: 'secondary', onTap: (): void => { this.onOpenAgreement() } })
      AppButton({ label: '查看《隐私政策》', variant: 'secondary', onTap: (): void => { this.onOpenPrivacy() } })
      Row() {
        AppButton({ label: '撤回隐私同意', variant: 'secondary', onTap: (): void => { this.onRevoke() } })
      }
      .width('100%')
      .onClick((): void => { this.onRevoke() })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  ProfileBody() {
    Column({ space: Theme.space.s4 }) {
      Text('昵称只保存在这台设备，不会上传。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.displayName, placeholder: '拾意的人' })
        .height(48)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => { this.onNameChange(v) })
      AppButton({ label: '保存', onTap: (): void => { this.onSaveProfile() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  JournalBody() {
    Row() {
      Text('首页显示今日三问')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.showRitual })
        .selectedColor(Theme.colors().brandPrimary)
        .onChange((v: boolean) => { this.onRitualChange(v) })
    }
    .width('100%')
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  RemindBody() {
    Column({ space: Theme.space.s4 }) {
      Text('不会申请系统通知。若今天还没写，打开首页时会看见一句很轻的话。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row() {
        Text('打开时轻轻提醒')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.reminderGentle })
          .selectedColor(Theme.colors().brandPrimary)
          .onChange((v: boolean) => { this.onRemindChange(v) })
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  DataBody() {
    Column({ space: Theme.space.s4 }) {
      Text('手账、拾意、心情和标签都保存在这台设备。清空后无法恢复。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({ label: '清空本机手账', variant: 'danger', onTap: (): void => { this.onClear() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  AboutBody() {
    Column({ space: Theme.space.s3 }) {
      Text('手账拾意')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('拾起生活里的小事，记录值得留下的心意。')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text('版本 1.0.0')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text('运营者：魏文波')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
