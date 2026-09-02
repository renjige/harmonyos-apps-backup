import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { SolarDetailNav } from '../services/SolarDetailNav'
import { PreferencesStore } from '../services/PreferencesStore'

@Component
export struct PreferencesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('prefVegetarianOnly') vegetarianOnly: boolean = false
  @StorageLink('prefLightTaste') lightTaste: boolean = false

  onRefreshTokenChange(): void {
    // sync from storage on overlay open
  }

  build() {
    DetailShell({
      title: '饮食偏好',
      contentKey: `${this.vegetarianOnly}-${this.lightTaste}`,
      onClose: () => SolarDetailNav.close()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text('偏好仅保存在本机，用于食谱库筛选，不会上传至服务器。')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Row() {
          Column({ space: 4 }) {
            Text('只看素食')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('食谱库隐藏含荤菜的条目')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Toggle({ type: ToggleType.Switch, isOn: this.vegetarianOnly })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((v: boolean) => {
              void PreferencesStore.setVegetarianOnly(v)
            })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

        Row() {
          Column({ space: 4 }) {
            Text('偏好清淡')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('标记您的口味倾向（本地备忘）')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Toggle({ type: ToggleType.Switch, isOn: this.lightTaste })
            .selectedColor(Theme.colors().brandAccent)
            .onChange((v: boolean) => {
              void PreferencesStore.setLightTaste(v)
            })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
