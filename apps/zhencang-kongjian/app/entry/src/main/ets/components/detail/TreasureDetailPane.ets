import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { TimelineEvent, TreasureItem } from '../../models/TreasureModels'
import { CompletenessUtil } from '../../services/CompletenessUtil'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { TreasureNav } from '../../services/TreasureNav'
import { TreasureStore } from '../../services/TreasureStore'

@Component
export struct TreasureDetailPane {
  @Prop itemId: string = ''
  @Prop @Watch('onOpen') openToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  @State item: TreasureItem = new TreasureItem()
  @State showDeleteConfirm: boolean = false
  @State timelineLabel: string = ''
  @State timelinePeriod: string = ''

  aboutToAppear(): void {
    this.load()
  }

  onOpen(): void {
    this.load()
  }

  private load(): void {
    const found: TreasureItem | null = TreasureStore.findItem(this.itemId)
    this.item = found !== null ? found : new TreasureItem()
    if (found !== null) {
      void TreasureStore.touchView(found.id)
    }
  }

  private ratingStars(): string {
    let stars = ''
    for (let i = 1; i <= 5; i++) {
      stars += i <= this.item.rating ? '★' : '☆'
    }
    return stars
  }

  private tagLabels(): string {
    const parts: string[] = []
    for (const id of this.item.tagIds) {
      const name: string = TreasureStore.tagName(id)
      if (name.length > 0) {
        parts.push(name)
      }
    }
    return parts.join(' · ')
  }

  private async addTimeline(): Promise<void> {
    if (this.timelineLabel.trim().length === 0) {
      this.onToast('请填写轨迹说明')
      return
    }
    const e: TimelineEvent = new TimelineEvent()
    e.id = TreasureStore.newId()
    e.period = this.timelinePeriod.length > 0 ? this.timelinePeriod : '当前'
    e.label = this.timelineLabel.trim()
    this.item.timeline.push(e)
    const ok: boolean = await TreasureStore.saveItem(this.item)
    if (ok) {
      this.timelineLabel = ''
      this.onToast('轨迹已添加')
      this.load()
    } else {
      this.onToast('保存失败，请重试')
    }
  }

  private async confirmDelete(): Promise<void> {
    const ok: boolean = await TreasureStore.softDelete(this.item.id)
    this.showDeleteConfirm = false
    if (ok) {
      TreasureNav.closeDetail()
      this.onToast('已移入回收站')
    } else {
      this.onToast('删除失败')
    }
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.name.length > 0 ? this.item.name : '藏品详情',
        onClose: (): void => { TreasureNav.closeDetail() },
        body: (): void => { this.Body() }
      })

      if (this.showDeleteConfirm) {
        Column({ space: Theme.space.s4 }) {
          Text('移入回收站？')
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
          Text('可在「我的 → 回收站」恢复或彻底删除。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.showDeleteConfirm = false } })
            AppButton({ label: '确认', variant: 'primary', onTap: (): void => { void this.confirmDelete() } })
          }
        }
        .width('88%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 24, color: 'rgba(0,0,0,0.12)', offsetY: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        if (this.item.imagePath.length > 0) {
          Image(ImagePathUtil.displayUri(this.item.imagePath))
            .width('100%')
            .height(240)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
        } else {
          Image($r('app.media.empty_vault'))
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Contain)
            .backgroundColor(Theme.colors().surfaceSubtle)
        }

        Row({ space: Theme.space.s4 }) {
          Text(`档案完整度 ${CompletenessUtil.percent(this.item)}%`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandPrimary)
            .layoutWeight(1)
          if (CompletenessUtil.percent(this.item) < 100) {
            Text('继续完善')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => TreasureNav.openEditor(this.item.id))
          }
        }

        AppCard({
          title: '档案信息',
          content: (): void => { this.MetaBlock() }
        })

        if (this.item.collectReason.length > 0) {
          AppCard({
            title: '收藏原因',
            content: (): void => { this.CollectReasonContent() }
          })
        }

        if (this.item.story.length > 0) {
          AppCard({
            title: '珍藏故事',
            content: (): void => { this.StoryContent() }
          })
        }

        if (this.item.rating > 0 || this.item.appreciationText.length > 0) {
          AppCard({
            title: '鉴赏卡',
            content: (): void => { this.AppreciationContent() }
          })
        }

        if (this.tagLabels().length > 0) {
          AppCard({
            title: '珍藏标签',
            content: (): void => { this.TagsContent() }
          })
        }

        AppCard({
          title: '珍藏轨迹',
          content: (): void => { this.TimelineBlock() }
        })

        Row({ space: Theme.space.s3 }) {
          AppButton({ label: '编辑', variant: 'primary', onTap: (): void => { TreasureNav.openEditor(this.item.id) } })
          AppButton({ label: '对比', variant: 'secondary', onTap: (): void => { TreasureNav.openCompare(this.item.id) } })
          AppButton({ label: '删除', variant: 'secondary', onTap: (): void => { this.showDeleteConfirm = true } })
        }
        .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CollectReasonContent() {
    Text(this.item.collectReason)
      .fontSize(Theme.type.body)
      .fontColor(Theme.colors().textPrimary)
      .lineHeight(24)
  }

  @Builder
  StoryContent() {
    Text(this.item.story)
      .fontSize(Theme.type.body)
      .fontColor(Theme.colors().textPrimary)
      .lineHeight(24)
  }

  @Builder
  AppreciationContent() {
    Column({ space: Theme.space.s2 }) {
      if (this.item.rating > 0) {
        Text(this.ratingStars())
          .fontSize(20)
          .fontColor(Theme.colors().brandPrimary)
      }
      if (this.item.appreciationText.length > 0) {
        Text(this.item.appreciationText)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(22)
      }
      if (this.item.personalReview.length > 0) {
        Text(this.item.personalReview)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
      }
    }
  }

  @Builder
  TagsContent() {
    Text(this.tagLabels())
      .fontSize(Theme.type.body)
      .fontColor(Theme.colors().textSecondary)
  }

  @Builder
  MetaBlock() {
    Column({ space: Theme.space.s2 }) {
      this.MetaRow('分类', TreasureStore.categoryName(this.item.categoryId))
      this.MetaRow('收藏时间', this.item.acquiredAt)
      this.MetaRow('来源', this.item.source)
      this.MetaRow('关键词', this.item.keywords)
      this.MetaRow('特点', this.item.traits)
      this.MetaRow('保存位置', this.item.storageLocation)
      this.MetaRow('档案状态', this.item.archiveStatus)
      this.MetaRow('清单状态', this.item.listStatus)
    }
  }

  @Builder
  MetaRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textSecondary)
        .width(88)
      Text(value.length > 0 ? value : '—')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  TimelineBlock() {
    Column({ space: Theme.space.s3 }) {
      ForEach(this.item.timeline, (e: TimelineEvent) => {
        Row({ space: Theme.space.s3 }) {
          Text(e.period)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width(72)
          Text(e.label)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
      }, (e: TimelineEvent) => e.id)

      TextInput({ text: this.timelinePeriod, placeholder: '时间 如 2025.03' })
        .onChange((v: string) => { this.timelinePeriod = v })
      TextInput({ text: this.timelineLabel, placeholder: '轨迹说明，如 移动至展示柜' })
        .onChange((v: string) => { this.timelineLabel = v })
      AppButton({ label: '添加轨迹', variant: 'secondary', onTap: (): void => { void this.addTimeline() } })
    }
  }
}
