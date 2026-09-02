import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { BrochureItem } from '../../models/BrochureModels'
import { BrochureMedia } from '../../services/BrochureMedia'
import { BrochureDetailNav } from '../../services/BrochureDetailNav'
import { FavoriteService } from '../../services/FavoriteService'
import { CompareStore } from '../../services/CompareStore'
import { WatchlistService } from '../../services/WatchlistService'
import { BrowseHistoryService } from '../../services/BrowseHistoryService'
import { DetailShell } from './DetailShell'

@Component
export struct BrochureDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: BrochureItem = new BrochureItem()
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @StorageLink('compareTick') compareTick: number = 0
  @StorageLink('watchTick') watchTick: number = 0
  @State fav: boolean = false
  @State compared: boolean = false
  @State watching: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    this.refreshFlags()
    void BrowseHistoryService.record(this.item.id, this.item.title, 'brochure')
  }

  private refreshFlags(): void {
    this.fav = FavoriteService.isFavorite(this.item.id)
    this.compared = CompareStore.contains(this.item.id)
    this.watching = WatchlistService.isWatching(this.item.id)
  }

  private handleBack(): void {
    BrochureDetailNav.close()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => {
      this.toastText = ''
    }, 2400)
  }

  private dateRange(): string {
    if (this.item.registrationStart.length === 0 && this.item.registrationEnd.length === 0) {
      return '以各省教育考试院及院校官网通知为准'
    }
    return `${this.item.registrationStart} 至 ${this.item.registrationEnd}`
  }

  private async toggleFavorite(): Promise<void> {
    this.fav = await FavoriteService.toggle(this.item.id, this.item.title)
    this.showToast(this.fav ? '已加入收藏' : '已取消收藏')
  }

  private async toggleCompare(): Promise<void> {
    if (CompareStore.contains(this.item.id)) {
      await CompareStore.remove(this.item.id)
      this.compared = false
      this.showToast('已从对比清单移除')
      return
    }
    if (!CompareStore.canAdd()) {
      this.showToast(`对比清单最多 ${CompareStore.maxCount()} 所院校`)
      return
    }
    const ok = await CompareStore.add(this.item.id)
    this.compared = ok
    if (ok) {
      this.showToast('已加入对比清单')
    }
  }

  private async toggleWatch(): Promise<void> {
    this.watching = await WatchlistService.toggle(this.item.id, this.item.title)
    this.showToast(this.watching ? '已关注该院校' : '已取消关注')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Column() {
          DetailShell({
            title: '简章详情',
            onClose: (): void => { this.handleBack() }
          }) {
            Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(BrochureMedia.cover(this.item.coverKey))
                  .width('100%')
                  .height(240)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(240)
                  .linearGradient({
                    angle: 180,
                    colors: [[0x00000000, 0.12], [0xCC0A2540, 0.55], [0xF00A2540, 1.0]]
                  })
                Row({ space: Theme.space.s3 }) {
                  Column({ space: Theme.space.s2 }) {
                    if (this.item.level.length > 0) {
                      Text(this.item.level)
                        .fontSize(Theme.type.overline)
                        .fontColor('#FFFFFF')
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor('rgba(0,122,255,0.85)')
                        .borderRadius(Theme.radius.pill)
                    }
                    Text(this.item.title)
                      .fontSize(Theme.type.title2)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .maxLines(2)
                    Text(this.item.metaLine())
                      .fontSize(Theme.type.caption)
                      .fontColor('#E8F4FF')
                    if (this.item.enrollmentTotal > 0) {
                      Text(`计划招生 ${this.item.enrollmentTotal} 人`)
                        .fontSize(Theme.type.caption)
                        .fontColor('#E8F4FF')
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding({
                  left: Theme.space.pageX,
                  right: Theme.space.pageX,
                  bottom: Theme.space.s4
                })
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .clip(true)

              Column({ space: Theme.space.s4 }) {
                if (this.item.tagList().length > 0) {
                  Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
                    ForEach(this.item.tagList(), (tag: string) => {
                      Text(tag)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor(Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.pill)
                        .margin({ right: 8, bottom: 8 })
                    }, (tag: string) => tag)
                  }
                  .width('100%')
                }
                AppCard({ title: '摘要' }) {
                  Text(this.item.summary.length > 0 ? this.item.summary : this.item.description)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .lineHeight(24)
                    .width('100%')
                }
                if (this.item.majorList().length > 0) {
                  AppCard({ title: '招生专业' }) {
                    Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
                      ForEach(this.item.majorList(), (major: string) => {
                        Text(major)
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                          .backgroundColor(Theme.colors().surfaceSubtle)
                          .borderRadius(Theme.radius.sm)
                          .margin({ right: 8, bottom: 8 })
                      }, (major: string) => major)
                    }
                    .width('100%')
                  }
                }
                AppCard({ title: '简章正文' }) {
                  Text(this.item.body.length > 0 ? this.item.body : this.item.description)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .lineHeight(24)
                    .width('100%')
                }
                AppCard({ title: '关键信息' }) {
                  Column({ space: Theme.space.s2 }) {
                    this.InfoRow('招生计划', `${this.item.enrollmentTotal} 人`)
                    this.InfoRow('参考分数线', this.item.scoreLine.length > 0 ?
                      this.item.scoreLine : '见各省投档线')
                    this.InfoRow('报名时间', this.dateRange())
                    this.InfoRow('咨询电话', this.item.contactPhone.length > 0 ?
                      this.item.contactPhone : '见官网')
                    this.InfoRow('招生邮箱', this.item.contactEmail.length > 0 ?
                      this.item.contactEmail : '见官网')
                    if (this.item.contactWebsite.length > 0) {
                      this.InfoRow('招生官网', this.item.contactWebsite)
                    }
                  }
                  .width('100%')
                }
                if (this.item.tuition.length > 0) {
                  AppCard({ title: '学费与住宿' }) {
                    Text(this.item.tuition)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .lineHeight(24)
                      .width('100%')
                  }
                }
                if (this.item.scholarship.length > 0) {
                  AppCard({ title: '奖助政策' }) {
                    Text(this.item.scholarship)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .lineHeight(24)
                      .width('100%')
                  }
                }
                if (this.item.examRequirement.length > 0) {
                  AppCard({ title: '选科与体检' }) {
                    Text(this.item.examRequirement)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .lineHeight(24)
                      .width('100%')
                  }
                }
                if (this.item.note.length > 0) {
                  Text(this.item.note)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                Blank().height(Theme.space.s2)
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX
              })
              .width('100%')
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          }
        }
        .layoutWeight(1)

        Column({ space: Theme.space.s2 }) {
          Row({ space: Theme.space.s2 }) {
            this.ActionChip('bookmark', this.fav ? '已收藏' : '收藏', this.fav,
              (): void => { void this.toggleFavorite() })
            this.ActionChip('chart', this.compared ? '已对比' : '加入对比', this.compared,
              (): void => { void this.toggleCompare() })
            this.ActionChip('ai', this.watching ? '已关注' : '关注院校', this.watching,
              (): void => { void this.toggleWatch() })
          }
          .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s4,
          top: Theme.space.s2
        })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
      }
      .width('100%')
      .height('100%')

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
  ActionChip(icon: AppIconName, label: string, active: boolean, onTap: () => void) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: icon,
          iconSize: Theme.icon.md,
          color: active ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(active ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      Text(label)
        .fontSize(Theme.type.overline)
        .fontColor(active ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Theme.space.s2, bottom: Theme.space.s1 })
    .onClick((): void => { onTap() })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width(72)
      Text(value)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
