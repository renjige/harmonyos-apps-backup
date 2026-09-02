import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TrailItem, Waypoint, WikiItem } from '../../models/NqModels'
import { ExploreRecord } from '../../models/ExploreRecordModels'
import { NqBizService } from '../../services/NqBizService'
import { NqDetailNav } from '../../services/NqDetailNav'
import { NqMedia } from '../../services/NqMedia'
import { ExploreRecordStore } from '../../services/ExploreRecordStore'
import { AuthService } from '../../services/AuthService'

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
export struct DiscoverDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onSpotIdChange') spotId: string = ''
  @Prop @Watch('onSpotIdChange') refreshToken: number = 0
  @State item: TrailItem | undefined = undefined
  @State relatedWikis: WikiItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  onNeedLogin: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onSpotIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await NqBizService.findTrail(this.spotId)
    this.relatedWikis = []
    if (this.item !== undefined && this.item.relatedWikiIds.length > 0) {
      const ids = RelatedIds.split(this.item.relatedWikiIds)
      const all = await NqBizService.loadArticles('')
      const picked: WikiItem[] = []
      for (const w of all) {
        for (const id of ids) {
          if (w.id === id) {
            picked.push(w)
          }
        }
      }
      this.relatedWikis = picked
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async fav(): Promise<void> {
    if (!AuthService.requireAuth('sync')) {
      this.onNeedLogin()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await NqBizService.addFavorite(this.item.title, 'trail', this.item.id)
    this.showToast(ok ? '已收藏这个探索点' : '收藏失败，请稍后重试')
  }

  private async noteFromSpot(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const rec = ExploreRecord.createNew()
    rec.title = `${this.item.title} 探索记`
    rec.location = this.item.region
    rec.body = this.item.summary
    const ok = await ExploreRecordStore.save(rec)
    if (ok) {
      NqDetailNav.switchTabRecords()
      NqDetailNav.close()
      this.showToast('已创建探索记录，可在「记录」查看')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '展开探索点' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '探索点', onClose: () => NqDetailNav.close() }) {
          AppEmpty({ title: '探索点不存在', description: '请返回列表重试' })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.spotId, onClose: () => NqDetailNav.close() }) {
          this.Body()
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
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
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(this.item !== undefined ? `${this.item.region} · ${this.item.modeLabel()}` : '')
            .fontSize(Theme.type.footnote)
            .fontColor('#F5F0E8')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
      .height(220)

      Column({ space: 8 }) {
        Text(this.item !== undefined ? this.item.metaLine() : '')
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
        Text('探索说明')
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

      if (this.item !== undefined && this.item.waypoints.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('沿途看点')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.item.waypoints, (n: Waypoint, idx: number) => {
            Column({ space: 4 }) {
              Text(`${n.km} km  ·  ${n.title}`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(n.note)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
          }, (n: Waypoint, idx: number) => `wp-${idx}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }

      if (this.relatedWikis.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('关联百科')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.relatedWikis, (w: WikiItem) => {
            Row() {
              Text(`${w.title}  ·  ${w.category}`)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => NqDetailNav.openWiki(w.id))
          }, (w: WikiItem) => w.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }

      Column({ space: Theme.space.s3 }) {
        AppButton({ label: '记一笔探索', onTap: (): void => { void this.noteFromSpot() } })
        AppButton({
          label: '收藏探索点',
          variant: 'secondary',
          onTap: (): void => { void this.fav() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .width('100%')
  }
}
