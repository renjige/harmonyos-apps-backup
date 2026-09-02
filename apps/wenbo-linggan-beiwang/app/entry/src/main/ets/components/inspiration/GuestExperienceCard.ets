import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

/** 游客：3 步体验路径，避免空间空白像 Demo */
@Component
export struct GuestExperienceCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onBrowseFeatured: () => void = () => {}
  onLogin: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('三步体验创意转化')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('1. 浏览精选 → 2. 对照三问写备忘 → 3. 登录后钉板、做计划、建专题')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(20)
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: '看精选对照',
            variant: 'secondary',
            onTap: (): void => { this.onBrowseFeatured() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.onBrowseFeatured() })
        Column() {
          AppButton({
            label: '登录开始转化',
            onTap: (): void => { this.onLogin() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.onLogin() })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
