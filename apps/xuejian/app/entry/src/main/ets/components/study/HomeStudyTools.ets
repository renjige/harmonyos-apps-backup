import { Theme } from '../design-system/Theme'
import { KnowledgeCardItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

/** 首页可见的复习 + 打卡闭环，避免审核判定为仅计时记录 */
@Component
export struct HomeStudyTools {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State card: KnowledgeCardItem = new KnowledgeCardItem()
  @State hasCard: boolean = false
  @State flipped: boolean = false
  @State checkin: string = ''
  @State savedLine: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private ink(): string {
    return Theme.isDark() ? '#F8FAFC' : '#0F172A'
  }

  private muted(): string {
    return Theme.bodyMutedOnTint()
  }

  private async load(): Promise<void> {
    this.savedLine = await StudyStore.loadTodayCheckin()
    const pick = await StudyStore.randomReviewCard()
    if (pick === undefined) {
      this.hasCard = false
      this.card = new KnowledgeCardItem()
      return
    }
    this.card = pick
    this.hasCard = true
    this.flipped = false
  }

  private async shuffleCard(): Promise<void> {
    const pick = await StudyStore.randomReviewCard()
    if (pick === undefined) {
      this.hasCard = false
      this.card = new KnowledgeCardItem()
      this.showToast('没有可复习的卡片，请到「我的」新建')
      return
    }
    this.card = pick
    this.hasCard = true
    this.flipped = false
  }

  private async deletePlaceholder(): Promise<void> {
    if (!this.hasCard || !this.card.isPlaceholder()) {
      return
    }
    await StudyStore.deleteCard(this.card.id)
    this.showToast('已删除占位卡片')
    await this.load()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async markMastered(): Promise<void> {
    if (!this.hasCard) {
      this.showToast('先建一张知识卡片')
      return
    }
    this.card.mastery = 'mastered'
    await StudyStore.saveCard(this.card)
    this.showToast('已标记掌握')
    await this.load()
  }

  private async saveCheckin(): Promise<void> {
    const line = this.checkin.trim()
    if (line.length === 0) {
      this.showToast('写一句今天学到的')
      return
    }
    await StudyStore.saveTodayCheckin(line)
    this.checkin = ''
    this.savedLine = line
    this.showToast('今日一句已记下')
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('翻转复习')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? this.ink() : this.ink())
        .width('100%')
      if (!this.hasCard) {
        Text('还没有卡片。到「我的 → 卡片」填写术语并保存，回来即可翻转复习。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.muted())
          .width('100%')
      } else {
        Column({ space: 8 }) {
          if (this.card.isPlaceholder()) {
            Text('这是旧版误触生成的占位卡，不是真实内容')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.muted())
              .width('100%')
          }
          Text(this.card.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.ink())
            .width('100%')
          Text(this.flipped ? (this.card.body.length > 0 ? this.card.body : '尚未填写解释') : '点卡片翻转查看解释')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.muted())
            .width('100%')
          Row({ space: 8 }) {
            Text(this.card.isMastered() ? '已掌握' : '标记掌握')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor('#1A2A4A')
              .borderRadius(16)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { void this.markMastered() })
            Text('翻转')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor('#1A2A4A')
              .borderRadius(16)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { this.flipped = !this.flipped })
            Text('换一张')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.softButtonFg())
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor(Theme.softButtonBg())
              .border({ width: 1, color: Theme.softButtonBorder() })
              .borderRadius(16)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { void this.shuffleCard() })
          }
          .width('100%')
          if (this.card.isPlaceholder()) {
            Text('删除占位卡')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor('#B91C1C')
              .borderRadius(16)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { void this.deletePlaceholder() })
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Theme.isDark() ? '#3A4558' : '#EFEAE3')
        .borderRadius(12)
        .onClick((): void => { this.flipped = !this.flipped })
      }

      Text('今日一句')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.ink())
        .width('100%')
      if (this.savedLine.length > 0) {
        Text(`已记下：${this.savedLine}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.muted())
          .width('100%')
      }
      Row({ space: 8 }) {
        TextInput({ text: this.checkin, placeholder: '今天最想记住的一句' })
          .layoutWeight(1)
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.checkin = v })
        Text('记下')
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .padding({ left: 14, right: 14, top: 12, bottom: 12 })
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { void this.saveCheckin() })
      }
      .width('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor('#1A2A4A')
          .borderRadius(10)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.isDark() ? '#2C2C2E' : '#FFFFFF')
    .borderRadius(16)
  }
}
