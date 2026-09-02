import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ProcurementTopic, ShoppingList } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { ShoppingMedia } from '../../services/ShoppingMedia'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct TopicDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop topicId: string = ''
  @State topic: ProcurementTopic = new ProcurementTopic()
  @State lists: ShoppingList[] = []
  @State allLists: ShoppingList[] = []
  @State title: string = ''
  onClose: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onDeleted: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const found = GrowthService.findTopic(this.topicId)
    if (found === undefined) {
      return
    }
    this.topic = found
    this.title = found.title
    this.allLists = await ShoppingService.lists()
    const linked: ShoppingList[] = []
    for (const row of this.allLists) {
      for (const id of found.listIds) {
        if (row.id === id) {
          linked.push(row)
          break
        }
      }
    }
    this.lists = linked
  }

  private isLinked(id: string): boolean {
    for (const row of this.topic.listIds) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('主题详情')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 14 }) {
          Image(ShoppingMedia.cover(this.topic.coverKey))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          TextInput({ text: this.title, placeholder: '主题名称' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.title = v })

          Text('已关联清单')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.lists.length === 0) {
            AppEmpty({ title: '还没有关联清单', description: '从下方选择清单加入本主题' })
          } else {
            ForEach(this.lists, (row: ShoppingList) => {
              Row() {
                Text(row.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .layoutWeight(1)
                  .maxLines(1)
                Text('打开')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .margin({ right: 12 })
                  .onClick((): void => { this.onOpenList(row.id) })
                Text('移除')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .onClick((): void => {
                    void GrowthService.unlinkListFromTopic(this.topicId, row.id).then(() => {
                      void this.reload()
                    })
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (row: ShoppingList) => row.id)
          }

          Text('添加清单到主题')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          ForEach(this.allLists, (row: ShoppingList) => {
            if (this.isLinked(row.id)) {
              Column().width('100%').height(0)
            } else {
              Row() {
                Text(row.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .layoutWeight(1)
                  .maxLines(1)
                Text('+ 加入')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => {
                void GrowthService.linkListToTopic(this.topicId, row.id).then(() => {
                  void this.reload()
                })
              })
            }
          }, (row: ShoppingList) => `pick_${row.id}`)

          AppButton({
            label: '保存主题名称',
            onTap: (): void => {
              this.topic.title = this.title.trim().length > 0 ? this.title.trim() : this.topic.title
              void GrowthService.saveTopic(this.topic).then(() => { this.onClose() })
            }
          })
          AppButton({
            label: '删除主题',
            variant: 'danger',
            onTap: (): void => {
              void GrowthService.deleteTopic(this.topicId).then(() => {
                this.onDeleted()
                this.onClose()
              })
            }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
