import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TipItem, TrailItem } from '../../models/NqModels'
import { NqBizService } from '../../services/NqBizService'
import { NqDetailNav } from '../../services/NqDetailNav'
import { NqMedia } from '../../services/NqMedia'

class RelatedIds {
  static split(raw: string): string[] {
    const out: string[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }
}

@Component
export struct TipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTipIdChange') tipId: string = ''
  @Prop @Watch('onTipIdChange') refreshToken: number = 0
  @State item: TipItem | undefined = undefined
  @State relatedTrails: TrailItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onTipIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await NqBizService.findTip(this.tipId)
    this.relatedTrails = []
    if (this.item !== undefined && this.item.relatedTrailIds.length > 0) {
      const ids = RelatedIds.split(this.item.relatedTrailIds)
      const all = await NqBizService.loadTrails('', '')
      const picked: TrailItem[] = []
      for (const t of all) {
        for (const id of ids) {
          if (t.id === id) {
            picked.push(t)
          }
        }
      }
      this.relatedTrails = picked
    }
    this.loading = false
  }

  private openFirstSpot(): void {
    if (this.relatedTrails.length > 0) {
      NqDetailNav.openSpot(this.relatedTrails[0].id)
      return
    }
    NqDetailNav.switchTabDiscover()
    NqDetailNav.close()
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开技巧' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '户外技巧', onClose: () => NqDetailNav.close() }) {
        AppEmpty({ title: '内容不存在' })
      }
    } else {
      DetailShell({ title: this.item.title, contentKey: this.tipId, onClose: () => NqDetailNav.close() }) {
        this.Body()
      }
    }
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(NqMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_forest_path'))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(96)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.86)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.item !== undefined ? this.item.categoryLabel() : '')
            .fontSize(Theme.type.caption)
            .fontColor('#F5F0E8')
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
      .height(200)

      Column({ space: 8 }) {
        Text(this.item !== undefined ? this.item.summary : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Column({ space: 8 }) {
        Text('详细说明')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .width('auto')

      Column({ space: Theme.space.s3 }) {
        AppButton({
          label: this.relatedTrails.length > 0 ? '去相关探索点' : '去发现更多',
          onTap: (): void => this.openFirstSpot()
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .width('100%')
  }
}
