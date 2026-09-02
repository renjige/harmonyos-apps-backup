import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { LearningHubService } from '../services/LearningHubService'
import { UserTopic } from '../models/LearningHubModels'

@Component
export struct TopicsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: UserTopic[] = []
  @State titleDraft: string = ''
  @State descDraft: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.items = LearningHubService.topics()
  }

  private async createTopic(): Promise<void> {
    const title = this.titleDraft.trim()
    if (title.length === 0) {
      this.toastText = '请填写专题名称'
      setTimeout((): void => { this.toastText = '' }, 1800)
      return
    }
    await LearningHubService.createTopic(title, this.descDraft)
    this.titleDraft = ''
    this.descDraft = ''
    this.items = LearningHubService.topics()
    this.toastText = '专题已创建'
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44).height(44).justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('专题夹')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Column({ space: Theme.space.s2 }) {
          TextInput({ text: this.titleDraft, placeholder: '专题名称，如「厨房安全」' })
            .onChange((v: string): void => { this.titleDraft = v })
          TextInput({ text: this.descDraft, placeholder: '简介（选填）' })
            .onChange((v: string): void => { this.descDraft = v })
          AppButton({ label: '新建专题', onTap: (): void => { void this.createTopic() } })
        }
        .padding(Theme.space.s4)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有专题',
            description: '把相关常识归到同一专题，方便复习。',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          List({ space: Theme.space.s2 }) {
            ForEach(this.items, (row: UserTopic) => {
              ListItem() {
                Column({ space: 6 }) {
                  Text(row.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  if (row.desc.length > 0) {
                    Text(row.desc)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                  }
                  Text(`已收录 ${row.factIds.length} 条常识`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                }
                .padding(Theme.space.s4)
                .width('100%')
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.card)
              }
            }, (row: UserTopic) => row.id)
          }
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s8 })
        }
      }
      .width('100%').height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%').height('100%').zIndex(18)
  }
}
