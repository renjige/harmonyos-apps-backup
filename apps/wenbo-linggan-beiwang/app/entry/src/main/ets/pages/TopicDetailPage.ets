import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import { TopicItem } from '../models/GrowthModels'
import { InspirationItem } from '../models/InspirationModels'
import { GrowthStore } from '../services/GrowthStore'
import { GrowthService } from '../services/GrowthService'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct TopicDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop @Watch('onTopicIdChange') topicId: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onTopicChanged: () => void = () => {}
  @State topic: TopicItem | undefined = undefined
  @State items: InspirationItem[] = []
  @State pool: InspirationItem[] = []
  @State showPicker: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onTopicIdChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const data = await GrowthStore.load(this.currentUsername)
    this.topic = GrowthService.findTopic(data, this.topicId)
    const all = await InspirationBizService.loadInspirations(this.currentUsername)
    this.pool = all
    const shown: InspirationItem[] = []
    if (this.topic !== undefined) {
      for (const id of this.topic.inspirationIds) {
        for (const it of all) {
          if (it.id === id) {
            shown.push(it)
          }
        }
      }
    }
    this.items = shown
  }

  private async addOne(id: string): Promise<void> {
    const data = await GrowthStore.load(this.currentUsername)
    const ok = GrowthService.addInspirationToTopic(data, this.topicId, id)
    if (ok) {
      await GrowthService.persist(this.currentUsername, data)
      this.showPicker = false
      this.showToast('已加入专题')
      this.onTopicChanged()
      await this.reload()
    } else {
      this.showToast('已在专题中')
    }
  }

  private async removeOne(id: string): Promise<void> {
    const data = await GrowthStore.load(this.currentUsername)
    GrowthService.removeInspirationFromTopic(data, this.topicId, id)
    await GrowthService.persist(this.currentUsername, data)
    this.showToast('已移出专题')
    this.onTopicChanged()
    await this.reload()
  }

  private async deleteTopic(): Promise<void> {
    const data = await GrowthStore.load(this.currentUsername)
    GrowthService.removeTopic(data, this.topicId)
    await GrowthService.persist(this.currentUsername, data)
    this.onTopicChanged()
    this.onClose()
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
          .onClick((): void => { this.onClose() })
          Text(this.topic !== undefined ? this.topic.title : '专题')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.topic !== undefined) {
          Text(`含 ${this.items.length} 条灵感`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        }

        if (this.topic === undefined) {
          AppEmpty({ title: '专题不存在', description: '可能已被删除' })
        } else if (this.items.length === 0) {
          Column() {
            AppEmpty({
              title: '专题还是空的',
              description: '从你已有的灵感里挑几条放进来，专题才会越用越厚',
              actionLabel: '加入灵感',
              onAction: (): void => { this.showPicker = true }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              if (this.topic !== undefined && this.topic.summary.length > 0) {
                Text(this.topic.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              ForEach(this.items, (item: InspirationItem) => {
                Column({ space: Theme.space.s2 }) {
                  InspirationListCard({
                    item: item,
                    onTap: (): void => { InspirationDetailNav.openInspiration(item.id) }
                  })
                  Text('移出专题')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .onClick((): void => { void this.removeOne(item.id) })
                }
                .width('100%')
                .alignItems(HorizontalAlign.End)
              }, (item: InspirationItem) => item.id)
              Column() {
                AppButton({
                  label: '加入更多灵感',
                  variant: 'secondary',
                  onTap: (): void => { this.showPicker = true }
                })
              }
              .width('100%')
              .onClick((): void => { this.showPicker = true })
              Column() {
                AppButton({
                  label: '删除这个专题',
                  variant: 'danger',
                  onTap: (): void => { this.confirmDelete = true }
                })
              }
              .width('100%')
              .onClick((): void => { this.confirmDelete = true })
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
      }
      .width('100%')
      .height('100%')

      if (this.showPicker) {
        Column() {
          Row() {
            Text('选择要加入的灵感')
              .fontSize(Theme.type.title3)
              .layoutWeight(1)
            Text('关闭')
              .onClick((): void => { this.showPicker = false })
          }
          .padding(Theme.space.pageX)
          .width('100%')
          if (this.pool.length === 0) {
            AppEmpty({ title: '还没有灵感可加入', description: '先去记录 Tab 写一条' })
          } else {
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.pool, (item: InspirationItem) => {
                  InspirationListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { void this.addOne(item.id) }
                  })
                }, (item: InspirationItem) => `pick_${item.id}`)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('删除专题后不会删除灵感本身，只去掉这个主题夹。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.confirmDelete = false }
              })
            }
            .layoutWeight(1)
            .onClick((): void => { this.confirmDelete = false })
            Column() {
              AppButton({
                label: '确认删除',
                variant: 'danger',
                onTap: (): void => { void this.deleteTopic() }
              })
            }
            .layoutWeight(1)
            .onClick((): void => { void this.deleteTopic() })
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(40)
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
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
