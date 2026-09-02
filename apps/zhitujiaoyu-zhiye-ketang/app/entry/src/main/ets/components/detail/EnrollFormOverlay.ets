import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CourseItem } from '../../models/CareerModels'
import { CareerBizService } from '../../services/CareerBizService'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { AuthService } from '../../services/AuthService'
import { EnrollmentCreateBody } from '../../models/CareerModels'

@Component
export struct EnrollFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop courseId: string = ''
  @State course: CourseItem = new CourseItem()
  @State name: string = ''
  @State phone: string = ''
  @State remark: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @State errorText: string = ''

  aboutToAppear(): void {
    void this.loadCourse()
    const u = AuthService.currentUsername()
    if (u !== '未登录' && this.name.length === 0) {
      this.name = u
    }
  }

  private async loadCourse(): Promise<void> {
    const row = await CareerBizService.loadCourseById(this.courseId)
    if (row !== undefined) {
      this.course = row
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private close(): void {
    CareerDetailNav.close()
  }

  private async submit(): Promise<void> {
    this.errorText = ''
    if (this.name.length === 0) {
      this.errorText = '请填写姓名'
      return
    }
    if (this.phone.length !== 11) {
      this.errorText = '请填写 11 位手机号'
      return
    }
    this.submitting = true
    const body = new EnrollmentCreateBody()
    body.courseId = this.courseId
    body.name = this.name
    body.phone = this.phone
    body.remark = this.remark
    body.username = AuthService.currentUsername()
    if (body.username === '未登录') {
      body.username = ''
    }
    const row = await CareerBizService.submitEnrollment(body)
    this.submitting = false
    if (row !== undefined) {
      CareerDetailNav.bump()
      this.showToast('报名已提交，工作人员将联系确认')
      setTimeout(() => {
        CareerDetailNav.close()
      }, 1200)
      return
    }
    this.errorText = '提交失败，请稍后重试'
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => this.close())
          Text('课程报名')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX - 8,
          right: Theme.space.pageX,
          top: Theme.space.s2
        })

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s2
            })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.course.title)
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`${this.course.category} · ${this.course.duration}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('姓名')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.name, placeholder: '请输入姓名' })
                .onChange((v: string) => { this.name = v })
                .width('100%')
                .height(44)
                .borderRadius(Theme.radius.sm)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('手机号')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.phone, placeholder: '11 位手机号' })
                .type(InputType.PhoneNumber)
                .onChange((v: string) => { this.phone = v })
                .width('100%')
                .height(44)
                .borderRadius(Theme.radius.sm)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('学习诉求（选填）')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.remark, placeholder: '如：希望周末班、转岗准备等' })
                .onChange((v: string) => { this.remark = v })
                .width('100%')
                .height(80)
                .borderRadius(Theme.radius.sm)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            }
            .width('100%')

            AppButton({
              label: this.submitting ? '提交中…' : '提交报名',
              disabled: this.submitting,
              onTap: (): void => { void this.submit() }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => this.close()
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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
