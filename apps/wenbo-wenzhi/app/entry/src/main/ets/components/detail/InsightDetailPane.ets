import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { CollectionItem, InsightItem } from '../../models/AskModels'
import { AskBizService } from '../../services/AskBizService'
import { AskMedia } from '../../services/AskMedia'
import { AskNav } from '../../services/AskNav'
import { LearnStore } from '../../services/LearnStore'
import { GrowthStore } from '../../services/GrowthStore'
import { VaultStore } from '../../services/VaultStore'

@Component
export struct InsightDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'insight'
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State title: string = ''
  @State category: string = ''
  @State summary: string = ''
  @State body: string = ''
  @State description: string = ''
  @State further: string = ''
  @State coverKey: string = 'cover_study'
  @State insightId: string = ''
  @State note: string = ''
  @State loaded: boolean = false
  @State toastText: string = ''
  @State collected: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.kind === 'collection') {
      const found = VaultStore.find(this.itemId)
      if (found === undefined) {
        this.loaded = false
        return
      }
      this.applyCollection(found)
      this.loaded = true
      return
    }
    const row = await AskBizService.findInsight(this.itemId)
    if (row === undefined) {
      this.loaded = false
      return
    }
    this.applyInsight(row)
    this.collected = VaultStore.isCollected(row.id)
    this.loaded = true
  }

  private applyInsight(row: InsightItem): void {
    this.title = row.title
    this.category = row.category
    this.summary = row.summary
    this.body = row.body
    this.description = row.description
    this.further = row.further
    this.coverKey = row.coverKey
    this.insightId = row.id
    this.note = ''
  }

  private applyCollection(row: CollectionItem): void {
    this.title = row.question
    this.category = row.folder
    this.summary = row.summary
    this.body = row.body
    this.description = row.description
    this.further = row.further
    this.coverKey = row.coverKey
    this.insightId = row.insightId
    this.note = row.note
    this.collected = true
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async collectNow(): Promise<void> {
    const insight = new InsightItem()
    insight.id = this.insightId.length > 0 ? this.insightId : this.itemId
    insight.title = this.title
    insight.summary = this.summary
    insight.body = this.body
    insight.description = this.description
    insight.further = this.further
    insight.category = this.category
    insight.coverKey = this.coverKey
    await VaultStore.collect(this.title, insight, this.category, '')
    await GrowthStore.logActivity('collect', this.title, insight.id, this.category)
    this.collected = true
    AskNav.bumpRefresh()
    this.showToast('已收入知识库')
  }

  private currentInsight(): InsightItem {
    const insight = new InsightItem()
    insight.id = this.insightId.length > 0 ? this.insightId : this.itemId
    insight.title = this.title
    insight.summary = this.summary
    insight.body = this.body
    insight.description = this.description
    insight.further = this.further
    insight.category = this.category
    insight.coverKey = this.coverKey
    return insight
  }

  private async saveCard(): Promise<void> {
    const insight = this.currentInsight()
    await LearnStore.saveCard(insight)
    await GrowthStore.logActivity('card', insight.title, insight.id, insight.category)
    AskNav.bumpRefresh()
    this.showToast('已生成知识卡片，可在「我的」里回顾')
  }

  private async shareCard(): Promise<void> {
    const text = LearnStore.cardText(this.title, this.summary, this.body, this.category)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('分享文案已复制，可粘贴到微信等应用')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async writeNote(): Promise<void> {
    if (this.kind === 'collection') {
      AskNav.openNote(this.itemId)
      return
    }
    if (!this.collected) {
      await this.collectNow()
    }
    let colId = this.itemId
    const all = VaultStore.all()
    for (const n of all) {
      if (n.insightId === this.insightId || n.question === this.title) {
        colId = n.id
        break
      }
    }
    AskNav.openNote(colId)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '智慧解答',
        showFavorite: this.kind !== 'collection',
        favorited: this.collected,
        onClose: (): void => { AskNav.closeDetail() },
        onFavorite: (): void => { void this.collectNow() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '未找到内容', description: '返回后重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(AskMedia.resource(this.coverKey))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(100)
                  .linearGradient({
                    direction: GradientDirection.Bottom,
                    colors: [['rgba(11,31,58,0)', 0], ['rgba(11,31,58,0.75)', 1]]
                  })
                Text(this.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)

              Text(`${this.category} · 供参考，不构成专业意见`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              Column({ space: Theme.space.s2 }) {
                Text('摘要')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(this.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              Text('要点归纳')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('相关背景')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.description)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text('延伸阅读')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.further.length > 0 ? this.further : '可结合自己的场景再问一条相关问题。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              if (this.note.length > 0) {
                Text(`我的备注：${this.note}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }

              if (this.kind === 'collection') {
                AppButton({
                  label: '编辑笔记与标签',
                  variant: 'secondary',
                  onTap: (): void => { AskNav.openNote(this.itemId) }
                })
              } else {
                AppButton({
                  label: this.collected ? '已收藏' : '收藏到知识库',
                  onTap: (): void => { void this.collectNow() }
                })
                AppButton({
                  label: '写知识笔记',
                  variant: 'secondary',
                  onTap: (): void => { void this.writeNote() }
                })
              }
              AppButton({
                label: '生成知识卡片',
                variant: 'secondary',
                onTap: (): void => { void this.saveCard() }
              })
              AppButton({
                label: '复制分享文案',
                variant: 'secondary',
                onTap: (): void => { void this.shareCard() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }

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
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
