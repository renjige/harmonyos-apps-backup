import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppTextField, AppTextAreaField } from '../components/design-system/AppTextField'
import { FanEntry, FanKind } from '../models/FanModels'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

@Component
export struct FanEditorPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('courtFanKind') courtFanKind: string = FanKind.MATCH
  @StorageLink('courtFanEditId') @Watch('onEditIdChange') courtFanEditId: string = ''
  @State titleText: string = ''
  @State subtitleText: string = ''
  @State dateLabel: string = ''
  @State bodyText: string = ''
  @State extraText: string = ''
  @State statusVal: string = ''
  @State ratingVal: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    this.hydrate()
  }

  onEditIdChange(): void {
    this.hydrate()
  }

  private hydrate(): void {
    if (this.courtFanEditId.length > 0) {
      const found = FanMemoryStore.find(this.courtFanEditId)
      if (found !== undefined) {
        this.titleText = found.title
        this.subtitleText = found.subtitle
        this.dateLabel = found.dateLabel
        this.bodyText = found.body
        this.extraText = found.extra
        this.statusVal = found.status
        this.ratingVal = found.rating
        return
      }
    }
    this.titleText = ''
    this.subtitleText = ''
    this.dateLabel = DateFormatUtil.formatDate(new Date())
    this.bodyText = ''
    this.extraText = ''
    this.statusVal = FanKind.defaultStatus(this.courtFanKind)
    this.ratingVal = 0
    const hint = AppStorage.get<string>('courtFanAlbumHint') ?? ''
    if (hint.length > 0 && this.courtFanKind === FanKind.MATCH) {
      this.extraText = hint
      AppStorage.setOrCreate('courtFanAlbumHint', '')
    }
    const preTitle = AppStorage.get<string>('courtFanPrefillTitle') ?? ''
    const preBody = AppStorage.get<string>('courtFanPrefillBody') ?? ''
    if (this.courtFanEditId.length === 0 && preTitle.length > 0) {
      this.titleText = preTitle
      AppStorage.setOrCreate('courtFanPrefillTitle', '')
    }
    if (this.courtFanEditId.length === 0 && preBody.length > 0) {
      this.bodyText = preBody
      AppStorage.setOrCreate('courtFanPrefillBody', '')
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async save(): Promise<void> {
    if (this.titleText.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    const e = new FanEntry()
    e.id = this.courtFanEditId
    e.kind = this.courtFanKind
    e.title = this.titleText.trim()
    e.subtitle = this.subtitleText.trim()
    e.dateLabel = this.dateLabel
    e.body = this.bodyText.trim()
    e.extra = this.extraText.trim()
    e.status = this.statusVal
    e.rating = this.ratingVal
    await FanMemoryStore.save(e)
    CourtDetailNav.closeFanEditor()
  }

  private extraPlaceholder(): string {
    if (this.courtFanKind === FanKind.MATCH) {
      return '收入收藏册名称（选填）'
    }
    if (this.courtFanKind === FanKind.EVENT) {
      return '看点备忘（选填）'
    }
    return '例如：最后一分钟绝杀'
  }

  private chipColor(active: boolean): ResourceColor {
    return active ? Theme.colors().textOnBrandContainer : Theme.colors().textSecondary
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .rotate({ angle: 180 })
          .onClick(() => {
            CourtDetailNav.closeFanEditor()
          })
          Text(this.courtFanEditId.length > 0 ? '编辑' : `新建${FanKind.titleOf(this.courtFanKind)}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            AppTextField({
              text: this.titleText,
              placeholder: FanKind.titlePlaceholder(this.courtFanKind),
              onChange: (v: string): void => {
                this.titleText = v
              }
            })

            AppDatePickerField({
              label: '日期',
              value: this.dateLabel,
              minDaysFromToday: -3650,
              maxDaysFromToday: 365,
              onChange: (v: string): void => {
                this.dateLabel = v
              }
            })

            if (this.courtFanKind === FanKind.ALBUM) {
              AppTextField({
                text: this.subtitleText,
                placeholder: '主题：世界杯 / 经典决赛 / 德比',
                fieldHeight: 44,
                onChange: (v: string): void => {
                  this.subtitleText = v
                }
              })
            }
            if (this.courtFanKind === FanKind.TEAM || this.courtFanKind === FanKind.PLAYER) {
              AppTextField({
                text: this.subtitleText,
                placeholder: this.courtFanKind === FanKind.TEAM ? '联赛 / 地区' : '位置 / 号码',
                fieldHeight: 44,
                onChange: (v: string): void => {
                  this.subtitleText = v
                }
              })
            }

            if (this.courtFanKind === FanKind.WATCHLIST) {
              this.StatusRow('pending', '待观看', 'watched', '已观看', 'starred', '已收藏')
            }
            if (this.courtFanKind === FanKind.TEAM) {
              this.StatusRow('like', '喜欢', 'follow', '关注', 'classic', '经典')
            }
            if (this.courtFanKind === FanKind.JOURNAL) {
              this.StatusRow('feel', '看球感受', 'analysis', '比赛分析', 'story', '球迷故事')
            }
            if (this.courtFanKind === FanKind.KNOWLEDGE) {
              this.StatusRow('history', '球队历史', 'player', '球员故事', 'rule', '比赛规则')
            }
            if (this.courtFanKind === FanKind.MATCH || this.courtFanKind === FanKind.REVIEW) {
              this.RatingRow()
            }

            AppTextAreaField({
              text: this.bodyText,
              placeholder: FanKind.bodyPlaceholder(this.courtFanKind),
              onChange: (v: string): void => {
                this.bodyText = v
              }
            })

            if (this.courtFanKind === FanKind.MATCH || this.courtFanKind === FanKind.HIGHLIGHT ||
              this.courtFanKind === FanKind.EVENT) {
              AppTextField({
                text: this.extraText,
                placeholder: this.extraPlaceholder(),
                fieldHeight: 44,
                onChange: (v: string): void => {
                  this.extraText = v
                }
              })
            }

            AppButton({
              label: '保存',
              onTap: (): void => {
                void this.save()
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatusRow(v1: string, l1: string, v2: string, l2: string, v3: string, l3: string) {
    Row({ space: Theme.space.s2 }) {
      Text(l1)
        .fontSize(Theme.type.caption)
        .fontColor(this.chipColor(this.statusVal === v1))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.statusVal === v1 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          this.statusVal = v1
        })
      Text(l2)
        .fontSize(Theme.type.caption)
        .fontColor(this.chipColor(this.statusVal === v2))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.statusVal === v2 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          this.statusVal = v2
        })
      Text(l3)
        .fontSize(Theme.type.caption)
        .fontColor(this.chipColor(this.statusVal === v3))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.statusVal === v3 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          this.statusVal = v3
        })
    }
    .width('100%')
  }

  @Builder
  RatingRow() {
    Row({ space: Theme.space.s2 }) {
      Text('未评分')
        .fontSize(Theme.type.caption)
        .fontColor(this.chipColor(this.ratingVal === 0))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.ratingVal === 0 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          this.ratingVal = 0
        })
      Text('值得一看')
        .fontSize(Theme.type.caption)
        .fontColor(this.chipColor(this.ratingVal === 3))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.ratingVal === 3 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          this.ratingVal = 3
        })
      Text('经典战役')
        .fontSize(Theme.type.caption)
        .fontColor(this.chipColor(this.ratingVal === 5))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.ratingVal === 5 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => {
          this.ratingVal = 5
        })
    }
    .width('100%')
  }
}
