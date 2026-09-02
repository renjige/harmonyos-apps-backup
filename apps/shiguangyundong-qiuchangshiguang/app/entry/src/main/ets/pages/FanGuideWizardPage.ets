import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppTextField, AppTextAreaField } from '../components/design-system/AppTextField'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

/** 赛后全套复盘向导：一次生成观赛记录 + 精彩瞬间 + 复盘笔记 */
@Component
export struct FanGuideWizardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: number = 0
  @State matchTitle: string = ''
  @State dateLabel: string = DateFormatUtil.formatDate(new Date())
  @State matchBody: string = ''
  @State highlightTitle: string = ''
  @State highlightBody: string = ''
  @State reviewTitle: string = ''
  @State reviewBody: string = ''
  @State saving: boolean = false
  @State toastText: string = ''

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2400)
  }

  private async submit(): Promise<void> {
    if (this.matchTitle.trim().length === 0) {
      this.showToast('请填写比赛名称')
      return
    }
    if (this.saving) {
      return
    }
    this.saving = true
    await FanMemoryStore.savePostMatchBundle(
      this.matchTitle.trim(),
      this.dateLabel,
      this.matchBody.trim(),
      this.highlightTitle.trim(),
      this.highlightBody.trim(),
      this.reviewTitle.trim(),
      this.reviewBody.trim()
    )
    this.saving = false
    this.showToast('已生成 3 条关联记忆')
    setTimeout((): void => {
      CourtDetailNav.closeFanWizard()
      CourtDetailNav.openFanTimeline()
    }, 800)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .rotate({ angle: 180 })
          .onClick((): void => {
            CourtDetailNav.closeFanWizard()
          })
          Column({ space: 2 }) {
            Text('赛后全套复盘')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text(`步骤 ${this.step + 1} / 3`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.step === 0) {
              Text('① 观赛记录')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              AppTextField({
                text: this.matchTitle,
                placeholder: '比赛名称，如：欧冠半决赛',
                onChange: (v: string): void => {
                  this.matchTitle = v
                }
              })
              AppDatePickerField({
                label: '观赛日期',
                value: this.dateLabel,
                onChange: (v: string): void => {
                  this.dateLabel = v
                }
              })
              AppTextAreaField({
                text: this.matchBody,
                placeholder: '比分、现场氛围、和谁一起看…',
                onChange: (v: string): void => {
                  this.matchBody = v
                }
              })
            } else if (this.step === 1) {
              Text('② 精彩瞬间')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              AppTextField({
                text: this.highlightTitle,
                placeholder: '如：补时绝杀 / 关键扑救',
                onChange: (v: string): void => {
                  this.highlightTitle = v
                }
              })
              AppTextAreaField({
                text: this.highlightBody,
                placeholder: '用文字还原那个瞬间',
                onChange: (v: string): void => {
                  this.highlightBody = v
                }
              })
            } else {
              Text('③ 复盘笔记')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              AppTextField({
                text: this.reviewTitle,
                placeholder: '复盘标题（可留空自动生成）',
                onChange: (v: string): void => {
                  this.reviewTitle = v
                }
              })
              AppTextAreaField({
                text: this.reviewBody,
                placeholder: '战术观察、球员表现、个人评价',
                onChange: (v: string): void => {
                  this.reviewBody = v
                }
              })
            }

            Row({ space: Theme.space.s3 }) {
              if (this.step > 0) {
                AppButton({
                  label: '上一步',
                  variant: 'secondary',
                  onTap: (): void => {
                    this.step = this.step - 1
                  }
                }).layoutWeight(1)
              }
              AppButton({
                label: this.step < 2 ? '下一步' : (this.saving ? '保存中…' : '生成 3 条记忆'),
                disabled: this.saving,
                onTap: (): void => {
                  if (this.step < 2) {
                    if (this.step === 0 && this.matchTitle.trim().length === 0) {
                      this.showToast('请先填写比赛名称')
                      return
                    }
                    this.step = this.step + 1
                    return
                  }
                  void this.submit()
                }
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

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
