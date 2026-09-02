import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { QuizItem, SpotItem, StudyWriteRequest } from '../../models/RoadModels'
import { AuthService } from '../../services/AuthService'
import { RoadBizService } from '../../services/RoadBizService'
import { RoadDetailNav } from '../../services/RoadDetailNav'
import { RoadMedia } from '../../services/RoadMedia'

@Component
export struct SpotDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onSpotIdChange') spotId: string = ''
  @Prop @Watch('onSpotIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: SpotItem | undefined = undefined
  @State quiz: QuizItem | undefined = undefined
  @State loading: boolean = true
  @State ageBand: number = 1
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onSpotIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await RoadBizService.findSpot(this.spotId)
    this.quiz = await RoadBizService.findQuizBySpot(this.spotId)
    this.loading = false
  }

  private knowledge(): string {
    if (this.item === undefined) {
      return ''
    }
    if (this.ageBand === 0) {
      return this.item.knowledgeAge3
    }
    if (this.ageBand === 2) {
      return this.item.knowledgeAge13
    }
    return this.item.knowledgeAge7
  }

  private async checkin(): Promise<void> {
    if (!AuthService.requireAuth('spot_checkin')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const body = new StudyWriteRequest()
    body.title = this.item.title
    body.spotId = this.item.id
    body.placeLabel = this.item.city
    const ok = await RoadBizService.createCheckin(body)
    this.toastText = ok ? '已记下这次打卡' : '打卡失败，请稍后重试'
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        AppLoading({ label: '打开百科' })
      } else if (this.item === undefined) {
        DetailShell({ title: '景点', onClose: (): void => { RoadDetailNav.close() } }) {
          AppEmpty({ title: '景点不存在', description: '请返回路线再试' })
        }
      } else {
        this.Body(this.item as SpotItem)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(20,61,40,0.92)')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body(item: SpotItem) {
    DetailShell({ title: item.title, contentKey: item.id, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(RoadMedia.resource(item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(88)
            .linearGradient({
              angle: 180,
              colors: [['rgba(20,61,40,0)', 0.0], ['rgba(20,61,40,0.78)', 1.0]]
            })
          Text(item.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 16, bottom: 16 })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(`${item.city} · 适龄 ${item.ageRange}`)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')

        Column() {
          AppCard() {
            Column({ space: 8 }) {
              Text('导语')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text(item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(item.body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text('分龄知识卡片')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .padding({ left: Theme.space.pageX })
          .width('100%')

        Row({ space: 8 }) {
          this.AgeChip('3–6 岁', 0)
          this.AgeChip('7–12 岁', 1)
          this.AgeChip('13–15 岁', 2)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')

        Text(this.knowledge())
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 12 }) {
          if (this.quiz !== undefined) {
            AppButton({
              label: '趣味问答',
              onTap: (): void => {
                RoadDetailNav.openQuiz(this.quiz !== undefined ? this.quiz.id : '')
              }
            })
          }
          AppButton({
            label: '景点打卡',
            variant: 'secondary',
            onTap: (): void => { void this.checkin() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
    }
  }

  @Builder
  AgeChip(label: string, band: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.ageBand === band ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .backgroundColor(this.ageBand === band ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.ageBand = band })
  }
}
