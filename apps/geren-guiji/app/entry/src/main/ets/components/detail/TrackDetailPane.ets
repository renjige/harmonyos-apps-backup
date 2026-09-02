import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { TrackRecord } from '../../models/TrackModels'
import { TrackStore } from '../../services/TrackStore'
import { TrackDetailNav } from '../../services/TrackDetailNav'

@Component
export struct TrackDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop trackId: string = ''
  @State record: TrackRecord = new TrackRecord()
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const found = TrackStore.findById(this.trackId)
    if (found !== null) {
      this.record = found
    }
  }

  private formatDistance(m: number): string {
    if (m <= 0) {
      return '未填写'
    }
    if (m >= 1000) {
      return `${(m / 1000).toFixed(2)} km`
    }
    return `${Math.round(m)} m`
  }

  private formatDuration(sec: number): string {
    if (sec <= 0) {
      return '未填写'
    }
    const m = Math.floor(sec / 60)
    return `${m} 分钟`
  }

  build() {
    DetailShell({
      title: '足迹详情',
      onClose: (): void => {
        TrackDetailNav.close()
      },
      body: (): void => {
        this.BodyContent()
      },
      footer: (): void => {
        this.FooterActions()
      }
    })
  }

  @Builder
  BodyContent() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_map_trail'))
        .width('100%')
        .height(240)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column({ space: 0 })
        .width('100%')
        .height(240)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(26,35,50,0.05)', 0.0],
            ['rgba(26,35,50,0.88)', 1.0]
          ]
        })
      Column({ space: 8 }) {
        Text(this.record.startedAt.slice(0, 10))
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,252,249,0.80)')
        Text(this.record.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
        Text(this.record.placeName.length > 0 ? `📍 ${this.record.placeName}` : '📍 未填写地点')
          .fontSize(Theme.type.subhead)
          .fontColor('rgba(255,252,249,0.90)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }

    Row({ space: Theme.space.s3 }) {
      this.MetaChip('里程', this.formatDistance(this.record.distanceM))
      this.MetaChip('时长', this.formatDuration(this.record.durationSec))
    }
    .width('100%')

    Column({ space: Theme.space.s3 }) {
      Text('回忆')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.record.note.length > 0 ? this.record.note : '暂无备注，可在编辑时补充当时的心情。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })

    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: 'clock', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      Text('数据由您手动填写，仅存于本机。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textTertiary)
        .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  MetaChip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FooterActions() {
    AppButton({
      label: '删除此足迹',
      variant: 'danger',
      onTap: (): void => {
        void this.removeTrack()
      }
    })
  }

  private async removeTrack(): Promise<void> {
    await TrackStore.remove(this.record.id)
    this.onChanged()
    TrackDetailNav.close()
  }
}
