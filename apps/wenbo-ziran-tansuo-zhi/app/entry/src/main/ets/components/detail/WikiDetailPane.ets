import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TrailItem, WikiItem } from '../../models/NqModels'
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
export struct WikiDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onWikiIdChange') wikiId: string = ''
  @Prop @Watch('onWikiIdChange') refreshToken: number = 0
  @State item: WikiItem | undefined = undefined
  @State relatedTrails: TrailItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onWikiIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await NqBizService.findWiki(this.wikiId)
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
        AppLoading({ label: '打开百科' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '百科', onClose: () => NqDetailNav.close() }) {
        AppEmpty({ title: '条目不存在' })
      }
    } else {
      DetailShell({ title: this.item.title, contentKey: this.wikiId, onClose: () => NqDetailNav.close() }) {
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
          .height(220)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(110)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.86)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.item !== undefined ? this.item.category : '')
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
      .height(220)

      Column({ space: 8 }) {
        if (this.item !== undefined && this.item.latinName.length > 0) {
          Text(`学名  ${this.item.latinName}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
        Text(this.item !== undefined ? `生境  ${this.item.habitat}` : '')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.item !== undefined ? `观察  ${this.item.observeHint}` : '')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.item !== undefined ? this.item.summary : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Column({ space: 8 }) {
        Text('条目正文')
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
          label: '去相关探索点',
          onTap: (): void => this.openFirstSpot()
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .width('100%')
  }
}
