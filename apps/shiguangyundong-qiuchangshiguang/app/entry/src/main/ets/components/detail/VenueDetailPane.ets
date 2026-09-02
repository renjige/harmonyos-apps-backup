import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { SlotItem, VenueItem } from '../../models/CourtModels'
import { CourtMedia } from '../../config/CourtMedia'
import { CourtBizService } from '../../services/CourtBizService'
import { CourtDetailNav } from '../../services/CourtDetailNav'
import { CourtFavoriteStore } from '../../services/CourtFavoriteStore'

@Component
export struct VenueDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('courtFavoriteIds') favCsv: string = ''
  @Prop venueId: string = ''
  @State item: VenueItem = new VenueItem()
  @State loading: boolean = true
  @State slots: SlotItem[] = []
  @State selectedTime: string = ''
  @State toastText: string = ''
  onBook: (slotTime: string) => void = (_t: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const found = await CourtBizService.findVenue(this.venueId)
    if (found !== undefined) {
      this.item = found
      this.slots = CourtBizService.buildSlots(found.id)
    }
    this.loading = false
  }

  private isFav(): boolean {
    return CourtFavoriteStore.isFavorite(this.venueId)
  }

  private async toggleFav(): Promise<void> {
    const added = await CourtFavoriteStore.toggle(this.venueId)
    this.toastText = added ? '已收藏该场馆' : '已取消收藏'
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private slotColor(state: string): ResourceColor {
    if (state === 'open') {
      return Theme.colors().success
    }
    if (state === 'full') {
      return Theme.colors().textTertiary
    }
    return Theme.colors().danger
  }

  private slotLabel(state: string): string {
    if (state === 'open') {
      return '可订'
    }
    if (state === 'full') {
      return '已满'
    }
    return '已过'
  }

  private pickSlot(s: SlotItem): void {
    if (s.state !== 'open') {
      this.toastText = s.state === 'full' ? '该时段已满，请换一档' : '该时段已过时'
      setTimeout(() => {
        this.toastText = ''
      }, 2200)
      return
    }
    this.selectedTime = s.time
  }

  build() {
    Stack() {
      DetailShell({
        title: '场馆详情',
        onClose: (): void => {
          CourtDetailNav.close()
        },
        body: (): void => {
          this.BodyContent()
        },
        footer: (): void => {
          this.FooterActions()
        }
      })
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BodyContent() {
    if (this.loading) {
      Text('加载中…')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
    } else {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CourtMedia.byKey(this.item.coverKey))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column({ space: 0 })
          .width('100%')
          .height(220)
          .borderRadius(Theme.radius.xl)
          .linearGradient({
            angle: 180,
            colors: [
              ['rgba(26,42,58,0.08)', 0.0],
              ['rgba(26,42,58,0.92)', 1.0]
            ]
          })
        Column({ space: 6 }) {
          Text(this.item.category)
            .fontSize(Theme.type.caption)
            .fontColor('rgba(255,255,255,0.85)')
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
          Text(`${this.item.priceLabel} · 评分 ${this.item.rating.toFixed(1)}`)
            .fontSize(Theme.type.subhead)
            .fontColor('rgba(255,255,255,0.92)')
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }

      Row({ space: Theme.space.s3 }) {
        this.MetaChip('区域', this.item.district)
        this.MetaChip('时长', this.item.durationLabel)
        this.MetaChip('预约', `${this.item.orderCount}次`)
      }
      .width('100%')

      AppCard({ title: '场馆简介', variant: 'plain' }) {
        Text(this.item.summary.length > 0 ? this.item.summary : '暂无简介')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }

      Column({ space: Theme.space.s2 }) {
        Text('可订时段（点选后预约）')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('绿=可订 · 灰=已满 · 红=已过时')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.slots, (s: SlotItem) => {
            Column({ space: 2 }) {
              Text(s.time)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.selectedTime === s.time ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              Text(this.slotLabel(s.state))
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedTime === s.time ?
                  Theme.colors().brandOnPrimary : this.slotColor(s.state))
            }
            .width('30%')
            .padding({ top: 10, bottom: 10 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.selectedTime === s.time ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({
              width: 1,
              color: this.selectedTime === s.time ?
                Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
            .onClick(() => {
              this.pickSlot(s)
            })
          }, (s: SlotItem) => s.time)
        }
        .width('100%')
      }
      .width('100%')

      Column({ space: Theme.space.s2 }) {
        Text('详细说明')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('预约仅生成凭证，不含在线支付；到场按场馆现场规则结算。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
  }

  @Builder
  MetaChip(label: string, value: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FooterActions() {
    Column({ space: Theme.space.s3 }) {
      AppButton({
        label: this.isFav() ? '已收藏 · 点按取消' : '收藏场馆',
        variant: 'secondary',
        onTap: (): void => {
          void this.toggleFav()
        }
      })
      AppButton({
        label: this.selectedTime.length > 0 ? `预约 ${this.selectedTime}` : '请先选择可订时段',
        onTap: (): void => {
          if (this.selectedTime.length === 0) {
            this.toastText = '请先点选绿色可订时段'
            setTimeout(() => {
              this.toastText = ''
            }, 2200)
            return
          }
          this.onBook(this.selectedTime)
        }
      })
    }
    .width('100%')
  }
}
