import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { InspirationCoverImage } from '../inspiration/InspirationCoverImage'
import { DetailShell } from './DetailShell'
import {
  InspirationItem,
  LinkedRef,
  LinkedRefList,
  UpdateTopicRequest
} from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct TopicDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onTopicChanged: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State linked: InspirationItem[] = []
  @State refs: LinkedRef[] = []
  @State pickerItems: InspirationItem[] = []
  @State pickerKind: string = 'inspiration'
  @State loading: boolean = true
  @State showPicker: boolean = false
  @State saving: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findTopic(this.itemId)
    if (this.item !== undefined) {
      this.refs = LinkedRefList.parse(this.item.linkedIdsJson)
      this.linked = await InspirationBizService.resolveLinkedItems(this.currentUsername, this.item.linkedIdsJson)
    } else {
      this.refs = []
      this.linked = []
    }
    this.loading = false
  }

  private async openPicker(kind: string): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    this.pickerKind = kind
    if (kind === 'inspiration') {
      this.pickerItems = await InspirationBizService.loadInspirations(this.currentUsername)
    } else if (kind === 'board') {
      this.pickerItems = await InspirationBizService.loadMoodBoards(this.currentUsername)
    } else {
      this.pickerItems = await InspirationBizService.loadCreativePlans(this.currentUsername)
    }
    this.showPicker = true
  }

  private async addLink(targetId: string): Promise<void> {
    if (this.item === undefined) {
      return
    }
    this.saving = true
    const req = new UpdateTopicRequest()
    req.title = this.item.title
    req.description = this.item.description.length > 0 ? this.item.description : this.item.summary
    req.coverKey = this.item.coverKey
    req.linkedIdsJson = LinkedRefList.add(this.item.linkedIdsJson, this.pickerKind, targetId)
    const updated = await InspirationBizService.updateTopic(this.item.id, req)
    this.saving = false
    this.showPicker = false
    if (updated !== undefined) {
      this.item = updated
      await this.loadItem()
      this.onTopicChanged()
      this.showToast('已加入专题合集')
    } else {
      this.showToast('添加失败，请稍后重试')
    }
  }

  private navigateLinkedRow(row: InspirationItem): void {
    let kind = 'inspiration'
    for (const ref of this.refs) {
      if (ref.id === row.id) {
        kind = ref.kind
        break
      }
    }
    if (kind === 'board') {
      InspirationDetailNav.navigateTo('board', row.id)
    } else if (kind === 'plan') {
      InspirationDetailNav.navigateTo('plan', row.id)
    } else {
      InspirationDetailNav.navigateTo('inspiration', row.id)
    }
  }

  private refKindLabel(id: string): string {
    for (const ref of this.refs) {
      if (ref.id === id) {
        return LinkedRefList.kindLabel(ref.kind)
      }
    }
    return '内容'
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.loading) {
        AppLoading({ label: '加载专题…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '专题不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '创意专题',
          onClose: (): void => { InspirationDetailNav.close() },
          body: () => { this.DetailBody() }
        })
      }

      if (this.showPicker) {
        this.PickerOverlay()
      }

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
        .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          InspirationCoverImage({
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_latest_inspiration',
            imageWidth: '100%',
            imageHeight: 160,
            useAspectRatio: false,
            cornerRadius: Theme.radius.xl,
            imageFit: ImageFit.Cover
          })
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.75)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
            .padding(Theme.space.s5)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '加灵感',
            variant: 'secondary',
            onTap: (): void => { void this.openPicker('inspiration') }
          }).layoutWeight(1)
          AppButton({
            label: '加画板',
            variant: 'secondary',
            onTap: (): void => { void this.openPicker('board') }
          }).layoutWeight(1)
          AppButton({
            label: '加计划',
            variant: 'secondary',
            onTap: (): void => { void this.openPicker('plan') }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(`合集内容（${this.linked.length}）`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.linked.length === 0) {
          AppEmpty({
            title: '专题还是空的',
            description: '把灵感、画板或计划加入这个专题，形成主题合集'
          })
        } else {
          ForEach(this.linked, (row: InspirationItem) => {
            Row({ space: Theme.space.s3 }) {
              Text(this.refKindLabel(row.id))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width(40)
              Column({ space: 4 }) {
                Text(InspirationItem.displayTitle(row))
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(row.summary.length > 0 ? row.summary : row.goal)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .onClick((): void => { this.navigateLinkedRow(row) })
          }, (row: InspirationItem) => row.id)
        }
      }
    }
  }

  @Builder
  PickerOverlay() {
    Column() {
      Row() {
        Text(`选择${LinkedRefList.kindLabel(this.pickerKind)}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text('关闭')
          .fontColor(Theme.colors().textSecondary)
          .onClick((): void => { this.showPicker = false })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.pickerItems.length === 0) {
            AppEmpty({ title: '暂无可添加内容', description: '先创建对应类型的内容' })
          } else {
            ForEach(this.pickerItems, (row: InspirationItem) => {
              Column({ space: Theme.space.s2 }) {
                Text(InspirationItem.displayTitle(row))
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  .maxLines(2)
                if (row.summary.length > 0 || row.goal.length > 0) {
                  Text(row.summary.length > 0 ? row.summary : row.goal)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                    .maxLines(2)
                }
                AppButton({
                  label: this.saving ? '…' : '添加',
                  disabled: this.saving,
                  onTap: (): void => { void this.addLink(row.id) }
                })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { void this.addLink(row.id) })
            }, (row: InspirationItem) => row.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(35)
  }
}
