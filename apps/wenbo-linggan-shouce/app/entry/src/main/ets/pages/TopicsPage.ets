import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateTopicRequest, InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct TopicsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State topics: InspirationItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDesc: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.topics = await InspirationBizService.loadTopics(this.currentUsername)
    } else {
      this.topics = []
    }
    this.loading = false
  }

  private async submitTopic(): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      return
    }
    this.submitting = true
    const req = new CreateTopicRequest()
    req.title = this.formTitle.trim()
    req.description = this.formDesc.trim()
    req.coverKey = 'hero_latest_inspiration'
    req.userId = this.currentUsername
    const created = await InspirationBizService.createTopic(req)
    this.submitting = false
    if (created !== undefined) {
      this.showForm = false
      this.formTitle = ''
      this.formDesc = ''
      await this.reload()
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('创意专题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => {
          if (!AuthService.requireAuth('create_inspiration')) {
            this.onRequireAuth()
            return
          }
          this.showForm = true
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '加载专题…' }).layoutWeight(1)
      } else if (this.topics.length === 0) {
        AppEmpty({
          title: '还没有专题',
          description: '把同一主题的灵感、画板与计划归拢到一个专题里',
          actionLabel: '创建专题',
          onAction: (): void => {
            if (AuthService.requireAuth('create_inspiration')) {
              this.showForm = true
            } else {
              this.onRequireAuth()
            }
          }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.topics, (item: InspirationItem) => {
              Column({ space: 6 }) {
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(item.description.length > 0 ? item.description : item.summary)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .maxLines(3)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { InspirationDetailNav.openTopic(item.id) })
            }, (item: InspirationItem) => item.id)
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

      if (this.showForm) {
        Column({ space: Theme.space.s4 }) {
          Text('新建创意专题')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.formTitle, placeholder: '专题名称' })
            .width('100%')
            .height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
          TextArea({ text: this.formDesc, placeholder: '专题说明（可选）' })
            .width('100%')
            .height(100)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formDesc = v })
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.showForm = false }
            }).layoutWeight(1)
            AppButton({
              label: this.submitting ? '保存中…' : '创建',
              disabled: this.submitting,
              onTap: (): void => { void this.submitTopic() }
            }).layoutWeight(1)
          }
          .width('100%')
        }
        .width('92%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .position({ x: '4%', y: '30%' })
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
