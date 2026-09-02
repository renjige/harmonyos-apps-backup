import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { CoolDetailNav } from '../services/CoolDetailNav'

@Component
export struct PrefsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('preferredMode') preferredMode: string = ''
  @StorageLink('heatLevel') heatLevel: string = 'mid'

  private setMode(v: string): void {
    this.preferredMode = v
    AppStorage.setOrCreate('preferredMode', v)
  }

  private setHeat(v: string): void {
    this.heatLevel = v
    AppStorage.setOrCreate('heatLevel', v)
  }

  build() {
    DetailShell({ title: '出行偏好', onClose: () => CoolDetailNav.close() }) {
      Column({ space: Theme.space.s4 }) {
        Text('常用出行方式会作为「路线」页的默认筛选，仍可随时改。保存在本机。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text('常用出行方式')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          Text('不限')
            .fontSize(Theme.type.footnote)
            .fontColor(this.preferredMode.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.preferredMode.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setMode(''))
          Text('步行')
            .fontSize(Theme.type.footnote)
            .fontColor(this.preferredMode === 'walk' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.preferredMode === 'walk' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setMode('walk'))
          Text('骑行')
            .fontSize(Theme.type.footnote)
            .fontColor(this.preferredMode === 'bike' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.preferredMode === 'bike' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setMode('bike'))
          Text('公交')
            .fontSize(Theme.type.footnote)
            .fontColor(this.preferredMode === 'transit' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.preferredMode === 'transit' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setMode('transit'))
        }
        .width('100%')
        Text('热敏感')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          Text('怕热')
            .fontSize(Theme.type.footnote)
            .fontColor(this.heatLevel === 'high' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.heatLevel === 'high' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setHeat('high'))
          Text('一般')
            .fontSize(Theme.type.footnote)
            .fontColor(this.heatLevel === 'mid' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.heatLevel === 'mid' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setHeat('mid'))
          Text('赶时间')
            .fontSize(Theme.type.footnote)
            .fontColor(this.heatLevel === 'low' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.heatLevel === 'low' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setHeat('low'))
        }
        .width('100%')
        AppButton({
          label: '去对比路线',
          onTap: (): void => {
            CoolDetailNav.switchTabRoutes()
            CoolDetailNav.close()
          }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
