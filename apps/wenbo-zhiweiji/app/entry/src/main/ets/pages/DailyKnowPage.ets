import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { DailyKnowItem } from '../models/ZhiweiModels'
import { DailyKnowCatalog } from '../services/DailyKnowCatalog'
import { ZhiweiMedia } from '../services/ZhiweiMedia'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct DailyKnowPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwDailyId') dailyId: string = ''
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State item: DailyKnowItem = new DailyKnowItem()
  @State read: boolean = false
  @State showReflect: boolean = false
  @State useWhere: string = ''
  @State counter: string = ''
  @State teach: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    if (this.dailyId.length > 0) {
      const found = DailyKnowCatalog.findById(this.dailyId)
      this.item = found !== null ? found : DailyKnowCatalog.today()
    } else {
      this.item = DailyKnowCatalog.today()
    }
    this.read = ZhiweiStore.isDailyRead(this.item.id)
    this.showReflect = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async markRead(): Promise<void> {
    const ok = await ZhiweiStore.markDailyRead(this.item.id)
    if (ok) {
      this.read = true
      this.showReflect = true
      this.showToast('已打卡，请完成下方三问巩固记忆')
      return
    }
    this.showToast('标记失败，请重试')
  }

  private async saveReflection(): Promise<void> {
    if (this.useWhere.trim().length === 0) {
      this.showToast('请至少写「能用在哪」')
      return
    }
    const ok = await ZhiweiStore.captureFromDailyReflection(
      this.item.title, this.item.body, this.item.category,
      this.useWhere.trim(), this.counter.trim(), this.teach.trim())
    if (ok) {
      this.showReflect = false
      this.showToast('已生成结构化笔记，可在复习队列巩固')
      return
    }
    this.showToast('保存失败，请重试')
  }

  private async collect(): Promise<void> {
    const ok = await ZhiweiStore.captureFromDaily(this.item.title, this.item.body, this.item.category)
    if (ok) {
      this.showToast('已收进知识库')
      return
    }
    this.showToast('收进失败，请重试')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => ZhiweiNav.closeDaily())
          Text('每日一知')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack() {
              Image(ZhiweiMedia.coverOf(this.item.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0.10)', 0], ['rgba(26,26,46,0.78)', 1]]
                })
              Column({ space: 6 }) {
                Text(CategoryEmojiUtil.chipLabel(this.item.category))
                  .fontSize(Theme.type.caption)
                  .fontColor('#F5F7FA')
                  .width('100%')
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F5F7FA')
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.md)
            .clip(true)

            Text(this.read ? '今日已阅读打卡' : '读完可标记已读，并完成三问巩固')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
              .lineHeight(22)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
            if (!this.read) {
              AppButton({
                label: '标记已读 · 今日打卡',
                variant: 'primary',
                onTap: (): void => { void this.markRead() }
              })
            }
            if (this.showReflect) {
              Column({ space: Theme.space.s3 }) {
                Text('学完三问（生成结构化笔记）')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .width('100%')
                TextInput({ text: this.useWhere, placeholder: '这篇能用在哪？' })
                  .width('100%')
                  .height(44)
                  .fontSize(Theme.type.body)
                  .onChange((v: string) => { this.useWhere = v })
                TextInput({ text: this.counter, placeholder: '反例或适用边界（选填）' })
                  .width('100%')
                  .height(44)
                  .fontSize(Theme.type.body)
                  .onChange((v: string) => { this.counter = v })
                TextInput({ text: this.teach, placeholder: '一句话教给别人（选填）' })
                  .width('100%')
                  .height(44)
                  .fontSize(Theme.type.body)
                  .onChange((v: string) => { this.teach = v })
                AppButton({
                  label: '保存为微知识笔记',
                  variant: 'primary',
                  onTap: (): void => { void this.saveReflection() }
                })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
            }
            AppButton({
              label: '快速收进知识库',
              variant: 'secondary',
              onTap: (): void => { void this.collect() }
            })
            Blank().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)

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
        .padding({ top: 48 })
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
