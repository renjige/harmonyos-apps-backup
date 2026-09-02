import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AskHistoryItem, KnowledgeCardItem, QuizWrongItem } from '../models/LearnModels'
import { AskNav } from '../services/AskNav'
import { LearnStore } from '../services/LearnStore'
import { VaultStore } from '../services/VaultStore'

@Component
export struct HistoryRecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @Prop mode: string = 'history'
  @State toastText: string = ''
  @State history: AskHistoryItem[] = []
  @State wrongs: QuizWrongItem[] = []
  @State cards: KnowledgeCardItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.history = LearnStore.historyAll()
    this.wrongs = LearnStore.wrongAll()
    this.cards = LearnStore.cardAll()
  }

  private title(): string {
    if (this.mode === 'wrong') {
      return '错题本'
    }
    if (this.mode === 'cards') {
      return '知识卡片'
    }
    return '提问记录'
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({ title: this.title(), onBack: (): void => { AskNav.closeLearn() } })
        if (this.mode === 'wrong') {
          this.WrongList()
        } else if (this.mode === 'cards') {
          this.CardList()
        } else {
          this.HistoryList()
        }
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
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HistoryList() {
    if (this.history.length === 0) {
      AppEmpty({
        title: '还没有提问记录',
        description: '在问答页提问后会出现在这里',
        actionLabel: '去提问',
        onAction: (): void => {
          AskNav.closeLearn()
          AskNav.switchTab(0)
        }
      })
        .layoutWeight(1)
    } else {
      List() {
        ForEach(this.history, (n: AskHistoryItem) => {
          ListItem() {
            Column({ space: 4 }) {
              Text(n.question)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`${n.title} · ${n.category} · ${VaultStore.formatDate(n.createdAt)}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick(() => { AskNav.openDetail('insight', n.insightId) })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s3
          })
        }, (n: AskHistoryItem) => n.id)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  WrongList() {
    if (this.wrongs.length === 0) {
      AppEmpty({
        title: '错题本是空的',
        description: '挑战答错的题目会保存在这里',
        actionLabel: '去挑战',
        onAction: (): void => { AskNav.openLearn('challenge') }
      })
        .layoutWeight(1)
    } else {
      List() {
        ForEach(this.wrongs, (n: QuizWrongItem) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(n.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`你的选择：${n.picked}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .width('100%')
              Text(`正确答案：${n.correct}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().success)
                .width('100%')
              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: '再看解答',
                  variant: 'secondary',
                  onTap: (): void => { AskNav.openDetail('insight', n.insightId) }
                })
                  .layoutWeight(1)
                AppButton({
                  label: '移出错题',
                  variant: 'ghost',
                  onTap: (): void => {
                    void LearnStore.removeWrong(n.id).then(() => { this.reload() })
                    AskNav.bumpRefresh()
                    this.showToast('已移出')
                  }
                })
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .clip(true)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s3
          })
        }, (n: QuizWrongItem) => n.id)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  CardList() {
    if (this.cards.length === 0) {
      AppEmpty({
        title: '还没有知识卡片',
        description: '在解答详情里可生成卡片，方便回顾',
        actionLabel: '去问答',
        onAction: (): void => {
          AskNav.closeLearn()
          AskNav.switchTab(0)
        }
      })
        .layoutWeight(1)
    } else {
      List() {
        ForEach(this.cards, (n: KnowledgeCardItem) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(n.category)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
                .width('100%')
              Text(n.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(n.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Row() {
                AppButton({
                  label: '查看原解答',
                  variant: 'secondary',
                  onTap: (): void => { AskNav.openDetail('insight', n.insightId) }
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s3
          })
        }, (n: KnowledgeCardItem) => n.id)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }
}
