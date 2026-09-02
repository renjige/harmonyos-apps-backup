import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct FeatureActionCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop iconName: AppIconName = 'chart'
  @Prop image: Resource = $r('app.media.hero_sport_bg')
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.image)
        .width('100%')
        .height(this.compact ? 100 : 124)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(this.compact ? 100 : 124)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Row({ space: Theme.space.s3 }) {
        Row() {
          AppIcon({ name: this.iconName, iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.16)')
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: 'rgba(255,255,255,0.22)' })
        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnScrim)
          Text(this.subtitle)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnScrimMuted)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textOnScrimMuted })
      }
      .width('100%')
      .padding(Theme.space.s4)
    }
    .width('100%')
    .height(this.compact ? 100 : 124)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeStrong })
    .shadow({
      radius: 18,
      color: Theme.isDark() ? 'rgba(0,0,0,0.42)' : 'rgba(26,92,255,0.14)',
      offsetY: 8
    })
    .onClick(() => {
      this.onTap()
    })
  }
}
