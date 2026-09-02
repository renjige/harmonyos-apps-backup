import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ArticleItem } from '../../models/PavilionModels'
import { QuizQuestion, QuizService } from '../../services/QuizService'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { ExploreStore } from '../../services/ExploreStore'
import { JournalStore } from '../../services/JournalStore'

@Component
export struct QuizPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop articleId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State questions: QuizQuestion[] = []
  @State index: number = 0
  @State picked: number = -1
  @State score: number = 0
  @State finished: boolean = false
  @State loaded: boolean = false
  @State title: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.finished = false
    this.index = 0
    this.picked = -1
    this.score = 0
    let article: ArticleItem | undefined = undefined
    if (this.articleId.length > 0 && this.articleId !== 'today') {
      article = await PavilionBizService.findArticle(this.articleId)
    }
    if (article === undefined) {
      const list = await PavilionBizService.loadArticles()
      if (list.length > 0) {
        article = list[0]
      }
    }
    if (article === undefined) {
      this.loaded = false
      return
    }
    this.title = article.title
    this.questions = QuizService.build(article)
    this.loaded = true
  }

  private current(): QuizQuestion {
    if (this.index < this.questions.length) {
      return this.questions[this.index]
    }
    return new QuizQuestion()
  }

  private pick(n: number): void {
    if (this.picked >= 0 || this.finished) {
      return
    }
    this.picked = n
    if (n === this.current().correct) {
      this.score = this.score + 1
    }
  }

  private async next(): Promise<void> {
    if (this.picked < 0) {
      return
    }
    if (this.index + 1 >= this.questions.length) {
      this.finished = true
      await ExploreStore.recordQuiz(this.score, this.questions.length)
      await JournalStore.appendQuiz(`${this.title} ${this.score}/${this.questions.length}`)
      return
    }
    this.index = this.index + 1
    this.picked = -1
  }

  build() {
    DetailShell({
      title: '趣味问答',
      onClose: (): void => { PavilionDetailNav.close() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '暂时没有可出题的趣知', description: '请先打开首页加载栏目。' })
      } else if (this.finished) {
        Column({ space: Theme.space.s4 }) {
          Text(`答对 ${this.score} / ${this.questions.length} 题`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .width('100%')
          Text(`围绕「${this.title}」巩固刚刚读过的内容。记录已写入成长档案。`)
            .fontSize(14)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .width('100%')
          AppButton({
            label: '再答一组',
            onTap: (): void => { void this.reload() }
          })
          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: (): void => { PavilionDetailNav.close() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        .width('100%')
      } else {
        Column({ space: Theme.space.s4 }) {
          Text(`第 ${this.index + 1} / ${this.questions.length} 题`)
            .fontSize(13)
            .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
            .width('100%')
          Text(this.current().prompt)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .width('100%')
          this.OptionRow(0, this.current().optionA)
          this.OptionRow(1, this.current().optionB)
          this.OptionRow(2, this.current().optionC)
          if (this.picked >= 0) {
            Text(this.current().explain)
              .fontSize(13)
              .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
              .width('100%')
            AppButton({
              label: this.index + 1 >= this.questions.length ? '查看结果' : '下一题',
              onTap: (): void => { void this.next() }
            })
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
        .width('100%')
      }
    }
  }

  @Builder
  OptionRow(n: number, label: string) {
    Text(label)
      .fontSize(15)
      .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
      .padding(14)
      .width('100%')
      .backgroundColor(this.picked === n ? Theme.brandBox(this.themeEpoch, this.darkModeOn) : Theme.cardBg(this.themeEpoch, this.darkModeOn))
      .borderRadius(12)
      .onClick((): void => { this.pick(n) })
  }
}
