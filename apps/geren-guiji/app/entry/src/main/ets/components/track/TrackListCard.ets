import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TrackRecord } from '../../models/TrackModels'

@Component
export struct TrackListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TrackRecord = new TrackRecord()
  @Prop selected: boolean = false
  @Prop cardIndex: number = 0
  onTap: () => void = () => {}

  private formatDistance(m: number): string {
    if (m <= 0) {
      return '—'
    }
    if (m >= 1000) {
      return `${(m / 1000).toFixed(1)} km`
    }
    return `${Math.round(m)} m`
  }

  private formatDuration(sec: number): string {
    if (sec <= 0) {
      return '—'
    }
    const m = Math.floor(sec / 60)
    return `${m} 分钟`
  }

  private coverResource(): Resource {
    if (this.cardIndex % 2 === 0) {
      return $r('app.media.hero_map_trail')
    }
    return $r('app.media.ambient_empty')
  }

  build() {
    Row({ space: 0 }) {
      Column()
        .width(4)
        .height('100%')
        .backgroundColor(this.selected ? Theme.colors().brandAccent : Theme.colors().brandPrimary)
        .borderRadius({ topLeft: Theme.radius.lg, bottomLeft: Theme.radius.lg })

      Row({ space: Theme.space.s3 }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Image(this.coverResource())
            .width(76)
            .height(76)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          if (this.selected) {
            Row() {
              AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandOnPrimary })
            }
            .width(22)
            .height(22)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .margin({ left: 4, top: 4 })
          }
        }

        Column({ space: 6 }) {
          Row({ space: Theme.space.s2 }) {
            Text(this.item.startedAt.slice(0, 10))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
            Blank()
          }
          .width('100%')

          Text(this.item.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(this.item.placeName.length > 0 ? `📍 ${this.item.placeName}` : '📍 未填写地点')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(`${this.formatDistance(this.item.distanceM)} · ${this.formatDuration(this.item.durationSec)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        AppIcon({
          name: 'chevron',
          iconSize: Theme.icon.sm,
          color: Theme.colors().textTertiary
        })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 16,
      color: Theme.isDark() ? 'rgba(0,0,0,0.30)' : 'rgba(26,35,50,0.08)',
      offsetY: 4,
      offsetX: 0
    })
    .onClick(() => {
      this.onTap()
    })
  }
}
