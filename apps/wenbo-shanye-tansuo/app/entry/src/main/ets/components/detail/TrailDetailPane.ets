import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TrailItem, Waypoint, WikiItem } from '../../models/MxModels'
import { MxBizService } from '../../services/MxBizService'
import { MxDetailNav } from '../../services/MxDetailNav'
import { MxMedia } from '../../services/MxMedia'
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
export struct TrailDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTrailIdChange') trailId: string = ''
  @Prop @Watch('onTrailIdChange') refreshToken: number = 0
  @State item: TrailItem | undefined = undefined
  @State relatedWikis: WikiItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  onNeedLogin: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTrailIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await MxBizService.findTrail(this.trailId)
    this.relatedWikis = []
    if (this.item !== undefined && this.item.relatedWikiIds.length > 0) {
      const ids = RelatedIds.split(this.item.relatedWikiIds)
      const all = await MxBizService.loadArticles('')
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
    if (!AuthService.requireAuth('favorite_trail')) {
      this.onNeedLogin()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await MxBizService.addFavorite(this.item.title, 'trail', this.item.id)
    this.showToast(ok ? '已收藏这条路线' : '收藏失败，请稍后重试')
  }

  private async mark(): Promise<void> {
    if (!AuthService.requireAuth('mark_footprint')) {
      this.onNeedLogin()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await MxBizService.markFootprint(this.item, '已走')
    this.showToast(ok ? '已记入探索足迹' : '标记失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '展开路线' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '路线', onClose: () => MxDetailNav.close() }) {
          AppEmpty({ title: '路线不存在', description: '请返回列表重试' })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.trailId, onClose: () => MxDetailNav.close() }) {
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
        Image(MxMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_ridge_compass'))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(110)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,29,31,0)', 0], ['rgba(26,29,31,0.86)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(this.item !== undefined ? `${this.item.region} · ${this.item.modeLabel()}` : '')
            .fontSize(Theme.type.footnote)
            .fontColor('#F5F3F0')
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
        Text('路线说明')
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
        Text('沿途看点')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.item !== undefined ? this.item.waypoints : [], (n: Waypoint, idx: number) => {
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

      Column({ space: Theme.space.s3 }) {
        Text('季节窗口')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item !== undefined ? this.item.seasonHint : '')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text('装备提示')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item !== undefined ? this.item.gearHint : '')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .width('auto')

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
            .onClick(() => MxDetailNav.openWiki(w.id))
          }, (w: WikiItem) => w.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }

      Column({ space: Theme.space.s3 }) {
        AppButton({ label: '收藏这条路线', onTap: (): void => { void this.fav() } })
        AppButton({
          label: '标记为已走',
          variant: 'secondary',
          onTap: (): void => { void this.mark() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .width('100%')
  }
}
