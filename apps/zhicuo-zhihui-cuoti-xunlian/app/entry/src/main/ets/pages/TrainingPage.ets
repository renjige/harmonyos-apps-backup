import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AnalyzeEngine, CatalogOptions } from '../services/AnalyzeEngine'
import { TrainingEngine, TrainingSession } from '../services/TrainingEngine'
import { WrongBizService } from '../services/WrongBizService'
import { AuthService } from '../services/AuthService'
import { SubjectOption, WrongEntry, WrongEntryWrite } from '../models/WrongModels'

@Component
export struct TrainingPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State entries: WrongEntry[] = []
  @State mode: string = 'random'
  @State subjectCode: string = 'all'
  @State tagQuery: string = ''
  @State session: TrainingSession = new TrainingSession()
  @State showAnswer: boolean = false
  @State started: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.entries = await WrongBizService.loadEntries()
  }

  private begin(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    const s = new TrainingSession()
    s.mode = this.mode
    s.subjectCode = this.subjectCode
    s.knowledgeTag = this.tagQuery.trim()
    s.queue = TrainingEngine.buildQueue(this.entries, this.mode, this.subjectCode, s.knowledgeTag)
    s.index = 0
    this.session = s
    this.showAnswer = false
    this.started = s.queue.length > 0
  }

  private current(): WrongEntry | null {
    return TrainingEngine.current(this.session)
  }

  private async markStatus(mastered: boolean): Promise<void> {
    const cur = this.current()
    if (cur === null) {
      return
    }
    const write = new WrongEntryWrite()
    write.stem = cur.stem
    write.correctAnswer = cur.correctAnswer
    write.wrongAnswer = cur.wrongAnswer
    write.subjectCode = cur.subjectCode
    write.knowledgeTag = cur.knowledgeTag
    write.causeCode = cur.causeCode
    write.photoUri = cur.photoUri
    write.remark = cur.remark
    write.status = mastered ? 'mastered' : 'pending'
    await WrongBizService.updateEntry(cur.id, write)
    TrainingEngine.bumpTodayDone()
    this.session.index += 1
    this.showAnswer = false
    await this.reload()
    if (TrainingEngine.current(this.session) === null) {
      this.started = false
    }
  }

  build() {
    Column() {
      Text('智慧训练')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY
        })

      if (!this.started) {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Row({ space: Theme.space.s2 }) {
              this.modeChip('随机训练', 'random')
              this.modeChip('专项训练', 'special')
            }
            .width('100%')

            if (this.mode === 'special') {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  this.subjectChip('全部', 'all')
                  ForEach(CatalogOptions.subjects(), (s: SubjectOption) => {
                    this.subjectChip(s.label, s.code)
                  }, (s: SubjectOption) => s.code)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')

              TextInput({ text: this.tagQuery, placeholder: '可选：按知识点关键词筛选' })
                .onChange((v: string) => { this.tagQuery = v })
                .height(44)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .width('100%')
            }

            AppCard({ title: '训练说明' }) {
              Text(this.mode === 'random' ?
                '从待复习错题中随机抽题，先看题干思考，再显示答案与解析，最后标记掌握程度。' :
                '按所选学科与知识点集中练习，适合考前专项突破。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            AppButton({
              label: '开始训练',
              onTap: () => this.begin()
            })

            if (TrainingEngine.filterPending(this.entries).length === 0) {
              AppEmpty({
                title: '暂无待复习错题',
                description: '先在错题本录入并保存错题，或把已掌握改回待复习后再来训练。'
              })
            }
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
      } else {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Text(`进度 ${this.session.index + 1}/${this.session.queue.length}`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
            Progress({
              value: this.session.index,
              total: this.session.queue.length,
              type: ProgressType.Linear
            })
              .layoutWeight(2)
              .color(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Scroll() {
            Column({ space: Theme.space.s5 }) {
              if (this.current() !== null) {
                AppCard({ title: CatalogOptions.subjectLabel(this.current()!.subjectCode) }) {
                  Text(this.current()!.stem)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  if (this.current()!.knowledgeTag.length > 0) {
                    Text(`知识点：${this.current()!.knowledgeTag}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .margin({ top: Theme.space.s3 })
                      .width('100%')
                  }
                }

                if (!this.showAnswer) {
                  AppButton({
                    label: '显示答案',
                    variant: 'secondary',
                    onTap: () => { this.showAnswer = true }
                  })
                } else {
                  AppCard({ title: '正确答案' }) {
                    Text(this.current()!.correctAnswer)
                      .fontSize(Theme.type.body)
                      .fontColor(Theme.colors().success)
                      .width('100%')
                  }
                  if (this.current()!.wrongAnswer.length > 0) {
                    AppCard({ title: '我的答案' }) {
                      Text(this.current()!.wrongAnswer)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .width('100%')
                    }
                  }
                  if (this.current()!.remark.length > 0) {
                    AppCard({ title: '解析' }) {
                      Text(this.current()!.remark)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .width('100%')
                    }
                  }
                  Row({ space: Theme.space.s3 }) {
                    AppButton({
                      label: '已掌握',
                      onTap: () => { void this.markStatus(true) }
                    }).layoutWeight(1)
                    AppButton({
                      label: '需复习',
                      variant: 'secondary',
                      onTap: () => { void this.markStatus(false) }
                    }).layoutWeight(1)
                  }
                  .width('100%')
                }
              } else {
                AppEmpty({
                  title: '本轮训练完成',
                  description: `今日已完成 ${TrainingEngine.readTodayDone()} 题训练。`,
                  actionLabel: '再来一轮',
                  onAction: () => this.begin()
                })
              }
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
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  modeChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.mode === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(this.mode === value ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => { this.mode = value })
  }

  @Builder
  subjectChip(label: string, code: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.subjectCode === code ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.subjectCode === code ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.subjectCode = code })
  }
}
