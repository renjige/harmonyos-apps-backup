import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { PuzzleItem } from '../models/PuzzleModels'
import { QuizNav } from '../services/QuizNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct CustomPuzzleOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: PuzzleItem[] = []
  @State editing: boolean = false
  @State title: string = ''
  @State question: string = ''
  @State optionA: string = ''
  @State optionB: string = ''
  @State optionC: string = ''
  @State optionD: string = ''
  @State answerIndex: number = 0
  @State explanation: string = ''
  @State ageBand: string = 'age68'
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ProgressStore.customPuzzles()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private ageLabel(): string {
    if (this.ageBand === 'age35') {
      return '3-5岁启蒙'
    }
    if (this.ageBand === 'age912') {
      return '9-12岁逻辑'
    }
    return '6-8岁思维'
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 || this.question.trim().length === 0) {
      this.showToast('请填写标题和题目')
      return
    }
    if (this.optionA.trim().length === 0 || this.optionB.trim().length === 0) {
      this.showToast('至少填写 A、B 两个选项')
      return
    }
    const p = new PuzzleItem()
    p.id = `home_${Date.now()}`
    p.title = this.title.trim()
    p.question = this.question.trim()
    p.optionA = this.optionA.trim()
    p.optionB = this.optionB.trim()
    p.optionC = this.optionC.trim().length > 0 ? this.optionC.trim() : '以上都不是'
    p.optionD = this.optionD.trim().length > 0 ? this.optionD.trim() : '再想想'
    p.answerIndex = this.answerIndex
    p.explanation = this.explanation.trim().length > 0 ? this.explanation.trim() : '这是家庭专属谜题。'
    p.hint = '和孩子一起读题，慢慢选。'
    p.summary = '家庭专属谜题'
    p.knowledge = p.explanation
    p.category = 'riddle'
    p.categoryLabel = '家庭谜题'
    p.difficulty = '轻松'
    p.coverKey = 'cat_riddle'
    p.ageBand = this.ageBand
    p.ageLabel = this.ageLabel()
    await ProgressStore.saveCustom(p)
    this.editing = false
    this.title = ''
    this.question = ''
    this.optionA = ''
    this.optionB = ''
    this.optionC = ''
    this.optionD = ''
    this.explanation = ''
    this.reload()
    this.showToast('已保存到家庭谜题库')
  }

  private async remove(id: string): Promise<void> {
    await ProgressStore.removeCustom(id)
    this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('返回')
            .fontSize(15)
            .fontColor(Theme.colors().brandPrimary)
            .onClick(() => QuizNav.close())
          Blank()
          Text('家庭谜题')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
        }
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })
        .width('100%')

        if (this.editing) {
          this.Editor()
        } else {
          this.ListPane()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(30,42,58,0.88)')
          .borderRadius(20)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ListPane() {
    Column({ space: 12 }) {
      Text('家长可以出题，孩子来答。题目只保存在当前账号。')
        .fontSize(14)
        .lineHeight(22)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: '创建一题',
        onTap: () => { this.editing = true }
      })
      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.items, (p: PuzzleItem) => {
            Row() {
              Column({ space: 4 }) {
                Text(p.title)
                  .fontSize(16)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(p.ageLabel)
                  .fontSize(12)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text('删除')
                .fontSize(13)
                .fontColor(Theme.colors().danger)
                .onClick(() => { void this.remove(p.id) })
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(18)
            .onClick(() => QuizNav.openQuiz([p.id], 0))
          }, (p: PuzzleItem) => p.id)
        }
      }
      .layoutWeight(1)
    }
    .padding({ left: 20, right: 20, bottom: 24 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  Editor() {
    Scroll() {
      Column({ space: 10 }) {
        TextInput({ text: this.title, placeholder: '标题，例如：冰箱里的秘密' })
          .height(44)
          .onChange((v: string) => { this.title = v })
        TextInput({ text: this.question, placeholder: '题目' })
          .height(44)
          .onChange((v: string) => { this.question = v })
        TextInput({ text: this.optionA, placeholder: '选项 A（正确答案可选下面点选）' })
          .height(44)
          .onChange((v: string) => { this.optionA = v })
        TextInput({ text: this.optionB, placeholder: '选项 B' })
          .height(44)
          .onChange((v: string) => { this.optionB = v })
        TextInput({ text: this.optionC, placeholder: '选项 C（可空）' })
          .height(44)
          .onChange((v: string) => { this.optionC = v })
        TextInput({ text: this.optionD, placeholder: '选项 D（可空）' })
          .height(44)
          .onChange((v: string) => { this.optionD = v })
        Text('正确答案')
          .fontSize(14)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 8 }) {
          this.AnsChip(0, 'A')
          this.AnsChip(1, 'B')
          this.AnsChip(2, 'C')
          this.AnsChip(3, 'D')
        }
        .width('100%')
        Text('适合年龄')
          .fontSize(14)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 8 }) {
          this.AgeChip('age35', '3-5岁')
          this.AgeChip('age68', '6-8岁')
          this.AgeChip('age912', '9-12岁')
        }
        .width('100%')
        TextInput({ text: this.explanation, placeholder: '解析 / 小知识（可空）' })
          .height(44)
          .onChange((v: string) => { this.explanation = v })
        AppButton({
          label: '保存到家庭谜题库',
          onTap: (): void => { void this.save() }
        })
        AppButton({
          label: '取消',
          variant: 'secondary',
          onTap: () => { this.editing = false }
        })
      }
      .padding({ left: 20, right: 20, bottom: 28 })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  AnsChip(i: number, label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.answerIndex === i ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.answerIndex === i ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.answerIndex = i })
  }

  @Builder
  AgeChip(id: string, label: string) {
    Text(label)
      .fontSize(13)
      .fontColor(this.ageBand === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.ageBand === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.ageBand = id })
  }
}
