import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { KnowledgeCardItem } from '../models/LearnModels'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { LearnStore } from '../services/LearnStore'

class FlashDeckItem {
  id: string = ''
  front: string = ''
  back: string = ''
  source: string = ''
}

@Component
export struct FlashcardReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State deck: FlashDeckItem[] = []
  @State index: number = 0
  @State flipped: boolean = false
  @State remembered: number = 0
  @State finished: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.buildDeck()
  }

  private buildDeck(): void {
    const items: FlashDeckItem[] = []
    for (const c of LearnStore.cardAll()) {
      const row = new FlashDeckItem()
      row.id = c.id
      row.front = c.title
      row.back = c.summary.length > 0 ? c.summary : c.body
      row.source = '知识卡片'
      items.push(row)
    }
    for (const w of LearnStore.wrongAll()) {
      const row = new FlashDeckItem()
      row.id = `w_${w.id}`
      row.front = w.title
      row.back = `正确：${w.correct}\n你曾选：${w.picked}`
      row.source = '错题本'
      items.push(row)
    }
    this.deck = items
    this.index = 0
    this.flipped = false
    this.remembered = 0
    this.finished = this.deck.length === 0
  }

  private current(): FlashDeckItem {
    if (this.deck.length === 0) {
      return new FlashDeckItem()
    }
    return this.deck[this.index]
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async mark(ok: boolean): Promise<void> {
    if (ok) {
      this.remembered += 1
    }
    const cur = this.current()
    await GrowthStore.logActivity('card', cur.front, cur.id, cur.source)
    if (this.index + 1 >= this.deck.length) {
      this.finished = true
      AskNav.bumpRefresh()
      return
    }
    this.index += 1
    this.flipped = false
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({ title: '闪卡复习', onBack: (): void => { AskNav.closeLearn() } })
        if (this.finished && this.deck.length === 0) {
          AppEmpty({
            title: '暂无可复习的卡片',
            description: '在解答详情生成知识卡片，或完成挑战积累错题',
            actionLabel: '去挑战',
            onAction: (): void => { AskNav.openChallenge(5) }
          })
            .layoutWeight(1)
        } else if (this.finished) {
          Column({ space: Theme.space.s4 }) {
            Text('本轮复习完成')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            Text(`记住 ${this.remembered} / ${this.deck.length} 张`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            AppButton({ label: '再复习一轮', onTap: (): void => { this.buildDeck() } })
            AppButton({
              label: '查看知识卡片库',
              variant: 'secondary',
              onTap: (): void => { AskNav.openLearn('cards') }
            })
          }
          .padding(Theme.space.pageX)
          .layoutWeight(1)
        } else {
          Column({ space: Theme.space.s4 }) {
            Text(`第 ${this.index + 1} / ${this.deck.length} 张 · ${this.current().source}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Column({ space: Theme.space.s3 }) {
              Text(this.flipped ? '背面' : '正面')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                .width('100%')
              Text(this.flipped ? this.current().back : this.current().front)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')
                .lineHeight(28)
            }
            .width('100%')
            .padding(Theme.space.s5)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            .constraintSize({ minHeight: 200 })
            .onClick((): void => { this.flipped = !this.flipped })

            AppButton({
              label: this.flipped ? '隐藏背面' : '翻转查看要点',
              variant: 'secondary',
              onTap: (): void => { this.flipped = !this.flipped }
            })
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '还需复习',
                variant: 'secondary',
                onTap: (): void => { void this.mark(false) }
              })
                .layoutWeight(1)
              AppButton({
                label: '记住了',
                onTap: (): void => { void this.mark(true) }
              })
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .layoutWeight(1)
        }
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
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
