import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { ContentService } from '../services/ContentService'
import { UserPrefsService } from '../services/UserPrefsService'
import { ContactUtil } from '../utils/ContactUtil'
import { JobItem } from '../models/ZhukeModels'
import { common } from '@kit.AbilityKit'

@Component
export struct JobDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop jobId: string = ''
  @State item: JobItem = new JobItem()
  onBack: () => void = () => {}

  aboutToAppear(): void {
    const found = ContentService.jobById(this.jobId)
    if (found !== null) {
      this.item = found
      UserPrefsService.addHistory('job', found.id, found.title)
    }
  }

  private dialPhone(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    ContactUtil.dial(ctx, this.item.contactPhone)
  }

  build() {
    Column() {
      AppNavBar({ title: '岗位详情', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            Text(this.item.salary)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .fontWeight(FontWeight.Medium)
            Text(`${this.item.location} · ${this.item.experience} · ${this.item.education}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')

          AppCard({ title: '岗位职责' }) {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.item.responsibilities, (line: string, index: number) => {
                Text(`${index + 1}. ${line}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }, (line: string, index: number) => `${index}`)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          AppCard({ title: '任职要求' }) {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.item.requirements, (line: string, index: number) => {
                Text(`${index + 1}. ${line}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }, (line: string, index: number) => `${index}`)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          AppCard({ title: '联系方式', variant: 'glass' }) {
            Column({ space: Theme.space.s2 }) {
              Text(`电话：${this.item.contactPhone}`)
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => this.dialPhone())
              Text(`邮箱：${this.item.contactEmail}`)
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => {
                  const ctx = getContext(this) as common.UIAbilityContext
                  ContactUtil.sendEmail(ctx, this.item.contactEmail)
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          AppButton({
            label: '电话咨询',
            onTap: () => this.dialPhone()
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
