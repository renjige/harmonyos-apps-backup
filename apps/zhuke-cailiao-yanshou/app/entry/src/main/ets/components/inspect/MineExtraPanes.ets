import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MineMenuRow } from './MineMenuRow'
import { InspectCatalog, MaterialCategory } from '../../models/InspectModels'
import { InspectLocalStore } from '../../services/InspectLocalStore'

@Component
export struct MineBackRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  onBack: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .rotate({ angle: 180 })
      .onClick(() => this.onBack())
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: 8 })
  }
}

@Component
export struct MineSettingsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop notifyEnabled: boolean = true
  @Prop @Watch('onAppearWatch') appearance: string = 'system'
  @Prop defaultCategory: string = '瓷砖'
  @Prop defaultUnit: string = '箱'
  @Prop @Watch('onThemeWatch') themeTick: number = 0
  @State showCatPick: boolean = false
  @State showUnitPick: boolean = false
  @State paint: number = 0
  onBack: () => void = () => {}
  onToggleNotify: () => void = () => {}
  onAppearanceChange: (value: string) => void = (value: string) => { if (value.length === 0) { return } }
  onOpenAgreement: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onDeleteAccount: () => void = () => {}
  onRevoke: () => void = () => {}

  onAppearWatch(): void {
    this.paint = this.paint + 1
  }

  onThemeWatch(): void {
    this.paint = this.themeTick + 1
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      MineBackRow({ title: '设置与隐私', onBack: () => this.onBack() })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('消息提醒')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(this.notifyEnabled ? '已开启' : '已关闭')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .onClick(() => this.onToggleNotify())

          Column({ space: 8 }) {
            Text('界面设置')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Row({ space: 8 }) {
              this.chip('跟随系统', 'system')
              this.chip('浅色', 'light')
              this.chip('深色', 'dark')
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          MineMenuRow({
            title: `默认类别：${this.defaultCategory}`,
            subtitle: '新建验收时预填',
            onTap: () => { this.showCatPick = !this.showCatPick }
          })
          if (this.showCatPick) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(InspectCatalog.all(), (cat: MaterialCategory) => {
                Text(cat.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.defaultCategory === cat.title ? Theme.chipFg(true) : Theme.chipFg(false))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.defaultCategory === cat.title ? Theme.chipBg(true) : Theme.chipBg(false))
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { void InspectLocalStore.setDefaultCategory(cat.title) })
              }, (cat: MaterialCategory) => cat.id)
            }
            .width('100%')
          }

          MineMenuRow({
            title: `默认单位：${this.defaultUnit}`,
            subtitle: '新建验收时预填',
            onTap: () => { this.showUnitPick = !this.showUnitPick }
          })
          if (this.showUnitPick) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(InspectCatalog.units(), (u: string) => {
                Text(u)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.defaultUnit === u ? Theme.chipFg(true) : Theme.chipFg(false))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.defaultUnit === u ? Theme.chipBg(true) : Theme.chipBg(false))
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { void InspectLocalStore.setDefaultUnit(u) })
              }, (u: string) => u)
            }
            .width('100%')
          }

          AppButton({ label: '查看《用户协议》', variant: 'secondary', onTap: () => this.onOpenAgreement() })
          AppButton({ label: '查看《隐私政策》', variant: 'secondary', onTap: () => this.onOpenPrivacy() })
          AppButton({ label: '注销账号', variant: 'danger', onTap: () => this.onDeleteAccount() })
          Row() {
            AppButton({ label: '撤回隐私同意', variant: 'secondary', onTap: () => this.onRevoke() })
          }
          .width('100%')
          .onClick(() => this.onRevoke())
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .id(`mine_settings_${this.paint}`)
  }

  @Builder
  chip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.appearance === value ? Theme.chipFg(true) : Theme.chipFg(false))
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(this.appearance === value ? Theme.chipBg(true) : Theme.chipBg(false))
      .border({ width: 1, color: this.appearance === value ? Theme.chipBg(true) : Theme.colors().strokeStrong })
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.onAppearanceChange(value)
        this.paint = this.paint + 1
      })
  }
}

@Component
export struct MineStatsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop allTotal: number = 0
  @Prop allPass: number = 0
  @Prop allPending: number = 0
  @Prop allFail: number = 0
  onBack: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      MineBackRow({ title: '数据统计', onBack: () => this.onBack() })
      Column({ space: 12 }) {
        this.line('全部验收', `${this.allTotal}`)
        this.line('通过', `${this.allPass}`)
        this.line('待处理', `${this.allPending}`)
        this.line('不通过', `${this.allFail}`)
      }
      .width('100%')
      .padding(Theme.space.s5)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.card)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  line(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Blank()
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
  }
}

@Component
export struct MineAboutPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onBack: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      MineBackRow({ title: '关于应用', onBack: () => this.onBack() })
      Column({ space: 10 }) {
        Image($r('app.media.icon'))
          .width(72)
          .height(72)
          .borderRadius(16)
        Text('筑科材料验收')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('让每一次材料验收都有据可查')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .textAlign(TextAlign.Center)
        Text('版本 1.0.0')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text('运营者 齐齐哈尔筑科建筑工程有限责任公司')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text('本应用用于施工现场材料进场验收记录，不替代法定质量检测，不含支付与商城。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
