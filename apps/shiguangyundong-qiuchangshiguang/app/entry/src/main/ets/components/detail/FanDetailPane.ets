import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CourtMedia } from '../../config/CourtMedia'
import { FanEntry, FanKind } from '../../models/FanModels'
import { FanMemoryStore } from '../../services/FanMemoryStore'
import { CourtDetailNav } from '../../services/CourtDetailNav'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct FanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('courtFanId') @Watch('onFanIdChange') courtFanId: string = ''
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State entry: FanEntry = new FanEntry()
  @State albumMembers: FanEntry[] = []
  @State relatedItems: FanEntry[] = []
  @State challengeHint: string = ''
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onFanIdChange(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.albumMembers = []
    this.relatedItems = []
    this.challengeHint = ''
    const found = FanMemoryStore.find(this.courtFanId)
    if (found !== undefined) {
      this.entry = found
      this.relatedItems = FanMemoryStore.related(found)
      if (found.kind === FanKind.ALBUM) {
        this.albumMembers = FanMemoryStore.albumMembers(found.title)
      }
      if (found.kind === FanKind.CHALLENGE) {
        this.challengeHint = FanMemoryStore.challengeHint(found.title)
      }
    }
  }

  private addMatchToAlbum(): void {
    AppStorage.setOrCreate('courtFanAlbumHint', this.entry.title)
    CourtDetailNav.openFanEditor(FanKind.MATCH, '')
  }

  private async writeMatchFromWatchlist(): Promise<void> {
    await FanMemoryStore.markWatchlistWatched(this.entry.id)
    AppStorage.setOrCreate('courtFanPrefillTitle', this.entry.title)
    if (this.entry.body.length > 0) {
      AppStorage.setOrCreate('courtFanPrefillBody', this.entry.body)
    }
    this.onChanged()
    CourtDetailNav.openFanEditor(FanKind.MATCH, '')
  }

  private async copyEntryText(): Promise<void> {
    try {
      const text = FanMemoryStore.exportText(this.entry)
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const sys = pasteboard.getSystemPasteboard()
      await sys.setData(data)
      this.showToast('已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2400)
  }

  private ratingText(): string {
    if (this.entry.rating >= 5) {
      return '经典战役'
    }
    if (this.entry.rating >= 3) {
      return '值得一看'
    }
    return ''
  }

  private async toggleChallenge(): Promise<void> {
    this.entry.status = this.entry.status === 'done' ? 'todo' : 'done'
    await FanMemoryStore.save(this.entry)
    this.reload()
    this.onChanged()
    this.showToast(this.entry.status === 'done' ? '挑战已完成' : '已标为进行中')
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await FanMemoryStore.remove(this.entry.id)
    this.onChanged()
    CourtDetailNav.closeFanDetail()
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
            CourtDetailNav.closeFanDetail()
          })
          Text(FanKind.titleOf(this.entry.kind))
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CourtMedia.byKey(FanKind.coverOf(this.entry.kind)))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column() {
                Text(this.entry.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
                if (this.entry.dateLabel.length > 0) {
                  Text(this.entry.dateLabel)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.78)', 1]]
              })
            }
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.lg)
            .clip(true)

            Column({ space: Theme.space.s2 }) {
              if (this.entry.subtitle.length > 0) {
                Text(this.entry.subtitle)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              if (FanMemoryStore.statusLabel(this.entry.kind, this.entry.status).length > 0) {
                Text(FanMemoryStore.statusLabel(this.entry.kind, this.entry.status))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
              }
              if (this.ratingText().length > 0) {
                Text(this.ratingText())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().warning)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            if (this.entry.extra.length > 0 && this.entry.kind !== FanKind.ALBUM) {
              Text(this.entry.kind === FanKind.MATCH ? `收藏册 · ${this.entry.extra}` : this.entry.extra)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
            }

            if (this.entry.kind === FanKind.ALBUM) {
              Text(this.albumMembers.length > 0 ? `已收录 ${this.albumMembers.length} 条` : '还没有收录比赛，可记一场进这本合集')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              ForEach(this.albumMembers, (m: FanEntry) => {
                Text(m.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .onClick(() => {
                    CourtDetailNav.openFanDetail(m.id)
                  })
              }, (m: FanEntry) => m.id)
              AppButton({
                label: '记一场进这本合集',
                onTap: (): void => {
                  this.addMatchToAlbum()
                }
              })
            }

            if (this.challengeHint.length > 0) {
              Text(this.challengeHint)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textOnBrandContainer)
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
            }

            if (this.relatedItems.length > 0) {
              Text('相关记忆')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.relatedItems, (r: FanEntry) => {
                Text(`${FanKind.titleOf(r.kind)} · ${r.title}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .onClick(() => {
                    CourtDetailNav.openFanDetail(r.id)
                  })
              }, (r: FanEntry) => r.id)
            }

            Text(this.entry.body.length > 0 ? this.entry.body : '暂无正文，可点编辑补充。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

            if (this.entry.kind === FanKind.CHALLENGE) {
              AppButton({
                label: this.entry.status === 'done' ? '标为未完成' : '标记完成',
                onTap: (): void => {
                  void this.toggleChallenge()
                }
              })
            }

            if (this.entry.kind === FanKind.WATCHLIST) {
              AppButton({
                label: '看完了，写观赛记录',
                onTap: (): void => {
                  void this.writeMatchFromWatchlist()
                }
              })
            }

            AppButton({
              label: '复制全文',
              variant: 'secondary',
              onTap: (): void => {
                void this.copyEntryText()
              }
            })
            AppButton({
              label: '编辑',
              onTap: (): void => {
                CourtDetailNav.openFanEditor(this.entry.kind, this.entry.id)
              }
            })
            AppButton({
              label: this.confirmDelete ? '再点确认删除' : '删除',
              variant: 'secondary',
              onTap: (): void => {
                void this.doDelete()
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
}
