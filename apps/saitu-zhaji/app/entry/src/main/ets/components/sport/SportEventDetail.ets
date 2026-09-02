import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { SportEvent } from '../../models/SaituSportModels'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { SaituAchievementStore } from '../../services/SaituAchievementStore'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct SportEventDetail {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituSportDetailId') @Watch('onIdChange') eventId: string = ''
  onChanged: () => void = () => {}
  @State item: SportEvent = new SportEvent()
  @State albumTitle: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await SaituSportStore.findEvent(this.eventId)
    if (found !== undefined) {
      this.item = found
      if (found.albumId.length > 0) {
        const alb = await SaituSportStore.findAlbum(found.albumId)
        this.albumTitle = alb !== undefined ? alb.title : ''
      } else {
        this.albumTitle = ''
      }
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async cyclePlan(): Promise<void> {
    if (this.item.kind !== 'plan') {
      return
    }
    if (this.item.status === 'pending') {
      this.item.status = 'done'
    } else if (this.item.status === 'done') {
      this.item.status = 'reviewed'
    } else {
      this.item.status = 'pending'
    }
    await SaituSportStore.saveEvent(this.item)
    this.showToast(`状态已更新为${this.item.statusLabel()}`)
    this.onChanged()
  }

  private async doDelete(): Promise<void> {
    await SaituSportStore.deleteEvent(this.item.id)
    this.confirmDelete = false
    SaituDetailNav.closeSportDetail()
    this.onChanged()
  }

  private async toggleFavorite(): Promise<void> {
    this.item.favorite = !this.item.favorite
    await SaituSportStore.saveEvent(this.item)
    await SaituAchievementStore.evaluateAndUnlock()
    this.showToast(this.item.favorite ? '已加入收藏' : '已取消收藏')
    this.onChanged()
  }

  private async copyReview(): Promise<void> {
    const text = this.item.reviewExportText()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('复盘已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  @Builder
  ReviewBlock(label: string, content: string) {
    if (content.length > 0) {
      Column({ space: Theme.space.s1 }) {
        Text(label)
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Text(content)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(22)
          .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          if (this.item.images.length > 0) {
            Image(ImagePathUtil.toDisplayUri(this.item.images[0]))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
          } else {
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 160,
                colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
              })
              .borderRadius(Theme.radius.lg)
          }
          Column()
            .width('100%')
            .height(100)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.72)', 1]]
            })
            .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
          Column({ space: Theme.space.s2 }) {
            Text(this.item.kindLabel())
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(`${this.item.eventDate} · ${this.item.typeLabel()}`)
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s5)
        }
        .width('100%')

        if (this.item.hasScore()) {
          Column({ space: Theme.space.s2 }) {
            Row() {
              Column({ space: 4 }) {
                Text(this.item.homeName)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(this.item.homeScore.length > 0 ? this.item.homeScore : '-')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .layoutWeight(1)
              Text(':')
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().textTertiary)
              Column({ space: 4 }) {
                Text(this.item.awayName)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(this.item.awayScore.length > 0 ? this.item.awayScore : '-')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .layoutWeight(1)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            if (this.item.watchModeLabel().length > 0 || this.item.moodStars().length > 0) {
              Text(`${this.item.watchModeLabel()}${this.item.moodStars().length > 0 ? ' · ' + this.item.moodStars() : ''}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            }
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }

        if (this.item.images.length > 1) {
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.item.images, (uri: string, idx: number) => {
                Image(ImagePathUtil.toDisplayUri(uri))
                  .width(120)
                  .height(90)
                  .borderRadius(Theme.radius.sm)
                  .objectFit(ImageFit.Cover)
              }, (uri: string, idx: number) => `${idx}_${uri}`)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

        if (this.item.kind === 'review' && this.item.hasReviewSections()) {
          Text('结构化复盘')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          this.ReviewBlock('场面与节奏', this.item.reviewScene)
          this.ReviewBlock('关键球/节点', this.item.reviewKeyMoment)
          this.ReviewBlock('情绪曲线', this.item.reviewEmotion)
          this.ReviewBlock('带走一句', this.item.reviewTakeaway)
          AppButton({
            label: '复制复盘到剪贴板',
            variant: 'secondary',
            onTap: (): void => { void this.copyReview() }
          })
        }

        Column({ space: Theme.space.s2 }) {
          Text('摘要')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
          Text(this.item.highlight.length > 0 ? this.item.highlight : '未填写亮点，可编辑补充。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text(this.item.body.length > 0 ? this.item.body : '正文为空，点编辑写下过程或复盘。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')

        if (this.item.tags.length > 0) {
          Text(`标签 · ${this.item.tags}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
        }
        if (this.albumTitle.length > 0) {
          Text(`纪念册 · ${this.albumTitle}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
        }
        if (this.item.kind === 'plan') {
          AppButton({
            label: `切换状态（当前：${this.item.statusLabel()}）`,
            variant: 'secondary',
            onTap: (): void => { void this.cyclePlan() }
          })
        }
        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '编辑',
            variant: 'primary',
            onTap: (): void => SaituDetailNav.openSportEditor(this.item.id, this.item.kind)
          })
          AppButton({
            label: this.item.favorite ? '已收藏' : '收藏',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFavorite() }
          })
          AppButton({
            label: '删除',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.item.kindLabel(),
        onClose: (): void => SaituDetailNav.closeSportDetail(),
        body: (): void => this.bodyContent()
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('确认删除这条赛事档案？')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .position({ x: '10%', y: '32%' })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
